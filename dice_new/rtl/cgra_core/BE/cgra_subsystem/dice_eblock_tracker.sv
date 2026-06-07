// =============================================================================
// dice_eblock_tracker — single-eblock-in-flight backbone (extracted from
// dice_core, adapted from Mini_Dice dice_backend.sv glue).
//
// Owns the core's backend control state:
//   * the latched in-flight e-block (fdr_active_q) + its valid,
//   * the FDR accept/ready handshake (single-eblock-in-flight model),
//   * the CGRA pipeline occupancy counter (for drain detection),
//   * the exec-retire pulse for no-mem-op e-blocks,
//   * the prog-pending state + single-cycle program pulse (prog_v),
//   * the CTA-boundary scoreboard-clear detect.
//
// Almost every other backend module consumes fdr_active_q / fdr_active (the comb
// select) produced here. prog_pending lives here (set on accept, cleared on the
// program pulse) because it shares the same accept/exec FSM branch as fdr_active.
// =============================================================================
module dice_eblock_tracker
  import dice_pkg::*;
  import dice_frontend_pkg::*;
(
    input  logic clk_i,
    input  logic rst_i,

    // ---- FDR payload (flattened fdr_if at dice_core) ----
    input  logic fdr_valid_i,
    input  fdr_t fdr_data_i,
    output logic fdr_ready_o,        // -> fdr_if.ready
    output logic fdr_accept_o,       // accept handshake (fans out widely)

    // ---- backend status feeding the accept/retire conditions ----
    input  logic dispatch_busy_i,
    input  logic dispatcher_done_i,
    input  logic prog_busy_i,        // from dice_cgra_prog
    input  logic prog_ready_i,       // from dice_cgra_prog
    input  logic cgra_v_i,           // CGRA result valid (from dice_cgra_rf)
    input  logic [3:0] rd_tid_valid_i, // launch-this-cycle lanes (pipeline inc)

    // ---- in-flight e-block (consumed across the backend) ----
    output fdr_t fdr_active_o,       // comb: accept ? incoming : held
    output fdr_t fdr_active_q_o,     // registered in-flight e-block
    output logic fdr_active_valid_o,

    // ---- exec retire (no-mem-op e-block) -> dice_brt ----
    output logic                            exec_pop_o,
    output logic [DICE_EBLOCK_ID_WIDTH-1:0] exec_pop_e_block_id_o,

    // ---- CGRA programming handshake -> dice_cgra_prog ----
    output logic prog_v_o,                  // single-cycle program pulse
    output logic prog_pending_o,
    output logic prog_pending_buffer_o,

    // ---- CTA-boundary scoreboard clear -> dispatcher ----
    output logic dispatch_clear_scoreboard_o
);

  // CGRA pipeline occupancy tracking (for fdr_ready backpressure / retirement).
  localparam int CgraPipeCountWidth = $clog2(DICE_NUM_MAX_THREADS_PER_CORE + 1) + 1;

  fdr_t                          fdr_active_q;
  logic                          fdr_active_valid_q;
  logic                          exec_pop_sent_q;
  logic                          exec_dispatch_done_q;
  logic                          prog_pending_q;
  logic                          prog_pending_buffer_q;
  logic [CgraPipeCountWidth-1:0] cgra_pipeline_count_q;
  logic [CgraPipeCountWidth-1:0] cgra_pipeline_inc_li;
  logic [CgraPipeCountWidth-1:0] cgra_pipeline_dec_li;
  logic                          cgra_pipeline_empty_lo;
  logic                          fdr_accept_li;
  logic                          prog_handshake_li;
  logic                          prog_handshake_q;
  logic                          prog_v_li;
  logic                          exec_pop_lo;

  // ---- comb ----
  assign fdr_active_o = fdr_accept_li ? fdr_data_i : fdr_active_q;

  assign cgra_pipeline_inc_li   = CgraPipeCountWidth'($countones(rd_tid_valid_i));
  assign cgra_pipeline_dec_li   = CgraPipeCountWidth'(cgra_v_i && !cgra_pipeline_empty_lo);
  assign cgra_pipeline_empty_lo = (cgra_pipeline_count_q == '0);

  // fdr_ready: accept a new e-block only when dispatcher idle, not programming,
  // and the CGRA pipeline has fully drained (single-eblock-in-flight model).
  assign fdr_ready_o   = ~dispatch_busy_i
                       & ~prog_busy_i
                       & ~prog_pending_q
                       & ~cgra_v_i
                       &  cgra_pipeline_empty_lo;
  assign fdr_accept_li = fdr_valid_i & fdr_ready_o;

  // Exec retire: e-block with no outstanding mem ops retires once it has fully
  // dispatched and the CGRA pipeline has drained.
  assign exec_pop_lo = fdr_active_valid_q
                     & ~exec_pop_sent_q
                     &  exec_dispatch_done_q
                     & ~prog_busy_i
                     & ~prog_pending_q
                     & ~cgra_v_i
                     &  cgra_pipeline_empty_lo;

  // CTA-boundary scoreboard clear: a true CTA-id change between the incoming
  // e-block payload and the currently in-flight e-block.
  assign dispatch_clear_scoreboard_o = fdr_accept_li
      & fdr_active_valid_q
      & (fdr_data_i.schedule_cta_id != fdr_active_q.schedule_cta_id);

  // Rising-edge detect on the prog handshake (single-cycle program pulse).
  assign prog_handshake_li = prog_pending_q & prog_ready_i;
  assign prog_v_li         = prog_handshake_li & ~prog_handshake_q;

  always_ff @(posedge clk_i) begin
    if (rst_i) prog_handshake_q <= 1'b0;
    else       prog_handshake_q <= prog_handshake_li;
  end

  // ---- In-flight / programming state registers ----
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      fdr_active_q          <= '0;
      fdr_active_valid_q    <= 1'b0;
      exec_pop_sent_q       <= 1'b0;
      exec_dispatch_done_q  <= 1'b0;
      prog_pending_q        <= 1'b0;
      prog_pending_buffer_q <= 1'b0;
      cgra_pipeline_count_q <= '0;
    end else begin
      if (fdr_accept_li) begin
        fdr_active_q          <= fdr_data_i;
        fdr_active_valid_q    <= 1'b1;
        exec_pop_sent_q       <= 1'b0;
        exec_dispatch_done_q  <= 1'b0;
        prog_pending_q        <= 1'b1;
        prog_pending_buffer_q <= fdr_data_i.loaded_buffer;  // TODO: confirm field
      end else if (exec_pop_lo) begin
        exec_pop_sent_q      <= 1'b1;
        exec_dispatch_done_q <= 1'b0;
      end else if (dispatcher_done_i) begin
        exec_dispatch_done_q <= 1'b1;
      end

      if (prog_v_li) prog_pending_q <= 1'b0;

      cgra_pipeline_count_q <= cgra_pipeline_count_q
                             + cgra_pipeline_inc_li - cgra_pipeline_dec_li;
    end
  end

  // ---- outputs ----
  assign fdr_accept_o          = fdr_accept_li;
  assign fdr_active_q_o        = fdr_active_q;
  assign fdr_active_valid_o    = fdr_active_valid_q;
  assign exec_pop_o            = exec_pop_lo;
  assign exec_pop_e_block_id_o = fdr_active_q.schedule_eblock_id;
  assign prog_v_o              = prog_v_li;
  assign prog_pending_o        = prog_pending_q;
  assign prog_pending_buffer_o = prog_pending_buffer_q;

endmodule

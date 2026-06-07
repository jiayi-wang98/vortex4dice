// =============================================================================
// dice_mem_dispatch_credit — dispatcher-side memory flow control (extracted from
// dice_core, adapted from Mini_Dice dice_backend.sv).
//
//   * Derives the per-e-block load/store counts (drives the block-retire table
//     accounting: fdr_pending_reads / fdr_pending_stores -> dice_brt).
//   * Gates the dispatcher pop (disp_pop) on per-mem-port credit: a memory-stage
//     dispatch is only allowed when every mem port has a reserved LDST slot
//     (one dice_ready_to_credit_flow_converter per port).
//   * Refunds a port's credit when its TMCU accepts the op
//     (cgra_mem_port_valid & tmcu_incmd_ready).
//   * Produces rd_tid_valid = dispatch_valid gated by the pop.
//
// NOTE: the per-port credit "open" (v_i = disp_pop & mem_stage) and "close"
// (credit_i = accept) are two halves of ONE credit loop and are kept together
// here so the accounting cannot be split / double-counted.
// =============================================================================
module dice_mem_dispatch_credit
  import dice_pkg::*;
  import dice_frontend_pkg::*;
  import DE_pkg::*;
(
    input  logic clk_i,
    input  logic rst_i,

    // In-flight e-block (comb select) + incoming payload, for the mem counts.
    input  fdr_t fdr_active_i,
    input  fdr_t fdr_data_i,

    // Dispatcher raw valid + programming busy gate.
    input  logic [3:0] disp_tid_valid_i,
    input  logic       prog_busy_i,

    // Per-port credit refund sources.
    input  logic [NUM_MEM_PORTS-1:0] cgra_mem_port_valid_i, // from dice_cgra_rf
    input  logic [NUM_MEM_PORTS-1:0] tmcu_incmd_ready_i,    // from dice_tmcu_mem_edge

    // ---- outputs ----
    output logic       disp_pop_o,        // -> dispatcher.dispatch_fifo_pop
    output logic [3:0] rd_tid_valid_o,    // dispatch_valid gated by pop
    output logic [PENDING_MEM_COUNT_WIDTH-1:0] fdr_pending_reads_o,  // -> dice_brt
    output logic [PENDING_MEM_COUNT_WIDTH-1:0] fdr_pending_stores_o  // -> dice_brt
);

  // Reshape fdr metadata ld_dest_regs (packed [$clog2(DICE_CGRA_MEM_PORTS-1)]
  // [REG_INDEX_WIDTH]) into the [NUM_MEM_PORTS][DICE_REG_ADDR_WIDTH] form the
  // gen_* helpers expect. Missing ports get the "no load" sentinel (31).
  function automatic logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] reshape_ld_dest(
      input logic [$clog2(`DICE_CGRA_MEM_PORTS-1):0][REG_INDEX_WIDTH-1:0] md_ld
  );
    for (int p = 0; p < NUM_MEM_PORTS; p++)
      reshape_ld_dest[p] = DICE_REG_ADDR_WIDTH'(31);  // sentinel = no load
    for (int p = 0; p <= $clog2(`DICE_CGRA_MEM_PORTS-1); p++)
      reshape_ld_dest[p] = DICE_REG_ADDR_WIDTH'(md_ld[p]);
  endfunction

  logic [$clog2(NUM_MEM_PORTS+1)-1:0] peek_num_load_lo;
  logic [$clog2(NUM_MEM_PORTS+1)-1:0] fdr_payload_num_load_lo;
  logic                               mem_stage_lo;
  logic                               dispatch_issue_req_lo;
  logic                               disp_pop_lo;
  logic                               mem_bundle_credit_ready_lo;
  logic [NUM_MEM_PORTS-1:0]           mem_port_credit_ready_lo;
  logic [NUM_MEM_PORTS-1:0][1:0]      mem_port_credit_return_lo;

  // Per-eblock load/store counts (drive the block-retire table accounting).
  assign peek_num_load_lo        = gen_num_loads(reshape_ld_dest(fdr_active_i.metadata.ld_dest_regs),
                                                 fdr_active_i.metadata.num_stores);
  assign fdr_payload_num_load_lo = gen_num_loads(reshape_ld_dest(fdr_data_i.metadata.ld_dest_regs),
                                                 fdr_data_i.metadata.num_stores);
  assign mem_stage_lo            = (peek_num_load_lo != '0)
                                || (fdr_active_i.metadata.num_stores != '0);
  assign fdr_pending_reads_o     = PENDING_MEM_COUNT_WIDTH'(
                                     $countones(fdr_data_i.real_active_mask)
                                     * fdr_payload_num_load_lo);
  assign fdr_pending_stores_o    = PENDING_MEM_COUNT_WIDTH'(
                                     ($countones(fdr_data_i.real_active_mask)
                                      * fdr_data_i.metadata.num_stores) + 1);

  // Dispatch issue/pop credit gating.
  assign dispatch_issue_req_lo = (|disp_tid_valid_i) & ~prog_busy_i;
  assign disp_pop_lo           = dispatch_issue_req_lo & mem_bundle_credit_ready_lo;
  assign disp_pop_o            = disp_pop_lo;
  assign rd_tid_valid_o        = disp_tid_valid_i & {4{disp_pop_lo}};

  // Dispatch credit counters (one per mem port).
  for (genvar p = 0; p < NUM_MEM_PORTS; p++) begin : gen_mem_port_credit
    dice_ready_to_credit_flow_converter #(
        .credit_initial_p(MEM_REQ_BUNDLE_FIFO_DEPTH),
        .credit_max_val_p(MEM_REQ_BUNDLE_FIFO_DEPTH),
        .max_step_p(2)
    ) mem_port_credit_ctrl (
        .clk_i(clk_i),
        .reset_i(rst_i),
        .v_i(disp_pop_lo && mem_stage_lo),
        .ready_o(mem_port_credit_ready_lo[p]),
        .v_o(),
        .credit_i(mem_port_credit_return_lo[p]),
        .credit_need_i(2'd1)
    );
  end
  assign mem_bundle_credit_ready_lo = !mem_stage_lo || (&mem_port_credit_ready_lo);

  // Credit refund: port p's slot frees when its TMCU accepts the op.
  for (genvar p = 0; p < NUM_MEM_PORTS; p++) begin : gen_mem_port_credit_return
    assign mem_port_credit_return_lo[p] =
        {1'b0, (cgra_mem_port_valid_i[p] & tmcu_incmd_ready_i[p])};
  end

endmodule

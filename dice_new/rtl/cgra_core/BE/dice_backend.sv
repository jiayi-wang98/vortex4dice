// =============================================================================
// dice_backend — backend wrapper (mirrors Mini_Dice dice_backend).
//
// Groups the whole backend datapath behind ONE boundary and exposes only
// FLATTENED payload signals (no interfaces — dice_core does the interface<->flat
// plumbing). Instantiates the modularized backend:
//   dice_eblock_tracker      — single-eblock FSM / occupancy / accept / prog pulse
//   dispatcher               — thread dispatcher + scoreboards
//   dice_mem_dispatch_credit — mem-port credit flow control
//   dice_cgra_rf             — RF + CGRA fabric + launch + special regs + pred
//   dice_brt                 — block-retire / commit
//   dice_cgra_prog           — CGRA bitstream programming
//   dice_tmcu_mem_edge       — TMCU coalescing + L1 cache (mem-side flattened)
//   dice_ldst_retire         — coalesced load-response retire
// =============================================================================
module dice_backend
  import dice_pkg::*;
  import dice_frontend_pkg::*;
  import DE_pkg::*;
#(
    parameter int CM_CHUNK_COUNT = (DICE_BITSTREAM_SIZE + DICE_MEM_DATA_WIDTH - 1)
                                   / DICE_MEM_DATA_WIDTH
)(
    input  logic clk_i,
    input  logic rst_i,

    // ---- FDR payload (flattened fdr_if) ----
    input  logic fdr_valid_i,
    input  fdr_t fdr_data_i,
    output logic fdr_ready_o,

    // ---- Config-memory chunk streams (flattened cm0_if/cm1_if) ----
    input  logic [DICE_MEM_DATA_WIDTH-1:0] cm0_data_i,
    input  logic [CM_CHUNK_COUNT-1:0]      cm0_chunk_en_i,
    input  logic [DICE_MEM_DATA_WIDTH-1:0] cm1_data_i,
    input  logic [CM_CHUNK_COUNT-1:0]      cm1_chunk_en_i,

    // ---- Commit feedback -> scheduler (frontend) ----
    output logic                            eblock_commit_valid_o,
    output logic [DICE_EBLOCK_ID_WIDTH-1:0] eblock_commit_id_o,
    output logic [2**DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_pending_o,

    // ---- Data-cache backing-memory side (flattened; dice_core -> dcache_mem_if) ----
    output logic                              mem_req_valid_o,
    output logic                              mem_req_rw_o,
    output logic [DICE_CACHE_LINE_SIZE-1:0]   mem_req_byteen_o,
    output logic [DCACHE_MEM_ADDR_WIDTH-1:0]  mem_req_addr_o,
    output logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_req_data_o,
    output logic [DCACHE_MEM_TAG_WIDTH-1:0]   mem_req_tag_o,
    input  logic                              mem_req_ready_i,
    input  logic                              mem_rsp_valid_i,
    input  logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_rsp_data_i,
    input  logic [DCACHE_MEM_TAG_WIDTH-1:0]   mem_rsp_tag_i,
    output logic                              mem_rsp_ready_o
);

  // ---------------------------------------------------------------------------
  // Inter-module wires
  // ---------------------------------------------------------------------------
  fdr_t                            fdr_active;
  fdr_t                            fdr_active_q;
  logic                            fdr_active_valid;
  logic                            fdr_accept;

  logic                            exec_pop;
  logic [DICE_EBLOCK_ID_WIDTH-1:0] exec_pop_e_block_id;

  logic                            prog_v;
  logic                            prog_pending;
  logic                            prog_pending_buffer;
  logic                            prog_busy;
  logic                            prog_ready;
  logic                            prog_rst, prog_done, prog_we, prog_din;

  logic                            dispatch_clear_scoreboard;

  logic [4*DICE_TID_WIDTH-1:0]     rd_tid;
  logic [3:0]                      disp_tid_valid;
  logic [3:0]                      rd_tid_valid;
  logic                            disp_pop;
  logic [`DICE_GPR_NUM-1:0]        gpr_bitmap;
  logic                            dispatch_busy;
  logic                            dispatcher_done;
  logic                            dispatch_fifo_empty;

  logic [PENDING_MEM_COUNT_WIDTH-1:0] fdr_pending_reads;
  logic [PENDING_MEM_COUNT_WIDTH-1:0] fdr_pending_stores;

  logic                            cgra_v;
  logic [DICE_TID_WIDTH-1:0]       cgra_tid;
  logic [DICE_EBLOCK_ID_WIDTH-1:0] cgra_e_block_id;
  logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_valid;
  logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_op;
  logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_addr;
  logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_data;
  logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] cgra_mem_rsp_addr;

  logic [DICE_EBLOCK_ID_WIDTH-1:0] dispatch_e_block_id;

  logic [DICE_NUM_BANKS-1:0]                  rf_ldst_pop;
  logic [DICE_NUM_BANKS-1:0][EBLOCK_ID_W-1:0] rf_ldst_pop_e_block_id;
  logic                                       rf_ldst_special_pop;
  logic [EBLOCK_ID_W-1:0]                      rf_ldst_special_pop_e_block_id;
  logic                                        rf_ldst_ready;
  cache_wr_cmd                                 rf_ldst_wr;

  logic                                core_rsp_valid;
  logic [DCACHE_OUTCMD_TAG_WIDTH-1:0]  core_rsp_tag;
  logic [DICE_CACHE_LINE_SIZE*8-1:0]   core_rsp_data;
  logic                                core_rsp_ready;
  logic [NUM_MEM_PORTS-1:0]            tmcu_incmd_ready;

  logic                                        ldst_wb_fire;
  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0]    scoreboard_wb_tid_bitmap;
  logic [REG_NUM-1:0]                          dispatch_wb_regs_bitmap;

  // ---------------------------------------------------------------------------
  // Single-eblock-in-flight tracker (FSM / occupancy / accept / prog pulse)
  // ---------------------------------------------------------------------------
  dice_eblock_tracker u_dice_eblock_tracker (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .fdr_valid_i(fdr_valid_i),
      .fdr_data_i(fdr_data_i),
      .fdr_ready_o(fdr_ready_o),
      .fdr_accept_o(fdr_accept),
      .dispatch_busy_i(dispatch_busy),
      .dispatcher_done_i(dispatcher_done),
      .prog_busy_i(prog_busy),
      .prog_ready_i(prog_ready),
      .cgra_v_i(cgra_v),
      .rd_tid_valid_i(rd_tid_valid),
      .fdr_active_o(fdr_active),
      .fdr_active_q_o(fdr_active_q),
      .fdr_active_valid_o(fdr_active_valid),
      .exec_pop_o(exec_pop),
      .exec_pop_e_block_id_o(exec_pop_e_block_id),
      .prog_v_o(prog_v),
      .prog_pending_o(prog_pending),
      .prog_pending_buffer_o(prog_pending_buffer),
      .dispatch_clear_scoreboard_o(dispatch_clear_scoreboard)
  );

  // ---------------------------------------------------------------------------
  // Dispatcher (existing dice_new module). wb driven by the mem response.
  // ---------------------------------------------------------------------------
  dispatcher u_dispatcher (
      .clk_i(clk_i),
      .rst(rst_i),
      .unrolling_factor(fdr_active.metadata.unrolling_factor),
      .input_register_bitmap(fdr_active.metadata.in_regs_bitmap),
      .active_mask(fdr_active.real_active_mask),
      .cta_size(fdr_active.schedule_hw_cta_size),
      .fetch_done(fdr_accept),
      .wb_valid(ldst_wb_fire),
      .wb_tid_bitmap(scoreboard_wb_tid_bitmap),
      .wb_regs_bitmap(dispatch_wb_regs_bitmap),
      .clear_scoreboard(dispatch_clear_scoreboard),
      .ld_dest_regs(fdr_active.metadata.ld_dest_regs),
      .dispatch_fifo_pop(disp_pop),
      .dispatch_tid_o(rd_tid),
      .dispatch_valid_o(disp_tid_valid),
      .dispatch_fifo_empty(dispatch_fifo_empty),
      .gpr_bitmap_o(gpr_bitmap),
      .dispatcher_busy(dispatch_busy),
      .dispatcher_done(dispatcher_done)
  );

  // ---------------------------------------------------------------------------
  // Dispatcher-side memory credit flow control
  // ---------------------------------------------------------------------------
  dice_mem_dispatch_credit u_dice_mem_dispatch_credit (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .fdr_active_i(fdr_active),
      .fdr_data_i(fdr_data_i),
      .disp_tid_valid_i(disp_tid_valid),
      .prog_busy_i(prog_busy),
      .cgra_mem_port_valid_i(cgra_mem_port_valid),
      .tmcu_incmd_ready_i(tmcu_incmd_ready),
      .disp_pop_o(disp_pop),
      .rd_tid_valid_o(rd_tid_valid),
      .fdr_pending_reads_o(fdr_pending_reads),
      .fdr_pending_stores_o(fdr_pending_stores)
  );

  // ---------------------------------------------------------------------------
  // RF + CGRA fabric + launch + special regs + predicate (keystone)
  // ---------------------------------------------------------------------------
  dice_cgra_rf u_dice_cgra_rf (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .prog_busy_i(prog_busy),
      .rd_tid_valid_i(rd_tid_valid),
      .rd_tid_i(rd_tid),
      .gpr_bitmap_i(gpr_bitmap),
      .fdr_active_i(fdr_active),
      .fdr_active_q_i(fdr_active_q),
      .fdr_accept_i(fdr_accept),
      .dispatch_e_block_id_i(dispatch_e_block_id),
      .rf_ldst_wr_i(rf_ldst_wr),
      .core_rsp_valid_i(core_rsp_valid),
      .rf_ldst_ready_o(rf_ldst_ready),
      .prog_rst_i(prog_rst),
      .prog_done_i(prog_done),
      .prog_we_i(prog_we),
      .prog_din_i(prog_din),
      .cgra_v_o(cgra_v),
      .cgra_tid_o(cgra_tid),
      .cgra_e_block_id_o(cgra_e_block_id),
      .cgra_mem_port_valid_o(cgra_mem_port_valid),
      .cgra_mem_port_op_o(cgra_mem_port_op),
      .cgra_mem_addr_o(cgra_mem_addr),
      .cgra_mem_data_o(cgra_mem_data),
      .cgra_mem_rsp_addr_o(cgra_mem_rsp_addr),
      .rf_ldst_pop_o(rf_ldst_pop),
      .rf_ldst_pop_e_block_id_o(rf_ldst_pop_e_block_id),
      .rf_ldst_special_pop_o(rf_ldst_special_pop),
      .rf_ldst_special_pop_e_block_id_o(rf_ldst_special_pop_e_block_id)
  );

  // ---------------------------------------------------------------------------
  // Block-Retire Table (commit)
  // ---------------------------------------------------------------------------
  dice_brt u_dice_brt (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .fdr_valid_i         (fdr_accept),
      .dispatch_busy_i     (dispatch_busy),
      .insert_hw_cta_id_i  (fdr_data_i.schedule_hw_cta_id),
      .fdr_e_block_id_i    (DICE_EBLOCK_ID_WIDTH'(fdr_data_i.schedule_eblock_id)),
      .fdr_pending_reads_i (fdr_pending_reads),
      .fdr_pending_stores_i(fdr_pending_stores),
      .dispatch_e_block_id_o(dispatch_e_block_id),
      .ldst_pop_i                   (rf_ldst_pop),
      .ldst_pop_e_block_id_i        (rf_ldst_pop_e_block_id),
      .ldst_special_pop_i           (rf_ldst_special_pop),
      .ldst_special_pop_e_block_id_i(rf_ldst_special_pop_e_block_id),
      // store_retire tied 0 until the mem_req_tag block_id field is confirmed.
      .store_retire_valid_i     (1'b0),
      .store_retire_e_block_id_i('0),
      .exec_retire_valid_i      (exec_pop),
      .exec_retire_e_block_id_i (exec_pop_e_block_id),
      .eblock_commit_valid_o(eblock_commit_valid_o),
      .eblock_commit_id_o   (eblock_commit_id_o),
      .eblock_commit_ready_i('1),
      .hw_cta_pending_o     (hw_cta_pending_o)
  );

  // ---------------------------------------------------------------------------
  // CGRA bitstream programming
  // ---------------------------------------------------------------------------
  dice_cgra_prog #(
      .CM_CHUNK_COUNT(CM_CHUNK_COUNT)
  ) u_dice_cgra_prog (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .cm0_data_i(cm0_data_i),
      .cm0_chunk_en_i(cm0_chunk_en_i),
      .cm1_data_i(cm1_data_i),
      .cm1_chunk_en_i(cm1_chunk_en_i),
      .prog_v_i(prog_v),
      .prog_pending_buffer_i(prog_pending_buffer),
      .prog_busy_o(prog_busy),
      .prog_ready_o(prog_ready),
      .prog_rst_o(prog_rst),
      .prog_done_o(prog_done),
      .prog_we_o(prog_we),
      .prog_din_o(prog_din)
  );

  // ---------------------------------------------------------------------------
  // TMCU memory edge (coalescing + L1 cache)
  // ---------------------------------------------------------------------------
  dice_tmcu_mem_edge #(
      .NUM_BANKS(1)
  ) u_dice_tmcu_mem_edge (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .cgra_mem_port_valid_i(cgra_mem_port_valid),
      .cgra_mem_port_op_i(cgra_mem_port_op),
      .cgra_mem_addr_i(cgra_mem_addr),
      .cgra_mem_data_i(cgra_mem_data),
      .cgra_mem_rsp_addr_i(cgra_mem_rsp_addr),
      .cgra_tid_i(cgra_tid),
      .cgra_e_block_id_i(cgra_e_block_id),
      .tmcu_incmd_ready_o(tmcu_incmd_ready),
      .core_rsp_data_o(core_rsp_data),
      .core_rsp_valid_o(core_rsp_valid),
      .core_rsp_tag_o(core_rsp_tag),
      .core_rsp_ready_i(core_rsp_ready),
      .mem_req_valid_o(mem_req_valid_o),
      .mem_req_rw_o(mem_req_rw_o),
      .mem_req_byteen_o(mem_req_byteen_o),
      .mem_req_addr_o(mem_req_addr_o),
      .mem_req_data_o(mem_req_data_o),
      .mem_req_tag_o(mem_req_tag_o),
      .mem_req_ready_i(mem_req_ready_i),
      .mem_rsp_valid_i(mem_rsp_valid_i),
      .mem_rsp_data_i(mem_rsp_data_i),
      .mem_rsp_tag_i(mem_rsp_tag_i),
      .mem_rsp_ready_o(mem_rsp_ready_o)
  );

  // ---------------------------------------------------------------------------
  // Coalesced load-response retire
  // ---------------------------------------------------------------------------
  dice_ldst_retire u_dice_ldst_retire (
      .core_rsp_valid_i(core_rsp_valid),
      .core_rsp_tag_i(core_rsp_tag),
      .core_rsp_data_i(core_rsp_data),
      .rf_ldst_ready_i(rf_ldst_ready),
      .core_rsp_ready_o(core_rsp_ready),
      .ldst_wb_fire_o(ldst_wb_fire),
      .scoreboard_wb_tid_bitmap_o(scoreboard_wb_tid_bitmap),
      .dispatch_wb_regs_bitmap_o(dispatch_wb_regs_bitmap),
      .rf_ldst_wr_o(rf_ldst_wr)
  );

endmodule

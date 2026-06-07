// =============================================================================
// dice_frontend — frontend wrapper (mirrors Mini_Dice dice_frontend).
//
// Groups the CTA-scheduling stage and the fetch/decode/resolve stage, owning the
// scheduler<->FDR glue (schedule_if, simt_status, branch-predict, simt-update,
// eblock-flush) internally. Exposes the external core interfaces (CTA launch,
// metadata/bitstream read masters) as pass-through ports, and the FDR payload +
// config-memory streams as FLATTENED ports so dice_core wires the frontend to the
// backend without interfaces crossing the FE/BE boundary.
// =============================================================================
module dice_frontend
  import dice_pkg::*;
  import dice_frontend_pkg::*;
#(
    parameter int CM_CHUNK_COUNT = (DICE_BITSTREAM_SIZE + DICE_MEM_DATA_WIDTH - 1)
                                   / DICE_MEM_DATA_WIDTH
)(
    input  logic clk_i,
    input  logic rst_i,

    // ---- External core interfaces (pass-through) ----
    cta_dispatch_if.slave  cta_dispatch_if_inst,
    cta_complete_if.master cta_complete_if_inst,
    VX_mem_bus_if.master   metacache_mem_if,
    VX_mem_bus_if.master   bitstream_cache_mem_if,

    // ---- FDR payload -> backend (flattened) ----
    output logic fdr_valid_o,
    output fdr_t fdr_data_o,
    input  logic fdr_ready_i,

    // ---- Config-memory chunk streams -> backend (flattened cm0_if/cm1_if) ----
    output logic [DICE_MEM_DATA_WIDTH-1:0] cm0_data_o,
    output logic [CM_CHUNK_COUNT-1:0]      cm0_chunk_en_o,
    output logic [DICE_MEM_DATA_WIDTH-1:0] cm1_data_o,
    output logic [CM_CHUNK_COUNT-1:0]      cm1_chunk_en_o,

    // ---- Commit / block-retire feedback from backend ----
    input  logic                            eblock_commit_valid_i,
    input  logic [DICE_EBLOCK_ID_WIDTH-1:0] eblock_commit_id_i,
    input  logic [2**DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_pending_i
);

  // ---- internal frontend interfaces ----
  cta_sched_if         schedule_if    ();
  fdr_if               fdr_out_if     ();
  simt_stack_status_if simt_status_if ();
  cgra_cm_if           cm0_if         ();
  cgra_cm_if           cm1_if         ();

  // FDR -> scheduler status/branch wires
  branch_predict_interface_t bh_branch_predict_info;
  logic                      bh_branch_predict_info_we;
  dice_cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_data;

  // FDR -> scheduler SIMT update wires
  logic                            simt_update_valid;
  logic                            simt_update_ready;
  simt_stack_update_t              simt_update_stack_data;
  logic [DICE_HW_CTA_ID_WIDTH-1:0] simt_update_hw_cta_id;
  cta_size_e                       simt_update_hw_cta_size;

  // Eblock flush wires (FDR -> Scheduler)
  logic                       eblock_flush_valid;
  logic [EBLOCK_ID_WIDTH-1:0] eblock_flush_id;

  // ---------------------------------------------------------------------------
  // CTA Schedule Stage
  // ---------------------------------------------------------------------------
  cta_schedule_stage u_cta_schedule_stage (
      .clk_i                   (clk_i),
      .rst_i                   (rst_i),
      .cta_dispatch_if         (cta_dispatch_if_inst),
      .cta_complete_if         (cta_complete_if_inst),
      .schedule_if             (schedule_if),
      // Commit feedback from the backend block-retire table.
      .eblock_commit_valid_i   (eblock_commit_valid_i),
      .eblock_commit_id_i      (eblock_commit_id_i),
      .eblock_flush_valid_i    (eblock_flush_valid),
      .eblock_flush_id_i       (eblock_flush_id),
      .bh_branch_predict_info_i(bh_branch_predict_info),
      .bh_branch_predict_info_we_i(bh_branch_predict_info_we),
      .cta_status_data_o       (cta_status_data),
      // Per-hw-cta pending vector from the backend dice_brt.
      .brt_info_i              ('{hw_cta_pending: hw_cta_pending_i}),
      .brt_info_write_enable_i (1'b1),
      .simt_update_valid_i     (simt_update_valid),
      .simt_update_ready_o     (simt_update_ready),
      .simt_update_stack_data_i(simt_update_stack_data),
      .simt_update_hw_cta_id_i (simt_update_hw_cta_id),
      .simt_update_hw_cta_size_i(simt_update_hw_cta_size),
      .simt_status_if          (simt_status_if)
  );

  // ---------------------------------------------------------------------------
  // FDR Top. Drives cm0_if/cm1_if config-memory writes.
  // ---------------------------------------------------------------------------
  fdr_top u_fdr_top (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .metacache_mem_if(metacache_mem_if),
      .bitstream_cache_mem_if(bitstream_cache_mem_if),
      .schedule_if(schedule_if),
      .fdr_if(fdr_out_if),
      .simt_status_if(simt_status_if),
      .bh_branch_predict_info_o(bh_branch_predict_info),
      .bh_branch_predict_info_we_o(bh_branch_predict_info_we),
      .cta_status_data_i(cta_status_data),
      .simt_update_valid_o(simt_update_valid),
      .simt_update_ready_i(simt_update_ready),
      .simt_update_stack_data_o(simt_update_stack_data),
      .simt_update_hw_cta_id_o(simt_update_hw_cta_id),
      .simt_update_hw_cta_size_o(simt_update_hw_cta_size),
      .cm0_if(cm0_if),
      .cm1_if(cm1_if),
      .eblock_flush_valid_o(eblock_flush_valid),
      .eblock_flush_id_o   (eblock_flush_id)
  );

  // ---- Flatten the FDR payload + config-memory interfaces to the boundary ----
  assign fdr_valid_o     = fdr_out_if.valid;
  assign fdr_data_o      = fdr_out_if.data;
  assign fdr_out_if.ready = fdr_ready_i;

  assign cm0_data_o     = cm0_if.data;
  assign cm0_chunk_en_o = cm0_if.chunk_en;
  assign cm1_data_o     = cm1_if.data;
  assign cm1_chunk_en_o = cm1_if.chunk_en;

endmodule

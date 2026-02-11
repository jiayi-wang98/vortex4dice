
module dice_core
  import dice_pkg::*;
  import dice_frontend_pkg::*;
(
    input logic clk,
    input logic reset,

    // Host/Dispatcher Interface - CTA Allocation
    input  logic           cta_add_valid_i,
    output logic           cta_add_ready_o,
    input  dice_cta_desc_t new_cta_desc_i,

    output logic         cta_complete_valid_o,
    input  logic         cta_complete_ready_i,
    output dice_cta_id_t cta_done_id_o,

    // Memory Bus Interfaces
    VX_mem_bus_if.master metacache_mem_if,
    VX_mem_bus_if.master bitstream_cache_mem_if

);
  // Internal Interfaces
  cta_sched_if         schedule_if          (); // between cta scheduler and fdr stages
  fdr_if               fdr_out_if           (); // between fdr and backend stages
  simt_stack_status_if simt_status_if       (); // exposes simt stack entries to modules that need it
  cgra_cm_if           cm0_if               ();
  cgra_cm_if           cm1_if               ();

  // FDR -> scheduler status table/branch prediction wires
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

  // CTA Dispatcher interfaces (internal, wired to flat top-level ports)
  cta_dispatch_if cta_dispatch_if_inst ();
  cta_complete_if cta_complete_if_inst ();

  // Wire flat top-level ports to internal interfaces
  assign cta_dispatch_if_inst.valid = cta_add_valid_i;
  assign cta_dispatch_if_inst.data  = new_cta_desc_i;
  assign cta_add_ready_o            = cta_dispatch_if_inst.ready;

  assign cta_complete_valid_o       = cta_complete_if_inst.valid;
  assign cta_done_id_o              = cta_complete_if_inst.cta_id;
  // Note: cta_complete_ready_i is not used by cta_controller (ready is always implicit)

  cta_schedule_stage u_cta_schedule_stage (
      .clk_i                   (clk),
      .rst_i                   (reset),
      .cta_dispatch_if         (cta_dispatch_if_inst),
      .cta_complete_if         (cta_complete_if_inst),
      .schedule_if             (schedule_if),
      .eblock_commit_valid_i   (),
      .eblock_commit_id_i      (),
      .eblock_flush_valid_i    (eblock_flush_valid),
      .eblock_flush_id_i       (eblock_flush_id),
      .bh_branch_predict_info_i(bh_branch_predict_info),
      .bh_branch_predict_info_we_i(bh_branch_predict_info_we),
      .cta_status_data_o       (cta_status_data),
      .brt_info_i              (),
      .brt_info_write_enable_i (),
      .simt_update_valid_i     (simt_update_valid),
      .simt_update_ready_o     (simt_update_ready),
      .simt_update_stack_data_i(simt_update_stack_data),
      .simt_update_hw_cta_id_i (simt_update_hw_cta_id),
      .simt_update_hw_cta_size_i(simt_update_hw_cta_size),
      .simt_status_if          (simt_status_if)
  );

  fdr_top u_fdr_top (
      .clk_i(clk),
      .rst_i(reset),
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
      .bh_buf_data_i       (),  // TODO: connect to backend predicate data
      .bh_buf_tid_offset_i (),  // TODO: connect to backend TID offset
      .bh_buf_valid_i      (),  // TODO: connect to backend valid
      .bh_buf_last_i       (),  // TODO: connect to backend last
      .bh_buf_consumed_o   (),  // TODO: connect to backend consumed
      .cm0_if(cm0_if),
      .cm1_if(cm1_if),
      .eblock_flush_valid_o(eblock_flush_valid),
      .eblock_flush_id_o   (eblock_flush_id)
  );

endmodule

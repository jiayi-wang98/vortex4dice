
module dice_core
  import dice_pkg::*;
  import dice_frontend_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

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
  logic                      bh_branch_predict_info_we; //after recent chances i don't think this signal is needed
  // but i haven't deleted it from all modules yet (enable signal is now a bitmap and is part of the struct)
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
      .clk_i                   (clk_i),
      .rst_i                   (rst_i),
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


  dispatcher u_dispatcher (
      .clk(clk_i),
      .rst_n(~rst_i),
      .unrolling_factor(fdr_out_if.data.metadata.unrolling_factor),
      .input_register_bitmap(fdr_out_if.data.metadata.in_regs_bitmap),
      .active_mask(fdr_out_if.data.real_active_mask),
      .cta_size(fdr_out_if.data.schedule_hw_cta_size),
      .fetch_done(fdr_out_if.valid),
      .wb_valid(),          // comes from cgra
      .wb_tid_bitmap(),     // comes from cgra
      .ld_dest_reg(),       // comes from cgra
      .dispatch_fifo_pop(), // cgra ready
      .dispatch_tid_0(rd_tid),
      .dispatch_valid_0(rd_tid_valid),
      .dispatch_tid_1(),
      .dispatch_valid_1(),
      .dispatch_tid_2(),
      .dispatch_valid_2(),
      .dispatch_tid_3(),
      .dispatch_valid_3(),
      .dispatch_fifo_empty(),
      .gpr_bitmap_o(gpr_bitmap),
      .dispatcher_busy(),
      .dispatcher_done()
  );

  logic [DICE_TID_WIDTH-1:0] rd_tid;
  logic rd_tid_valid;
  logic [31:0] gpr_bitmap;

  logic rf_rd_valid_lo;

  logic [DICE_NUM_BANKS*DICE_REG_DATA_WIDTH-1:0] rd_data_lo;
dice_rf_ctrl #(
    .NUM_PORTS(DICE_NUM_BANKS),
    .DATA_WIDTH(DICE_REG_DATA_WIDTH),
    .NUM_TID(512),
    .TID_WIDTH($clog2(512)),
    .DEPTH(512),
    .ADDR_WIDTH($clog2(512)),
    .NUM_SPECIAL_REG(16),
    .MAX_CTA_ID(65535),
    .CTA_ID_WIDTH($clog2(65535)),
    .BUF_DEPTH(8)
) u_dice_rf_ctrl (


    .clk_i(clk_i),
    .rst_i(rst_i),

    // Read Input Ports
    .rd_tid_valid_i(rd_tid_valid),
    .rd_tid_ready_o(),
    .rd_unroll_factor_i(fdr_out_if.data.metadata.unrolling_factor),
    .rd_en_i(rd_tid_valid),
    .rd_tid_i(rd_tid),
    .rd_bitmap_i(gpr_bitmap),
    .rd_data_o(rd_data_lo),
    .rf_rd_valid_o(rf_rd_valid_lo),

    // Write Input Ports
    .cgra_tid_i(),         // comes from cgra
    .cgra_data_i(),        // comes from cgra
    .wr_bitmap_i(fdr_out_if.data.metadata.out_regs_bitmap), // TODO: add shift reg
    .cgra_valid_i(),       // comes from cgra

    // init test no LDST and no special register for now
    .ldst_wr_i(),
    .ldst_valid_i(),
    .ldst_ready_o(),

    .clear_i(),
    .spec_rd_enable_i(),
    .spec_reg_sel_i(),
    .const_reg_i(),
    .tid_x_i(),
    .tid_y_i(),
    .tid_z_i(),
    .ntid_x_i(),
    .ntid_y_i(),
    .ntid_z_i(),
    .ctaid_x_i(),
    .ctaid_y_i(),
    .ctaid_z_i(),
    .nctaid_x_i(),
    .nctaid_y_i(),
    .nctaid_z_i(),
    .spec_reg_out_o()
);



// add dummy cgra

logic cgra_v_lo;
logic [DICE_NUM_BANKS*DICE_REG_DATA_WIDTH-1:0] cgra_data_lo;
logic [DICE_TID_WIDTH-1:0] cgra_tid_lo;

dummy_cgra u_dummy_cgra (
  .clk_i(clk_i),
  .rst_i(rst_i),
  .v_i(rf_rd_valid_lo),
  .ready_o(),
  .data_i(rd_data_lo),
  .tid_i(rd_tid),
  .v_o(cgra_v_lo),
  .tid_o(cgra_tid_lo),
  .data_o(cgra_data_lo)
);


// TODO: Check if this is what should be in the core or if the
// internal TMCU should be here
VX_cache_with_temporal u_vx_cache_with_temporal (
    .clk(clk_i),
    .rst(rst_i),
    .incmd_valid(),
    .incmd_block_id(),
    .incmd_tid(),
    .incmd_write_enable(),
    .incmd_write_data(),
    .incmd_write_mask(),
    .incmd_address(),
    .incmd_size(),
    .incmd_ld_dest_reg(),
    .outcmd_ready(),
    .core_rsp_data(),
    .core_rsp_valid(),
    .core_rsp_tag(),
    .core_rsp_ready(),
    .mem_req_valid(),
    .mem_req_rw(),
    .mem_req_byteen(),
    .mem_req_addr(),
    .mem_req_data(),
    .mem_req_tag(),
    .mem_req_ready(),
    .mem_rsp_valid(),
    .mem_rsp_data(),
    .mem_rsp_tag(),
    .mem_rsp_ready()
);





block_commit_table u_block_commit_table (
    .clk(clk_i),
    .rst(~rst_i),
    .insert_valid(),
    .insert_hw_cta_id(),
    .insert_e_block_id(),
    .insert_pending_reads(),
    .insert_pending_writes(),
    .update_valid(),
    .update_e_block_id(),
    .update_is_write(),
    .update_reduce_count(),
    .pop_valid(),
    .pop_e_block_id(),
    .pop_ready(),
    .hw_cta_pending()
);

endmodule

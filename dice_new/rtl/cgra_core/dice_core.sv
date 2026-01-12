
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
  cta_sched_if schedule_if ();  //between cta scheduler and fdr stages
  branch_handler_if     bh_if (); //between fdr and cta scheduler stages (branch handler, simt stack update, simt status)
  fdr_if fdr_out_if ();  //between fdr and backend stages
  dice_bh_simt_if       simt_stack_update_if (); //between branch handler and simt stack controller stages
  simt_stack_status_if simt_status_if ();  //exposes simt stack entries to modules that need it
  prf_if prf_if ();  //between branch handler and predicated register files
  cgra_cm_if cm0_if ();  //between bitstream fetch and cgra buffer #0
  cgra_cm_if cm1_if ();  //between bitstream fetch and cgra buffer #1

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
      .clk_i(clk),
      .rst_i(reset),
      .cta_dispatch_if(cta_dispatch_if_inst),
      .cta_complete_if(cta_complete_if_inst),
      .schedule_if(schedule_if),
      .eblock_commit_valid_i(),
      .eblock_commit_id_i(),
      .status_table_bh_if(bh_if),
      .brt_info_i(),
      .brt_info_write_enable_i(),
      .simt_stack_update(simt_stack_update_if),
      .simt_status_if(simt_status_if)
  );

  fdr_top u_fdr_top (
      .clk_i(clk),
      .rst_i(reset),
      .metacache_mem_if(metacache_mem_if),
      .bitstream_cache_mem_if(bitstream_cache_mem_if),
      .schedule_if(schedule_if),
      .fdr_if(fdr_out_if),  //modify to include hw size 0-3 rather than cta x*y*z
      .simt_status_if(simt_status_if),
      .simt_stack_update_if(simt_stack_update_if),
      .prf_if(prf_if),
      .bh_if(bh_if),
      .cm0_if(cm0_if),  //these intercaes could be combined into one
      .cm1_if(cm1_if)
  );

endmodule

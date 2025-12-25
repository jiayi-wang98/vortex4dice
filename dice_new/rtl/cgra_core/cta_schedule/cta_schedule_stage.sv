  //TODO: EITHER MAKE INTERFACES FOR SOME OF THE I/O OR AT LEAST SWITCH TO STRUCTS
  //TODO: MAKE RESET SYNCHRONOUS HIGH FOR FPGA

`include "VX_define.vh"

import dice_frontend_pkg::*;
import dice_pkg::*;
import VX_gpu_pkg::*;

module cta_schedule_stage #(
    parameter int MAX_NUM_CTA = 4,
    parameter int PC_WIDTH = 32,
    parameter int THREAD_WIDTH = 256,
    parameter int STACK_DEPTH = 32,
    parameter int NUM_STACK = 4,
    parameter int CTA_ID_WIDTH = $clog2(MAX_NUM_CTA),
    parameter int EBLOCK_ID_WIDTH = $clog2(MAX_NUM_CTA + 4)
) (
    input logic clk,
    input logic rst,

    // Host/Dispatcher interface for new CTA allocation
    input  logic        cta_add_valid,
    output logic        cta_add_ready,
    input dice_cta_desc_t new_cta_all_desc,
    
    // CTA completion output (to dispatcher)
    output logic            cta_complete_valid,
    input  logic            cta_complete_ready,
    output dice_cta_id_t    cta_done_id,

    // Scheduler output interface (to FDR stage)
    cta_sched_if.master schedule_if,

    // E-block commit interface (from execution/retire)
    // input logic                       eblock_commit_valid,
    // input logic [EBLOCK_ID_WIDTH-1:0] eblock_commit_id,

    // Branch handler / predictor interface (from FDR/execution)
    branch_handler_if.slave    status_table_bh_if,

    // TO DO: Block Retire Table interface 
    // input dice_pkg::block_retire_status brt_info,
    // input logic                         brt_info_write_enable,


    // UPDATE INTERFACE (SIMT STACK CONTROLLER AND BRANCH HANDLER)
    dice_bh_simt_if.slave       simt_stack_update,


    // SIMT STACK STATUS - MAY CHANGE TO BE INCLUDED IN BH AND VC IFs
    output logic [NUM_STACK-1:0] stack_top_valid,
    output logic [NUM_STACK-1:0][PC_WIDTH-1:0] stack_top_next_pc,
    output logic [NUM_STACK-1:0][PC_WIDTH-1:0] stack_top_reconvergence_pc,
    output logic [NUM_STACK-1:0][THREAD_WIDTH-1:0] stack_top_active_mask,
    // Stack status - individual stack status
    output logic [NUM_STACK-1:0] stack_empty,
    output logic [NUM_STACK-1:0] stack_full

    //cta status table stuff

);


  // -------------------------------------------------------------------------
  // CTA Controller
  // -------------------------------------------------------------------------
  cta_controller #(
    // Parameters can be added here
  ) cta_controller_inst (
    .clk                    (),
    .rst                    (),

    // Host/Dispatcher interface for new CTA allocation
    .cta_add_valid          (cta_add_valid),
    .cta_add_ready          (cta_add_ready),
    .new_cta_all_desc       (new_cta_all_desc),

    // CTA completion output (to host/dispatcher)
    .cta_complete_valid     (cta_complete_valid),
    .cta_complete_ready     (cta_complete_ready),
    .cta_done_id            (cta_done_id),

    // Initialization interface with simt stack
    .init_valid             (),
    .init_hw_cta_id         (),
    .init_hw_cta_size       (),
    .init_pc                (),
    .init_reconvergence_pc  (),
    .init_ready             (),

    // Add new cta
    .add_active_cta_valid   (),
    .add_active_cta_ready   (),
    .active_cta_table_desc  (),

    // Pop/delete cta (active cta table)
    .pop_valid              (),
    .pop_hw_cta_id          ()
  );

  // -------------------------------------------------------------------------
  // Active CTA Table
  // -------------------------------------------------------------------------
  active_cta_table #(
      .MAX_NUM_CTA    (MAX_NUM_CTA),
      .CTA_INDEX_WIDTH(CTA_ID_WIDTH),
      .THREAD_WIDTH   (THREAD_WIDTH)
  ) active_cta_table_inst (
      .clk                 (),
      .rst_n               (),
      .pop_valid           (),
      .pop_hw_cta_id       (),
      .add_valid           (),
      .add_cta_id_x        (),
      .add_cta_id_y        (),
      .add_cta_id_z        (),
      .add_grid_size_x     (),
      .add_grid_size_y     (),
      .add_grid_size_z     (),
      .add_cta_size_x      (),
      .add_cta_size_y      (),
      .add_cta_size_z      (),
      .add_cta_size        (),
      .add_kernel_id       (),
      .add_ready           (),
      .out_valid           (),
      .out_cta_id_x        (),
      .out_cta_id_y        (),
      .out_cta_id_z        (),
      .out_cta_size        (),
      .out_kernel_id       (),
      .out_ready           (),
      .cta_valid           (),
      .cta_id_x            (),
      .cta_id_y            (),
      .cta_id_z            (),
      .grid_size_x         (),
      .grid_size_y         (),
      .grid_size_z         (),
      .cta_size_x          (),
      .cta_size_y          (),
      .cta_size_z          (),
      .cta_size            (),
      .kernel_id           (),
      .full                (),
      .next_empty_cta_index()
  );

  // -------------------------------------------------------------------------
  // CTA Scheduler
  // -------------------------------------------------------------------------
  cta_scheduler #(
      .MAX_NUM_CTA    (MAX_NUM_CTA),
      .PC_WIDTH       (PC_WIDTH),
      .CTA_ID_WIDTH   (CTA_ID_WIDTH),
      .EBLOCK_ID_WIDTH(EBLOCK_ID_WIDTH)
  ) cta_scheduler_inst (
      .clk                   (),
      .rst_n                 (),
      .enable                (),
      .cta_valid             (),
      .cta_branch_resolving  (),
      .cta_next_pc           (),
      .eblock_commit_valid   (),
      .eblock_commit_id      (),
      .schedule_valid        (),
      .schedule_hw_cta_id    (),
      .schedule_next_pc      (),
      .schedule_eblock_id    (),
      .schedule_cta_predicted(),
      .schedule_ready        ()
  );

  // -------------------------------------------------------------------------
  // CTA Status Table - NOT FINISHED YET
  // -------------------------------------------------------------------------
  cta_status_table #(
      .MAX_CTA_SIZE(MAX_NUM_CTA)
  ) cta_status_table_inst ( // use interface
      .clk                             (),
      .rst_n                           (),
      .branch_predict_info             (),
      .branch_predict_info_write_enable(),
      .brt_info                        (),
      .brt_info_write_enable           (),
      .cta_status                      ()
  );

  // -------------------------------------------------------------------------
  // SIMT Stack Controller
  // -------------------------------------------------------------------------
  simt_stack_controller #(
      .STACK_DEPTH (STACK_DEPTH),
      .PC_WIDTH    (PC_WIDTH),
      .THREAD_WIDTH(THREAD_WIDTH),
      .NUM_STACK   (NUM_STACK)
  ) simt_stack_controller_inst (
      .clk                       (),
      .rst_n                     (),
      .hw_cta_id                 (),
      .hw_cta_size               (),
      .update_valid              (),
      .update_with_divergence    (),
      .update_next_pc            (),
      .predicate_regs_value      (),
      .branch_not_taken_pc       (),
      .branch_reconvergence_pc   (),
      .update_ready              (),
      .init_valid                (),
      .init_hw_cta_id            (),
      .init_hw_cta_size          (),
      .init_pc                   (),
      .init_reconvergence_pc     (),
      .init_ready                (),
      .stack_top_valid           (),
      .stack_top_next_pc         (),
      .stack_top_reconvergence_pc(),
      .stack_top_active_mask     (),
      .stack_empty               (),
      .stack_full                ()
  );








  

endmodule
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
    input  logic           cta_add_valid,
    output logic           cta_add_ready,
    input  dice_cta_desc_t new_cta_all_desc,

    // CTA completion output (to dispatcher)
    output logic         cta_complete_valid,
    input  logic         cta_complete_ready,
    output dice_cta_id_t cta_done_id,

    // Scheduler output interface (to FDR stage)
    cta_sched_if.master schedule_if,

    // E-block commit interface (from execution/retire)
    // input logic                       eblock_commit_valid,
    // input logic [EBLOCK_ID_WIDTH-1:0] eblock_commit_id,

    // Branch handler / predictor interface (from FDR/execution)
    branch_handler_if.slave status_table_bh_if,

    // TO DO: Block Retire Table interface 
    // input dice_pkg::block_retire_status brt_info,
    // input logic                         brt_info_write_enable,


    // UPDATE INTERFACE (SIMT STACK CONTROLLER AND BRANCH HANDLER)
    dice_bh_simt_if.slave simt_stack_update,


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
      .clk(),
      .rst(),

      // Host/Dispatcher interface for new CTA allocation
      .cta_add_valid   (cta_add_valid),
      .cta_add_ready   (cta_add_ready),
      .new_cta_all_desc(new_cta_all_desc),

      // CTA completion output (to host/dispatcher)
      .cta_complete_valid(cta_complete_valid),
      .cta_complete_ready(cta_complete_ready),
      .cta_done_id       (cta_done_id),

      // Initialization interface with simt stack
      .init_valid           (),
      .init_hw_cta_id       (),
      .init_hw_cta_size     (),
      .init_pc              (),
      .init_reconvergence_pc(),
      .init_ready           (),

      // Add new cta
      .add_active_cta_valid (),
      .add_active_cta_ready (),
      .active_cta_table_desc(),

      // Pop/delete cta (active cta table)
      .pop_valid    (),
      .pop_hw_cta_id()
  );

  // -------------------------------------------------------------------------
  // Active CTA Table
  // -------------------------------------------------------------------------
    active_cta_table #(
        .THREAD_WIDTH (THREAD_WIDTH)
    ) active_cta_table_inst (
        .clk                  (),
        .rst                  (),
        .add_ready            (),
        .add_valid            (),
        .add_cta_info         (),
        .add_cta_size         (),
        .pop_valid            (),
        .pop_hw_cta_id        (),
        .out_valid            (),
        .out_ready            (),
        .out_cta_id           (),
        .out_cta_size         (),
        .out_kernel_id        (),
        .active_cta_entries   (),
        .full                 (),
        .next_empty_cta_index ()
    );


  // -------------------------------------------------------------------------
  // CTA Scheduler
  // -------------------------------------------------------------------------
  cta_scheduler cta_scheduler_inst (
    .clk                   (),
    .rst                   (),
    .enable                (),
    .active_cta_entries    (),
    .cta_status_entries    (),
    .cta_next_pc           (),
    .stack_top_active_mask (),
    .eblock_commit_valid   (),
    .eblock_commit_id      (),
    .scheduled_eblock      ()
  );

  // -------------------------------------------------------------------------
  // CTA Status Table - NOT FINISHED YET
  // -------------------------------------------------------------------------
  cta_status_table #(
      .MAX_CTA_SIZE(MAX_NUM_CTA)
  ) cta_status_table_inst (  // use interface
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

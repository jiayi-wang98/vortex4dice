//TO DO: EITHER MAKE INTERFACES FOR SOME OF THE I/O OR AT LEAST SWITCH TO STRUCTS
//TO DO: MAKE RESET SYNCHRONOUS HIGH FOR FPGA

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
  // Local wires
  // -------------------------------------------------------------------------
  logic                                             add_ready;
  logic                                             add_valid;
  dice_cta_desc_t                                   add_cta_info;
  logic             [           DICE_TID_WIDTH-1:0] add_cta_size;
  logic                                             pop_valid_int;
  logic             [     DICE_HW_CTA_ID_WIDTH-1:0] pop_hw_cta_id_int;
  logic                                             table_out_valid;
  logic                                             table_out_ready;
  dice_cta_id_t                                     table_out_cta_id;
  logic             [     DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index;
  active_cta_t      [DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries;

  dice_cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_zero;
  logic             [DICE_NUM_MAX_CTA_PER_CORE-1:0] bct_hw_cta_pending_zero;
  cta_status_t      [DICE_NUM_MAX_CTA_PER_CORE-1:0] scheduler_cta_status_zero;

  assign cta_status_zero                    = '0;
  assign bct_hw_cta_pending_zero            = '0;
  assign scheduler_cta_status_zero          = '0;
  assign status_table_bh_if.cta_status_data = '0;

  // SIMT stack update wiring
  logic simt_update_ready;
  assign simt_stack_update.update_ready = simt_update_ready;

  // -------------------------------------------------------------------------
  // CTA Controller
  // -------------------------------------------------------------------------
  cta_controller cta_controller_inst (
      .clk(clk),
      .rst(rst),
      .cta_add_valid(cta_add_valid),
      .cta_add_ready(cta_add_ready),
      .new_cta_all_desc(new_cta_all_desc),
      .cta_complete_valid(cta_complete_valid),
      .cta_complete_ready(cta_complete_ready),
      .cta_done_id(cta_done_id),
      .add_active_cta_valid(add_valid),
      .add_active_cta_ready(add_ready),
      .active_cta_table_desc(add_cta_info),
      .add_active_cta_hw_size(add_cta_size),
      .next_empty_cta_index(next_empty_cta_index),
      .pop_valid(pop_valid_int),
      .pop_hw_cta_id(pop_hw_cta_id_int),
      .pop_out_valid(table_out_valid),
      .pop_out_ready(table_out_ready),
      .pop_out_cta_id(table_out_cta_id),
      .active_cta_entries(active_cta_entries),
      .init_valid(  /* init to SIMT */),
      .init_hw_cta_id(  /* init to SIMT */),
      .init_hw_cta_size(  /* init to SIMT */),
      .init_pc(  /* init to SIMT */),
      .init_reconvergence_pc(  /* init to SIMT */),
      .init_ready(  /* init from SIMT */),
      .cta_status_table(),
      .clear_entry_valid(),
      .clear_entry_hw_id()
  );

  // -------------------------------------------------------------------------
  // Active CTA Table
  // -------------------------------------------------------------------------
  active_cta_table #(
      .THREAD_WIDTH(THREAD_WIDTH)
  ) active_cta_table_inst (
      .clk                 (clk),
      .rst                 (rst),
      .add_ready           (add_ready),
      .add_valid           (add_valid),
      .add_cta_info        (add_cta_info),
      .add_cta_size        (add_cta_size),
      .pop_valid           (pop_valid_int),
      .pop_hw_cta_id       (pop_hw_cta_id_int),
      .out_valid           (table_out_valid),
      .out_ready           (table_out_ready),
      .out_cta_id          (table_out_cta_id),
      .out_cta_size        (),
      .out_kernel_id       (),
      .active_cta_entries  (active_cta_entries),
      .full                (),
      .next_empty_cta_index(next_empty_cta_index)
  );


  // -------------------------------------------------------------------------
  // CTA Scheduler
  // -------------------------------------------------------------------------
  cta_scheduler #(
      .MAX_EBLOCK(DICE_NUM_MAX_CTA_PER_CORE + 4)
  ) cta_scheduler_inst (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .active_cta_entries(active_cta_entries),
      .cta_status_entries(scheduler_cta_status_zero),
      .cta_next_pc(stack_top_next_pc),
      .stack_top_active_mask(stack_top_active_mask),
      .eblock_commit_valid(1'b0),
      .eblock_commit_id('0),
      .scheduled_eblock(schedule_if)
  );


  // -------------------------------------------------------------------------
  // CTA Status Table
  // -------------------------------------------------------------------------
  cta_status_table cta_status_table_inst (
      .clk(clk),
      .rst(rst),
      .branch_predict_info(status_table_bh_if.bh_data),
      .branch_predict_info_write_enable(status_table_bh_if.branch_predict_info_write_enable),
      .brt_info(),
      .brt_info_write_enable(),
      .clear_entry_valid(),  // TODO: hook up controller clear path when available
      .clear_entry_hw_id(),  // TODO: hook up controller clear path when available
      .cta_status()  // TODO: type mismatch vs scheduler/controller; leave unconnected
  );


  // -------------------------------------------------------------------------
  // SIMT Stack Controller - FIX RESET
  // -------------------------------------------------------------------------
  simt_stack_controller #(
      .STACK_DEPTH (STACK_DEPTH),
      .PC_WIDTH    (PC_WIDTH),
      .THREAD_WIDTH(THREAD_WIDTH),
      .NUM_STACK   (NUM_STACK)
  ) simt_stack_controller_inst (
      .clk(clk),
      .rst_n(~rst),
      .hw_cta_id(),  // TODO: needs hw_cta_id from execution pipeline
      .hw_cta_size(),  // TODO: needs hw_cta_size from execution pipeline
      .update_valid(simt_stack_update.update_valid),
      .update_with_divergence(simt_stack_update.update_stack_data.update_with_divergence),
      .update_next_pc(simt_stack_update.update_stack_data.update_next_pc),
      .predicate_regs_value(simt_stack_update.update_stack_data.predicate_regs_value),
      .branch_not_taken_pc(simt_stack_update.update_stack_data.branch_not_taken_pc),
      .branch_reconvergence_pc(simt_stack_update.update_stack_data.branch_reconvergence_pc),
      .update_ready(simt_update_ready),
      .init_valid(  /* from CTA controller */),
      .init_hw_cta_id(  /* from CTA controller */),
      .init_hw_cta_size(  /* from CTA controller */),
      .init_pc(  /* from CTA controller */),
      .init_reconvergence_pc(  /* from CTA controller */),
      .init_ready(  /* back to CTA controller */),
      .stack_top_valid(stack_top_valid),
      .stack_top_next_pc(stack_top_next_pc),
      .stack_top_reconvergence_pc(stack_top_reconvergence_pc),
      .stack_top_active_mask(stack_top_active_mask),
      .stack_empty(stack_empty),
      .stack_full(stack_full)
  );


endmodule

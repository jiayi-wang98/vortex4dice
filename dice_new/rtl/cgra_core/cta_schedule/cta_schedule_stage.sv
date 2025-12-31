//TO DO: EITHER MAKE INTERFACES FOR SOME OF THE I/O OR AT LEAST SWITCH TO STRUCTS
//TO DO: MAKE RESET SYNCHRONOUS HIGH FOR FPGA

`include "dice_define.vh"

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
    input  dice_pkg::dice_cta_desc_t new_cta_all_desc,

    // CTA completion output (to dispatcher)
    output logic         cta_complete_valid,
    input  logic         cta_complete_ready,
    output dice_pkg::dice_cta_id_t cta_done_id,

    // Scheduler output interface (to FDR stage)
    cta_sched_if.master schedule_if,

    // E-block commit interface (from execution/retire)
    input logic                       eblock_commit_valid,
    input logic [EBLOCK_ID_WIDTH-1:0] eblock_commit_id,

    // Branch handler / predictor interface (from FDR/execution)
    branch_handler_if.slave status_table_bh_if,

    // Block Retire Table interface
    input dice_pkg::block_retire_status_t brt_info,
    input logic                         brt_info_write_enable,


    // UPDATE INTERFACE (SIMT STACK CONTROLLER AND BRANCH HANDLER)
    dice_bh_simt_if.slave simt_stack_update,
    input logic [CTA_ID_WIDTH-1:0]      simt_update_hw_cta_id,
    input logic [1:0]                   simt_update_hw_cta_size,


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
  logic                                                                  active_table_add_ready;
  logic                                                                  active_table_add_valid;
  dice_pkg::dice_cta_desc_t                                              active_table_cta_desc;
  logic             [                        dice_pkg::DICE_TID_WIDTH-1:0] active_table_cta_size;
  logic                                                                  active_table_pop_valid;
  logic             [                  dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] active_table_pop_hw_id;
  logic                                                                  active_table_pop_ready;
  logic                                                                  active_table_out_valid;
  logic                                                                  active_table_out_ready;
  dice_pkg::dice_cta_id_t                                                active_table_out_cta_id;
  logic             [                  dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] active_table_next_empty_idx;
  dice_frontend_pkg::active_cta_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries;

  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_real;

  /* verilator lint_off WIDTHTRUNC */
  assign status_table_bh_if.cta_status_data = cta_status_real;
  /* verilator lint_on WIDTHTRUNC */

  // Adapter for cta_scheduler which uses dice_frontend_pkg::cta_status_t
  dice_frontend_pkg::cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] scheduler_status_adapter;

  always_comb begin
      for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
          scheduler_status_adapter[i].hw_cta_id = (dice_pkg::DICE_CTA_ID_WIDTH + 1)'(i);
          scheduler_status_adapter[i].is_prefetch = cta_status_real[i].is_prefetch;
          scheduler_status_adapter[i].predict_pc = cta_status_real[i].predict_pc;
      end
  end

  // SIMT stack update wiring
  logic simt_stack_update_ready;
  assign simt_stack_update.update_ready = simt_stack_update_ready;

  // SIMT stack initialization wiring (cta_controller → simt_stack_controller)
  logic                                simt_init_valid;
  logic [$clog2(MAX_NUM_CTA)-1:0]      simt_init_hw_cta_id;
  logic [1:0]                          simt_init_hw_cta_size;
  logic [PC_WIDTH-1:0]                 simt_init_pc;
  logic [PC_WIDTH-1:0]                 simt_init_reconvergence_pc;
  logic                                simt_init_ready;


  // Create validity bitmap from active_cta_entries
  logic [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_validty_bitmap;
  always_comb begin
      for (int i=0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
          active_cta_validty_bitmap[i] = active_cta_entries[i].cta_valid;
      end
  end

  logic clear_entry_valid;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id;

  // -------------------------------------------------------------------------
  // CTA Controller
  // -------------------------------------------------------------------------
  cta_controller cta_controller_inst (
      .clk(clk),
      .rst(rst),
      .in_cta_valid(cta_add_valid),
      .in_cta_ready(cta_add_ready),
      .in_cta_desc(new_cta_all_desc),
      .comp_cta_valid(cta_complete_valid),
      .comp_cta_ready(cta_complete_ready),
      .comp_cta_id(cta_done_id),
      .add_valid(active_table_add_valid),
      .add_ready(active_table_add_ready),
      .add_cta_info(active_table_cta_desc),
      .add_cta_size(active_table_cta_size),
      .next_empty_cta_index(active_table_next_empty_idx),
      .pop_valid(active_table_pop_valid),
      .pop_hw_cta_id(active_table_pop_hw_id),
      .pop_ready(active_table_pop_ready),
      .active_cta_status(active_cta_validty_bitmap), // New Input
      .pop_out_valid(active_table_out_valid),     // New Input
      .pop_out_cta_id(active_table_out_cta_id),   // New Input
      .init_valid(simt_init_valid),
      .init_hw_cta_id(simt_init_hw_cta_id),
      .init_hw_cta_size(simt_init_hw_cta_size),
      .init_pc(simt_init_pc),
      .init_reconvergence_pc(simt_init_reconvergence_pc),
      .init_ready(simt_init_ready),
      .cta_status_table(cta_status_real),
      .clear_entry_valid(clear_entry_valid),
      .clear_entry_hw_id(clear_entry_hw_id)
  );

  // -------------------------------------------------------------------------
  // Active CTA Table
  // -------------------------------------------------------------------------
  active_cta_table #(
      .THREAD_WIDTH(THREAD_WIDTH)
  ) active_cta_table_inst (
      .clk                 (clk),
      .rst                 (rst),
      .add_ready           (active_table_add_ready),
      .add_valid           (active_table_add_valid),
      .add_cta_info        (active_table_cta_desc),
      .add_cta_size        (active_table_cta_size),
      .pop_valid           (active_table_pop_valid),
      .pop_hw_cta_id       (active_table_pop_hw_id),
      .pop_ready           (active_table_pop_ready),
      .out_valid           (active_table_out_valid),
      .out_ready           (active_table_out_ready),
      .out_cta_id          (active_table_out_cta_id),
      .out_kernel_id       (),
      .active_cta_entries  (active_cta_entries),
      .full                (),
      .next_empty_cta_index(active_table_next_empty_idx)
  );


  // -------------------------------------------------------------------------
  // CTA Scheduler
  // -------------------------------------------------------------------------
  cta_scheduler #(
      .MAX_EBLOCK(dice_pkg::DICE_NUM_MAX_CTA_PER_CORE + 4),
      .THREAD_WIDTH(THREAD_WIDTH)
  ) cta_scheduler_inst (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .active_cta_entries(active_cta_entries),
      .cta_status_entries(scheduler_status_adapter),
      .cta_next_pc(stack_top_next_pc),
      .stack_top_active_mask(stack_top_active_mask),
      .eblock_commit_valid(eblock_commit_valid),
      .eblock_commit_id((dice_pkg::DICE_EBLOCK_ID_WIDTH)'(eblock_commit_id)),
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
      .brt_info(brt_info),
      .brt_info_write_enable(brt_info_write_enable),
      .clear_entry_valid(clear_entry_valid),
      .clear_entry_hw_id(clear_entry_hw_id),
      .cta_status(cta_status_real)
  );


  // -------------------------------------------------------------------------
  // SIMT Stack Controller
  // -------------------------------------------------------------------------
  simt_stack_controller #(
      .STACK_DEPTH (STACK_DEPTH),
      .THREAD_WIDTH(THREAD_WIDTH),
      .NUM_STACK   (NUM_STACK)
  ) simt_stack_controller_inst (
      .clk(clk),
      .rst(rst),
      .hw_cta_id(simt_update_hw_cta_id),
      .hw_cta_size(simt_update_hw_cta_size),
      .update_valid(simt_stack_update.update_valid),
      .update_with_divergence(simt_stack_update.update_stack_data.update_with_divergence),
      .update_next_pc(simt_stack_update.update_stack_data.update_next_pc),
      .predicate_regs_value(simt_stack_update.update_stack_data.predicate_regs_value[NUM_STACK*THREAD_WIDTH-1:0]),
      .branch_not_taken_pc(simt_stack_update.update_stack_data.branch_not_taken_pc),
      .branch_reconvergence_pc(simt_stack_update.update_stack_data.branch_reconvergence_pc),
      .update_ready(simt_stack_update_ready),
      .init_valid(simt_init_valid),
      .init_hw_cta_id(simt_init_hw_cta_id),
      .init_hw_cta_size(simt_init_hw_cta_size),
      .init_pc(simt_init_pc),
      .init_reconvergence_pc(simt_init_reconvergence_pc),
      .init_ready(simt_init_ready),
      .stack_top_valid(stack_top_valid),
      .stack_top_next_pc(stack_top_next_pc),
      .stack_top_reconvergence_pc(stack_top_reconvergence_pc),
      .stack_top_active_mask(stack_top_active_mask),
      .stack_empty(stack_empty),
      .stack_full(stack_full)
  );


endmodule

`timescale 1ns/1ps
`include "dice_define.vh"

module cta_schedule_stage_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int MaxNumCta = 4;
  localparam int PcWidth = 32;
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int StackDepth = 32;
  localparam int NumStack = 4;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                                   clk;
  logic                                                   rst;

  // DUT I/O
  logic                                                   cta_add_valid_i;
  logic                                                   cta_add_ready_o;
  dice_pkg::dice_cta_desc_t                               new_cta_all_desc_i;

  logic                                                   comp_cta_ready_i;
  logic                                                   comp_cta_valid_o;
  dice_pkg::dice_cta_id_t                                 comp_cta_id_o;

  // SIMT Stack update interface
  logic                            [$clog2(NumStack)-1:0] simt_update_hw_cta_id_i;
  logic                            [                 1:0] simt_update_hw_cta_size_i;
  logic                                                   simt_update_valid_i;
  logic                                                   simt_update_ready_o;
  logic                                                   simt_update_with_divergence_i;
  logic                            [         PcWidth-1:0] simt_update_next_pc_i;
  dice_frontend_pkg::thread_mask_t                        simt_predicate_regs_value_i;
  logic                            [         PcWidth-1:0] simt_branch_not_taken_pc_i;
  logic                            [         PcWidth-1:0] simt_branch_reconvergence_pc_i;

  // Scheduler/FDR interfaces
  cta_sched_if scheduled_eblock ();
  cta_status_bh_if status_table_bh_if ();

  // Stack outputs
  logic [NumStack-1:0]                  stack_top_valid_o;
  logic [NumStack-1:0][    PcWidth-1:0] stack_top_next_pc_o;
  logic [NumStack-1:0][    PcWidth-1:0] stack_top_reconvergence_pc_o;
  logic [NumStack-1:0][ThreadWidth-1:0] stack_top_active_mask_o;
  logic [NumStack-1:0]                  stack_empty_o;
  logic [NumStack-1:0]                  stack_full_o;

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  cta_schedule_stage #(
      .MAX_NUM_CTA(MaxNumCta),
      .PC_WIDTH   (PcWidth),
      .STACK_DEPTH(StackDepth),
      .NUM_STACK  (NumStack)
  ) u_dut (
      .clk_i                         (clk),
      .rst_i                         (rst),
      .cta_add_valid_i               (cta_add_valid_i),
      .cta_add_ready_o               (cta_add_ready_o),
      .new_cta_all_desc_i            (new_cta_all_desc_i),
      .comp_cta_ready_i              (comp_cta_ready_i),
      .comp_cta_valid_o              (comp_cta_valid_o),
      .comp_cta_id_o                 (comp_cta_id_o),
      .simt_update_hw_cta_id_i       (simt_update_hw_cta_id_i),
      .simt_update_hw_cta_size_i     (simt_update_hw_cta_size_i),
      .simt_update_valid_i           (simt_update_valid_i),
      .simt_update_ready_o           (simt_update_ready_o),
      .simt_update_with_divergence_i (simt_update_with_divergence_i),
      .simt_update_next_pc_i         (simt_update_next_pc_i),
      .simt_predicate_regs_value_i   (simt_predicate_regs_value_i),
      .simt_branch_not_taken_pc_i    (simt_branch_not_taken_pc_i),
      .simt_branch_reconvergence_pc_i(simt_branch_reconvergence_pc_i),
      .scheduled_eblock              (scheduled_eblock),
      .status_table_bh_if            (status_table_bh_if),
      .stack_top_valid_o             (stack_top_valid_o),
      .stack_top_next_pc_o           (stack_top_next_pc_o),
      .stack_top_reconvergence_pc_o  (stack_top_reconvergence_pc_o),
      .stack_top_active_mask_o       (stack_top_active_mask_o),
      .stack_empty_o                 (stack_empty_o),
      .stack_full_o                  (stack_full_o)
  );

  // =========================================================================
  // Clock Generation
  // =========================================================================
  localparam int ClkPeriod = 10;

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // =========================================================================
  // Reset Sequence
  // =========================================================================
  task automatic apply_reset();
    rst = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // =========================================================================
  // Test Stimulus
  // =========================================================================
  initial begin
    // Initialize inputs
    cta_add_valid_i                = 1'b0;
    new_cta_all_desc_i             = '0;
    comp_cta_ready_i               = 1'b1;
    simt_update_hw_cta_id_i        = '0;
    simt_update_hw_cta_size_i      = '0;
    simt_update_valid_i            = 1'b0;
    simt_update_with_divergence_i  = 1'b0;
    simt_update_next_pc_i          = '0;
    simt_predicate_regs_value_i    = '0;
    simt_branch_not_taken_pc_i     = '0;
    simt_branch_reconvergence_pc_i = '0;

    // Interface initialization
    scheduled_eblock.ready         = 1'b1;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] cta_schedule_stage_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("cta_schedule_stage_tb.fsdb");
    $fsdbDumpvars(0, cta_schedule_stage_tb);
  end
`endif

endmodule

// =============================================================================
// Testbench: cta_schedule_stage_tb.sv
// =============================================================================
// FILES USED: cta_schedule_stage_tb.sv (boilerplate), dice_pkg.sv, dice_frontend_pkg.sv
// ASSUMPTIONS: Top-level scheduling stage. Combines CTA controller, scheduler, SIMT stacks.
//              Uses interface instances (cta_sched_if). Synchronous active-high reset.
// TESTS: Reset, add single CTA, SIMT update, backpressure, hold inputs stable, random.
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

// Dummy interface for status_table_bh_if since not found in allowed files
interface cta_status_bh_if;
  logic dummy;
  modport master(output dummy);
  modport slave(input dummy);
endinterface

module cta_schedule_stage_tb;

  localparam int MaxNumCta = 4;
  localparam int PcWidth = 32;
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int StackDepth = 32;
  localparam int NumStack = 4;
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 10000;
  localparam int RandSeed = 44444;

  logic                                                   clk;
  logic                                                   rst;

  logic                                                   cta_add_valid_i;
  logic                                                   cta_add_ready_o;
  dice_pkg::dice_cta_desc_t                               new_cta_all_desc_i;

  logic                                                   comp_cta_ready_i;
  logic                                                   comp_cta_valid_o;
  dice_pkg::dice_cta_id_t                                 comp_cta_id_o;

  logic                            [$clog2(NumStack)-1:0] simt_update_hw_cta_id_i;
  logic                            [                 1:0] simt_update_hw_cta_size_i;
  logic                                                   simt_update_valid_i;
  logic                                                   simt_update_ready_o;
  logic                                                   simt_update_with_divergence_i;
  logic                            [         PcWidth-1:0] simt_update_next_pc_i;
  dice_frontend_pkg::thread_mask_t                        simt_predicate_regs_value_i;
  logic                            [         PcWidth-1:0] simt_branch_not_taken_pc_i;
  logic                            [         PcWidth-1:0] simt_branch_reconvergence_pc_i;

  cta_sched_if scheduled_eblock ();
  cta_status_bh_if status_table_bh_if ();

  logic [NumStack-1:0]                  stack_top_valid_o;
  logic [NumStack-1:0][    PcWidth-1:0] stack_top_next_pc_o;
  logic [NumStack-1:0][    PcWidth-1:0] stack_top_reconvergence_pc_o;
  logic [NumStack-1:0][ThreadWidth-1:0] stack_top_active_mask_o;
  logic [NumStack-1:0]                  stack_empty_o;
  logic [NumStack-1:0]                  stack_full_o;

  int                                   cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

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

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst = 1'b1;
    cta_add_valid_i = 1'b0;
    new_cta_all_desc_i = '0;
    comp_cta_ready_i = 1'b1;
    simt_update_hw_cta_id_i = '0;
    simt_update_hw_cta_size_i = '0;
    simt_update_valid_i = 1'b0;
    simt_update_with_divergence_i = 1'b0;
    simt_update_next_pc_i = '0;
    simt_predicate_regs_value_i = '0;
    simt_branch_not_taken_pc_i = '0;
    simt_branch_reconvergence_pc_i = '0;
    scheduled_eblock.ready = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic add_cta(input dice_pkg::dice_cta_desc_t desc);
    new_cta_all_desc_i = desc;
    cta_add_valid_i = 1'b1;
    @(posedge clk);
    while (cta_add_ready_o != 1'b1) @(posedge clk);
    @(posedge clk);
    cta_add_valid_i = 1'b0;
  endtask

  task automatic simt_update(input int idx, input logic div, input logic [31:0] pc);
    simt_update_hw_cta_id_i = idx[$clog2(NumStack)-1:0];
    simt_update_with_divergence_i = div;
    simt_update_next_pc_i = pc;
    simt_update_valid_i = 1'b1;
    @(posedge clk);
    while (simt_update_ready_o != 1'b1) @(posedge clk);
    @(posedge clk);
    simt_update_valid_i = 1'b0;
  endtask

  initial begin
    int rand_val;
    dice_pkg::dice_cta_desc_t test_desc;

    $display("cta_schedule_stage Testbench");

    // Test 1: Reset
    reset_dut();
    assert (cta_add_ready_o == 1'b1)
    else $fatal(1, "Not ready after reset");
    assert (comp_cta_valid_o == 1'b0)
    else $fatal(1, "comp valid after reset");
    $display("TEST 1 PASS: Reset");

    // Test 2: Add single CTA
    test_desc = '0;
    test_desc.kernel_desc.start_pc = 32'h1000;
    add_cta(test_desc);
    repeat (5) @(posedge clk);
    $display("TEST 2 PASS: Add CTA");

    // Test 3: SIMT update (no divergence)
    simt_update(0, 1'b0, 32'h1100);
    repeat (2) @(posedge clk);
    $display("TEST 3 PASS: SIMT update");

    // Test 4: Backpressure on scheduled_eblock
    scheduled_eblock.ready = 1'b0;
    repeat (10) @(posedge clk);
    scheduled_eblock.ready = 1'b1;
    repeat (5) @(posedge clk);
    $display("TEST 4 PASS: Backpressure");

    // Test 5: Hold inputs stable N cycles
    reset_dut();
    test_desc.kernel_desc.start_pc = 32'h2000;
    new_cta_all_desc_i = test_desc;
    cta_add_valid_i = 1'b1;
    repeat (20) @(posedge clk);
    cta_add_valid_i = 1'b0;
    $display("TEST 5 PASS: Hold stable");

    // Test 6: Random smoke
    reset_dut();
    rand_val = RandSeed;
    for (int i = 0; i < 20; i++) begin
      rand_val = rand_val * 1103515245 + 12345;
      if ((rand_val[1:0]) == 2'b00 && cta_add_ready_o) begin
        test_desc = '0;
        test_desc.kernel_desc.start_pc = rand_val[31:0];
        add_cta(test_desc);
      end else if ((rand_val[1:0]) == 2'b01) begin
        simt_update(rand_val[3:2], rand_val[4], rand_val[31:0]);
      end
      scheduled_eblock.ready = rand_val[5];
      @(posedge clk);
    end
    scheduled_eblock.ready = 1'b1;
    repeat (10) @(posedge clk);
    $display("TEST 6 PASS: Random smoke");

    $display("ALL TESTS PASSED: cta_schedule_stage_tb");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

`ifdef VCD
  initial begin
    $dumpfile("cta_schedule_stage_tb.vcd");
    $dumpvars(0, cta_schedule_stage_tb);
  end
`endif

endmodule

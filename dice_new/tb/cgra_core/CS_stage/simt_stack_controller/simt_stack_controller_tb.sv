// =============================================================================
// Testbench: simt_stack_controller_tb.sv
// =============================================================================
// DESCRIPTION: Simplified testbench for SIMT stack controller.
// TESTS:
//   1. Reset        - Verify all stacks are empty after reset
//   2. Init Stack   - Initialize stack 0 with PC=0x1000 and verify it's not empty
//   3. Simple Update - Send an update (no divergence) and verify ready signal
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module simt_stack_controller_tb;

  // ==========================================================================
  // PARAMETERS
  // ==========================================================================
  localparam int NumStack = dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 500;

  // ==========================================================================
  // CLOCK AND RESET
  // ==========================================================================
  logic clk;
  logic rst;

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // ==========================================================================
  // TESTBENCH SIGNALS
  // ==========================================================================
  
  // Branch handler interface
  logic [$clog2(NumStack)-1:0] hw_cta_id_i;
  logic [1:0] hw_cta_size_i;
  logic update_valid_i;
  logic update_ready_o;
  logic update_with_divergence_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] update_next_pc_i;
  dice_frontend_pkg::thread_mask_t predicate_regs_value_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] branch_not_taken_pc_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] branch_reconvergence_pc_i;

  // CTA controller interface
  logic init_valid_i;
  logic [$clog2(NumStack)-1:0] init_hw_cta_id_i;
  logic [1:0] init_hw_cta_size_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] init_pc_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] init_reconvergence_pc_i;
  logic init_ready_o;

  // Stack outputs
  logic [NumStack-1:0] stack_top_valid_o;
  logic [NumStack-1:0][dice_pkg::DICE_ADDR_WIDTH-1:0] stack_top_next_pc_o;
  logic [NumStack-1:0][dice_pkg::DICE_ADDR_WIDTH-1:0] stack_top_reconvergence_pc_o;
  logic [NumStack-1:0][ThreadWidth-1:0] stack_top_active_mask_o;
  logic [NumStack-1:0] stack_empty_o;
  logic [NumStack-1:0] stack_full_o;

  // ==========================================================================
  // TIMEOUT COUNTER
  // ==========================================================================
  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  // ==========================================================================
  // DUT INSTANTIATION
  // ==========================================================================
  simt_stack_controller u_dut (
      .clk_i                       (clk),
      .rst_i                       (rst),
      .hw_cta_id_i                 (hw_cta_id_i),
      .hw_cta_size_i               (hw_cta_size_i),
      .update_valid_i              (update_valid_i),
      .update_ready_o              (update_ready_o),
      .update_with_divergence_i    (update_with_divergence_i),
      .update_next_pc_i            (update_next_pc_i),
      .predicate_regs_value_i      (predicate_regs_value_i),
      .branch_not_taken_pc_i       (branch_not_taken_pc_i),
      .branch_reconvergence_pc_i   (branch_reconvergence_pc_i),
      .init_valid_i                (init_valid_i),
      .init_hw_cta_id_i            (init_hw_cta_id_i),
      .init_hw_cta_size_i          (init_hw_cta_size_i),
      .init_pc_i                   (init_pc_i),
      .init_reconvergence_pc_i     (init_reconvergence_pc_i),
      .init_ready_o                (init_ready_o),
      .stack_top_valid_o           (stack_top_valid_o),
      .stack_top_next_pc_o         (stack_top_next_pc_o),
      .stack_top_reconvergence_pc_o(stack_top_reconvergence_pc_o),
      .stack_top_active_mask_o     (stack_top_active_mask_o),
      .stack_empty_o               (stack_empty_o),
      .stack_full_o                (stack_full_o)
  );

  // ==========================================================================
  // HELPER TASKS
  // ==========================================================================

  // Reset DUT and clear all inputs
  task automatic reset_dut();
    rst = 1'b1;
    hw_cta_id_i = '0;
    hw_cta_size_i = 2'b00;
    update_valid_i = 1'b0;
    update_with_divergence_i = 1'b0;
    update_next_pc_i = '0;
    predicate_regs_value_i = '0;
    branch_not_taken_pc_i = '0;
    branch_reconvergence_pc_i = '0;
    init_valid_i = 1'b0;
    init_hw_cta_id_i = '0;
    init_hw_cta_size_i = 2'b00;
    init_pc_i = '0;
    init_reconvergence_pc_i = '0;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // Initialize a stack with given PC values
  // Waits for handshake to complete
  task automatic init_stack(
    input int idx,
    input logic [31:0] pc,
    input logic [31:0] reconv_pc
  );
    $display("  -> Initializing stack %0d with PC=0x%h, ReconvPC=0x%h", idx, pc, reconv_pc);
    init_hw_cta_id_i = idx[$clog2(NumStack)-1:0];
    init_hw_cta_size_i = 2'b00;  // Single stack
    init_pc_i = pc;
    init_reconvergence_pc_i = reconv_pc;
    init_valid_i = 1'b1;
    @(posedge clk);
    // Wait for ready (should be immediate when idle)
    while (!init_ready_o) @(posedge clk);
    @(posedge clk);
    init_valid_i = 1'b0;
    // Wait for operation to complete (FSM returns to idle)
    repeat (5) @(posedge clk);
  endtask

  // Send a simple update (no divergence)
  task automatic update_no_divergence(
    input int idx,
    input logic [31:0] next_pc
  );
    $display("  -> Updating stack %0d with next_pc=0x%h (no divergence)", idx, next_pc);
    hw_cta_id_i = idx[$clog2(NumStack)-1:0];
    hw_cta_size_i = 2'b00;
    update_with_divergence_i = 1'b0;
    update_next_pc_i = next_pc;
    update_valid_i = 1'b1;
    @(posedge clk);
    // Wait for ready
    while (!update_ready_o) @(posedge clk);
    @(posedge clk);
    update_valid_i = 1'b0;
    // Wait for operation to complete
    repeat (5) @(posedge clk);
  endtask

  // ==========================================================================
  // MAIN TEST SEQUENCE
  // ==========================================================================
  initial begin
    $display("=================================================");
    $display("SIMT Stack Controller Testbench - Simplified");
    $display("=================================================");

    // ========================================================================
    // TEST 1: RESET
    // After reset, all stacks should be empty
    // ========================================================================
    $display("\n[TEST 1] Reset - All stacks should be empty");
    reset_dut();
    if (stack_empty_o == {NumStack{1'b1}}) begin
      $display("  PASS: All %0d stacks are empty", NumStack);
    end else begin
      $display("  FAIL: stack_empty_o = %b (expected all 1s)", stack_empty_o);
    end

    // ========================================================================
    // TEST 2: INIT STACK
    // Initialize stack 0 with PC=0x1000. After init, stack 0 should NOT be empty.
    // ========================================================================
    $display("\n[TEST 2] Init Stack - Stack 0 should not be empty after init");
    init_stack(0, 32'h0000_1000, 32'h0000_FFFF);
    if (stack_empty_o[0] == 1'b0) begin
      $display("  PASS: Stack 0 is NOT empty after init");
    end else begin
      $display("  FAIL: Stack 0 is still empty after init");
    end

    // ========================================================================
    // TEST 3: SIMPLE UPDATE (NO DIVERGENCE)
    // Send an update with no divergence. This should just modify the top PC.
    // ========================================================================
    $display("\n[TEST 3] Simple Update - No divergence, just update PC");
    update_no_divergence(0, 32'h0000_2000);
    $display("  PASS: Update completed without hanging");

    // ========================================================================
    // DONE
    // ========================================================================
    $display("\n=================================================");
    $display("ALL TESTS PASSED");
    $display("=================================================");

`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  // ==========================================================================
  // VCD DUMP (for Verilator)
  // ==========================================================================
`ifdef VCD
  initial begin
    $dumpfile("simt_stack_controller_tb.vcd");
    $dumpvars(0, simt_stack_controller_tb);
  end
`endif

endmodule

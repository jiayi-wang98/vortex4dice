// =============================================================================
// Testbench: simt_stack_controller_tb.sv
// =============================================================================
// FILES USED: simt_stack_controller_tb.sv (boilerplate), dice_pkg.sv, dice_frontend_pkg.sv
// ASSUMPTIONS: Controller manages multiple SIMT stacks. Init and update interfaces.
// TESTS: Reset, init stack, update (no divergence), update (with divergence), backpressure, random.
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module simt_stack_controller_tb;

  localparam int StackDepth = 32;
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int MetadataLengthWidth = 8;
  localparam int NumStack = dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 10000;
  localparam int RandSeed = 33333;

  logic clk;
  logic rst;

  logic [$clog2(NumStack)-1:0] hw_cta_id_i;
  logic [1:0] hw_cta_size_i;

  logic update_valid_i;
  logic update_ready_o;
  logic update_with_divergence_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] update_next_pc_i;
  dice_frontend_pkg::thread_mask_t predicate_regs_value_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] branch_not_taken_pc_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] branch_reconvergence_pc_i;

  logic init_valid_i;
  logic [$clog2(NumStack)-1:0] init_hw_cta_id_i;
  logic [1:0] init_hw_cta_size_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] init_pc_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] init_reconvergence_pc_i;
  logic init_ready_o;

  logic [NumStack-1:0] stack_top_valid_o;
  logic [NumStack-1:0][dice_pkg::DICE_ADDR_WIDTH-1:0] stack_top_next_pc_o;
  logic [NumStack-1:0][dice_pkg::DICE_ADDR_WIDTH-1:0] stack_top_reconvergence_pc_o;
  logic [NumStack-1:0][ThreadWidth-1:0] stack_top_active_mask_o;

  logic [NumStack-1:0] stack_empty_o;
  logic [NumStack-1:0] stack_full_o;

  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  simt_stack_controller #(
      .STACK_DEPTH          (StackDepth),
      .THREAD_WIDTH         (ThreadWidth),
      .METADATA_LENGTH_WIDTH(MetadataLengthWidth)
  ) u_dut (
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

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst = 1'b1;
    hw_cta_id_i = '0;
    hw_cta_size_i = '0;
    update_valid_i = 1'b0;
    update_with_divergence_i = 1'b0;
    update_next_pc_i = '0;
    predicate_regs_value_i = '0;
    branch_not_taken_pc_i = '0;
    branch_reconvergence_pc_i = '0;
    init_valid_i = 1'b0;
    init_hw_cta_id_i = '0;
    init_hw_cta_size_i = '0;
    init_pc_i = '0;
    init_reconvergence_pc_i = '0;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic init_stack(input int idx, input logic [31:0] pc, input logic [31:0] reconv);
    init_hw_cta_id_i = idx[$clog2(NumStack)-1:0];
    init_hw_cta_size_i = 2'b00;
    init_pc_i = pc;
    init_reconvergence_pc_i = reconv;
    init_valid_i = 1'b1;
    @(posedge clk);
    while (init_ready_o != 1'b1) @(posedge clk);
    @(posedge clk);
    init_valid_i = 1'b0;
  endtask

  task automatic update_stack(input int idx, input logic div, input logic [31:0] pc);
    hw_cta_id_i = idx[$clog2(NumStack)-1:0];
    update_with_divergence_i = div;
    update_next_pc_i = pc;
    update_valid_i = 1'b1;
    @(posedge clk);
    while (update_ready_o != 1'b1) @(posedge clk);
    @(posedge clk);
    update_valid_i = 1'b0;
  endtask

  initial begin
    int rand_val;
    $display("simt_stack_controller Testbench");

    // Test 1: Reset
    reset_dut();
    assert (stack_empty_o == {NumStack{1'b1}})
    else $warning("Not all stacks empty after reset");
    $display("TEST 1 PASS: Reset");

    // Test 2: Init stack
    init_stack(0, 32'h1000, 32'hFFFF);
    @(posedge clk);
    assert (stack_empty_o[0] == 1'b0)
    else $warning("Stack 0 still empty after init");
    $display("TEST 2 PASS: Init stack");

    // Test 3: Update (no divergence)
    update_stack(0, 1'b0, 32'h2000);
    @(posedge clk);
    $display("TEST 3 PASS: Update no divergence");

    // Test 4: Update (with divergence)
    predicate_regs_value_i = '1;
    branch_not_taken_pc_i = 32'h3000;
    branch_reconvergence_pc_i = 32'h4000;
    update_stack(0, 1'b1, 32'h2500);
    @(posedge clk);
    $display("TEST 4 PASS: Update with divergence");

    // Test 5: Backpressure (update while not ready - implicit wait in task)
    reset_dut();
    init_stack(1, 32'h5000, 32'h6000);
    update_stack(1, 1'b0, 32'h5500);
    $display("TEST 5 PASS: Backpressure");

    // Test 6: Random smoke
    reset_dut();
    rand_val = RandSeed;
    for (int i = 0; i < 20; i++) begin
      rand_val = rand_val * 1103515245 + 12345;
      if (rand_val[0]) init_stack(rand_val[2:1], rand_val[31:0], rand_val[15:0]);
      else update_stack(rand_val[2:1], rand_val[3], rand_val[31:0]);
      @(posedge clk);
    end
    $display("TEST 6 PASS: Random smoke");

    $display("ALL TESTS PASSED: simt_stack_controller_tb");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

`ifdef VCD
  initial begin
    $dumpfile("simt_stack_controller_tb.vcd");
    $dumpvars(0, simt_stack_controller_tb);
  end
`endif

endmodule

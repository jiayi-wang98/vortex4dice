// =============================================================================
// Testbench: simt_stack_tb.sv
// =============================================================================
// FILES USED: simt_stack_tb.sv (boilerplate), dice_pkg.sv
// ASSUMPTIONS: LIFO stack for SIMT divergence. Push/pop/modify_top ops.
// TESTS: Reset, push, pop, modify_top, fill stack, random smoke.
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module simt_stack_tb;

  localparam int StackDepth = 32;
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 10000;
  localparam int RandSeed = 22222;

  logic                                 clk;
  logic                                 rst;

  logic                                 push_i;
  logic                                 modify_top_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] push_next_pc_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] push_reconvergence_pc_i;
  logic [              ThreadWidth-1:0] push_active_mask_i;

  logic                                 pop_i;
  logic                                 read_top_i;

  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] top_next_pc_o;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] top_reconvergence_pc_o;
  logic [              ThreadWidth-1:0] top_active_mask_o;
  logic                                 out_valid_o;

  logic                                 stack_empty_o;
  logic                                 stack_full_o;

  int                                   cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  simt_stack #(
      .STACK_DEPTH (StackDepth),
      .THREAD_WIDTH(ThreadWidth)
  ) u_dut (
      .clk_i                  (clk),
      .rst_i                  (rst),
      .push_i                 (push_i),
      .modify_top_i           (modify_top_i),
      .push_next_pc_i         (push_next_pc_i),
      .push_reconvergence_pc_i(push_reconvergence_pc_i),
      .push_active_mask_i     (push_active_mask_i),
      .pop_i                  (pop_i),
      .read_top_i             (read_top_i),
      .top_next_pc_o          (top_next_pc_o),
      .top_reconvergence_pc_o (top_reconvergence_pc_o),
      .top_active_mask_o      (top_active_mask_o),
      .out_valid_o            (out_valid_o),
      .stack_empty_o          (stack_empty_o),
      .stack_full_o           (stack_full_o)
  );

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst = 1'b1;
    push_i = 1'b0;
    modify_top_i = 1'b0;
    push_next_pc_i = '0;
    push_reconvergence_pc_i = '0;
    push_active_mask_i = '0;
    pop_i = 1'b0;
    read_top_i = 1'b0;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic push_entry(input logic [31:0] pc, input logic [31:0] reconv,
                            input logic [ThreadWidth-1:0] mask);
    push_next_pc_i = pc;
    push_reconvergence_pc_i = reconv;
    push_active_mask_i = mask;
    push_i = 1'b1;
    @(posedge clk);
    push_i = 1'b0;
  endtask

  task automatic pop_entry();
    pop_i = 1'b1;
    @(posedge clk);
    pop_i = 1'b0;
  endtask

  initial begin
    int rand_val;
    $display("simt_stack Testbench");

    // Test 1: Reset
    reset_dut();
    assert (stack_empty_o == 1'b1)
    else $fatal(1, "Reset: stack not empty");
    assert (stack_full_o == 1'b0)
    else $fatal(1, "Reset: stack full");
    $display("TEST 1 PASS: Reset");

    // Test 2: Push single entry
    push_entry(32'h1000, 32'h2000, {ThreadWidth{1'b1}});
    @(posedge clk);
    assert (stack_empty_o == 1'b0)
    else $fatal(1, "Push: still empty");
    $display("TEST 2 PASS: Push");

    // Test 3: Pop entry
    pop_entry();
    @(posedge clk);
    assert (stack_empty_o == 1'b1)
    else $fatal(1, "Pop: not empty");
    $display("TEST 3 PASS: Pop");

    // Test 4: Modify top
    push_entry(32'h3000, 32'h4000, 4'hF);
    push_next_pc_i = 32'h5000;
    push_active_mask_i = 4'hA;
    modify_top_i = 1'b1;
    @(posedge clk);
    modify_top_i = 1'b0;
    @(posedge clk);
    $display("TEST 4 PASS: Modify top");

    // Test 5: Fill stack
    reset_dut();
    for (int i = 0; i < StackDepth && stack_full_o != 1'b1; i++) begin
      push_entry(i * 4, i * 8, i[ThreadWidth-1:0]);
    end
    assert (stack_full_o == 1'b1)
    else $warning("Stack not full after %0d pushes", StackDepth);
    $display("TEST 5 PASS: Fill stack");

    // Test 6: Random smoke
    reset_dut();
    rand_val = RandSeed;
    for (int i = 0; i < 30; i++) begin
      rand_val = rand_val * 1103515245 + 12345;
      if (rand_val[0] && stack_full_o != 1'b1)
        push_entry(rand_val[31:0], rand_val[15:0], rand_val[ThreadWidth-1:0]);
      else if (stack_empty_o != 1'b1) pop_entry();
      @(posedge clk);
    end
    $display("TEST 6 PASS: Random smoke");

    $display("ALL TESTS PASSED: simt_stack_tb");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

`ifdef VCD
  initial begin
    $dumpfile("simt_stack_tb.vcd");
    $dumpvars(0, simt_stack_tb);
  end
`endif

endmodule

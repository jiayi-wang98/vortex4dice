`timescale 1ns/1ps
`include "dice_define.vh"

module simt_stack_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int StackDepth = 32;
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                 clk;
  logic                                 rst;

  // DUT I/O
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

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
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
    push_i                  = 1'b0;
    modify_top_i            = 1'b0;
    push_next_pc_i          = '0;
    push_reconvergence_pc_i = '0;
    push_active_mask_i      = '0;
    pop_i                   = 1'b0;
    read_top_i              = 1'b0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] simt_stack_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("simt_stack_tb.fsdb");
    $fsdbDumpvars(0, simt_stack_tb);
  end
`endif

endmodule

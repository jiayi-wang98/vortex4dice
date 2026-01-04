`timescale 1ns/1ps
`include "dice_define.vh"

module simt_stack_controller_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int StackDepth = 32;
  localparam int ThreadWidth       = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                                     dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;
  localparam int MetadataLengthWidth = 8;
  localparam int NumStack = dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic clk;
  logic rst;

  // DUT I/O
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

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  simt_stack_controller #(
      .STACK_DEPTH          (StackDepth),
      .THREAD_WIDTH         (ThreadWidth),
      .METADATA_LENGTH_WIDTH(MetadataLengthWidth),
      .NUM_STACK            (NumStack)
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
    hw_cta_id_i               = '0;
    hw_cta_size_i             = '0;
    update_valid_i            = 1'b0;
    update_with_divergence_i  = 1'b0;
    update_next_pc_i          = '0;
    predicate_regs_value_i    = '0;
    branch_not_taken_pc_i     = '0;
    branch_reconvergence_pc_i = '0;
    init_valid_i              = 1'b0;
    init_hw_cta_id_i          = '0;
    init_hw_cta_size_i        = '0;
    init_pc_i                 = '0;
    init_reconvergence_pc_i   = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] simt_stack_controller_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("simt_stack_controller_tb.fsdb");
    $fsdbDumpvars(0, simt_stack_controller_tb);
  end
`endif

endmodule

`timescale 1ns / 1ps
`include "dice_define.vh"

module valid_check_tb;
  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                      clk;
  logic                                      rst;

  // DUT I/O
  logic                                      barrier_indicator_i;
  logic                                      mask_valid_i;
  logic [     dice_pkg::DICE_ADDR_WIDTH-1:0] eblock_pc_i;
  logic                                      prefetch_block_i;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id_i;
  logic [     dice_pkg::DICE_ADDR_WIDTH-1:0] simt_stack_pc_i;
  logic                                      bitstream_loaded_i;
  logic                                      unresolved_div_i;
  logic                                      barrier_complete_i;
  logic                                      prefetch_cleared_i;
  logic                                      fdr_valid_o;
  logic                                      ex_ready_i;
  logic                                      fire_eblock_o;
  logic                                      clear_prefetch_o;
  logic                                      predict_miss_o;

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  valid_check u_dut (
      .barrier_indicator_i(barrier_indicator_i),
      .mask_valid_i       (mask_valid_i),
      .eblock_pc_i        (eblock_pc_i),
      .prefetch_block_i   (prefetch_block_i),
      .hw_cta_id_i        (hw_cta_id_i),
      .simt_stack_pc_i    (simt_stack_pc_i),
      .bitstream_loaded_i (bitstream_loaded_i),
      .unresolved_div_i   (unresolved_div_i),
      .barrier_complete_i (barrier_complete_i),
      .prefetch_cleared_i (prefetch_cleared_i),
      .fdr_valid_o        (fdr_valid_o),
      .ex_ready_i         (ex_ready_i),
      .fire_eblock_o      (fire_eblock_o),
      .clear_prefetch_o   (clear_prefetch_o),
      .predict_miss_o     (predict_miss_o)
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
    barrier_indicator_i = 1'b0;
    mask_valid_i        = 1'b0;
    eblock_pc_i         = '0;
    prefetch_block_i    = 1'b0;
    hw_cta_id_i         = '0;
    simt_stack_pc_i     = '0;
    bitstream_loaded_i  = 1'b0;
    unresolved_div_i    = 1'b0;
    barrier_complete_i  = 1'b0;
    prefetch_cleared_i  = 1'b0;
    ex_ready_i          = 1'b0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] valid_check_tb: Test passed!", $time);
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("valid_check_tb.fsdb");
    $fsdbDumpvars(0, valid_check_tb);
  end
`endif

endmodule

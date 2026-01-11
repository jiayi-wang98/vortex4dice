// =============================================================================
// Testbench: valid_check_tb.sv
// =============================================================================
// Simple testbench for valid_check module (combinational).
// Tests:
//   1) All conditions met - fdr_valid_o should be high
//   2) Bitstream not loaded - fdr_valid_o should be low
//   3) PC mismatch on prefetch block - predict_miss_o should be high
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module valid_check_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // ===========================================================================
  // Parameters
  // ===========================================================================
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 100;

  // ===========================================================================
  // Clock and Reset
  // ===========================================================================
  logic clk;
  logic rst;

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // ===========================================================================
  // Timeout Counter
  // ===========================================================================
  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) begin
        $fatal(1, "[%0t] TIMEOUT: Test exceeded %0d cycles", $time, TimeoutCycles);
      end
    end
  end

  // ===========================================================================
  // DUT Signals
  // ===========================================================================
  logic                       barrier_indicator_i;
  logic                       decode_done_i; // Renamed from mask_valid_i
  logic [DICE_ADDR_WIDTH-1:0] eblock_pc_i; // Added missing declaration
  logic                       prefetch_block_i; // Added missing declaration
  // logic [DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id_i; // Removed
  logic [DICE_ADDR_WIDTH-1:0] simt_stack_pc_i;
  logic                       bitstream_loaded_i;
  logic                       unresolved_div_i;
  logic                       barrier_complete_i;
  logic                       prefetch_cleared_i;
  logic                       fdr_valid_o;
  logic                       ex_ready_i;
  logic                       fire_eblock_o;
  logic                       clear_prefetch_o;
  logic                       predict_miss_o;

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  valid_check u_dut (
      .barrier_indicator_i(barrier_indicator_i),
      .decode_done_i      (decode_done_i), // Renamed
      .eblock_pc_i        (eblock_pc_i),
      .prefetch_block_i   (prefetch_block_i),
      // .hw_cta_id_i        (hw_cta_id_i), // Removed
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

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================
  task automatic reset_dut();
    rst                 = 1'b1;
    barrier_indicator_i = 1'b0;
    barrier_indicator_i = 1'b0;
    decode_done_i       = 1'b0;
    eblock_pc_i         = '0;
    prefetch_block_i    = 1'b0;
    // hw_cta_id_i         = '0;
    simt_stack_pc_i     = '0;
    bitstream_loaded_i  = 1'b0;
    unresolved_div_i    = 1'b0;
    barrier_complete_i  = 1'b0;
    prefetch_cleared_i  = 1'b0;
    ex_ready_i          = 1'b0;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    $display("=============================================================");
    $display(" valid_check Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: All conditions met - fdr_valid should be high
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: All conditions met", $time);
    reset_dut();

    // Set all enabling conditions
    bitstream_loaded_i  = 1'b1;  // Bitstream loaded
    bitstream_loaded_i  = 1'b1;  // Bitstream loaded
    decode_done_i       = 1'b1;  // Decode done
    barrier_indicator_i = 1'b0;  // No barrier required
    prefetch_block_i    = 1'b0;  // Not a prefetch block
    unresolved_div_i    = 1'b0;  // No unresolved divergence
    ex_ready_i          = 1'b1;  // EX stage ready
    @(posedge clk);

    assert (fdr_valid_o == 1'b1)
    else $fatal(1, "FAIL: fdr_valid_o should be high when all conditions met");
    assert (fire_eblock_o == 1'b1)
    else $fatal(1, "FAIL: fire_eblock_o should be high (valid && ready)");
    $display("[%0t] PASS: All conditions met, fdr_valid_o=1, fire_eblock_o=1", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Bitstream not loaded - fdr_valid should be low
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Bitstream not loaded", $time);
    reset_dut();

    bitstream_loaded_i  = 1'b0;  // NOT loaded
    bitstream_loaded_i  = 1'b0;  // NOT loaded
    decode_done_i       = 1'b1;
    barrier_indicator_i = 1'b0;
    prefetch_block_i    = 1'b0;
    unresolved_div_i    = 1'b0;
    ex_ready_i          = 1'b1;
    @(posedge clk);

    assert (fdr_valid_o == 1'b0)
    else $fatal(1, "FAIL: fdr_valid_o should be 0 when bitstream not loaded");
    $display("[%0t] PASS: fdr_valid_o=0 when bitstream not loaded", $time);

    // -------------------------------------------------------------------------
    // TEST 3: PC mismatch on prefetch block - predict_miss should be high
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: PC mismatch on prefetch block", $time);
    reset_dut();

    bitstream_loaded_i  = 1'b1;
    bitstream_loaded_i  = 1'b1;
    decode_done_i       = 1'b1;
    prefetch_block_i    = 1'b1;  // IS a prefetch block
    prefetch_cleared_i  = 1'b0;  // Prefetch NOT cleared yet
    unresolved_div_i    = 1'b0;  // Divergence resolved
    eblock_pc_i         = 32'h1000;
    simt_stack_pc_i     = 32'h2000;  // MISMATCH
    @(posedge clk);

    assert (predict_miss_o == 1'b1)
    else $fatal(1, "FAIL: predict_miss_o should be 1 on PC mismatch");
    $display("[%0t] PASS: predict_miss_o=1 on PC mismatch", $time);

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: valid_check_tb");
    $display("=============================================================");

`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  // ===========================================================================
  // Waveform Dump
  // ===========================================================================
`ifdef VCD
  initial begin
    $dumpfile("valid_check_tb.vcd");
    $dumpvars(0, valid_check_tb);
  end
`endif

endmodule

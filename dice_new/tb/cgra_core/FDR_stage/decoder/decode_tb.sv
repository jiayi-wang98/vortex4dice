// =============================================================================
// Testbench: decode_tb.sv
// =============================================================================
// Simple testbench for decode module (combinational).
// Tests:
//   1) Reset/idle state - outputs zero when input not valid
//   2) Bitstream address passthrough
//   3) Branch metadata passthrough
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module decode_tb;
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
  pgraph_meta_t                      metadata_i;
  logic                              meta_in_valid_i;
  thread_mask_t                      real_active_thread_mask_i;
  logic [DICE_ADDR_WIDTH-1:0]        bitstream_addr_o;
  logic                              bitstream_addr_valid_o;
  logic [BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length_o;
  branch_meta_t                      branch_metadata_o;
  logic                              branch_req_valid_o;
  logic                              is_barrier_o;
  fdr_meta_t                         meta_o;

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  decode u_dut (
      .metadata_i               (metadata_i),
      .meta_in_valid_i          (meta_in_valid_i),
      .real_active_thread_mask_i(real_active_thread_mask_i),
      .bitstream_addr_o         (bitstream_addr_o),
      .bitstream_addr_valid_o   (bitstream_addr_valid_o),
      .bitstream_length_o       (bitstream_length_o),
      .branch_metadata_o        (branch_metadata_o),
      .branch_req_valid_o       (branch_req_valid_o),
      .is_barrier_o             (is_barrier_o),
      .meta_o                   (meta_o)
  );

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================
  task automatic reset_dut();
    rst                       = 1'b1;
    metadata_i                = '0;
    meta_in_valid_i           = 1'b0;
    real_active_thread_mask_i = '1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    $display("=============================================================");
    $display(" decode Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Invalid input - outputs should reflect valid=0
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: Invalid input", $time);
    reset_dut();

    metadata_i        = '0;
    meta_in_valid_i   = 1'b0;
    @(posedge clk);

    assert (bitstream_addr_valid_o == 1'b0)
    else $fatal(1, "FAIL: bitstream_addr_valid_o should be 0 when meta_in_valid_i is 0");
    assert (branch_req_valid_o == 1'b0)
    else $fatal(1, "FAIL: branch_req_valid_o should be 0 when meta_in_valid_i is 0");
    $display("[%0t] PASS: Invalid input handled correctly", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Bitstream address passthrough
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Bitstream address passthrough", $time);

    metadata_i.bitstream_addr   = 32'hDEAD_BEEF;
    metadata_i.bitstream_length = 8'd128;
    meta_in_valid_i             = 1'b1;
    @(posedge clk);

    assert (bitstream_addr_o == 32'hDEAD_BEEF)
    else $fatal(1, "FAIL: bitstream_addr_o mismatch, got 0x%h", bitstream_addr_o);
    assert (bitstream_addr_valid_o == 1'b1)
    else $fatal(1, "FAIL: bitstream_addr_valid_o should be 1");
    assert (bitstream_length_o == 8'd128)
    else $fatal(1, "FAIL: bitstream_length_o mismatch");
    $display("[%0t] PASS: Bitstream address passthrough", $time);

    // -------------------------------------------------------------------------
    // TEST 3: Branch metadata passthrough
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: Branch metadata passthrough", $time);

    metadata_i.branch_meta.branch_ena = 1'b1;
    metadata_i.branch_meta.branch_uni = 1'b1;
    metadata_i.barrier                = 1'b1;
    meta_in_valid_i                   = 1'b1;
    @(posedge clk);

    assert (branch_metadata_o.branch_ena == 1'b1)
    else $fatal(1, "FAIL: branch_ena mismatch");
    assert (branch_metadata_o.branch_uni == 1'b1)
    else $fatal(1, "FAIL: branch_uni mismatch");
    assert (branch_req_valid_o == 1'b1)
    else $fatal(1, "FAIL: branch_req_valid_o should be 1");
    assert (is_barrier_o == 1'b1)
    else $fatal(1, "FAIL: is_barrier_o mismatch");
    $display("[%0t] PASS: Branch metadata passthrough", $time);

    // -------------------------------------------------------------------------
    // TEST 4: is_return passthrough
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 4: is_return passthrough", $time);

    metadata_i                         = '0;
    metadata_i.branch_meta.is_return   = 1'b1;
    meta_in_valid_i                    = 1'b1;
    @(posedge clk);

    assert (branch_metadata_o.is_return == 1'b1)
    else $fatal(1, "FAIL: is_return mismatch, expected 1");
    $display("[%0t] PASS: is_return passthrough", $time);

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: decode_tb");
    $display("=============================================================");

    $finish;
  end

  // ===========================================================================
  // Waveform Dump
  // ===========================================================================
`ifdef VCD
  initial begin
    $dumpfile("decode_tb.vcd");
    $dumpvars(0, decode_tb);
  end
`endif

endmodule

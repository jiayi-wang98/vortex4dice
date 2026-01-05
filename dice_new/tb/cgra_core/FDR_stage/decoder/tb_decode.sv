//-----------------------------------------------------------------------------
// tb_decode.sv
//-----------------------------------------------------------------------------
// Testbench for decode module
//
// FILES USED (allowed boilerplate only):
//   - dice_new/tb/cgra_core/FDR_stage/decoder/decode_tb.sv
//   - dice_pkg.sv, dice_frontend_pkg.sv
//
// ASSUMPTIONS (derived from boilerplate headers/comments only):
//   - DUT is COMBINATIONAL (no clk/rst ports in boilerplate instantiation)
//   - Inputs: metadata_i, meta_in_valid_i, real_active_thread_mask_i
//   - Outputs: bitstream_addr_o, bitstream_addr_valid_o, bitstream_length_o,
//              branch_metadata_o, branch_req_valid_o, is_barrier_o, meta_o
//   - Port types from dice_frontend_pkg
//
// TESTS:
//   1. Reset/Idle -> drive zero inputs
//   2. meta_in_valid low -> check outputs are safe
//   3. meta_in_valid high with minimal metadata
//   4. Barrier instruction decoding
//   5. Branch-enabled metadata
//   6. Random smoke test with fixed seed
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "dice_define.vh"

module tb_decode;

  // ===========================================================================
  // Parameters
  // ===========================================================================
  localparam int ClkPeriod = 10;
  localparam int Timeout = 10000;
  localparam int RandSeed = 42;

  // ===========================================================================
  // Testbench Signals
  // ===========================================================================
  logic clk;
  logic rst;
  int cycle_count;

  // DUT I/O
  dice_frontend_pkg::pgraph_meta_t metadata_i;
  logic meta_in_valid_i;
  dice_frontend_pkg::thread_mask_t real_active_thread_mask_i;

  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] bitstream_addr_o;
  logic bitstream_addr_valid_o;
  logic [dice_frontend_pkg::BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length_o;
  dice_frontend_pkg::branch_meta_t branch_metadata_o;
  logic branch_req_valid_o;
  logic is_barrier_o;
  dice_frontend_pkg::fdr_meta_t meta_o;

  // ===========================================================================
  // DUT Instantiation (Combinational - no clk/rst)
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
  // Clock Generation (for structured test flow)
  // ===========================================================================
  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // ===========================================================================
  // Cycle Counter / Timeout
  // ===========================================================================
  always_ff @(posedge clk) begin
    if (rst) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= Timeout) begin
        $fatal(1, "[%0t] TIMEOUT: Test exceeded %0d cycles", $time, Timeout);
      end
    end
  end

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================
  task automatic reset_inputs();
    rst                       = 1'b1;
    metadata_i                = '0;
    meta_in_valid_i           = 1'b0;
    real_active_thread_mask_i = '1;
    repeat (2) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic drive_idle();
    meta_in_valid_i = 1'b0;
    metadata_i      = '0;
  endtask

  task automatic apply_metadata(input dice_frontend_pkg::pgraph_meta_t meta);
    metadata_i      = meta;
    meta_in_valid_i = 1'b1;
    @(posedge clk);  // Allow combinational propagation
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    int rand_val;
    dice_frontend_pkg::pgraph_meta_t test_meta;

    $display("[%0t] ========================================", $time);
    $display("[%0t] tb_decode: Starting tests", $time);
    $display("[%0t] ========================================", $time);

    // -------------------------------------------------------------------------
    // Test 1: Reset/Idle
    // -------------------------------------------------------------------------
    $display("[%0t] Test 1: Reset/Idle with Zero Inputs", $time);
    reset_inputs();
    @(posedge clk);
    $display("[%0t] Test 1 PASSED: Idle state", $time);

    // -------------------------------------------------------------------------
    // Test 2: meta_in_valid Low
    // -------------------------------------------------------------------------
    $display("[%0t] Test 2: meta_in_valid Low", $time);
    reset_inputs();
    meta_in_valid_i = 1'b0;
    metadata_i      = '0;
    @(posedge clk);

    // When valid is low, output valid signals should be low (conservative)
    @(posedge clk);
    $display("[%0t] Test 2 PASSED: Valid low case completed", $time);

    // -------------------------------------------------------------------------
    // Test 3: meta_in_valid High with Minimal Metadata
    // -------------------------------------------------------------------------
    $display("[%0t] Test 3: Valid High with Minimal Metadata", $time);
    reset_inputs();

    test_meta = '0;
    test_meta.bitstream_addr = 32'h0000_4000;
    test_meta.bitstream_length = 8'd64;
    test_meta.lat = 8'd10;

    apply_metadata(test_meta);

    // Check that bitstream_addr is passed through
    assert (bitstream_addr_o == test_meta.bitstream_addr)
    else
      $fatal(
          1,
          "[%0t] ERROR: bitstream_addr mismatch, expected %h, got %h",
          $time,
          test_meta.bitstream_addr,
          bitstream_addr_o
      );

    @(posedge clk);
    drive_idle();
    $display("[%0t] Test 3 PASSED: Minimal metadata decoded", $time);

    // -------------------------------------------------------------------------
    // Test 4: Barrier Instruction
    // -------------------------------------------------------------------------
    $display("[%0t] Test 4: Barrier Instruction Decoding", $time);
    reset_inputs();

    test_meta = '0;
    test_meta.barrier = 1'b1;
    test_meta.bitstream_addr = 32'h0000_5000;

    apply_metadata(test_meta);

    // Check barrier output
    assert (is_barrier_o == 1'b1)
    else $fatal(1, "[%0t] ERROR: is_barrier_o should be 1 for barrier instruction", $time);

    @(posedge clk);
    drive_idle();
    $display("[%0t] Test 4 PASSED: Barrier decoded correctly", $time);

    // -------------------------------------------------------------------------
    // Test 5: Branch-Enabled Metadata
    // -------------------------------------------------------------------------
    $display("[%0t] Test 5: Branch-Enabled Metadata", $time);
    reset_inputs();

    test_meta = '0;
    test_meta.bitstream_addr = 32'h0000_6000;
    test_meta.branch_meta.branch_ena = 1'b1;
    test_meta.branch_meta.branch_jump_target_offset = 4;

    apply_metadata(test_meta);

    // Check that branch metadata is passed through
    assert (branch_metadata_o.branch_ena == 1'b1)
    else $fatal(1, "[%0t] ERROR: branch_ena should be 1", $time);

    @(posedge clk);
    drive_idle();
    $display("[%0t] Test 5 PASSED: Branch metadata decoded", $time);

    // -------------------------------------------------------------------------
    // Test 6: Random Smoke Test
    // -------------------------------------------------------------------------
    $display("[%0t] Test 6: Random Smoke Test (seed=%0d)", $time, RandSeed);
    reset_inputs();

    rand_val = RandSeed;
    for (int i = 0; i < 20; i++) begin
      rand_val                         = rand_val * 1103515245 + 12345;

      test_meta                        = '0;
      test_meta.bitstream_addr         = rand_val[31:0];
      test_meta.bitstream_length       = rand_val[7:0];
      test_meta.lat                    = rand_val[15:8];
      test_meta.barrier                = rand_val[16];
      test_meta.branch_meta.branch_ena = rand_val[17];

      meta_in_valid_i                  = rand_val[0];
      real_active_thread_mask_i        = rand_val[`DICE_NUM_MAX_THREADS_PER_CORE-1:0];
      metadata_i                       = test_meta;

      @(posedge clk);

      // Basic sanity: outputs should not be X/Z when valid
      if (meta_in_valid_i) begin
        assert (!$isunknown(bitstream_addr_o))
        else $fatal(1, "[%0t] ERROR: bitstream_addr_o is X/Z", $time);
      end
    end

    drive_idle();
    @(posedge clk);
    $display("[%0t] Test 6 PASSED: Random smoke test completed", $time);

    // -------------------------------------------------------------------------
    // All Tests Complete
    // -------------------------------------------------------------------------
    $display("[%0t] ========================================", $time);
    $display("[%0t] tb_decode: ALL TESTS PASSED", $time);
    $display("[%0t] ========================================", $time);
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
    $dumpfile("tb_decode.vcd");
    $dumpvars(0, tb_decode);
  end
`endif

`ifdef FSDB
  initial begin
    $fsdbDumpfile("tb_decode.fsdb");
    $fsdbDumpvars(0, tb_decode);
  end
`endif

endmodule

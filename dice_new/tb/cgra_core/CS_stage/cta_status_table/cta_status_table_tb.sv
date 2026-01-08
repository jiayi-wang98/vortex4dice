// =============================================================================
// Testbench: cta_status_table_tb.sv
// =============================================================================
// Simple testbench for cta_status_table module.
// Tests branch predict writes, BRT writes, and clear entry functionality.
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module cta_status_table_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // ===========================================================================
  // Parameters
  // ===========================================================================
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 1000;

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
  branch_predict_interface_t                                 branch_predict_info_i;
  logic                                                      branch_predict_info_we_i;
  block_retire_status_t                                      brt_info_i;
  logic                                                      brt_info_we_i;
  logic                                                      clear_entry_valid_i;
  logic                      [     DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id_i;
  dice_cta_status_t          [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_o;

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  cta_status_table u_dut (
      .clk_i                   (clk),
      .rst_i                   (rst),
      .branch_predict_info_i   (branch_predict_info_i),
      .branch_predict_info_we_i(branch_predict_info_we_i),
      .brt_info_i              (brt_info_i),
      .brt_info_we_i           (brt_info_we_i),
      .clear_entry_valid_i     (clear_entry_valid_i),
      .clear_entry_hw_id_i     (clear_entry_hw_id_i),
      .cta_status_o            (cta_status_o)
  );

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================

  task automatic reset_dut();
    rst                      = 1'b1;
    branch_predict_info_i    = '0;
    branch_predict_info_we_i = 1'b0;
    brt_info_i               = '0;
    brt_info_we_i            = 1'b0;
    clear_entry_valid_i      = 1'b0;
    clear_entry_hw_id_i      = '0;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic drive_idle();
    branch_predict_info_we_i = 1'b0;
    brt_info_we_i            = 1'b0;
    clear_entry_valid_i      = 1'b0;
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    $display("=============================================================");
    $display(" cta_status_table Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Reset
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: Reset", $time);
    reset_dut();

    // After reset, all status entries should be cleared
    assert (cta_status_o[0].unresolved_control_divergence == 1'b0)
    else $fatal(1, "FAIL: Status not cleared after reset");
    assert (cta_status_o[0].has_pending_eblock == 1'b0)
    else $fatal(1, "FAIL: has_pending_eblock not cleared after reset");
    $display("[%0t] PASS: Reset complete, status cleared", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Branch predict write (data setup before enable)
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Branch predict write", $time);

    // Setup data first (enable still low)
    branch_predict_info_i.hw_cta_id = 0;
    branch_predict_info_i.unresolved_control_divergence = 1'b1;
    branch_predict_info_i.predict_pc = 32'hABCD_0000;
    branch_predict_info_i.is_return = 1'b1;
    branch_predict_info_i.is_barrier = 1'b0;
    @(posedge clk);

    // Now assert enable
    branch_predict_info_we_i = 1'b1;
    @(posedge clk);
    drive_idle();
    @(posedge clk);

    $display("[%0t] prefetch_cleared=%b, predict_pc=0x%h, is_return=%b", $time,
             cta_status_o[0].prefetch_cleared, cta_status_o[0].predict_pc,
             cta_status_o[0].is_return);
    assert (cta_status_o[0].prefetch_cleared == 1'b1)
    else $fatal(1, "FAIL: prefetch_cleared not set");
    assert (cta_status_o[0].predict_pc == 32'hABCD_0000)
    else $fatal(1, "FAIL: predict_pc mismatch");
    assert (cta_status_o[0].is_return == 1'b1)
    else $fatal(1, "FAIL: is_return not set");
    $display("[%0t] PASS: Branch predict write", $time);

    // -------------------------------------------------------------------------
    // TEST 3: BRT info write - set pending eblocks
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: BRT info write - set pending", $time);

    // Setup BRT data first
    brt_info_i.hw_cta_pending[0] = 1'b1;
    brt_info_i.hw_cta_pending[1] = 1'b1;
    brt_info_i.hw_cta_pending[2] = 1'b0;
    @(posedge clk);

    // Assert enable
    brt_info_we_i = 1'b1;
    @(posedge clk);
    drive_idle();
    @(posedge clk);

    $display("[%0t] has_pending_eblock: [0]=%b, [1]=%b, [2]=%b", $time,
             cta_status_o[0].has_pending_eblock, cta_status_o[1].has_pending_eblock,
             cta_status_o[2].has_pending_eblock);
    assert (cta_status_o[0].has_pending_eblock == 1'b1)
    else $fatal(1, "FAIL: has_pending_eblock[0] not set");
    assert (cta_status_o[1].has_pending_eblock == 1'b1)
    else $fatal(1, "FAIL: has_pending_eblock[1] not set");
    assert (cta_status_o[2].has_pending_eblock == 1'b0)
    else $fatal(1, "FAIL: has_pending_eblock[2] unexpectedly set");
    $display("[%0t] PASS: BRT info write - set pending", $time);

    // -------------------------------------------------------------------------
    // TEST 4: BRT info write - clear pending eblocks
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 4: BRT info write - clear pending", $time);

    // Update BRT to clear pending status
    brt_info_i.hw_cta_pending[0] = 1'b0;
    brt_info_i.hw_cta_pending[1] = 1'b0;
    @(posedge clk);

    brt_info_we_i = 1'b1;
    @(posedge clk);
    drive_idle();
    @(posedge clk);

    $display("[%0t] has_pending_eblock: [0]=%b, [1]=%b", $time, cta_status_o[0].has_pending_eblock,
             cta_status_o[1].has_pending_eblock);
    assert (cta_status_o[0].has_pending_eblock == 1'b0)
    else $fatal(1, "FAIL: has_pending_eblock[0] not cleared by BRT");
    assert (cta_status_o[1].has_pending_eblock == 1'b0)
    else $fatal(1, "FAIL: has_pending_eblock[1] not cleared by BRT");
    // Verify branch predict data still intact
    assert (cta_status_o[0].predict_pc == 32'hABCD_0000)
    else $fatal(1, "FAIL: predict_pc corrupted by BRT write");
    $display("[%0t] PASS: BRT info write - clear pending", $time);

    // -------------------------------------------------------------------------
    // TEST 5: Clear entry - clears all fields for a CTA
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 5: Clear entry", $time);

    // Setup clear command
    clear_entry_hw_id_i = 0;
    @(posedge clk);

    clear_entry_valid_i = 1'b1;
    @(posedge clk);
    drive_idle();
    @(posedge clk);

    $display("[%0t] After clear[0]: prefetch_cleared=%b, is_return=%b, predict_pc=0x%h", $time,
             cta_status_o[0].prefetch_cleared, cta_status_o[0].is_return,
             cta_status_o[0].predict_pc);
    assert (cta_status_o[0].prefetch_cleared == 1'b0)
    else $fatal(1, "FAIL: prefetch_cleared not cleared");
    assert (cta_status_o[0].is_return == 1'b0)
    else $fatal(1, "FAIL: is_return not cleared");
    assert (cta_status_o[0].predict_pc == '0)
    else $fatal(1, "FAIL: predict_pc not cleared");
    assert (cta_status_o[0].is_barrier == 1'b0)
    else $fatal(1, "FAIL: is_barrier not cleared");
    $display("[%0t] PASS: Clear entry", $time);

    // -------------------------------------------------------------------------
    // TEST 6: Clear different entry - verify isolation
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 6: Clear different entry - verify isolation", $time);

    // First, write some data to entry 1
    branch_predict_info_i.hw_cta_id  = 1;
    branch_predict_info_i.predict_pc = 32'h1234_5678;
    branch_predict_info_i.is_barrier = 1'b1;
    @(posedge clk);
    branch_predict_info_we_i = 1'b1;
    @(posedge clk);
    drive_idle();
    @(posedge clk);

    // Clear entry 1
    clear_entry_hw_id_i = 1;
    @(posedge clk);
    clear_entry_valid_i = 1'b1;
    @(posedge clk);
    drive_idle();
    @(posedge clk);

    $display("[%0t] After clear[1]: predict_pc=0x%h, is_barrier=%b", $time,
             cta_status_o[1].predict_pc, cta_status_o[1].is_barrier);
    assert (cta_status_o[1].predict_pc == '0)
    else $fatal(1, "FAIL: Entry 1 predict_pc not cleared");
    assert (cta_status_o[1].is_barrier == 1'b0)
    else $fatal(1, "FAIL: Entry 1 is_barrier not cleared");
    // Entry 0 should still be cleared from previous test
    assert (cta_status_o[0].predict_pc == '0)
    else $fatal(1, "FAIL: Entry 0 was corrupted");
    $display("[%0t] PASS: Clear different entry - verify isolation", $time);

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: cta_status_table_tb");
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
    $dumpfile("cta_status_table_tb.vcd");
    $dumpvars(0, cta_status_table_tb);
  end
`endif

endmodule

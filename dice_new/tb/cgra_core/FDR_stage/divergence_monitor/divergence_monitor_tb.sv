// =============================================================================
// Testbench: divergence_monitor_tb.sv
// =============================================================================
// Simple testbench for divergence_monitor module (sequential FSM).
// Tests:
//   1) Reset - module should be in scan state
//   2) Find work - detects CTA with unresolved divergence and no pending eblock
//   3) Clear divergence - signals to clear status table
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module divergence_monitor_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // ===========================================================================
  // Parameters
  // ===========================================================================
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 200;
  localparam int PcWidth = DICE_ADDR_WIDTH;
  localparam int ThreadWidth = DICE_NUM_MAX_THREADS_PER_CORE;
  localparam int NumCta = DICE_NUM_MAX_CTA_PER_CORE;
  localparam int NumPredRegs = DICE_PR_NUM;

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
  dice_cta_status_t [NumCta-1:0]                 cta_status_i;
  pending_branch_info_t [NumCta-1:0]             pending_branch_table_i;
  logic                                          prf_req_o;
  logic [$clog2(NumCta)+$clog2(NumPredRegs)-1:0] prf_raddr_o;
  logic [ThreadWidth-1:0]                        prf_rdata_i;
  logic                                          update_valid_o;
  logic                                          update_with_divergence_o;
  logic [PcWidth-1:0]                            update_next_pc_o;
  logic [PcWidth-1:0]                            branch_not_taken_pc_o;
  logic [PcWidth-1:0]                            branch_reconvergence_pc_o;
  logic [ThreadWidth-1:0]                        predicate_regs_value_o;
  logic [$clog2(NumCta)-1:0]                     update_hw_cta_id_o;
  logic                                          update_ready_i;
  logic                                          grant_i;
  logic [$clog2(NumCta)-1:0]                     clear_cta_id_o;
  logic                                          clear_divergence_valid_o;

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  divergence_monitor #(
      .PcWidth    (PcWidth),
      .ThreadWidth(ThreadWidth),
      .NumCta     (NumCta),
      .NumPredRegs(NumPredRegs)
  ) u_dut (
      .clk_i                    (clk),
      .rst_i                    (rst),
      .cta_status_i             (cta_status_i),
      .pending_branch_table_i   (pending_branch_table_i),
      .prf_req_o                (prf_req_o),
      .prf_raddr_o              (prf_raddr_o),
      .prf_rdata_i              (prf_rdata_i),
      .update_valid_o           (update_valid_o),
      .update_with_divergence_o (update_with_divergence_o),
      .update_next_pc_o         (update_next_pc_o),
      .branch_not_taken_pc_o    (branch_not_taken_pc_o),
      .branch_reconvergence_pc_o(branch_reconvergence_pc_o),
      .predicate_regs_value_o   (predicate_regs_value_o),
      .update_hw_cta_id_o       (update_hw_cta_id_o),
      .update_ready_i           (update_ready_i),
      .grant_i                  (grant_i),
      .clear_cta_id_o           (clear_cta_id_o),
      .clear_divergence_valid_o (clear_divergence_valid_o)
  );

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================
  task automatic reset_dut();
    rst                    = 1'b1;
    cta_status_i           = '0;
    pending_branch_table_i = '0;
    prf_rdata_i            = '0;
    update_ready_i         = 1'b1;
    grant_i                = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    $display("=============================================================");
    $display(" divergence_monitor Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Reset - module should be idle (scanning)
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: Reset", $time);
    reset_dut();

    assert (update_valid_o == 1'b0)
    else $fatal(1, "FAIL: update_valid_o should be 0 after reset");
    assert (clear_divergence_valid_o == 1'b0)
    else $fatal(1, "FAIL: clear_divergence_valid_o should be 0 after reset");
    $display("[%0t] PASS: Reset complete, module in scan state", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Find work - CTA 0 has unresolved divergence
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Find work", $time);

    // Setup CTA 0 with unresolved divergence and no pending eblock
    cta_status_i[0].unresolved_control_divergence = 1'b1;
    cta_status_i[0].has_pending_eblock            = 1'b0;

    // Setup pending branch info
    pending_branch_table_i[0].taken_pc     = 32'h0000_3000;
    pending_branch_table_i[0].not_taken_pc = 32'h0000_2004;
    pending_branch_table_i[0].reconv_pc    = 32'h0000_3010;

    grant_i = 1'b1;  // Grant access to the stack

    // Wait for monitor to find work and issue update
    wait (update_valid_o);
    // Check immediately
    assert (update_valid_o == 1'b1)
    else $fatal(1, "FAIL: update_valid_o should be 1 when work found");
    assert (update_with_divergence_o == 1'b1)
    else $fatal(1, "FAIL: update_with_divergence_o should be 1");

    @(posedge clk);
    $display("[%0t] PASS: Work found, update issued", $time);

    // -------------------------------------------------------------------------
    // TEST 3: Clear divergence
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: Clear divergence", $time);

    // Wait for clear_divergence_valid
    wait (clear_divergence_valid_o);
    // Check immediately
    assert (clear_divergence_valid_o == 1'b1)
    else $fatal(1, "FAIL: clear_divergence_valid_o should be 1");
    assert (clear_cta_id_o == 0)
    else $fatal(1, "FAIL: clear_cta_id_o should be 0");

    @(posedge clk);
    $display("[%0t] PASS: Divergence cleared for CTA 0", $time);

    // Clean up
    cta_status_i = '0;

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: divergence_monitor_tb");
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
    $dumpfile("divergence_monitor_tb.vcd");
    $dumpvars(0, divergence_monitor_tb);
  end
`endif

endmodule

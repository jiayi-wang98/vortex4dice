// =============================================================================
// Testbench: cta_controller_tb.sv
// =============================================================================
// Simple testbench for cta_controller module.
// Tests each handshake interface: dispatch, add, init, pop, complete.
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module cta_controller_tb;
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
  // Interfaces
  // ===========================================================================
  cta_dispatch_if dispatch_if ();
  cta_complete_if complete_if ();

  // ===========================================================================
  // DUT Signals
  // ===========================================================================
  // Active CTA table interface
  logic                                             pop_valid_o;
  logic             [     DICE_HW_CTA_ID_WIDTH-1:0] pop_hw_cta_id_o;
  logic                                             pop_ready_i;
  logic                                             add_ready_i;
  logic                                             add_valid_o;
  dice_cta_desc_t                                   add_cta_info_o;
  logic             [                          1:0] add_hw_cta_size_o;
  logic             [     DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index_i;
  logic             [DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_status_i;
  logic                                             pop_out_valid_i;
  dice_cta_id_t                                     pop_out_cta_id_i;

  // SIMT Stack Controller interface
  logic                                             init_valid_o;
  logic                                             init_ready_i;
  logic             [     DICE_HW_CTA_ID_WIDTH-1:0] init_hw_cta_id_o;
  logic             [     DICE_HW_CTA_ID_WIDTH-1:0] init_hw_cta_size_o;
  logic             [          DICE_ADDR_WIDTH-1:0] init_pc_o;
  logic             [          DICE_ADDR_WIDTH-1:0] init_reconvergence_pc_o;

  // CTA Status Table interface
  dice_cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_table_i;
  logic                                             clear_entry_valid_o;
  logic             [     DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id_o;

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  cta_controller u_dut (
      .clk_i                  (clk),
      .rst_i                  (rst),
      .dispatch_if            (dispatch_if.slave),
      .complete_if            (complete_if.master),
      .pop_valid_o            (pop_valid_o),
      .pop_hw_cta_id_o        (pop_hw_cta_id_o),
      .pop_ready_i            (pop_ready_i),
      .add_ready_i            (add_ready_i),
      .add_valid_o            (add_valid_o),
      .add_cta_info_o         (add_cta_info_o),
      .add_hw_cta_size_o      (add_hw_cta_size_o),
      .next_empty_cta_index_i (next_empty_cta_index_i),
      .active_cta_status_i    (active_cta_status_i),
      .pop_out_valid_i        (pop_out_valid_i),
      .pop_out_cta_id_i       (pop_out_cta_id_i),
      .init_valid_o           (init_valid_o),
      .init_ready_i           (init_ready_i),
      .init_hw_cta_id_o       (init_hw_cta_id_o),
      .init_hw_cta_size_o     (init_hw_cta_size_o),
      .init_pc_o              (init_pc_o),
      .init_reconvergence_pc_o(init_reconvergence_pc_o),
      .cta_status_table_i     (cta_status_table_i),
      .clear_entry_valid_o    (clear_entry_valid_o),
      .clear_entry_hw_id_o    (clear_entry_hw_id_o)
  );

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================

  task automatic reset_dut();
    rst                    = 1'b1;
    dispatch_if.valid      = 1'b0;
    dispatch_if.data       = '0;
    complete_if.ready      = 1'b1;
    pop_ready_i            = 1'b1;
    add_ready_i            = 1'b1;
    next_empty_cta_index_i = '0;
    active_cta_status_i    = '0;
    pop_out_valid_i        = 1'b0;
    pop_out_cta_id_i       = '0;
    init_ready_i           = 1'b1;
    cta_status_table_i     = '0;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic drive_idle();
    dispatch_if.valid = 1'b0;
    dispatch_if.data  = '0;
    pop_out_valid_i   = 1'b0;
    pop_out_cta_id_i  = '0;
  endtask

  // Helper to create a simple CTA descriptor
  function automatic dice_cta_desc_t make_cta_desc(input logic [DICE_KERNEL_ID_WIDTH-1:0] kernel_id,
                                                   input logic [DICE_ADDR_WIDTH-1:0] start_pc,
                                                   input logic [DICE_TID_WIDTH:0] cta_size_x);
    dice_cta_desc_t desc;
    desc = '0;
    desc.kernel_desc.kernel_id = kernel_id;
    desc.kernel_desc.start_pc = start_pc;
    desc.kernel_desc.cta_size.x = cta_size_x;
    desc.kernel_desc.cta_size.y = 1;
    desc.kernel_desc.cta_size.z = 1;
    return desc;
  endfunction

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    dice_cta_desc_t test_desc;

    $display("=============================================================");
    $display(" cta_controller Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Reset
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: Reset", $time);
    reset_dut();

    // After reset, dispatch_if.ready should reflect add_ready_i && init_ready_i
    assert (dispatch_if.ready == 1'b1)
    else $fatal(1, "FAIL: dispatch_if.ready not high after reset");
    $display("[%0t] PASS: Reset complete, dispatch ready", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Dispatch -> Add handshake
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Dispatch -> Add handshake", $time);
    test_desc = make_cta_desc(1, 32'h1000, 32);  // 32 threads

    dispatch_if.data = test_desc;
    dispatch_if.valid = 1'b1;
    @(posedge clk);

    // add_valid_o should fire when dispatch valid and init_ready
    assert (add_valid_o == 1'b1)
    else $fatal(1, "FAIL: add_valid_o not asserted on dispatch");
    assert (add_cta_info_o.kernel_desc.kernel_id == 1)
    else $fatal(1, "FAIL: add_cta_info_o mismatch");
    $display("[%0t] add_valid_o=%b, add_hw_cta_size_o=%b", $time, add_valid_o, add_hw_cta_size_o);

    dispatch_if.valid = 1'b0;
    @(posedge clk);
    $display("[%0t] PASS: Dispatch -> Add handshake", $time);

    // -------------------------------------------------------------------------
    // TEST 3: Dispatch -> Init handshake
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: Dispatch -> Init handshake", $time);
    test_desc = make_cta_desc(2, 32'h2000, 64);  // 64 threads
    next_empty_cta_index_i = 2'd1;  // Expect this to appear on init_hw_cta_id_o

    dispatch_if.data = test_desc;
    dispatch_if.valid = 1'b1;
    @(posedge clk);

    // init_valid_o should fire when dispatch valid and add_ready
    assert (init_valid_o == 1'b1)
    else $fatal(1, "FAIL: init_valid_o not asserted on dispatch");
    assert (init_hw_cta_id_o == 2'd1)
    else $fatal(1, "FAIL: init_hw_cta_id_o should be next_empty_cta_index_i");
    assert (init_pc_o == 32'h2000)
    else $fatal(1, "FAIL: init_pc_o mismatch");
    $display("[%0t] init_valid_o=%b, init_hw_cta_id_o=%0d, init_pc_o=0x%h", $time, init_valid_o,
             init_hw_cta_id_o, init_pc_o);

    dispatch_if.valid = 1'b0;
    @(posedge clk);
    $display("[%0t] PASS: Dispatch -> Init handshake", $time);

    // -------------------------------------------------------------------------
    // TEST 4: Backpressure - add_ready_i low
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 4: Backpressure - add_ready_i low", $time);
    add_ready_i = 1'b0;  // Block add

    test_desc = make_cta_desc(3, 32'h3000, 32);
    dispatch_if.data = test_desc;
    dispatch_if.valid = 1'b1;
    @(posedge clk);

    // dispatch.ready should be low
    assert (dispatch_if.ready == 1'b0)
    else $fatal(1, "FAIL: dispatch_if.ready should be low when add_ready_i is low");
    // init_valid should also be low (since add not ready)
    assert (init_valid_o == 1'b0)
    else $fatal(1, "FAIL: init_valid_o should be low when add_ready_i is low");

    // Release backpressure
    add_ready_i = 1'b1;
    @(posedge clk);

    dispatch_if.valid = 1'b0;
    @(posedge clk);
    $display("[%0t] PASS: Backpressure test", $time);

    // -------------------------------------------------------------------------
    // TEST 5: Pop -> Complete handshake
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 5: Pop -> Complete handshake", $time);

    // Setup: Mark CTA 0 as active, completed (is_return=1, no pending eblocks)
    active_cta_status_i[0] = 1'b1;
    cta_status_table_i[0].has_pending_eblock = 1'b0;
    cta_status_table_i[0].is_return = 1'b1;
    pop_out_valid_i = 1'b0;  // No pending output
    @(posedge clk);

    // pop_valid_o should go high
    $display("[%0t] pop_valid_o=%b, pop_hw_cta_id_o=%0d", $time, pop_valid_o, pop_hw_cta_id_o);
    assert (pop_valid_o == 1'b1)
    else $fatal(1, "FAIL: pop_valid_o should be high for completed CTA");

    // Simulate pop completing - active_cta_table returns the CTA id
    active_cta_status_i[0] = 1'b0;  // Clear the entry
    pop_out_valid_i = 1'b1;
    pop_out_cta_id_i = '0;
    @(posedge clk);

    // complete_if.valid should fire
    assert (complete_if.valid == 1'b1)
    else $fatal(1, "FAIL: complete_if.valid should be high");
    $display("[%0t] complete_if.valid=%b, complete_if.cta_id=%p", $time, complete_if.valid,
             complete_if.cta_id);

    pop_out_valid_i = 1'b0;
    @(posedge clk);
    $display("[%0t] PASS: Pop -> Complete handshake", $time);

    // -------------------------------------------------------------------------
    // TEST 6: Clear entry fires with pop
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 6: Clear entry signal", $time);

    // Setup another completed CTA
    active_cta_status_i[1] = 1'b1;
    cta_status_table_i[1].has_pending_eblock = 1'b0;
    cta_status_table_i[1].is_return = 1'b1;
    pop_out_valid_i = 1'b0;
    @(posedge clk);

    // clear_entry should fire with pop
    assert (clear_entry_valid_o == pop_valid_o)
    else $fatal(1, "FAIL: clear_entry_valid_o should match pop_valid_o");
    $display("[%0t] clear_entry_valid_o=%b, clear_entry_hw_id_o=%0d", $time, clear_entry_valid_o,
             clear_entry_hw_id_o);

    // Cleanup
    active_cta_status_i = '0;
    cta_status_table_i  = '0;
    @(posedge clk);
    $display("[%0t] PASS: Clear entry signal", $time);

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: cta_controller_tb");
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
    $dumpfile("cta_controller_tb.vcd");
    $dumpvars(0, cta_controller_tb);
  end
`endif

endmodule

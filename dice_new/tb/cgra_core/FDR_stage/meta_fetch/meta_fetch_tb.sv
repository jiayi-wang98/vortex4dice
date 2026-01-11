// =============================================================================
// Testbench: meta_fetch_tb.sv
// =============================================================================
// Simple testbench for meta_fetch module (sequential FSM).
// Tests:
//   1) Reset - module should be ready to accept schedule
//   2) Schedule -> Request handshake
//   3) Request -> Response -> Hold Data flow
// =============================================================================

`timescale 1ns / 1ps
`include "VX_define.vh"

module meta_fetch_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // ===========================================================================
  // Parameters
  // ===========================================================================
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 200;
  localparam int TagWidth = DICE_ADDR_WIDTH;

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
  logic                       schedule_valid_i;
  logic [DICE_ADDR_WIDTH-1:0] fdr_next_pc_i;
  logic [EBLOCK_ID_WIDTH-1:0] schedule_eblock_id_i;
  logic                       schedule_ready_o;
  pgraph_meta_t               outgoing_meta_o;
  logic                       meta_valid_o;
  logic                       fire_eblock_i;
  logic                       flush_i;

  // Cache bus interface
  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(TagWidth)
  ) meta_fetch_bus_if ();

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  meta_fetch #(
      .TAG_WIDTH(TagWidth)
  ) u_dut (
      .clk_i               (clk),
      .rst_i               (rst),
      .schedule_valid_i    (schedule_valid_i),
      .fdr_next_pc_i       (fdr_next_pc_i),
      .schedule_eblock_id_i(schedule_eblock_id_i),
      .schedule_ready_o    (schedule_ready_o),
      .meta_fetch_bus_if   (meta_fetch_bus_if),
      .outgoing_meta_o     (outgoing_meta_o),
      .meta_valid_o        (meta_valid_o),
      .fire_eblock_i       (fire_eblock_i),
      .flush_i             (flush_i)
  );

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================
  task automatic reset_dut();
    rst                         = 1'b1;
    schedule_valid_i            = 1'b0;
    fdr_next_pc_i               = '0;
    schedule_eblock_id_i        = '0;
    fire_eblock_i               = 1'b0;
    flush_i                     = 1'b0;
    meta_fetch_bus_if.req_ready = 1'b1;
    meta_fetch_bus_if.rsp_valid = 1'b0;
    meta_fetch_bus_if.rsp_data  = '0;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    $display("=============================================================");
    $display(" meta_fetch Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Reset - schedule_ready should be high
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: Reset", $time);
    reset_dut();

    assert (schedule_ready_o == 1'b1)
    else $fatal(1, "FAIL: schedule_ready_o should be high after reset");
    assert (meta_valid_o == 1'b0)
    else $fatal(1, "FAIL: meta_valid_o should be 0 after reset");
    $display("[%0t] PASS: Reset complete, schedule_ready=1", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Schedule -> Request handshake
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Schedule -> Request handshake", $time);

    fdr_next_pc_i    = 32'h0000_1000;
    schedule_valid_i = 1'b1;
    @(posedge clk);
    schedule_valid_i = 1'b0;

    // Wait for request to fire
    repeat (2) @(posedge clk);

    assert (meta_fetch_bus_if.req_valid == 1'b1)
    else $fatal(1, "FAIL: req_valid should be high after schedule");
    $display("[%0t] PASS: Request fired after schedule", $time);

    // -------------------------------------------------------------------------
    // TEST 3: Request -> Response -> Hold Data
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: Full request/response flow", $time);

    // Simulate cache response with matching tag
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid          = 1'b1;
    meta_fetch_bus_if.rsp_data.tag       = TagWidth'(32'h0000_1000);
    meta_fetch_bus_if.rsp_data.data[7:0] = 8'hAB;  // Some test data
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid          = 1'b0;

    // Wait for meta_valid to go high
    repeat (2) @(posedge clk);

    assert (meta_valid_o == 1'b1)
    else $fatal(1, "FAIL: meta_valid_o should be high after response");
    $display("[%0t] PASS: Meta valid after response", $time);

    // Fire eblock to consume the data
    fire_eblock_i = 1'b1;
    @(posedge clk);
    fire_eblock_i = 1'b0;
    @(posedge clk);

    assert (schedule_ready_o == 1'b1)
    else $fatal(1, "FAIL: schedule_ready_o should be high after fire_eblock");
    $display("[%0t] PASS: Back to ready after fire_eblock", $time);

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: meta_fetch_tb");
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
    $dumpfile("meta_fetch_tb.vcd");
    $dumpvars(0, meta_fetch_tb);
  end
`endif

endmodule

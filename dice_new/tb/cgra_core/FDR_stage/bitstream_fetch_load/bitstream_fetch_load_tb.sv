// =============================================================================
// Testbench: bitstream_fetch_load_tb.sv
// =============================================================================
// Simple testbench for bitstream_fetch_load module (sequential FSM).
// Tests:
//   1) Reset - module should be idle, done_streaming=0
//   2) Start streaming - transitions to StateStreaming on meta_valid
//   3) Flush during streaming - returns to idle
// =============================================================================

`timescale 1ns / 1ps
`include "VX_define.vh"

module bitstream_fetch_load_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // ===========================================================================
  // Parameters
  // ===========================================================================
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 200;
  localparam int TagWidth = DICE_ADDR_WIDTH;
  localparam int BitstreamSize = 2056;
  localparam int ChunkSize = VX_gpu_pkg::VX_MEM_DATA_WIDTH;
  localparam int NumChunks = (BitstreamSize + ChunkSize - 1) / ChunkSize;

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
  logic                       flush_i;
  logic                       meta_valid_i;
  logic [DICE_ADDR_WIDTH-1:0] bitstream_addr_i;
  logic [ChunkSize-1:0]       cm0_data_o;
  logic [NumChunks-1:0]       cm0_chunk_en_o;
  logic [ChunkSize-1:0]       cm1_data_o;
  logic [NumChunks-1:0]       cm1_chunk_en_o;
  logic                       done_streaming_o;
  logic                       cm_num_o;

  // Cache bus interface
  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(TagWidth)
  ) cache_bus_if ();

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  bitstream_fetch_load #(
      .TAG_WIDTH     (TagWidth),
      .BITSTREAM_SIZE(BitstreamSize)
  ) u_dut (
      .clk_i           (clk),
      .rst_i           (rst),
      .flush_i         (flush_i),
      .meta_valid_i    (meta_valid_i),
      .bitstream_addr_i(bitstream_addr_i),
      .cm0_data_o      (cm0_data_o),
      .cm0_chunk_en_o  (cm0_chunk_en_o),
      .cm1_data_o      (cm1_data_o),
      .cm1_chunk_en_o  (cm1_chunk_en_o),
      .done_streaming_o(done_streaming_o),
      .cache_bus_if    (cache_bus_if),
      .cm_num_o        (cm_num_o)
  );

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================
  task automatic reset_dut();
    rst                     = 1'b1;
    flush_i                 = 1'b0;
    meta_valid_i            = 1'b0;
    bitstream_addr_i        = '0;
    cache_bus_if.req_ready  = 1'b1;
    cache_bus_if.rsp_valid  = 1'b0;
    cache_bus_if.rsp_data   = '0;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    $display("=============================================================");
    $display(" bitstream_fetch_load Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Reset - done_streaming should be 0
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: Reset", $time);
    reset_dut();

    assert (done_streaming_o == 1'b0)
    else $fatal(1, "FAIL: done_streaming_o should be 0 after reset");
    $display("[%0t] PASS: Reset complete, done_streaming=0", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Start streaming on meta_valid
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Start streaming", $time);

    bitstream_addr_i = 32'h0000_2000;
    meta_valid_i     = 1'b1;
    @(posedge clk);
    meta_valid_i     = 1'b0;

    // Wait for request to be issued
    repeat (2) @(posedge clk);

    assert (cache_bus_if.req_valid == 1'b1)
    else $fatal(1, "FAIL: req_valid should be high after meta_valid");
    $display("[%0t] PASS: Streaming started, req_valid=1", $time);

    // -------------------------------------------------------------------------
    // TEST 3: Flush during streaming
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: Flush during streaming", $time);

    // Issue flush
    flush_i = 1'b1;
    @(posedge clk);
    flush_i = 1'b0;

    // Wait a cycle for state to update
    @(posedge clk);

    // Should be back in idle (req_valid should drop)
    assert (cache_bus_if.req_valid == 1'b0)
    else $fatal(1, "FAIL: req_valid should be 0 after flush");
    $display("[%0t] PASS: Flush returned to idle", $time);

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: bitstream_fetch_load_tb");
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
    $dumpfile("bitstream_fetch_load_tb.vcd");
    $dumpvars(0, bitstream_fetch_load_tb);
  end
`endif

endmodule

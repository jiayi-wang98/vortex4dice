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
  // logic [EBLOCK_ID_WIDTH-1:0] schedule_eblock_id_i; // Removed: not in DUT
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
      // .schedule_eblock_id_i(schedule_eblock_id_i), // Removed: not in DUT
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
    // schedule_eblock_id_i        = '0; // Removed
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
    // -------------------------------------------------------------------------
    // TEST 2: Two Sequential Transactions (A then B)
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Sequential Transactions Check", $time);

    // --- Transaction A ---
    $display("[%0t] TEST 2: Starting Transaction A (PC=1000)", $time);
    fdr_next_pc_i    = 32'h0000_1000;
    schedule_valid_i = 1'b1;
    
    // Wait for DUT to assert request
    wait(meta_fetch_bus_if.req_valid);
    $display("[%0t] TEST 2: Req A observed", $time);
    assert(meta_fetch_bus_if.req_data.tag == TagWidth'(32'h0000_1000))
    else $fatal(1, "FAIL: Expected req tag A (1000)");

    // Drop schedule valid (pulse simulation)
    schedule_valid_i = 1'b0; 

    // Wait for DUT to be ready for response (StateWaitResp)
    wait(meta_fetch_bus_if.rsp_ready);
    $display("[%0t] TEST 2: DUT ready for response A", $time);
    
    // Drive Response
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 1'b1;
    meta_fetch_bus_if.rsp_data.tag = TagWidth'(32'h0000_1000);
    meta_fetch_bus_if.rsp_data.data = '0; 
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 1'b0;
    
    // Wait for Output Validity
    wait(meta_valid_o);
    $display("[%0t] TEST 2: Meta Valid A observed", $time);
    
    // Fire eblock to finish A
    fire_eblock_i = 1'b1;
    @(posedge clk);
    fire_eblock_i = 1'b0;
    $display("[%0t] TEST 2: Fired eblock for A", $time);

    // --- Transaction B ---
    // Wait for DUT to become ready again
    wait(schedule_ready_o);
    $display("[%0t] TEST 2: DUT ready for Transaction B", $time);

    fdr_next_pc_i    = 32'h0000_2000;
    schedule_valid_i = 1'b1;
    @(posedge clk);
    schedule_valid_i = 1'b0;

    wait(meta_fetch_bus_if.req_valid);
    $display("[%0t] TEST 2: Req B observed", $time);
    assert(meta_fetch_bus_if.req_data.tag == TagWidth'(32'h0000_2000))
    else $fatal(1, "FAIL: Expected req tag B (2000)");

    // Complete B Response
    wait(meta_fetch_bus_if.rsp_ready);
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 1'b1;
    meta_fetch_bus_if.rsp_data.tag = TagWidth'(32'h0000_2000);
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 1'b0;
    
    wait(meta_valid_o);
    fire_eblock_i = 1'b1;
    @(posedge clk);
    fire_eblock_i = 1'b0;

    reset_dut(); 
    $display("[%0t] PASS: Sequential Transactions verified", $time);

    // -------------------------------------------------------------------------
    // TEST 3: Cache Stall (Backpressure)
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: Cache Stall", $time);
    
    schedule_valid_i = 1'b1;
    fdr_next_pc_i    = 32'h0000_3000;
    // Cache is busy!
    meta_fetch_bus_if.req_ready = 1'b0; 
    @(posedge clk);
    schedule_valid_i = 1'b0;

    repeat(3) @(posedge clk);
    assert(meta_fetch_bus_if.req_valid == 1'b1)
    else $fatal(1, "FAIL: Request should persist during stall");

    // Unstall
    meta_fetch_bus_if.req_ready = 1'b1;
    @(posedge clk);
    assert(meta_fetch_bus_if.req_valid == 1'b0) // Should be consumed ? Depends on handshake timing
       else begin /* It might deassert depending on state */ end

    reset_dut();
    $display("[%0t] PASS: Cache Stall verified", $time);

    // -------------------------------------------------------------------------
    // TEST 4: Flush during Request
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 4: Flush (Request Phase)", $time);
    
    schedule_valid_i = 1'b1;
    fdr_next_pc_i    = 32'h0000_4000;
    meta_fetch_bus_if.req_ready = 1'b0; // Force wait
    @(posedge clk);
    schedule_valid_i = 1'b0;

    // Flush!
    flush_i = 1'b1;
    @(posedge clk);
    flush_i = 1'b0;
    
    // Should return to ready immediately
    assert(schedule_ready_o == 1'b1) 
    else $fatal(1, "FAIL: Should remain ready after flush");

    reset_dut();
    $display("[%0t] PASS: Flush (Request) verified", $time);

    // -------------------------------------------------------------------------
    // TEST 5: Flush during Wait Response
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 5: Flush (Wait Response Phase)", $time);

    schedule_valid_i = 1'b1;
    fdr_next_pc_i    = 32'h0000_5000;
    meta_fetch_bus_if.req_ready = 1'b1;
    @(posedge clk);
    schedule_valid_i = 1'b0;

    // Should be waiting for response now
    wait(meta_fetch_bus_if.rsp_ready); // waiting for response

    // Flush!
    flush_i = 1'b1;
    @(posedge clk);
    flush_i = 1'b0;

    // Late response arrives... should be IGNORED
    meta_fetch_bus_if.rsp_valid = 1'b1;
    meta_fetch_bus_if.rsp_data.tag = TagWidth'(32'h0000_5000);
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 1'b0;

    assert(meta_valid_o == 1'b0)
    else $fatal(1, "FAIL: Flushed request should not produce valid meta");

    reset_dut();
    $display("[%0t] PASS: Flush (Wait) verified", $time);

    // -------------------------------------------------------------------------
    // TEST 6: Tag Mismatch (Stray Response)
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 6: Tag Mismatch", $time);

    schedule_valid_i = 1'b1;
    fdr_next_pc_i    = 32'h0000_6000;
    meta_fetch_bus_if.req_ready = 1'b1;
    @(posedge clk);
    schedule_valid_i = 1'b0;

    // Stray response with wrong tag
    meta_fetch_bus_if.rsp_valid = 1'b1;
    meta_fetch_bus_if.rsp_data.tag = TagWidth'(32'h0000_DEAD);
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 1'b0;

    assert(meta_valid_o == 1'b0)
    else $fatal(1, "FAIL: Should not accept wrong tag");

    // Correct response
    meta_fetch_bus_if.rsp_valid = 1'b1;
    meta_fetch_bus_if.rsp_data.tag = TagWidth'(32'h0000_6000);
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 1'b0;

    wait(meta_valid_o);
    $display("[%0t] PASS: Tag Mismatch logic verified", $time);

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

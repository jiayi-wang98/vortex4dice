//-----------------------------------------------------------------------------
// tb_meta_fetch.sv - Testbench for meta_fetch module
//
// FILES USED: meta_fetch_tb.sv (boilerplate), dice_pkg.sv, dice_frontend_pkg.sv
//             VX_gpu_pkg.sv
//
// ASSUMPTIONS: clk_i/rst_i, valid/ready handshake on cache bus,
//              Parameters: TAG_WIDTH
//
// TESTS: 1) Reset, 2) No schedule, 3) Basic fetch handshake, 4) Cache backpressure,
//        5) fire_eblock pulse, 6) Random smoke
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "VX_define.vh"

module tb_meta_fetch;

  localparam int TagWidth = 48;
  localparam int ClkPeriod = 10;
  localparam int Timeout = 10000;
  localparam int RandSeed = 42;

  logic clk, rst;
  int cycle_count;

  logic schedule_valid_i, schedule_ready_o, meta_valid_o, fire_eblock_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] fdr_next_pc_i;
  logic [dice_frontend_pkg::EBLOCK_ID_WIDTH-1:0] schedule_eblock_id_i;
  dice_frontend_pkg::pgraph_meta_t outgoing_meta_o;

  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(TagWidth)
  ) meta_fetch_bus_if ();

  meta_fetch #(
      .TAG_WIDTH(TagWidth)
  ) u_dut (
      .clk_i(clk),
      .rst_i(rst),
      .schedule_valid_i(schedule_valid_i),
      .fdr_next_pc_i(fdr_next_pc_i),
      .schedule_eblock_id_i(schedule_eblock_id_i),
      .schedule_ready_o(schedule_ready_o),
      .meta_fetch_bus_if(meta_fetch_bus_if),
      .outgoing_meta_o(outgoing_meta_o),
      .meta_valid_o(meta_valid_o),
      .fire_eblock_i(fire_eblock_i)
  );

  initial begin
    clk = 0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  always_ff @(posedge clk) begin
    if (rst) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= Timeout) $fatal(1, "TIMEOUT");
    end
  end

  task automatic reset_dut();
    rst = 1;
    schedule_valid_i = 0;
    fdr_next_pc_i = '0;
    schedule_eblock_id_i = '0;
    fire_eblock_i = 0;
    meta_fetch_bus_if.req_ready = 1;
    meta_fetch_bus_if.rsp_valid = 0;
    meta_fetch_bus_if.rsp_data.data = '0;
    meta_fetch_bus_if.rsp_data.tag = '0;
    repeat (10) @(posedge clk);
    rst = 0;
    @(posedge clk);
  endtask

  task automatic provide_cache_rsp(input logic [VX_gpu_pkg::VX_MEM_DATA_WIDTH-1:0] data);
    meta_fetch_bus_if.rsp_valid = 1;
    meta_fetch_bus_if.rsp_data.data = data;
    @(posedge clk);
    meta_fetch_bus_if.rsp_valid = 0;
  endtask

  initial begin
    int rand_val;
    $display("[%0t] tb_meta_fetch: Starting tests", $time);

    // Test 1: Reset
    reset_dut();
    $display("[%0t] Test 1 PASSED: Reset", $time);

    // Test 2: No schedule request
    reset_dut();
    schedule_valid_i = 0;
    repeat (10) @(posedge clk);
    $display("[%0t] Test 2 PASSED: No schedule", $time);

    // Test 3: Basic fetch handshake
    reset_dut();
    schedule_valid_i = 1;
    fdr_next_pc_i = 32'h1000;
    schedule_eblock_id_i = 4'd1;
    @(posedge clk);
    if (schedule_ready_o) schedule_valid_i = 0;
    repeat (5) @(posedge clk);
    if (meta_fetch_bus_if.req_valid) provide_cache_rsp('1);
    repeat (10) @(posedge clk);
    $display("[%0t] Test 3 PASSED: Basic fetch", $time);

    // Test 4: Cache backpressure
    reset_dut();
    meta_fetch_bus_if.req_ready = 0;
    schedule_valid_i = 1;
    fdr_next_pc_i = 32'h2000;
    @(posedge clk);
    schedule_valid_i = 0;
    repeat (5) @(posedge clk);
    meta_fetch_bus_if.req_ready = 1;
    repeat (10) @(posedge clk);
    $display("[%0t] Test 4 PASSED: Cache backpressure", $time);

    // Test 5: fire_eblock pulse
    reset_dut();
    schedule_valid_i = 1;
    fdr_next_pc_i = 32'h3000;
    @(posedge clk);
    schedule_valid_i = 0;
    repeat (5) @(posedge clk);
    fire_eblock_i = 1;
    @(posedge clk);
    fire_eblock_i = 0;
    repeat (5) @(posedge clk);
    $display("[%0t] Test 5 PASSED: fire_eblock", $time);

    // Test 6: Random smoke
    reset_dut();
    rand_val = RandSeed;
    for (int i = 0; i < 15; i++) begin
      rand_val = rand_val * 1103515245 + 12345;
      schedule_valid_i = rand_val[0];
      fdr_next_pc_i = rand_val[31:0];
      meta_fetch_bus_if.req_ready = rand_val[1];
      fire_eblock_i = rand_val[2];
      @(posedge clk);
      if (rand_val[3] && meta_fetch_bus_if.req_valid) provide_cache_rsp(rand_val);
    end
    schedule_valid_i = 0;
    fire_eblock_i = 0;
    repeat (5) @(posedge clk);
    $display("[%0t] Test 6 PASSED: Random smoke", $time);

    $display("[%0t] tb_meta_fetch: ALL TESTS PASSED", $time);
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  always_ff @(posedge clk)
    if (!rst) begin
      assert (!$isunknown(schedule_ready_o))
      else $fatal(1, "schedule_ready_o X/Z");
      assert (!$isunknown(meta_valid_o))
      else $fatal(1, "meta_valid_o X/Z");
    end

`ifdef VCD
  initial begin
    $dumpfile("tb_meta_fetch.vcd");
    $dumpvars(0, tb_meta_fetch);
  end
`endif
`ifdef FSDB
  initial begin
    $fsdbDumpfile("tb_meta_fetch.fsdb");
    $fsdbDumpvars(0, tb_meta_fetch);
  end
`endif

endmodule

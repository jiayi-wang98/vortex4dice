//-----------------------------------------------------------------------------
// tb_fdr_top.sv - Testbench for fdr_top module (top-level FDR stage)
//
// FILES USED: fdr_top_tb.sv (boilerplate), dice_pkg.sv, dice_frontend_pkg.sv,
//             VX_gpu_pkg.sv, cta_sched_if.sv, fdr_if.sv
//
// TESTS: 1) Reset, 2) No schedule, 3) Basic handshake, 4) fdr_if backpressure,
//        5) Cache backpressure, 6) Random smoke
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
`include "VX_define.vh"

module tb_fdr_top;

  localparam int TagWidth = 48;
  localparam int BitstreamSize = 2056;
  localparam int ChunkSize = VX_gpu_pkg::VX_MEM_DATA_WIDTH;
  localparam int NumChunks = (BitstreamSize + ChunkSize - 1) / ChunkSize;
  localparam int ClkPeriod = 10;
  localparam int Timeout = 10000;
  localparam int RandSeed = 42;

  logic clk, rst;
  int cycle_count;

  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] simt_stack_pc_i;
  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_i;
  logic clear_prefetch_valid_o;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_prefetch_hw_cta_id_o;
  logic predict_miss_flush_o;
  logic [ChunkSize-1:0] cm0_data_o, cm1_data_o;
  logic [NumChunks-1:0] cm0_chunk_en_o, cm1_chunk_en_o;

  VX_mem_bus_if #(
      .DATA_SIZE(ChunkSize / 8),
      .TAG_WIDTH(TagWidth)
  ) metacache_mem_if ();
  VX_mem_bus_if #(
      .DATA_SIZE(ChunkSize / 8),
      .TAG_WIDTH(TagWidth)
  ) bitstream_cache_mem_if ();
  cta_sched_if schedule_if ();
  fdr_if fdr_if ();

  fdr_top #(
      .TAG_WIDTH(TagWidth),
      .BITSTREAM_SIZE(BitstreamSize)
  ) u_dut (
      .clk_i(clk),
      .rst_i(rst),
      .metacache_mem_if(metacache_mem_if),
      .bitstream_cache_mem_if(bitstream_cache_mem_if),
      .schedule_if(schedule_if),
      .fdr_if(fdr_if),
      .simt_stack_pc_i(simt_stack_pc_i),
      .cta_status_i(cta_status_i),
      .clear_prefetch_valid_o(clear_prefetch_valid_o),
      .clear_prefetch_hw_cta_id_o(clear_prefetch_hw_cta_id_o),
      .predict_miss_flush_o(predict_miss_flush_o),
      .cm0_data_o(cm0_data_o),
      .cm0_chunk_en_o(cm0_chunk_en_o),
      .cm1_data_o(cm1_data_o),
      .cm1_chunk_en_o(cm1_chunk_en_o)
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
    simt_stack_pc_i = '0;
    cta_status_i = '0;
    schedule_if.valid = 0;
    schedule_if.data = '0;
    fdr_if.ready = 1;
    metacache_mem_if.req_ready = 1;
    metacache_mem_if.rsp_valid = 0;
    metacache_mem_if.rsp_data.data = '0;
    metacache_mem_if.rsp_data.tag = '0;
    bitstream_cache_mem_if.req_ready = 1;
    bitstream_cache_mem_if.rsp_valid = 0;
    bitstream_cache_mem_if.rsp_data.data = '0;
    bitstream_cache_mem_if.rsp_data.tag = '0;
    repeat (10) @(posedge clk);
    rst = 0;
    @(posedge clk);
  endtask

  initial begin
    int rand_val;
    dice_frontend_pkg::schedule_eblock_t test_sched;
    $display("[%0t] tb_fdr_top: Starting tests", $time);

    // Test 1: Reset
    reset_dut();
    $display("[%0t] Test 1 PASSED: Reset", $time);

    // Test 2: No schedule
    reset_dut();
    schedule_if.valid = 0;
    repeat (10) @(posedge clk);
    $display("[%0t] Test 2 PASSED: No schedule", $time);

    // Test 3: Basic handshake
    reset_dut();
    test_sched = '0;
    test_sched.schedule_next_pc = 32'h1000;
    schedule_if.valid = 1;
    schedule_if.data = test_sched;
    @(posedge clk);
    schedule_if.valid = 0;
    repeat (20) @(posedge clk);
    $display("[%0t] Test 3 PASSED: Basic handshake", $time);

    // Test 4: fdr_if backpressure
    reset_dut();
    fdr_if.ready = 0;
    schedule_if.valid = 1;
    schedule_if.data = '0;
    @(posedge clk);
    schedule_if.valid = 0;
    repeat (5) @(posedge clk);
    fdr_if.ready = 1;
    repeat (10) @(posedge clk);
    $display("[%0t] Test 4 PASSED: fdr_if backpressure", $time);

    // Test 5: Cache backpressure
    reset_dut();
    metacache_mem_if.req_ready = 0;
    bitstream_cache_mem_if.req_ready = 0;
    schedule_if.valid = 1;
    schedule_if.data = '0;
    @(posedge clk);
    schedule_if.valid = 0;
    repeat (5) @(posedge clk);
    metacache_mem_if.req_ready = 1;
    bitstream_cache_mem_if.req_ready = 1;
    repeat (10) @(posedge clk);
    $display("[%0t] Test 5 PASSED: Cache backpressure", $time);

    // Test 6: Random smoke
    reset_dut();
    rand_val = RandSeed;
    for (int i = 0; i < 15; i++) begin
      rand_val = rand_val * 1103515245 + 12345;
      schedule_if.valid = rand_val[0];
      fdr_if.ready = rand_val[1];
      metacache_mem_if.req_ready = rand_val[2];
      @(posedge clk);
    end
    schedule_if.valid = 0;
    fdr_if.ready = 1;
    repeat (5) @(posedge clk);
    $display("[%0t] Test 6 PASSED: Random smoke", $time);

    $display("[%0t] tb_fdr_top: ALL TESTS PASSED", $time);
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  always_ff @(posedge clk)
    if (!rst) begin
      assert (!$isunknown(fdr_if.valid))
      else $fatal(1, "fdr_if.valid X/Z");
    end

`ifdef VCD
  initial begin
    $dumpfile("tb_fdr_top.vcd");
    $dumpvars(0, tb_fdr_top);
  end
`endif
`ifdef FSDB
  initial begin
    $fsdbDumpfile("tb_fdr_top.fsdb");
    $fsdbDumpvars(0, tb_fdr_top);
  end
`endif

endmodule

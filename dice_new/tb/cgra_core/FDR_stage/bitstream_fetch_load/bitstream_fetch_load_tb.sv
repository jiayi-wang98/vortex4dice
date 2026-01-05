`timescale 1ns / 1ps
`include "VX_define.vh"

module bitstream_fetch_load_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int TagWidth = 48;
  localparam int BitstreamSize = 2056;
  localparam int ChunkSize = VX_gpu_pkg::VX_MEM_DATA_WIDTH;
  localparam int NumChunks = (BitstreamSize + ChunkSize - 1) / ChunkSize;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                 clk;
  logic                                 rst;

  // DUT I/O
  logic                                 meta_valid_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] bitstream_addr_i;
  logic [                ChunkSize-1:0] cm0_data_o;
  logic [                NumChunks-1:0] cm0_chunk_en_o;
  logic [                ChunkSize-1:0] cm1_data_o;
  logic [                NumChunks-1:0] cm1_chunk_en_o;
  logic                                 done_streaming_o;
  logic                                 cm_num_o;

  // Cache bus interface
  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(TagWidth)
  ) cache_bus_if ();

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  bitstream_fetch_load #(
      .TAG_WIDTH     (TagWidth),
      .BITSTREAM_SIZE(BitstreamSize)
  ) u_dut (
      .clk_i           (clk),
      .rst_i           (rst),
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

  // =========================================================================
  // Clock Generation
  // =========================================================================
  localparam int ClkPeriod = 10;

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // =========================================================================
  // Reset Sequence
  // =========================================================================
  task automatic apply_reset();
    rst = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // =========================================================================
  // Test Stimulus
  // =========================================================================
  initial begin
    // Initialize inputs
    meta_valid_i               = 1'b0;
    bitstream_addr_i           = '0;

    // Initialize cache bus slave side
    cache_bus_if.req_ready     = 1'b1;
    cache_bus_if.rsp_valid     = 1'b0;
    cache_bus_if.rsp_data.data = '0;
    cache_bus_if.rsp_data.tag  = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] bitstream_fetch_load_tb: Test passed!", $time);
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("bitstream_fetch_load_tb.fsdb");
    $fsdbDumpvars(0, bitstream_fetch_load_tb);
  end
`endif

endmodule

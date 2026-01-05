`timescale 1ns / 1ps
`include "VX_define.vh"

module fdr_top_tb;
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
  logic                                                                 clk;
  logic                                                                 rst;

  // DUT I/O
  logic                       [          dice_pkg::DICE_ADDR_WIDTH-1:0] simt_stack_pc_i;
  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_i;
  logic                                                                 clear_prefetch_valid_o;
  logic                       [     dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_prefetch_hw_cta_id_o;
  logic                                                                 predict_miss_flush_o;

  logic                       [                          ChunkSize-1:0] cm0_data_o;
  logic                       [                          NumChunks-1:0] cm0_chunk_en_o;
  logic                       [                          ChunkSize-1:0] cm1_data_o;
  logic                       [                          NumChunks-1:0] cm1_chunk_en_o;

  // Cache bus interfaces
  VX_mem_bus_if #(
      .DATA_SIZE(ChunkSize / 8),
      .TAG_WIDTH(TagWidth)
  ) metacache_mem_if ();

  VX_mem_bus_if #(
      .DATA_SIZE(ChunkSize / 8),
      .TAG_WIDTH(TagWidth)
  ) bitstream_cache_mem_if ();

  // Scheduler/FDR interfaces
  cta_sched_if schedule_if ();
  fdr_if fdr_if ();

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  fdr_top #(
      .TAG_WIDTH     (TagWidth),
      .BITSTREAM_SIZE(BitstreamSize)
  ) u_dut (
      .clk_i                     (clk),
      .rst_i                     (rst),
      .metacache_mem_if          (metacache_mem_if),
      .bitstream_cache_mem_if    (bitstream_cache_mem_if),
      .schedule_if               (schedule_if),
      .fdr_if                    (fdr_if),
      .simt_stack_pc_i           (simt_stack_pc_i),
      .cta_status_i              (cta_status_i),
      .clear_prefetch_valid_o    (clear_prefetch_valid_o),
      .clear_prefetch_hw_cta_id_o(clear_prefetch_hw_cta_id_o),
      .predict_miss_flush_o      (predict_miss_flush_o),
      .cm0_data_o                (cm0_data_o),
      .cm0_chunk_en_o            (cm0_chunk_en_o),
      .cm1_data_o                (cm1_data_o),
      .cm1_chunk_en_o            (cm1_chunk_en_o)
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
    simt_stack_pc_i                      = '0;
    cta_status_i                         = '0;

    // Initialize scheduler interface
    schedule_if.valid                    = 1'b0;
    schedule_if.data                     = '0;

    // Initialize FDR interface
    fdr_if.ready                         = 1'b1;

    // Initialize cache buses slave side
    metacache_mem_if.req_ready           = 1'b1;
    metacache_mem_if.rsp_valid           = 1'b0;
    metacache_mem_if.rsp_data.data       = '0;
    metacache_mem_if.rsp_data.tag        = '0;

    bitstream_cache_mem_if.req_ready     = 1'b1;
    bitstream_cache_mem_if.rsp_valid     = 1'b0;
    bitstream_cache_mem_if.rsp_data.data = '0;
    bitstream_cache_mem_if.rsp_data.tag  = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] fdr_top_tb: Test passed!", $time);
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
    $fsdbDumpfile("fdr_top_tb.fsdb");
    $fsdbDumpvars(0, fdr_top_tb);
  end
`endif

endmodule

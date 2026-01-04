`timescale 1ns/1ps
`include "VX_define.vh"

module meta_fetch_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int TagWidth = 48;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                                                     clk;
  logic                                                                     rst;

  // DUT I/O
  logic                                                                     schedule_valid_i;
  logic                            [         dice_pkg::DICE_ADDR_WIDTH-1:0] fdr_next_pc_i;
  logic                            [dice_frontend_pkg::EBLOCK_ID_WIDTH-1:0] schedule_eblock_id_i;
  logic                                                                     schedule_ready_o;
  dice_frontend_pkg::pgraph_meta_t                                          outgoing_meta_o;
  logic                                                                     meta_valid_o;
  logic                                                                     fire_eblock_i;

  // Cache bus interface
  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(TagWidth)
  ) meta_fetch_bus_if ();

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
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
      .fire_eblock_i       (fire_eblock_i)
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
    schedule_valid_i                = 1'b0;
    fdr_next_pc_i                   = '0;
    schedule_eblock_id_i            = '0;
    fire_eblock_i                   = 1'b0;

    // Initialize cache bus slave side
    meta_fetch_bus_if.req_ready     = 1'b1;
    meta_fetch_bus_if.rsp_valid     = 1'b0;
    meta_fetch_bus_if.rsp_data.data = '0;
    meta_fetch_bus_if.rsp_data.tag  = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] meta_fetch_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("meta_fetch_tb.fsdb");
    $fsdbDumpvars(0, meta_fetch_tb);
  end
`endif

endmodule

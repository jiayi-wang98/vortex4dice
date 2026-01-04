`timescale 1ns / 1ps
`include "dice_define.vh"

module decode_tb;
  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic clk;
  logic rst;

  // DUT I/O
  dice_frontend_pkg::pgraph_meta_t metadata_i;
  logic meta_in_valid_i;
  dice_frontend_pkg::thread_mask_t real_active_thread_mask_i;

  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] bitstream_addr_o;
  logic bitstream_addr_valid_o;
  logic [dice_frontend_pkg::BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length_o;
  dice_frontend_pkg::branch_meta_t branch_metadata_o;
  logic branch_req_valid_o;
  logic is_barrier_o;
  dice_frontend_pkg::fdr_meta_t meta_o;

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  decode u_dut (
      .metadata_i               (metadata_i),
      .meta_in_valid_i          (meta_in_valid_i),
      .real_active_thread_mask_i(real_active_thread_mask_i),
      .bitstream_addr_o         (bitstream_addr_o),
      .bitstream_addr_valid_o   (bitstream_addr_valid_o),
      .bitstream_length_o       (bitstream_length_o),
      .branch_metadata_o        (branch_metadata_o),
      .branch_req_valid_o       (branch_req_valid_o),
      .is_barrier_o             (is_barrier_o),
      .meta_o                   (meta_o)
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
    metadata_i                = '0;
    meta_in_valid_i           = 1'b0;
    real_active_thread_mask_i = '1;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] decode_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("decode_tb.fsdb");
    $fsdbDumpvars(0, decode_tb);
  end
`endif

endmodule


`timescale 1ns/1ps
`include "dice_define.vh"

module cta_status_table_tb;
  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic clk;
  logic rst;

  // DUT I/O
  dice_pkg::branch_predict_interface_t branch_predict_info_i;
  logic branch_predict_info_we_i;

  dice_pkg::block_retire_status_t brt_info_i;
  logic brt_info_we_i;

  logic clear_entry_valid_i;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id_i;

  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_o;

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  cta_status_table u_dut (
      .clk_i                   (clk),
      .rst_i                   (rst),
      .branch_predict_info_i   (branch_predict_info_i),
      .branch_predict_info_we_i(branch_predict_info_we_i),
      .brt_info_i              (brt_info_i),
      .brt_info_we_i           (brt_info_we_i),
      .clear_entry_valid_i     (clear_entry_valid_i),
      .clear_entry_hw_id_i     (clear_entry_hw_id_i),
      .cta_status_o            (cta_status_o)
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
    branch_predict_info_i    = '0;
    branch_predict_info_we_i = 1'b0;
    brt_info_i               = '0;
    brt_info_we_i            = 1'b0;
    clear_entry_valid_i      = 1'b0;
    clear_entry_hw_id_i      = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] cta_status_table_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("cta_status_table_tb.fsdb");
    $fsdbDumpvars(0, cta_status_table_tb);
  end
`endif

endmodule

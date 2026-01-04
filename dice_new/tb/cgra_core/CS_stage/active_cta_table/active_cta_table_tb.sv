`timescale 1ns/1ps
`include "dice_define.vh"

module active_cta_table_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                                                     clk;
  logic                                                                     rst;

  // DUT I/O
  logic                                                                     add_ready_o;
  logic                                                                     add_valid_i;
  dice_pkg::dice_cta_desc_t                                                 add_cta_info_i;
  logic                           [             dice_pkg::DICE_TID_WIDTH:0] add_cta_size_i;

  logic                                                                     pop_valid_i;
  logic                           [     dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] pop_hw_cta_id_i;
  logic                                                                     pop_ready_o;

  logic                                                                     out_valid_o;
  dice_pkg::dice_cta_id_t                                                   out_cta_id_o;
  logic                           [           dice_pkg::DICE_TID_WIDTH-1:0] out_cta_size_o;
  logic                           [     dice_pkg::DICE_KERNEL_ID_WIDTH-1:0] out_kernel_id_o;

  dice_frontend_pkg::active_cta_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries_o;

  logic                                                                     full_o;
  logic                           [     dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index_o;

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  active_cta_table #(
      .THREAD_WIDTH(ThreadWidth)
  ) u_dut (
      .clk_i                 (clk),
      .rst_i                 (rst),
      .add_ready_o           (add_ready_o),
      .add_valid_i           (add_valid_i),
      .add_cta_info_i        (add_cta_info_i),
      .add_cta_size_i        (add_cta_size_i),
      .pop_valid_i           (pop_valid_i),
      .pop_hw_cta_id_i       (pop_hw_cta_id_i),
      .pop_ready_o           (pop_ready_o),
      .out_valid_o           (out_valid_o),
      .out_cta_id_o          (out_cta_id_o),
      .out_cta_size_o        (out_cta_size_o),
      .out_kernel_id_o       (out_kernel_id_o),
      .active_cta_entries_o  (active_cta_entries_o),
      .full_o                (full_o),
      .next_empty_cta_index_o(next_empty_cta_index_o)
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
    add_valid_i     = 1'b0;
    add_cta_info_i  = '0;
    add_cta_size_i  = '0;
    pop_valid_i     = 1'b0;
    pop_hw_cta_id_i = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] active_cta_table_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("active_cta_table_tb.fsdb");
    $fsdbDumpvars(0, active_cta_table_tb);
  end
`endif

endmodule

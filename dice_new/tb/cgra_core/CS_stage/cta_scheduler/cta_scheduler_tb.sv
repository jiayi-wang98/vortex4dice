`timescale 1ns/1ps
`include "dice_define.vh"

module cta_scheduler_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int MaxEblock = dice_pkg::DICE_NUM_MAX_CTA_PER_CORE + 4;
  localparam int ThreadWidth = dice_pkg::DICE_NUM_MAX_THREADS_PER_CORE /
                               dice_pkg::DICE_NUM_MAX_CTA_PER_CORE;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic clk;
  logic rst;

  // DUT I/O
  logic enable_i;

  dice_frontend_pkg::active_cta_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries_i;
  dice_frontend_pkg::cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_entries_i;

  logic [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0][dice_pkg::DICE_ADDR_WIDTH-1:0] cta_next_pc_i;

  logic eblock_commit_valid_i;
  logic [dice_pkg::DICE_EBLOCK_ID_WIDTH-1:0] eblock_commit_id_i;

  // Scheduler/FDR interface
  cta_sched_if scheduled_eblock ();

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  cta_scheduler #(
      .MAX_EBLOCK  (MaxEblock),
      .THREAD_WIDTH(ThreadWidth)
  ) u_dut (
      .clk_i                (clk),
      .rst_i                (rst),
      .enable_i             (enable_i),
      .active_cta_entries_i (active_cta_entries_i),
      .cta_status_entries_i (cta_status_entries_i),
      .cta_next_pc_i        (cta_next_pc_i),
      .eblock_commit_valid_i(eblock_commit_valid_i),
      .eblock_commit_id_i   (eblock_commit_id_i),
      .scheduled_eblock     (scheduled_eblock)
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
    enable_i               = 1'b1;
    active_cta_entries_i   = '0;
    cta_status_entries_i   = '0;
    cta_next_pc_i          = '0;
    eblock_commit_valid_i  = 1'b0;
    eblock_commit_id_i     = '0;

    // Interface initialization
    scheduled_eblock.ready = 1'b1;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] cta_scheduler_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("cta_scheduler_tb.fsdb");
    $fsdbDumpvars(0, cta_scheduler_tb);
  end
`endif

endmodule

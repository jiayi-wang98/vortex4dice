// =============================================================================
// Testbench: cta_scheduler_tb.sv (simplified happy-path)
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module cta_scheduler_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  localparam int ThreadWidth = DICE_NUM_MAX_THREADS_PER_CORE / DICE_NUM_MAX_CTA_PER_CORE;
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 1000;

  logic clk;
  logic rst;

  logic enable_i;
  active_cta_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries_i;
  cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_entries_i;

  logic [DICE_NUM_MAX_CTA_PER_CORE-1:0][DICE_ADDR_WIDTH-1:0] cta_next_pc_i;
  logic [DICE_NUM_MAX_CTA_PER_CORE-1:0][ThreadWidth-1:0] stack_top_active_mask_i;

  logic eblock_commit_valid_i;
  logic [EBLOCK_ID_WIDTH-1:0] eblock_commit_id_i;

  cta_sched_if scheduled_eblock();

  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  cta_scheduler u_dut (
      .clk_i                  (clk),
      .rst_i                  (rst),
      .enable_i               (enable_i),
      .active_cta_entries_i   (active_cta_entries_i),
      .cta_status_entries_i   (cta_status_entries_i),
      .cta_next_pc_i          (cta_next_pc_i),
      .stack_top_active_mask_i(stack_top_active_mask_i),
      .eblock_commit_valid_i  (eblock_commit_valid_i),
      .eblock_commit_id_i     (eblock_commit_id_i),
      .scheduled_eblock       (scheduled_eblock)
  );

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst                    = 1'b1;
    enable_i               = 1'b1;
    active_cta_entries_i   = '0;
    cta_status_entries_i   = '0;
    cta_next_pc_i          = '0;
    stack_top_active_mask_i = '0;
    eblock_commit_valid_i  = 1'b0;
    eblock_commit_id_i     = '0;
    scheduled_eblock.ready = 1'b1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  initial begin
    logic [DICE_ADDR_WIDTH-1:0] start_pc;

    $display("cta_scheduler_tb (happy-path)");

    reset_dut();

    start_pc = 32'h0000_1000;

    // Single active CTA
    active_cta_entries_i[0].cta_valid        = 1'b1;
    active_cta_entries_i[0].cta_id.x         = '0;
    active_cta_entries_i[0].cta_id.y         = '0;
    active_cta_entries_i[0].cta_id.z         = '0;
    active_cta_entries_i[0].grid_size.x      = 1;
    active_cta_entries_i[0].grid_size.y      = 1;
    active_cta_entries_i[0].grid_size.z      = 1;
    active_cta_entries_i[0].cta_size.x       = 1;
    active_cta_entries_i[0].cta_size.y       = 1;
    active_cta_entries_i[0].cta_size.z       = 1;
    active_cta_entries_i[0].kernel_id        = '0;
    active_cta_entries_i[0].smem_per_cta     = '0;
    active_cta_entries_i[0].hw_cta_size      = CTA_SIZE_1;
    active_cta_entries_i[0].cta_thread_count = ThreadWidth;

    cta_status_entries_i[0].is_prefetch = 1'b0;
    cta_status_entries_i[0].predict_pc  = '0;

    cta_next_pc_i[0] = start_pc;
    stack_top_active_mask_i[0] = {ThreadWidth{1'b1}};


    repeat (5) @(posedge clk);

    wait (scheduled_eblock.valid == 1'b1);
    assert (scheduled_eblock.data.schedule_next_pc == start_pc)
      else $fatal(1, "schedule_next_pc mismatch");
    assert (scheduled_eblock.data.schedule_hw_cta_id == '0)
      else $fatal(1, "schedule_hw_cta_id mismatch");

    $display("PASS: scheduled one CTA");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

`ifdef VCD
  initial begin
    $dumpfile("cta_scheduler_tb.vcd");
    $dumpvars(0, cta_scheduler_tb);
  end
`endif

endmodule

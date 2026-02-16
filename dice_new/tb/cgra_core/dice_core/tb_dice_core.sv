// `timescale 1ns/1ps
`include "dice_define.vh"

module tb_dice_core;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int TimeoutCycles = 1000;
  localparam int ClkPeriod     = 10;

  // =========================================================================
  // Signals
  // =========================================================================
  logic clk;
  logic reset;

  // Host/Dispatcher Interface - CTA Allocation
  logic           cta_add_valid_i;
  logic           cta_add_ready_o;
  dice_cta_desc_t new_cta_desc_i;

  logic         cta_complete_valid_o;
  logic         cta_complete_ready_i;
  dice_cta_id_t cta_done_id_o;

  // Memory Bus Interfaces
  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(48)
  ) metacache_mem_if ();

  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(48)
  ) bitstream_cache_mem_if ();

  int cycle_count;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  dice_core u_dut (
      .clk_i                   (clk),
      .rst_i                   (reset),
      .cta_add_valid_i         (cta_add_valid_i),
      .cta_add_ready_o         (cta_add_ready_o),
      .new_cta_desc_i          (new_cta_desc_i),
      .cta_complete_valid_o    (cta_complete_valid_o),
      .cta_complete_ready_i    (cta_complete_ready_i),
      .cta_done_id_o           (cta_done_id_o),
      .metacache_mem_if        (metacache_mem_if),
      .bitstream_cache_mem_if  (bitstream_cache_mem_if)
  );

  // =========================================================================
  // Clock Generation
  // =========================================================================
  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // =========================================================================
  // Helper Tasks
  // =========================================================================
  task automatic init_inputs();
    cta_add_valid_i      = 1'b0;
    new_cta_desc_i       = '0;
    cta_complete_ready_i = 1'b1;

    // Memory responses default to ready/idle in this skeleton.
    metacache_mem_if.req_ready = 1'b1;
    metacache_mem_if.rsp_valid = 1'b0;
    metacache_mem_if.rsp_data  = '0;

    bitstream_cache_mem_if.req_ready = 1'b1;
    bitstream_cache_mem_if.rsp_valid = 1'b0;
    bitstream_cache_mem_if.rsp_data  = '0;
  endtask

  task automatic reset_dut();
    reset = 1'b1;
    repeat (10) @(posedge clk);
    reset = 1'b0;
    @(posedge clk);
  endtask

  // =========================================================================
  // Placeholder Stimulus (Skeleton Only)
  // =========================================================================
  initial begin
    $display("dice_core skeleton testbench");
    reset = 1'b1;
    init_inputs();
    reset_dut();

    // TODO: Add directed/random test scenarios in a follow-up change.
    repeat (20) @(posedge clk);

    $display("dice_core skeleton testbench complete");
    $finish;
  end

`ifdef FSDB
  initial begin
    // Optional waveform dump hook for debug.
    $fsdbDumpfile("tb_dice_core.fsdb");
    $fsdbDumpvars(0, tb_dice_core);
  end
`endif

endmodule

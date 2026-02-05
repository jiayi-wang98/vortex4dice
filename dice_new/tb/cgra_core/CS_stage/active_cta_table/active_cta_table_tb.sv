// =============================================================================
// Testbench: active_cta_table_tb.sv (simplified happy-path)
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module active_cta_table_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 500;

  logic clk;
  logic rst;

  logic                            add_ready_o;
  logic                            add_valid_i;
  dice_cta_desc_t                  add_cta_info_i;
  cta_size_e                       add_hw_cta_size_i;
  logic [DICE_TID_WIDTH:0]         add_cta_thread_count_i;

  logic                            pop_valid_i;
  logic [DICE_HW_CTA_ID_WIDTH-1:0] pop_hw_cta_id_i;
  logic                            pop_ready_o;

  logic                            out_valid_o;
  logic                            out_ready_i;
  dice_cta_id_t                    out_cta_id_o;
  logic [DICE_TID_WIDTH-1:0]       out_cta_size_o;
  logic [DICE_KERNEL_ID_WIDTH-1:0] out_kernel_id_o;
  logic [DICE_TID_WIDTH:0]         out_cta_thread_count_o;

  active_cta_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries_o;

  logic                            full_o;
  logic [DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index_o;

  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  active_cta_table u_dut (
      .clk_i                 (clk),
      .rst_i                 (rst),
      .add_ready_o           (add_ready_o),
      .add_valid_i           (add_valid_i),
      .add_cta_info_i        (add_cta_info_i),
      .add_hw_cta_size_i     (add_hw_cta_size_i),
      .add_cta_thread_count_i(add_cta_thread_count_i),
      .pop_valid_i           (pop_valid_i),
      .pop_hw_cta_id_i       (pop_hw_cta_id_i),
      .pop_ready_o           (pop_ready_o),
      .out_valid_o           (out_valid_o),
      .out_ready_i           (out_ready_i),
      .out_cta_id_o          (out_cta_id_o),
      .out_cta_size_o        (out_cta_size_o),
      .out_kernel_id_o       (out_kernel_id_o),
      .out_cta_thread_count_o(out_cta_thread_count_o),
      .active_cta_entries_o  (active_cta_entries_o),
      .full_o                (full_o),
      .next_empty_cta_index_o(next_empty_cta_index_o)
  );

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst                   = 1'b1;
    add_valid_i           = 1'b0;
    add_cta_info_i        = '0;
    add_hw_cta_size_i     = CTA_SIZE_1;
    add_cta_thread_count_i = '0;
    pop_valid_i           = 1'b0;
    pop_hw_cta_id_i       = '0;
    out_ready_i           = 1'b1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  initial begin
    dice_cta_desc_t desc;

    $display("active_cta_table_tb (happy-path)");

    reset_dut();

    // Build a minimal CTA descriptor
    desc = '0;
    desc.cta_id.x = '0;
    desc.cta_id.y = '0;
    desc.cta_id.z = '0;
    desc.kernel_desc.cta_size.x = 1;
    desc.kernel_desc.cta_size.y = 1;
    desc.kernel_desc.cta_size.z = 1;
    desc.kernel_desc.grid_size.x = 1;
    desc.kernel_desc.grid_size.y = 1;
    desc.kernel_desc.grid_size.z = 1;

    // Add one CTA
    wait (add_ready_o == 1'b1);
    add_cta_info_i         = desc;
    add_hw_cta_size_i      = CTA_SIZE_1;
    add_cta_thread_count_i = 1;
    add_valid_i            = 1'b1;
    @(posedge clk);
    add_valid_i            = 1'b0;

    // Pop the CTA
    wait (pop_ready_o == 1'b1);
    pop_hw_cta_id_i = '0;
    pop_valid_i     = 1'b1;
    @(posedge clk);
    pop_valid_i     = 1'b0;

    // Check output
    wait (out_valid_o == 1'b1);
    assert (out_cta_id_o == desc.cta_id)
      else $fatal(1, "out_cta_id_o mismatch");

    $display("PASS: add -> pop -> output");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

`ifdef VCD
  initial begin
    $dumpfile("active_cta_table_tb.vcd");
    $dumpvars(0, active_cta_table_tb);
  end
`endif

endmodule

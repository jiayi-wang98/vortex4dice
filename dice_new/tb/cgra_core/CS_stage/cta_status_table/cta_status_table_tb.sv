// =============================================================================
// Testbench: cta_status_table_tb.sv (simplified happy-path)
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module cta_status_table_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 500;

  logic clk;
  logic rst;

  branch_predict_interface_t                                 branch_predict_info_i;
  logic                                                      branch_predict_info_we_i;
  block_retire_status_t                                      brt_info_i;
  logic                                                      brt_info_we_i;
  logic                                                      clear_entry_valid_i;
  logic                      [     DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id_i;
  dice_cta_status_t          [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_o;

  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

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

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst                      = 1'b1;
    branch_predict_info_i    = '0;
    branch_predict_info_we_i = 1'b0;
    brt_info_i               = '0;
    brt_info_we_i            = 1'b0;
    clear_entry_valid_i      = 1'b0;
    clear_entry_hw_id_i      = '0;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  initial begin
    logic [DICE_ADDR_WIDTH-1:0] predict_pc;

    $display("cta_status_table_tb (happy-path)");

    reset_dut();

    predict_pc = 32'hABCD_0000;

    branch_predict_info_i.hw_cta_id = '0;
    branch_predict_info_i.unresolved_control_divergence = 1'b1;
    branch_predict_info_i.predict_pc = predict_pc;
    branch_predict_info_i.is_return = 1'b1;
    branch_predict_info_i.is_barrier = 1'b0;

    branch_predict_info_we_i = 1'b1;
    @(posedge clk);
    branch_predict_info_we_i = 1'b0;

    @(posedge clk);
    assert (cta_status_o[0].prefetch_cleared == 1'b1)
      else $fatal(1, "prefetch_cleared not set");
    assert (cta_status_o[0].predict_pc == predict_pc)
      else $fatal(1, "predict_pc mismatch");
    assert (cta_status_o[0].is_return == 1'b1)
      else $fatal(1, "is_return not set");

    // Clear entry
    clear_entry_valid_i = 1'b1;
    clear_entry_hw_id_i = '0;
    @(posedge clk);
    clear_entry_valid_i = 1'b0;

    @(posedge clk);
    assert (cta_status_o[0].prefetch_cleared == 1'b0)
      else $fatal(1, "prefetch_cleared not cleared");
    assert (cta_status_o[0].predict_pc == '0)
      else $fatal(1, "predict_pc not cleared");
    assert (cta_status_o[0].is_return == 1'b0)
      else $fatal(1, "is_return not cleared");

    $display("PASS: branch predict update + clear");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

`ifdef VCD
  initial begin
    $dumpfile("cta_status_table_tb.vcd");
    $dumpvars(0, cta_status_table_tb);
  end
`endif

endmodule

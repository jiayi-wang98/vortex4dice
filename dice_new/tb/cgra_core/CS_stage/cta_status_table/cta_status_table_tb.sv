// =============================================================================
// Testbench: cta_status_table_tb.sv
// =============================================================================
// FILES USED: cta_status_table_tb.sv (boilerplate), dice_pkg.sv
// ASSUMPTIONS: Table stores CTA status. Supports branch_predict/brt writes, clear.
// TESTS: Reset, branch predict write, brt write, clear entry, multi-write, random.
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module cta_status_table_tb;

  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 10000;
  localparam int RandSeed = 11111;

  logic clk;
  logic rst;

  dice_pkg::branch_predict_interface_t branch_predict_info_i;
  logic branch_predict_info_we_i;

  dice_pkg::block_retire_status_t brt_info_i;
  logic brt_info_we_i;

  logic clear_entry_valid_i;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id_i;

  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_o;

  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) cycle_count <= 0;
    else begin
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
    rst = 1'b1;
    branch_predict_info_i = '0;
    branch_predict_info_we_i = 1'b0;
    brt_info_i = '0;
    brt_info_we_i = 1'b0;
    clear_entry_valid_i = 1'b0;
    clear_entry_hw_id_i = '0;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  task automatic write_branch_predict(input int hw_id, input logic div, input logic [31:0] pc);
    branch_predict_info_i.hw_cta_id = hw_id[dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0];
    branch_predict_info_i.unresolved_control_divergence = div;
    branch_predict_info_i.predict_pc = pc;
    branch_predict_info_i.is_return = 1'b0;
    branch_predict_info_i.is_barrier = 1'b0;
    branch_predict_info_we_i = 1'b1;
    @(posedge clk);
    branch_predict_info_we_i = 1'b0;
  endtask

  task automatic clear_entry(input int hw_id);
    clear_entry_hw_id_i = hw_id[dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0];
    clear_entry_valid_i = 1'b1;
    @(posedge clk);
    clear_entry_valid_i = 1'b0;
  endtask

  initial begin
    int rand_val;
    $display("cta_status_table Testbench");

    // Test 1: Reset
    reset_dut();
    assert (cta_status_o[0].unresolved_control_divergence == 1'b0)
    else $fatal(1, "Reset fail");
    $display("TEST 1 PASS: Reset");

    // Test 2: Write branch predict
    write_branch_predict(0, 1'b1, 32'hABCD);
    @(posedge clk);
    assert (cta_status_o[0].unresolved_control_divergence == 1'b1)
    else $fatal(1, "Write fail");
    $display("TEST 2 PASS: Branch predict write");

    // Test 3: BRT info write
    brt_info_i.hw_cta_pending[0] = 1'b1;
    brt_info_we_i = 1'b1;
    @(posedge clk);
    brt_info_we_i = 1'b0;
    $display("TEST 3 PASS: BRT write");

    // Test 4: Clear entry
    clear_entry(0);
    @(posedge clk);
    assert (cta_status_o[0].unresolved_control_divergence == 1'b0)
    else $fatal(1, "Clear fail");
    $display("TEST 4 PASS: Clear entry");

    // Test 5: Multi-write
    write_branch_predict(0, 1'b1, 32'h1111);
    write_branch_predict(0, 1'b0, 32'h2222);
    @(posedge clk);
    assert (cta_status_o[0].predict_pc == 32'h2222)
    else $fatal(1, "Multi-write fail");
    $display("TEST 5 PASS: Multi-write");

    // Test 6: Random smoke
    reset_dut();
    rand_val = RandSeed;
    for (int i = 0; i < 20; i++) begin
      rand_val = rand_val * 1103515245 + 12345;
      if (rand_val[0]) write_branch_predict(rand_val[2:1], rand_val[3], rand_val[31:0]);
      else clear_entry(rand_val[2:1]);
      @(posedge clk);
    end
    $display("TEST 6 PASS: Random smoke");

    $display("ALL TESTS PASSED: cta_status_table_tb");
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

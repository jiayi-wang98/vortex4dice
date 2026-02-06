// =============================================================================
// Testbench: tb_branch_handler.sv (placeholder)
// =============================================================================

`timescale 1ns / 1ps

module tb_branch_handler;
  initial begin
    $display("tb_branch_handler: SKIPPED (branch_handler RTL missing)");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end
endmodule

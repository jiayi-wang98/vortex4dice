// =============================================================================
// Testbench: branch_handler_tb.sv
// =============================================================================
// NOTE: The branch_handler.sv module is currently commented out.
// This testbench is a placeholder until the module is reimplemented.
// The branch_resolver.sv module has replaced this functionality.
// =============================================================================

`timescale 1ns / 1ps

module branch_handler_tb;

  initial begin
    $display("=============================================================");
    $display(" branch_handler Testbench");
    $display("=============================================================");
    $display(" NOTE: branch_handler.sv is currently commented out.");
    $display(" Use branch_resolver_tb.sv instead.");
    $display("=============================================================");
    $display(" SKIPPED: No tests to run");
    $display("=============================================================");

`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

endmodule

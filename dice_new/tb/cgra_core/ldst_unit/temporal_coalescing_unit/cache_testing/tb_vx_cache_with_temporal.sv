`timescale 1ns/1ps

module tb_vx_cache_with_temporal;

    // Clock & reset
    logic clk;
    logic rst;

    // Instantiate wrapper
    vx_cache_with_temporal wrapper_inst (
        .clk(clk),
        .rst(rst),
    );

    

endmodule

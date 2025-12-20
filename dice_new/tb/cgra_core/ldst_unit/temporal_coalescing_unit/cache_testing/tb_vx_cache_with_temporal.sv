`timescale 1ns/1ps

module tb_vx_cache_with_temporal;

    // Clock & reset
    logic clk;
    logic rst;

    // Instantiate wrapper
    vx_cache_with_temporal wrapper_inst (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

    // Test procedure
    initial begin
        // Reset
        rst = 1;
        #20;
        rst = 0;
        #10;

        // Insert data 5 at address 1
        wrapper_inst.incmd_valid       = 1;
        wrapper_inst.incmd_block_id    = 4'd0;
        wrapper_inst.incmd_tid         = 10'd0;
        wrapper_inst.incmd_write_enable= 1'b1;
        wrapper_inst.incmd_write_data  = 64'd5;
        wrapper_inst.incmd_write_mask  = 8'h00;  // write all bytes
        wrapper_inst.incmd_address     = 64'd1;
        wrapper_inst.incmd_size        = 2'b11;  // 8B
        wrapper_inst.incmd_ld_dest_reg = 7'd0;

        // Wait for temporal to accept
        wait(wrapper_inst.incmd_ready);
        #10;
        wrapper_inst.incmd_valid = 0;

        // Step some cycles to let temporal unit coalesce
        repeat (10) @(posedge clk);

        // Observe temporal output
        $display("Temporal outcmd_valid = %b", wrapper_inst.outcmd_valid);
        $display("Temporal outcmd_address = %0d", wrapper_inst.outcmd_address);
        $display("Temporal outcmd_write_data = %0d", wrapper_inst.outcmd_write_data);

        // Here you can also inspect cache signals if connected:
        // e.g., $display("Cache core req ready = %b", wrapper_inst.cache_inst.core_bus_if[0].req_ready);

        #50;
        $finish;
    end

endmodule

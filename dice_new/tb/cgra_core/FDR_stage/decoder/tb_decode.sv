`timescale 1ns/1ps

// Import the package so the testbench understands pgraph_meta_t
import frontend_pkg::*;

module tb_decode;

    // =========================================================
    // Parameters & Signals
    // =========================================================
    parameter MASK_WIDTH = 512;

    // Inputs to DUT
    pgraph_meta_t           metadata_in;
    logic                   meta_in_valid;
    logic [MASK_WIDTH-1:0]  real_active_thread_mask;
    logic                   mask_valid;

    // Outputs from DUT
    logic [31:0]            bitstream_addr;
    logic                   bitstream_addr_valid;
    logic [7:0]             bitstream_length;
    logic [31:0]            branch_metadata;
    logic                   branch_req_valid;
    logic                   decode_valid;
    pgraph_meta_t           metadata_out;
    logic [MASK_WIDTH-1:0]  mask_out;

    // =========================================================
    // Device Under Test (DUT) Instantiation
    // =========================================================
    decode #(
        .MASK_WIDTH(MASK_WIDTH)
    ) dut (
        // Metadata inputs/outputs
        .metadata_in(metadata_in),
        .meta_in_valid(meta_in_valid),
        
        // Bitstream interface
        .bitstream_addr(bitstream_addr),
        .bitstream_addr_valid(bitstream_addr_valid),
        .bitstream_length(bitstream_length),
        
        // Branch interface
        .branch_metadata(branch_metadata),
        .branch_req_valid(branch_req_valid),
        
        // Active Mask interface
        .real_active_thread_mask(real_active_thread_mask),
        .mask_valid(mask_valid),
        
        // Valid Checker & Next Stage interface
        .decode_valid(decode_valid),
        .metadata_out(metadata_out),
        .mask_out(mask_out)
    );

    // =========================================================
    // Test Stimulus
    // =========================================================
    initial begin
        // 1. Initialize Inputs to 0
        $display("\n--- Simulation Start ---");
        metadata_in             = '0;
        meta_in_valid           = 0;
        real_active_thread_mask = '0;
        mask_valid              = 0;

        // Wait a bit to see the "reset" state in waveform
        #20;

        // ------------------------------------------------------------
        // Test Case 1: Incoming Metadata (Fetch stage provides data)
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 1: Driving valid metadata", $time);
        
        // Construct a fake p-graph metadata packet
        metadata_in.bitstream_addr   = 32'hDEAD_BEEF;
        metadata_in.bitstream_length = 8'h10;         // 16 bytes
        metadata_in.unrolling_factor = 2'b01;
        metadata_in.lat              = 8'd5;
        metadata_in.branch_meta      = 32'hCAFE_F00D;
        metadata_in.barrier          = 1'b1;
        
        // Assert Valid
        meta_in_valid = 1;

        #10; // Wait for signals to propagate

        // Check outputs automatically (Optional, but good for sanity)
        if (bitstream_addr !== 32'hDEAD_BEEF) $error("Mismatch: Bitstream Address");
        if (branch_metadata !== 32'hCAFE_F00D) $error("Mismatch: Branch Metadata");
        if (bitstream_addr_valid !== 1'b1) $error("Mismatch: Bitstream Valid");

        // ------------------------------------------------------------
        // Test Case 2: Incoming Mask (Branch handler resolves mask)
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 2: Driving active thread mask", $time);
        
        // Set first 4 bits to 1, rest 0
        real_active_thread_mask = {{MASK_WIDTH-4{1'b0}}, 4'b1111};
        mask_valid = 1;

        #10;

        if (decode_valid !== 1'b1) $error("Mismatch: Decode Valid");
        if (mask_out !== real_active_thread_mask) $error("Mismatch: Mask Out");

        // ------------------------------------------------------------
        // Test Case 3: Clear Signals (Simulate bubble/idle)
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 3: Clearing valid signals", $time);
        meta_in_valid = 0;
        mask_valid    = 0;
        
        // Note: The data buses (bitstream_addr, etc.) will likely hold 
        // the old values because it's combinational logic without a reset 
        // or muxing to 0. This is expected behavior for this module.
        
        #10;

        // ------------------------------------------------------------
        // Test Case 4: Modify Data without Valid (Glitch test)
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 4: Changing data while valid is low", $time);
        metadata_in.bitstream_addr = 32'h0000_1234;
        
        #10;

        $display("--- Simulation End ---");
        $stop; // Pause simulation
    end

endmodule
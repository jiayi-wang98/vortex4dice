`timescale 1ns/1ps

`include "VX_define.vh"

// 1. IMPORT PACKAGES
import dice_pkg::*;
import frontend_pkg::*;
import VX_gpu_pkg::*;

module tb_decode;

    // =========================================================
    // 1. Signals & Interface
    // =========================================================
    // Use the typedefs directly from frontend_pkg
    pgraph_meta_t       metadata_in;
    logic               meta_in_valid;
    
    thread_mask_t       real_active_thread_mask;
    logic               mask_valid;

    // Outputs from DUT
    // Use package constants for widths
    logic [BITSTREAM_ADDR_WIDTH-1:0]   bitstream_addr;
    logic                              bitstream_addr_valid;
    logic [BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length;
    
    logic [31:0]        branch_metadata;
    logic               branch_req_valid;
    logic               decode_valid;
    
    pgraph_meta_t       metadata_out;
    thread_mask_t       mask_out;

    // =========================================================
    // 2. DUT Instantiation (FIXED)
    // =========================================================
    decode dut (
        // No parameters here! The module gets them from the package.
        
        // Metadata inputs/outputs
        .metadata_in            (metadata_in),
        .meta_in_valid          (meta_in_valid),
        
        // Bitstream interface
        .bitstream_addr         (bitstream_addr),
        .bitstream_addr_valid   (bitstream_addr_valid),
        .bitstream_length       (bitstream_length),
        
        // Branch interface
        .branch_metadata        (branch_metadata),
        .branch_req_valid       (branch_req_valid),
        
        // Active Mask interface
        .real_active_thread_mask(real_active_thread_mask),
        .mask_valid             (mask_valid),
        
        // Valid Checker & Next Stage interface
        .decode_valid           (decode_valid),
        .metadata_out           (metadata_out),
        .mask_out               (mask_out)
    );

    // =========================================================
    // 3. Test Stimulus
    // =========================================================
    initial begin
        // Initialize Inputs
        $display("\n--- Simulation Start ---");
        metadata_in             = '0;
        meta_in_valid           = 0;
        real_active_thread_mask = '0;
        mask_valid              = 0;

        #20;

        // ------------------------------------------------------------
        // Test Case 1: Incoming Metadata
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 1: Driving valid metadata", $time);
        
        metadata_in.bitstream_addr   = 32'hDEAD_BEEF;
        metadata_in.bitstream_length = 8'h10;         
        metadata_in.unrolling_factor = 2'b01;
        metadata_in.lat              = 8'd5;
        metadata_in.branch_meta      = 32'hCAFE_F00D;
        metadata_in.barrier          = 1'b1;
        
        meta_in_valid = 1;

        #10;

        // Checks
        if (bitstream_addr !== 32'hDEAD_BEEF) $error("Mismatch: Bitstream Address");
        if (branch_metadata !== 32'hCAFE_F00D) $error("Mismatch: Branch Metadata");
        if (bitstream_addr_valid !== 1'b1) $error("Mismatch: Bitstream Valid");

        // ------------------------------------------------------------
        // Test Case 2: Incoming Mask
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 2: Driving active thread mask", $time);
        
        // Create a mask (e.g., first 4 threads active)
        real_active_thread_mask = '0; 
        real_active_thread_mask[3:0] = 4'b1111;
        
        mask_valid = 1;

        #10;

        if (decode_valid !== 1'b1) $error("Mismatch: Decode Valid");
        if (mask_out !== real_active_thread_mask) $error("Mismatch: Mask Out");

        // ------------------------------------------------------------
        // Test Case 3: Clear Signals
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 3: Clearing valid signals", $time);
        meta_in_valid = 0;
        mask_valid    = 0;
        
        #10;

        // ------------------------------------------------------------
        // Test Case 4: Glitch Test
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 4: Changing data while valid is low", $time);
        metadata_in.bitstream_addr = 32'h0000_1234;
        
        #10;

        $display("--- Simulation End ---");
        $stop;
    end

endmodule
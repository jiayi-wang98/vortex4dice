/*
NOTE:
THIS TESTBENCH WAS AI GENERATED SOLELY
TO TEST BASIC FUNCTIONALITY SO BEFORE I DID A PR

I WILL MAKE IT MUCH MORE ROBUST LATER/ONCE I HAVE A BETTER
UNDERSTANDING DIFFERENT SITUATIONS TO TEST
*/


`timescale 1ns/1ps

// Ensure this define is available or remove if covered by dice_pkg
`ifndef VX_DEFINE_VH
`include "VX_define.vh" 
`endif

import dice_pkg::*;
import frontend_pkg::*;
import VX_gpu_pkg::*;

module tb_decode;

    // =========================================================
    // 1. Signals & Interface
    // =========================================================

    // Inputs
    pgraph_meta_t   metadata_in;
    logic           meta_in_valid;
    thread_mask_t   real_active_thread_mask; // Defined in frontend_pkg

    // Outputs (Wires)
    logic [BITSTREAM_ADDR_WIDTH-1:0]    bitstream_addr;
    logic                               bitstream_addr_valid;
    logic [BITSTREAM_LENGTH_WIDTH-1:0]  bitstream_length;

    logic [31:0]    branch_metadata;
    logic           branch_req_valid;
    logic           is_barrier;

    // Output Struct: Must match DUT output type (fdr_meta_t)
    fdr_meta_t      meta_out; 

    // =========================================================
    // 2. DUT Instantiation
    // =========================================================
    decode dut (
        // Inputs
        .metadata_in            (metadata_in),
        .meta_in_valid          (meta_in_valid),
        .real_active_thread_mask(real_active_thread_mask),

        // Bitstream Fetcher Interface
        .bitstream_addr         (bitstream_addr),
        .bitstream_addr_valid   (bitstream_addr_valid),
        .bitstream_length       (bitstream_length),

        // Branch Handler Interface
        .branch_metadata        (branch_metadata),
        .branch_req_valid       (branch_req_valid),

        // Valid Checker / Next Stage Interface
        .is_barrier             (is_barrier),
        .meta_out               (meta_out)
    );

    // =========================================================
    // 3. Test Stimulus
    // =========================================================
    initial begin
        // --- Initialize Inputs ---
        $display("\n--- Simulation Start ---");
        metadata_in             = '0;
        meta_in_valid           = 0;
        real_active_thread_mask = '0;

        #20;

        // ------------------------------------------------------------
        // Test Case 1: Standard Decode Operation
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 1: Driving valid metadata and mask", $time);

        // Populate Input Metadata (pgraph_meta_t)
        metadata_in.bitstream_addr   = 32'hDEAD_BEEF;
        metadata_in.bitstream_length = 8'h10;
        metadata_in.unrolling_factor = 2'b11;
        metadata_in.lat              = 8'd5;
        metadata_in.in_regs          = 34'h1_AAAA_AAAA;
        metadata_in.branch_meta      = 32'hCAFE_F00D;
        metadata_in.barrier          = 1'b1;
        metadata_in.parameter_load   = 1'b0;

        // Populate Mask
        real_active_thread_mask = '1; // Set all bits to 1 (broadcast)

        // Assert Valid
        meta_in_valid = 1;

        #10; // Wait for combinational logic

        // --- Verify Outputs ---
        
        // 1. Check Passthrough Signals (Bitstream)
        if (bitstream_addr !== 32'hDEAD_BEEF) 
            $error("Mismatch: bitstream_addr expected DEAD_BEEF, got %h", bitstream_addr);
        if (bitstream_addr_valid !== 1'b1) 
            $error("Mismatch: bitstream_addr_valid should be high");

        // 2. Check Branch Interface
        if (branch_metadata !== 32'hCAFE_F00D) 
            $error("Mismatch: branch_metadata expected CAFE_F00D, got %h", branch_metadata);
        if (branch_req_valid !== 1'b1) 
            $error("Mismatch: branch_req_valid should be high");

        // 3. Check Barrier
        if (is_barrier !== 1'b1) 
            $error("Mismatch: is_barrier should be high");

        // 4. Check Struct Packing (meta_out)
        // Verify that the mask was packed correctly into fdr_meta_t
        if (meta_out.active_mask !== real_active_thread_mask) 
            $error("Mismatch: meta_out.active_mask does not match input mask");
        
        // Verify a field passed from metadata_in to meta_out
        if (meta_out.lat !== 8'd5)
            $error("Mismatch: meta_out.lat expected 5, got %d", meta_out.lat);

        $display("[Time %0t] Checks Complete for Test Case 1.", $time);

        // ------------------------------------------------------------
        // Test Case 2: Invalidate Signals
        // ------------------------------------------------------------
        $display("[Time %0t] Test Case 2: Dropping valid signal", $time);
        meta_in_valid = 0;
        
        #10;

        if (bitstream_addr_valid !== 1'b0) 
            $error("Mismatch: bitstream_addr_valid should be low");
        
        // Note: Data buses (like bitstream_addr) may hold old values or go X depending on logic,
        // but the VALID signal must be low.

        $display("--- Simulation End ---");
        $stop;
    end

endmodule
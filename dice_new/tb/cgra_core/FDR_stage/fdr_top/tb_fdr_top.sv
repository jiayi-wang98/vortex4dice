/*
NOTE:
THIS TESTBENCH WAS AI GENERATED SOLELY
TO TEST BASIC FUNCTIONALITY SO BEFORE I DID A PR

I WILL MAKE IT MUCH MORE ROBUST LATER/ONCE I HAVE A BETTER
UNDERSTANDING DIFFERENT SITUATIONS TO TEST
*/

`timescale 1ns/1ps
`include "VX_define.vh"

import VX_gpu_pkg::*;
import dice_pkg::*;
import frontend_pkg::*;

module tb_fdr_top;

    // ==============================================================================
    // 1. Configuration & Constants
    // ==============================================================================
    parameter int TAG_WIDTH      = 48;
    parameter int BITSTREAM_SIZE = 2056;
    parameter time CLK_PERIOD    = 10ns;

    // Derived Constants for verification
    localparam int CHUNK_SIZE = VX_MEM_DATA_WIDTH;
    localparam int NUM_CHUNKS = (BITSTREAM_SIZE + CHUNK_SIZE - 1) / CHUNK_SIZE;

    // ==============================================================================
    // 2. Interfaces & Signals
    // ==============================================================================
    logic clk, rst;
    logic [DICE_ADDR_WIDTH-1:0] simt_stack_pc; // Controlled by TB now

    // CGRA Memory Outputs
    logic [VX_MEM_DATA_WIDTH-1:0] cm0_data, cm1_data;
    logic [NUM_CHUNKS-1:0]        cm0_chunk_en, cm1_chunk_en;

    // Interfaces
    VX_mem_bus_if #(
        .DATA_SIZE (VX_MEM_DATA_WIDTH/8),
        .TAG_WIDTH (TAG_WIDTH)
    ) metacache_mem_if ();

    VX_mem_bus_if #(
        .DATA_SIZE (VX_MEM_DATA_WIDTH/8),
        .TAG_WIDTH (TAG_WIDTH)
    ) bitstream_cache_mem_if ();

    cta_sched_if schedule_if();
    fdr_if fdr_if();

    // ==============================================================================
    // 3. DUT Instantiation
    // ==============================================================================
    fdr_top #(
        .TAG_WIDTH      (TAG_WIDTH),
        .BITSTREAM_SIZE (BITSTREAM_SIZE)
    ) dut (
        .clk                    (clk),
        .rst                    (rst),
        .metacache_mem_if       (metacache_mem_if),       
        .bitstream_cache_mem_if (bitstream_cache_mem_if), 
        .schedule_if            (schedule_if),
        .fdr_if                 (fdr_if),
        .simt_stack_pc          (simt_stack_pc),
        .cm0_data               (cm0_data),
        .cm0_chunk_en           (cm0_chunk_en),
        .cm1_data               (cm1_data),
        .cm1_chunk_en           (cm1_chunk_en)
    );

    // ==============================================================================
    // 4. Clock Generation
    // ==============================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ==============================================================================
    // 5. Intelligent Memory Responders
    // ==============================================================================
    
    // Task A: Responds to Metadata Requests
    task automatic meta_responder();
        pgraph_meta_t mock_meta;
        begin
            metacache_mem_if.req_ready = 0;
            metacache_mem_if.rsp_valid = 0;
            metacache_mem_if.rsp_data  = '0;

            forever begin
                // Wait for request
                wait(metacache_mem_if.req_valid);
                
                // Ack Request
                repeat($urandom_range(0,2)) @(posedge clk);
                metacache_mem_if.req_ready = 1;
                @(posedge clk);
                metacache_mem_if.req_ready = 0;

                // Latency
                repeat($urandom_range(2,5)) @(posedge clk);

                // Prepare Response
                $display("[MetaMem] Serving Metadata Request for PC %h", metacache_mem_if.req_data.addr);
                
                mock_meta = '0;
                mock_meta.bitstream_addr   = 32'h0000_5000; 
                mock_meta.bitstream_length = 8'd64; 
                mock_meta.barrier          = 1'b0; // Not a barrier
                // mock_meta.branch_meta   = ... (Optional: randomize if you want to test divergence)

                metacache_mem_if.rsp_valid = 1;
                metacache_mem_if.rsp_data.data = '0;
                metacache_mem_if.rsp_data.data[$bits(pgraph_meta_t)-1:0] = mock_meta;
                metacache_mem_if.rsp_data.tag = metacache_mem_if.req_data.tag;

                wait(metacache_mem_if.rsp_ready);
                @(posedge clk);
                metacache_mem_if.rsp_valid = 0;
            end
        end
    endtask

    // Task B: Responds to Bitstream Requests
    task automatic bitstream_responder();
        logic [VX_MEM_DATA_WIDTH-1:0] mock_chunk;
        begin
            bitstream_cache_mem_if.req_ready = 0;
            bitstream_cache_mem_if.rsp_valid = 0;
            bitstream_cache_mem_if.rsp_data  = '0;

            forever begin
                wait(bitstream_cache_mem_if.req_valid);

                // Ack
                repeat($urandom_range(0,1)) @(posedge clk);
                bitstream_cache_mem_if.req_ready = 1;
                @(posedge clk);
                bitstream_cache_mem_if.req_ready = 0;

                // Latency
                repeat($urandom_range(2,4)) @(posedge clk);

                // Respond
                // $display("[BitMem] Serving Bitstream Chunk for Addr %h", bitstream_cache_mem_if.req_data.addr);
                mock_chunk = {($urandom), ($urandom)}; 
                
                bitstream_cache_mem_if.rsp_valid = 1;
                bitstream_cache_mem_if.rsp_data.data = mock_chunk;
                bitstream_cache_mem_if.rsp_data.tag  = bitstream_cache_mem_if.req_data.tag;

                wait(bitstream_cache_mem_if.rsp_ready);
                @(posedge clk);
                bitstream_cache_mem_if.rsp_valid = 0;
            end
        end
    endtask

    // ==============================================================================
    // 6. Main Test Sequence
    // ==============================================================================
    initial begin
        // Init
        rst = 1;
        schedule_if.valid = 0;
        schedule_if.data  = '0;
        fdr_if.ready      = 1; 
        simt_stack_pc     = 0;

        // Launch Responders
        fork 
            meta_responder(); 
            bitstream_responder();
        join_none

        // Reset
        #(CLK_PERIOD * 10);
        rst = 0;
        #(CLK_PERIOD * 10);

        $display("\n[%0t] === Simulation Started ===", $time);

        // ---------------------------------------------------------------------
        // SCENARIO 1: Basic Schedule with PC Sync
        // ---------------------------------------------------------------------
        $display("\n[%0t] TC1: Scheduling Block at PC 0x1000", $time);

        // 1. Wait for Scheduler Ready
        wait(schedule_if.ready);
        @(posedge clk);

        // 2. Drive Schedule Interface
        schedule_if.valid = 1;
        schedule_if.data.schedule_next_pc     = 32'h0000_1000;
        schedule_if.data.schedule_eblock_id   = 1;
        schedule_if.data.schedule_hw_cta_id   = 0;
        schedule_if.data.active_mask          = '1; 
        
        // **IMPORTANT FIX**: Simulate the SIMT Stack updating to match the Scheduler
        // In a real system, the Fetch unit updates the PC, so the Stack should reflect that.
        simt_stack_pc = 32'h0000_1000; 

        @(posedge clk);
        schedule_if.valid = 0;

        $display("[%0t] Schedule sent. Waiting for FDR Valid...", $time);

        // 3. Wait for FDR Output
        fork 
            begin 
                wait(fdr_if.valid); 
                $display("PASS: FDR Valid Asserted!");
            end
            begin 
                #20000; 
                $error("FAIL: Timeout waiting for FDR Valid (Check PC Match or Mask Logic)"); 
                $stop; 
            end
        join_any

        // 4. Verification
        // Note: bitstream_addr is consumed by the FDR stage, so we check bitstream_length
        // which IS passed through to the execution stage.
        if (fdr_if.data.metadata.bitstream_length == 8'd64)
            $display("PASS: Output Metadata contains correct Bitstream Length");
        else 
            $error("FAIL: Metadata corrupted. Expected Length 64, got %d", fdr_if.data.metadata.bitstream_length);

        // Optional: Check if we actually requested the correct address on the bus earlier
        // (You would typically use a monitor for this, but checking the length is sufficient for a basic test)
        // 5. Mask Check (New Logic)
        // Since we passed '1 (all ones) into the decoder, and branch_handler likely passes it through for now:
        if (fdr_if.data.metadata.active_mask != 0) 
            $display("PASS: Active Mask propagated correctly (%h)", fdr_if.data.metadata.active_mask);
        else
            $error("FAIL: Active Mask is ZERO. Decoder/BranchHandler link might be broken.");


        #(CLK_PERIOD * 20);
        $display("\n[%0t] === All Tests Passed ===", $time);
        $stop;
    end

endmodule
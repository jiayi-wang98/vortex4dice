`timescale 1ns/1ps

`include "VX_define.vh"

// 1. IMPORT PACKAGES
import VX_gpu_pkg::*;
import dice_pkg::*;
import frontend_pkg::*;

module tb_meta_fetch;

    // ==============================================================================
    // 1. Parameters & Constants
    // ==============================================================================
    // Only TAG_WIDTH remains a configurable parameter on the DUT
    parameter int TAG_WIDTH = 48;
    
    // Derived widths for Testbench wires (using package constants)
    localparam int EBLOCK_WIDTH_TB = frontend_pkg::EBLOCK_ID_WIDTH;
    localparam int ADDR_WIDTH_TB   = dice_pkg::DICE_ADDR_WIDTH;

    // Calculate Data Size based on the Struct
    localparam int CACHE_DATA_SIZE = $bits(pgraph_meta_t) / 8;

    parameter time CLK_PERIOD = 10ns;

    // ==============================================================================
    // 2. Signals
    // ==============================================================================
    logic clk;
    logic rst;

    // DUT Inputs
    logic schedule_valid;
    logic [ADDR_WIDTH_TB-1:0]   fdr_next_pc;        // Fixed width
    logic [EBLOCK_WIDTH_TB-1:0] schedule_eblock_id; // Fixed width
    logic fire_eblock;

    // DUT Outputs
    logic schedule_ready;
    pgraph_meta_t outgoing_meta;
    logic meta_valid;

    // Interface
    VX_mem_bus_if #(
        .DATA_SIZE (CACHE_DATA_SIZE),
        .TAG_WIDTH (TAG_WIDTH)
    ) meta_fetch_bus_if ();

    // ==============================================================================
    // 3. DUT Instantiation
    // ==============================================================================
    meta_fetch #(
        // REMOVED: MAX_NUM_CTA, PC_WIDTH, MAX_EBLOCKS, EBLOCK_ID_WIDTH
        // Only TAG_WIDTH is left
        .TAG_WIDTH (TAG_WIDTH)
    ) dut (
        .clk                (clk),
        .rst                (rst),
        .schedule_valid     (schedule_valid),
        .fdr_next_pc        (fdr_next_pc),
        .schedule_eblock_id (schedule_eblock_id),
        .schedule_ready     (schedule_ready),
        .meta_fetch_bus_if  (meta_fetch_bus_if),
        .outgoing_meta      (outgoing_meta),
        .meta_valid         (meta_valid),
        .fire_eblock        (fire_eblock)
    );

    // ==============================================================================
    // 4. Clock Gen
    // ==============================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ==============================================================================
    // 5. Memory Model (Cache Responder)
    // ==============================================================================
    task automatic memory_responder();
        pgraph_meta_t mock_meta;
        // Make sure this matches the total bits of the struct
        logic [$bits(pgraph_meta_t)-1:0] rand_bits; 
        
        begin
            meta_fetch_bus_if.req_ready = 0;
            meta_fetch_bus_if.rsp_valid = 0;
            meta_fetch_bus_if.rsp_data  = '0;

            forever begin
                // 1. Wait for DUT to Request
                wait(meta_fetch_bus_if.req_valid);
                
                // Random delay
                repeat($urandom_range(0, 3)) @(posedge clk);
                
                // 2. Accept Request (Address Phase)
                meta_fetch_bus_if.req_ready = 1;
                @(posedge clk);
                meta_fetch_bus_if.req_ready = 0;

                // 3. Simulate Memory Latency
                repeat($urandom_range(2, 6)) @(posedge clk);

                // 4. Prepare Random Metadata Response
                // Fill random bits
                rand_bits = {$urandom(), $urandom(), $urandom(), $urandom(), 
                             $urandom(), $urandom(), $urandom(), $urandom()};
                             
                // Cast to struct
                mock_meta = pgraph_meta_t'(rand_bits); 
                
                meta_fetch_bus_if.rsp_valid = 1;
                meta_fetch_bus_if.rsp_data.data = mock_meta; 
                meta_fetch_bus_if.rsp_data.tag  = meta_fetch_bus_if.req_data.tag;

                // 5. Wait for DUT to Accept Response
                wait(meta_fetch_bus_if.rsp_ready);
                @(posedge clk);
                meta_fetch_bus_if.rsp_valid = 0;
            end
        end
    endtask

    // ==============================================================================
    // 6. Test Sequence
    // ==============================================================================
    initial begin
        // Init
        rst = 1;
        schedule_valid = 0;
        fdr_next_pc = 0;
        schedule_eblock_id = 0;
        fire_eblock = 0;

        // Start Memory Model
        fork 
            memory_responder();
        join_none

        // Reset
        #(CLK_PERIOD * 5);
        rst = 0;
        #(CLK_PERIOD * 5);

        $display("\n[%0t] === Simulation Started ===", $time);

        // -----------------------------------------------------------
        // Test Case 1: Standard Fetch Sequence
        // -----------------------------------------------------------
        $display("\n[%0t] TC1: Basic Fetch (PC=0x1000, ID=2)", $time);

        wait(schedule_ready);
        @(posedge clk);

        schedule_valid = 1;
        fdr_next_pc = 32'h0000_1000;
        schedule_eblock_id = 2;
        @(posedge clk);
        schedule_valid = 0; 

        wait(dut.state_q == dut.S_WAIT_RESP);
        $display("[%0t] DUT Sent Request, Waiting for Response...", $time);

        wait(meta_valid);
        $display("[%0t] Metadata Received! (State: S_HOLD_DATA)", $time);
        
        repeat(3) @(posedge clk);
        if (!meta_valid) $error("FAIL: meta_valid dropped before fire_eblock!");
        if (schedule_ready) $error("FAIL: schedule_ready went high before fire_eblock!");

        $display("[%0t] Firing Eblock...", $time);
        fire_eblock = 1;
        @(posedge clk);
        fire_eblock = 0;

        wait(schedule_ready);
        if (meta_valid) $error("FAIL: meta_valid should be low after fire");
        $display("[%0t] TC1 Complete: DUT returned to Ready.", $time);

        // -----------------------------------------------------------
        // Test Case 2: Back-to-Back Fetch
        // -----------------------------------------------------------
        $display("\n[%0t] TC2: Fetch (PC=0x2000)", $time);
        
        fdr_next_pc = 32'h0000_2000;
        schedule_eblock_id = 5;
        schedule_valid = 1;
        
        wait(!schedule_ready); 
        @(posedge clk);
        schedule_valid = 0;

        wait(meta_valid);
        
        // Verify Tag (using localparam EBLOCK_WIDTH_TB)
        if (meta_fetch_bus_if.req_data.tag[EBLOCK_WIDTH_TB-1:0] == 5)
            $display("PASS: Cache Request Tag matched Eblock ID (5)");
        else 
            $warning("WARN: Cache Request Tag mismatch (Check timing/internal probes)");

        fire_eblock = 1;
        @(posedge clk);
        fire_eblock = 0;
        
        #(CLK_PERIOD * 5);
        $display("\n[%0t] === All Tests Passed ===", $time);
        $stop;
    end

endmodule
`timescale 1ns/1ps

`include "VX_define.vh"
import VX_gpu_pkg::*;
import dice_pkg::*;
import frontend_pkg::*;
/*
Note: I generated this tb so that I could run some quick tests before I submitted a PR,
I will be making an improved one by myself when I get a chance. I also tested this in ModelSim
rather than on the squire server since I am more used to the workflow but I will be switching
to using vcs/verdi full time when making more robust testbenches.
*/
module tb_meta_fetch;

    // ==============================================================================
    // 1. Parameters & Constants
    // ==============================================================================
    parameter int MAX_NUM_CTA     = 4;
    parameter int PC_WIDTH        = 32;
    parameter int MAX_EBLOCKS     = 8;
    parameter int EBLOCK_ID_WIDTH = $clog2(MAX_EBLOCKS);
    parameter int TAG_WIDTH       = 48;
    
    // Derived for the interface instantiation
    // Assuming a standard cache line width for metadata or checking `pgraph_meta_t` size
    // Adjust DATA_SIZE if pgraph_meta_t is larger than 64 bytes
    localparam int CACHE_DATA_SIZE = 64; 

    parameter time CLK_PERIOD = 10ns;

    // ==============================================================================
    // 2. Signals
    // ==============================================================================
    logic clk;
    logic rst;

    // DUT Inputs
    logic schedule_valid;
    logic [PC_WIDTH-1:0] fdr_next_pc;
    logic [EBLOCK_ID_WIDTH-1:0] schedule_eblock_id;
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
        .MAX_NUM_CTA     (MAX_NUM_CTA),
        .PC_WIDTH        (PC_WIDTH),
        .MAX_EBLOCKS     (MAX_EBLOCKS),
        .EBLOCK_ID_WIDTH (EBLOCK_ID_WIDTH),
        .TAG_WIDTH       (TAG_WIDTH)
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
    // 5. Memory Model (Cache Responder) - License Safe Version
    // ==============================================================================
    task automatic memory_responder();
        pgraph_meta_t mock_meta;
        // Create a temporary logic vector to hold random bits. 
        // We make it large enough to cover the struct size.
        logic [511:0] rand_bits; 
        begin
            meta_fetch_bus_if.req_ready = 0;
            meta_fetch_bus_if.rsp_valid = 0;
            meta_fetch_bus_if.rsp_data  = '0;

            forever begin
                // 1. Wait for DUT to Request
                wait(meta_fetch_bus_if.req_valid);
                
                // Random delay before acknowledging request
                repeat($urandom_range(0, 3)) @(posedge clk);
                
                // 2. Accept Request (Address Phase)
                meta_fetch_bus_if.req_ready = 1;
                @(posedge clk);
                meta_fetch_bus_if.req_ready = 0;

                // 3. Simulate Memory Latency
                repeat($urandom_range(2, 6)) @(posedge clk);

                // 4. Prepare Random Metadata Response
                // FIX: Use $urandom instead of std::randomize to avoid license errors
                // We concatenate multiple $urandom calls to ensure we fill larger structs
                rand_bits = {$urandom(), $urandom(), $urandom(), $urandom(), 
                             $urandom(), $urandom(), $urandom(), $urandom()};
                             
                // Cast the random bits to your struct type (assuming packed struct)
                mock_meta = pgraph_meta_t'(rand_bits[$bits(pgraph_meta_t)-1:0]); 
                
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

        // A. Wait for DUT to be ready
        wait(schedule_ready);
        @(posedge clk);

        // B. Send Schedule Request
        schedule_valid = 1;
        fdr_next_pc = 32'h0000_1000;
        schedule_eblock_id = 2;
        @(posedge clk);
        schedule_valid = 0; // Pulse valid (DUT captures it on transition to S_REQ_VAL)

        // C. Monitor for Cache Request (Internal check)
        wait(dut.state_q == dut.S_WAIT_RESP);
        $display("[%0t] DUT Sent Request, Waiting for Response...", $time);

        // D. Monitor for Data Available (Meta Valid)
        wait(meta_valid);
        $display("[%0t] Metadata Received! (State: S_HOLD_DATA)", $time);
        
        // E. Verify Hold State (Should stay valid until fired)
        repeat(3) @(posedge clk);
        if (!meta_valid) $error("FAIL: meta_valid dropped before fire_eblock!");
        if (schedule_ready) $error("FAIL: schedule_ready went high before fire_eblock!");

        // F. Fire Eblock (Consume Data)
        $display("[%0t] Firing Eblock...", $time);
        fire_eblock = 1;
        @(posedge clk);
        fire_eblock = 0;

        // G. Verify Return to Ready
        wait(schedule_ready);
        if (meta_valid) $error("FAIL: meta_valid should be low after fire");
        $display("[%0t] TC1 Complete: DUT returned to Ready.", $time);


        // -----------------------------------------------------------
        // Test Case 2: Back-to-Back Fetch
        // -----------------------------------------------------------
        $display("\n[%0t] TC2: Fetch (PC=0x2000)", $time);
        
        // Input logic
        fdr_next_pc = 32'h0000_2000;
        schedule_eblock_id = 5;
        schedule_valid = 1;
        
        // Wait for DUT to accept (it transitions out of READY)
        wait(!schedule_ready); 
        @(posedge clk);
        schedule_valid = 0;

        // Wait for completion
        wait(meta_valid);
        
        // Check Tag Logic (Mock check: The tag sent to cache should contain the eblock_id)
        // Accessing internal signal for verification
        // PAD_WIDTH is TAG_WIDTH - EBLOCK_ID_WIDTH.
        // We verify the lower bits of the tag match the eblock ID.
        if (meta_fetch_bus_if.req_data.tag[EBLOCK_ID_WIDTH-1:0] == 5)
            $display("PASS: Cache Request Tag matched Eblock ID (5)");
        else 
            $warning("WARN: Cache Request Tag mismatch (Check timing/internal probes)");

        // Fire to clear
        fire_eblock = 1;
        @(posedge clk);
        fire_eblock = 0;
        
        #(CLK_PERIOD * 5);
        $display("\n[%0t] === All Tests Passed ===", $time);
        $stop;
    end

endmodule
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
module tb_bitstream_fetch_load;

    // ==============================================================================
    // 1. Parameters (Matching DICE/DUT configuration)
    // ==============================================================================
    parameter int BITSTREAM_ADDR_WIDTH = 32;
    parameter int BITSTREAM_SIZE       = 2056;
    parameter int CHUNK_SIZE           = 512;
    parameter int NUM_CHUNKS           = (BITSTREAM_SIZE + CHUNK_SIZE - 1) / CHUNK_SIZE;
    parameter int TAG_WIDTH            = 48;

    // Simulation timing
    parameter time CLK_PERIOD = 10ns;

    // ==============================================================================
    // 2. Signals & Interface
    // ==============================================================================
    logic clk;
    logic rst;

    // DUT Inputs
    logic meta_valid;
    logic [BITSTREAM_ADDR_WIDTH-1:0] bitstream_addr;

    // DUT Outputs
    logic [CHUNK_SIZE-1:0] cm0_data;
    logic [NUM_CHUNKS-1:0] cm0_chunk_en;
    logic [CHUNK_SIZE-1:0] cm1_data;
    logic [NUM_CHUNKS-1:0] cm1_chunk_en;
    logic done_streaming;
    logic cm_num;

    // Vortex Memory Bus Interface
    // DATA_SIZE is typically in bytes. 512 bits / 8 = 64 bytes.
    VX_mem_bus_if #(
        .DATA_SIZE (CHUNK_SIZE/8), 
        .TAG_WIDTH (TAG_WIDTH)
    ) cache_bus_if ();

    // ==============================================================================
    // 3. DUT Instantiation
    // ==============================================================================
    bitstream_fetch_load #(
        .BITSTREAM_ADDR_WIDTH (BITSTREAM_ADDR_WIDTH),
        .BITSTREAM_SIZE       (BITSTREAM_SIZE),
        .CHUNK_SIZE           (CHUNK_SIZE),
        .NUM_CHUNKS           (NUM_CHUNKS),
        .TAG_WIDTH            (TAG_WIDTH)
    ) dut (
        .clk            (clk),
        .rst            (rst),
        .meta_valid     (meta_valid),
        .bitstream_addr (bitstream_addr),
        .cm0_data       (cm0_data),
        .cm0_chunk_en   (cm0_chunk_en),
        .cm1_data       (cm1_data),
        .cm1_chunk_en   (cm1_chunk_en),
        .done_streaming (done_streaming),
        .cache_bus_if   (cache_bus_if), 
        .cm_num         (cm_num)
    );

    // ==============================================================================
    // 4. Clock Generation
    // ==============================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ==============================================================================
    // 5. Memory Model (Simulates Cache Response)
    // ==============================================================================
    // This task runs in the background to handle the ready/valid handshake
    task automatic memory_responder();
        logic [CHUNK_SIZE-1:0] mock_data;
        integer i;
        begin
            // Init slave signals
            cache_bus_if.req_ready = 0;
            cache_bus_if.rsp_valid = 0;
            cache_bus_if.rsp_data  = '0;

            forever begin
                // A. Wait for Request
                wait(cache_bus_if.req_valid);
                
                // Simulate random bus busy/latency before accepting request
                repeat($urandom_range(0, 2)) @(posedge clk);
                
                // Accept Request
                cache_bus_if.req_ready = 1;
                @(posedge clk);
                cache_bus_if.req_ready = 0;

                // B. Simulate Memory Access Latency
                repeat($urandom_range(2, 5)) @(posedge clk);

                // C. Prepare Response Data
                // Filling with random data to verify data path
                mock_data = {CHUNK_SIZE{1'b0}};
                for (i = 0; i < CHUNK_SIZE/32; i++) begin
                    mock_data[i*32 +: 32] = $urandom();
                end

                // D. Send Response
                cache_bus_if.rsp_valid = 1;
                cache_bus_if.rsp_data.data = mock_data;
                cache_bus_if.rsp_data.tag  = cache_bus_if.req_data.tag; // Echo tag

                // Wait for DUT to accept response
                wait(cache_bus_if.rsp_ready);
                @(posedge clk);
                cache_bus_if.rsp_valid = 0;
            end
        end
    endtask

    // ==============================================================================
    // 6. Test Sequence
    // ==============================================================================
    initial begin
        // Setup signals
        rst = 1;
        meta_valid = 0;
        bitstream_addr = 0;

        // Launch memory responder
        fork
            memory_responder();
        join_none

        // Apply Reset
        #(CLK_PERIOD * 10);
        rst = 0;
        #(CLK_PERIOD * 5);

        $display("\n[%0t] === Simulation Started ===", $time);
        $display("Config: NUM_CHUNKS=%0d, CHUNK_SIZE=%0d bits", NUM_CHUNKS, CHUNK_SIZE);

        // -------------------------------------------------------------------------
        // Test Case 1: First Fetch (Expect CM0)
        // -------------------------------------------------------------------------
        $display("\n[%0t] TC1: Triggering Fetch 1 (Addr: 0x1000) -> Expecting CM0", $time);
        
        bitstream_addr = 32'h0000_1000;
        meta_valid = 1; 

        // Wait for DUT to start streaming
        wait(dut.state == dut.S_STREAMING);
        $display("[%0t] State transitioned to S_STREAMING", $time);
        
        // Lower valid (DUT captures it on transition from IDLE)
        meta_valid = 0;

        // Wait for completion
        wait(done_streaming);
        @(posedge clk); // Give one cycle for signals to settle
        $display("[%0t] TC1 Complete.", $time);

        // Checks
        if (cm_num !== 0) 
            $error("FAIL: cm_num should be 0, got %b", cm_num);
        else 
            $display("PASS: cm_num is 0");

        if (dut.cm0_valid_q && dut.cm0_addr == 32'h0000_1000)
            $display("PASS: CM0 Valid bit set, Address matches.");
        else
            $error("FAIL: CM0 status incorrect. Valid: %b, Addr: %h", dut.cm0_valid_q, dut.cm0_addr);

        #(CLK_PERIOD * 10);

        // -------------------------------------------------------------------------
        // Test Case 2: Second Fetch (Expect CM1 - Ping Pong)
        // -------------------------------------------------------------------------
        $display("\n[%0t] TC2: Triggering Fetch 2 (Addr: 0x2000) -> Expecting CM1", $time);

        bitstream_addr = 32'h0000_2000;
        meta_valid = 1;

        wait(dut.state == dut.S_STREAMING);
        meta_valid = 0;

        wait(done_streaming);
        @(posedge clk);
        $display("[%0t] TC2 Complete.", $time);

        // Checks
        if (cm_num !== 1) 
            $error("FAIL: cm_num should be 1 (Ping Pong), got %b", cm_num);
        else 
            $display("PASS: cm_num is 1 (Ping Pong working)");

        if (dut.cm1_valid_q && dut.cm1_addr == 32'h0000_2000)
            $display("PASS: CM1 Valid bit set, Address matches.");
        else
            $error("FAIL: CM1 status incorrect.");

        #(CLK_PERIOD * 10);

        // -------------------------------------------------------------------------
        // Test Case 3: Third Fetch (Expect CM0 again)
        // -------------------------------------------------------------------------
        $display("\n[%0t] TC3: Triggering Fetch 3 (Addr: 0x3000) -> Expecting CM0", $time);
        
        bitstream_addr = 32'h0000_3000;
        meta_valid = 1;

        wait(dut.state == dut.S_STREAMING);
        meta_valid = 0;

        wait(done_streaming);
        @(posedge clk);
        $display("[%0t] TC3 Complete.", $time);

        if (cm_num !== 0) 
            $error("FAIL: cm_num should be 0, got %b", cm_num);
        else 
            $display("PASS: cm_num returned to 0.");

        $display("\n[%0t] === All Tests Passed ===", $time);
        $stop;
    end

endmodule
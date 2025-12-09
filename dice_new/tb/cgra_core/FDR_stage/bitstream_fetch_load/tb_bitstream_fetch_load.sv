`timescale 1ns/1ps

`include "VX_define.vh"
import VX_gpu_pkg::*;
import frontend_pkg::*;

module tb_bitstream_fetch_load;

    // =========================================================================
    // Parameters ( configured for "Atomic Chunk" strategy)
    // =========================================================================
    // Assuming a 128-bit cache bus
    localparam int CACHE_BUS_WIDTH = 128; 
    
    // KEY: CHUNK_SIZE matches bus width to avoid packing logic
    localparam int CHUNK_SIZE = CACHE_BUS_WIDTH; 
    
    // Total size of one bitstream (256 bytes for this test)
    localparam int BITSTREAM_SIZE = 256 * 8; 
    localparam int ADDR_WIDTH = 32;

    // Calculated parameters
    localparam int NUM_CHUNKS = (BITSTREAM_SIZE + CHUNK_SIZE - 1) / CHUNK_SIZE; // Should be 16
    localparam int OFFSET = CHUNK_SIZE / 8; // 16 bytes

    // =========================================================================
    // Signals
    // =========================================================================
    logic clk;
    logic rst;

    // Decoder Interface
    logic meta_valid;
    logic [ADDR_WIDTH-1:0] bitstream_addr;

    // Buffer Interface
    logic [CHUNK_SIZE-1:0] cm0_data, cm1_data;
    logic [NUM_CHUNKS-1:0] cm0_chunk_en, cm1_chunk_en;
    logic cm_num;

    // Status
    logic done_streaming;
    logic fire_eblock;

    // Cache Interface (Instantiate the Interface)
    VX_mem_bus_if #(
        .DATA_SIZE(CACHE_BUS_WIDTH/8), 
        .TAG_WIDTH(VX_gpu_pkg::ICACHE_MEM_TAG_WIDTH)
    ) cache_bus_if();

    // =========================================================================
    // DUT Instantiation
    // =========================================================================
    bitstream_fetch_load #(
        .BITSTREAM_ADDR_WIDTH(ADDR_WIDTH),
        .BITSTREAM_SIZE(BITSTREAM_SIZE),
        .CHUNK_SIZE(CHUNK_SIZE), // 128
        .NUM_CHUNKS(NUM_CHUNKS)  // 16
    ) dut (
        .clk(clk),
        .rst(rst),
        .meta_valid(meta_valid),
        .bitstream_addr(bitstream_addr),
        .cm0_data(cm0_data),
        .cm0_chunk_en(cm0_chunk_en),
        .cm1_data(cm1_data),
        .cm1_chunk_en(cm1_chunk_en),
        .done_streaming(done_streaming),
        .fire_eblock(fire_eblock),
        .cache_bus_if(cache_bus_if),
        .cm_num(cm_num)
    );

    // =========================================================================
    // Clock Generation
    // =========================================================================
    always #5 clk = ~clk; // 10ns period

    // =========================================================================
    // Mock Cache Memory Task
    // =========================================================================
    // This process mimics the Vortex Memory System
    initial begin
        // Init slave signals
        cache_bus_if.req_ready = 0;
        cache_bus_if.rsp_valid = 0;
        cache_bus_if.rsp_data = '0;

        forever begin
            @(posedge clk);
            
            // 1. Randomly assert READY to accept requests
            cache_bus_if.req_ready <= ($urandom_range(0, 10) > 2); // 80% chance ready

            // 2. If we see a valid request, process it
            if (cache_bus_if.req_valid && cache_bus_if.req_ready) begin
                
                // Capture the address requested
                automatic logic [ADDR_WIDTH-1:0] req_addr = cache_bus_if.req_data.addr;
                
                // Simulate Memory Latency (1-5 cycles)
                repeat($urandom_range(1, 5)) @(posedge clk);

                // Send Response
                cache_bus_if.rsp_valid <= 1;
                // Generate data: Address + 0xAA for visibility
                cache_bus_if.rsp_data.data <= {4{req_addr[31:0]}} ^ {4{32'hAAAAAAAA}}; 
                cache_bus_if.rsp_data.tag <= cache_bus_if.req_data.tag;
                
                // Wait for DUT to accept response
                do begin
                    @(posedge clk);
                end while (!cache_bus_if.rsp_ready);
                
                cache_bus_if.rsp_valid <= 0;
            end
        end
    end

    // =========================================================================
    // Test Sequence
    // =========================================================================
    initial begin
        // Setup
        clk = 0;
        rst = 1;
        meta_valid = 0;
        bitstream_addr = 0;
        fire_eblock = 0;

        // Reset Pulse
        #20 rst = 0;
        #20;

        $display("=== TEST START: NUM_CHUNKS = %0d, CHUNK_SIZE = %0d ===", NUM_CHUNKS, CHUNK_SIZE);

        // ---------------------------------------------------------------------
        // TEST CASE 1: Load Stream A (Cold Miss -> Fills CM0)
        // ---------------------------------------------------------------------
        $display("\n[T= %0t] Test 1: Load Stream A (Addr 0x1000)", $time);
        bitstream_addr = 32'h1000;
        meta_valid = 1; // Trigger logic

        // Wait until done
        wait(done_streaming);
        $display("[T= %0t] Stream A Loaded!", $time);
        
        // Checks
        assert(cm_num == 0) else $error("Error: Should have selected CM0");
        assert(dut.cm0_valid_q == 1) else $error("Error: CM0 should be valid");

        // Stop valid signal to simulate decoder moving on (optional in level logic but good practice)
        meta_valid = 0; 
        #50;

        // ---------------------------------------------------------------------
        // TEST CASE 2: Load Stream B (Cold Miss -> Fills CM1)
        // ---------------------------------------------------------------------
        $display("\n[T= %0t] Test 2: Load Stream B (Addr 0x2000)", $time);
        bitstream_addr = 32'h2000;
        meta_valid = 1;

        wait(done_streaming);
        $display("[T= %0t] Stream B Loaded!", $time);

        // Checks
        assert(cm_num == 1) else $error("Error: Should have selected CM1");
        assert(dut.cm1_valid_q == 1) else $error("Error: CM1 should be valid");
        
        meta_valid = 0;
        #50;

        // ---------------------------------------------------------------------
        // TEST CASE 3: Reload Stream A (Cache Hit!)
        // ---------------------------------------------------------------------
        $display("\n[T= %0t] Test 3: Reload Stream A (Hit Check)", $time);
        bitstream_addr = 32'h1000;
        meta_valid = 1;

        // We expect done_streaming to go high IMMEDIATELY (within 1 cycle)
        // and NO activity on the cache bus.
        @(posedge clk);
        #1; 
        
        if (done_streaming) 
            $display("SUCCESS: Instant Hit Detected!");
        else 
            $error("FAILURE: Did not detect hit immediately.");

        assert(cm_num == 0) else $error("Error: Should have switched back to CM0");
        
        // Ensure no requests are being sent
        assert(cache_bus_if.req_valid == 0) else $error("Error: Generated cache requests during a HIT!");

        #50;

        // ---------------------------------------------------------------------
        // TEST CASE 4: Eviction (Load Stream C -> Overwrites CM0)
        // ---------------------------------------------------------------------
        $display("\n[T= %0t] Test 4: Eviction (Addr 0x3000 -> Overwrites A)", $time);
        bitstream_addr = 32'h3000; // New address
        meta_valid = 1;

        wait(done_streaming);
        $display("[T= %0t] Stream C Loaded!", $time);

        assert(cm_num == 0) else $error("Error: Should have evicted CM0 (LRU)");
        assert(dut.cm0_addr == 32'h3000) else $error("Error: CM0 address tag not updated");

        $display("\n=== ALL TESTS PASSED ===");
        $stop;
    end

endmodule
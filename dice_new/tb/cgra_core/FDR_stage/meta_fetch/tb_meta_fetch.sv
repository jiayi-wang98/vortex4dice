`timescale 1ns/1ps
`include "VX_define.vh"

// =========================================================================
// MOCK INTERFACE (Temporarily defined here for testing)
// =========================================================================
interface VX_mem_bus_if #(
    parameter DATA_SIZE   = 1,
    parameter TAG_WIDTH   = 1,
    parameter FLAGS_WIDTH = 1,     // Dummy default
    parameter ADDR_WIDTH  = 32     // Dummy default
) ();

    // Simplified Request Struct
    typedef struct packed {
        logic                   rw;
        logic [ADDR_WIDTH-1:0]  addr;
        logic [DATA_SIZE*8-1:0] data;
        logic [DATA_SIZE-1:0]   byteen;
        logic [FLAGS_WIDTH-1:0] flags;
        logic [TAG_WIDTH-1:0]   tag; // Defined as flat vector for easy assignment
    } req_data_t;

    // Simplified Response Struct
    typedef struct packed {
        logic [DATA_SIZE*8-1:0] data;
        logic [TAG_WIDTH-1:0]   tag;
    } rsp_data_t;

    logic       req_valid;
    req_data_t  req_data;
    logic       req_ready;

    logic       rsp_valid;
    rsp_data_t  rsp_data;
    logic       rsp_ready;

    modport master (
        output req_valid, req_data,
        input  req_ready,
        input  rsp_valid, rsp_data,
        output rsp_ready
    );

    modport slave (
        input  req_valid, req_data,
        output req_ready,
        output rsp_valid, rsp_data,
        input  rsp_ready
    );

endinterface

// =========================================================================
// MAIN TESTBENCH
// =========================================================================
import frontend_pkg::*;

module tb_meta_fetch;

    // =========================================================================
    // PARAMETERS
    // =========================================================================
    localparam MAX_NUM_CTA     = 4;
    localparam PC_WIDTH        = 32;
    localparam EBLOCK_ID_WIDTH = $clog2(MAX_NUM_CTA + 4);
    
    // FIX REVERTED: Now using package constant
    localparam TAG_WIDTH       = VX_gpu_pkg::ICACHE_MEM_TAG_WIDTH; 
    localparam CLK_PERIOD      = 10;
    localparam DATA_SIZE       = 4; // 32-bit data

    // =========================================================================
    // SIGNALS
    // =========================================================================
    logic clk;
    logic rst;

    // Scheduler Interface
    logic schedule_valid;
    logic [PC_WIDTH-1:0] fdr_next_pc;
    logic [EBLOCK_ID_WIDTH-1:0] schedule_eblock_id;
    logic schedule_ready;

    // Memory Interface
    // Instantiating the Mock Interface defined above
    VX_mem_bus_if #(
        .TAG_WIDTH (TAG_WIDTH),
        .DATA_SIZE (DATA_SIZE)
    ) mem_bus_if();

    // Decoder Interface
    pgraph_meta_t outgoing_meta;
    logic meta_valid;

    // Feedback Interface
    logic fire_eblock;

    // =========================================================================
    // DUT INSTANTIATION
    // =========================================================================
    meta_fetch #(
        .MAX_NUM_CTA    (MAX_NUM_CTA),
        .PC_WIDTH       (PC_WIDTH),
        .EBLOCK_ID_WIDTH(EBLOCK_ID_WIDTH),
        .TAG_WIDTH      (TAG_WIDTH)
    ) dut (
        .clk                (clk),
        .rst                (rst),

        .schedule_valid     (schedule_valid),
        .fdr_next_pc        (fdr_next_pc),
        .schedule_eblock_id (schedule_eblock_id),
        .schedule_ready     (schedule_ready),

        .meta_fetch_bus_if  (mem_bus_if),

        .outgoing_meta      (outgoing_meta),
        .meta_valid         (meta_valid),

        .fire_eblock        (fire_eblock)
    );

    // =========================================================================
    // CLOCK GENERATION
    // =========================================================================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // =========================================================================
    // TASKS
    // =========================================================================
    
    // Task to drive reset
    task apply_reset();
        begin
            rst = 1;
            schedule_valid = 0;
            fdr_next_pc = 0;
            schedule_eblock_id = 0;
            fire_eblock = 0;
            
            // Initialize Bus Slave signals (Acting as Cache)
            mem_bus_if.req_ready = 0;
            mem_bus_if.rsp_valid = 0;
            mem_bus_if.rsp_data  = '0;

            @(posedge clk);
            @(posedge clk);
            rst = 0;
            @(posedge clk);
        end
    endtask

    // Task to simulate the scheduler sending a request
    task send_schedule_req(input logic [31:0] pc, input logic [EBLOCK_ID_WIDTH-1:0] id);
        begin
            // 1. Wait for DUT to be ready
            wait(schedule_ready); 
            
            // 2. Drive data combinatorially
            schedule_valid = 1;
            fdr_next_pc = pc;
            schedule_eblock_id = id;
            
            // 3. Wait for the DUT to clock the data and drop ready
            @(posedge clk);
            wait(!schedule_ready); // Wait until DUT has transitioned state
            
            // 4. Drop valid
            schedule_valid = 0;
            
            @(posedge clk); // Consume one more cycle
        end
    endtask

    // =========================================================================
    // MEMORY SIMULATION (Background Process)
    // =========================================================================
    initial begin
        forever begin
            // 1. Randomly assert Ready to simulate cache availability
            @(posedge clk);
            mem_bus_if.req_ready = $urandom_range(0, 1); 

            // 2. If we get a valid request
            if (mem_bus_if.req_valid && mem_bus_if.req_ready) begin
                logic [TAG_WIDTH-1:0] captured_tag;
                captured_tag = mem_bus_if.req_data.tag;

                $display("[%0t] MEM: Received Request for Addr: 0x%h, Tag: 0x%h", $time, mem_bus_if.req_data.addr, captured_tag);

                // 3. Wait some cycles (Simulate Latency)
                repeat($urandom_range(2, 5)) @(posedge clk);

                // 4. Send Response
                mem_bus_if.rsp_valid = 1;
                // Mock return data
                mem_bus_if.rsp_data.data = {mem_bus_if.req_data.addr}; 
                mem_bus_if.rsp_data.tag  = captured_tag;

                // Wait for DUT to accept response
                wait(mem_bus_if.rsp_ready);
                @(posedge clk);
                mem_bus_if.rsp_valid = 0;
                $display("[%0t] MEM: Response Sent", $time);
            end
        end
    end

    // =========================================================================
    // TEST SEQUENCER
    // =========================================================================
    initial begin
        $display("=== STARTING TESTBENCH ===");
        
        apply_reset();

        // TEST CASE 1: Basic Fetch
        $display("\n--- Test Case 1: Basic Fetch ---");
        fork
            send_schedule_req(32'h1000, 3'd1);
        join_none

        // Wait for meta_valid
        wait(meta_valid);
        $display("[%0t] DUT: Output Valid! Data: 0x%h", $time, outgoing_meta);
        
        // Assert Fire Eblock to clear stage
        @(posedge clk);
        fire_eblock = 1;
        @(posedge clk);
        fire_eblock = 0;
        
        // Verify we go back to ready
        wait(schedule_ready);
        $display("[%0t] DUT: Ready for next instruction", $time);


        // TEST CASE 2: Back-to-Back Requests with different IDs
        $display("\n--- Test Case 2: Different ID ---");
        fork
            send_schedule_req(32'h2000, 3'd2);
        join_none

        wait(meta_valid);
        
        @(posedge clk);
        fire_eblock = 1;
        @(posedge clk);
        fire_eblock = 0;
        
        // TEST CASE 3: Reset mid-operation
        $display("\n--- Test Case 3: Reset Recovery ---");
        fork
            send_schedule_req(32'h3000, 3'd3);
        join_none
        
        repeat(3) @(posedge clk);
        $display("[%0t] SYS: Applying Reset!", $time);
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;
        
        if (schedule_ready) $display("[%0t] SUCCESS: DUT recovered to Ready state", $time);
        else $error("FAILURE: DUT stuck after reset");


        #100;
        $display("\n=== TEST COMPLETE ===");
        $stop;
    end

endmodule
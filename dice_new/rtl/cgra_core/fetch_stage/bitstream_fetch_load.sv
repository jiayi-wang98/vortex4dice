`timescale 1ns/1ps

import VX_gpu_pkg::*;
import dice_pkg::*;
import frontend_pkg::*;

module bitstream_fetch_load #(
    parameter int TAG_WIDTH = 48,
    parameter int BITSTREAM_SIZE = 2056,
    parameter int CHUNK_SIZE = VX_MEM_DATA_WIDTH,
    parameter int NUM_CHUNKS = (BITSTREAM_SIZE + CHUNK_SIZE - 1) / CHUNK_SIZE
)(
    input logic clk,
    input logic rst,

    //from decoder
    input logic meta_valid, 
    input logic [BITSTREAM_ADDR_WIDTH-1:0] bitstream_addr,

    //to cgra buffers
    output logic [CHUNK_SIZE-1:0] cm0_data,
    output logic [NUM_CHUNKS-1:0] cm0_chunk_en,

    output logic [CHUNK_SIZE-1:0] cm1_data,
    output logic [NUM_CHUNKS-1:0] cm1_chunk_en,

    //to valid checker
    output logic done_streaming,

    //cache interface
    VX_mem_bus_if.master cache_bus_if,

    //to FDR EX buffer
    output logic cm_num
);  

    localparam int COUNTER_BITS = $clog2(NUM_CHUNKS + 1);
    localparam int OFFSET = CHUNK_SIZE / 8;

    typedef enum logic [1:0] {
        S_IDLE,
        S_STREAMING, // Handles both Request and Response phases
        S_DONE
    } bitstream_fetch_state;

    bitstream_fetch_state state, state_n;

    // registered states
    logic [BITSTREAM_ADDR_WIDTH-1:0] cm0_addr, cm1_addr, cm0_addr_n, cm1_addr_n;
    logic cm_select, cm_select_n;  // 0 = cm0, 1 = cm1

    logic [COUNTER_BITS-1:0] chunk_count_q, chunk_count_d; //how many chunks have been streamed

    // Data
    logic [CHUNK_SIZE-1:0] data_chunk, data_chunk_n;

    logic [BITSTREAM_ADDR_WIDTH-1:0] addr_q, addr_d;
    logic cm0_valid_d, cm1_valid_d, cm0_valid_q, cm1_valid_q;
    
    // Track if we have sent the request for the current chunk
    logic req_sent_q, req_sent_d;
    
    logic [NUM_CHUNKS-1:0] load_chunk_en_d;
    logic [NUM_CHUNKS-1:0] load_chunk_en_q;

    // Address alias
    logic [BITSTREAM_ADDR_WIDTH-1:0] bitstream_addr_dec; 
    assign bitstream_addr_dec = bitstream_addr; 

    // Bus Handshake Signals
    logic req_fire;
    logic rsp_fire;
    
    assign req_fire = cache_bus_if.req_valid && cache_bus_if.req_ready;
    assign rsp_fire = cache_bus_if.rsp_valid && cache_bus_if.rsp_ready;

    // Vortex Bus Assignments
    assign cache_bus_if.req_data.flags  = '0;
    assign cache_bus_if.req_data.rw     = 0;  // Read
    assign cache_bus_if.req_data.byteen = '1; // All bytes enabled
    assign cache_bus_if.req_data.data   = '0; 

    assign cache_bus_if.req_data.tag = {TAG_WIDTH{1'b0}}; 
    
    assign cache_bus_if.req_data.addr = addr_q;

    // We are valid to request if we are streaming and haven't sent the request yet
    assign cache_bus_if.req_valid = (state == S_STREAMING) && !req_sent_q;
    
    // We are ready for a response if we are streaming and HAVE sent the request
    assign cache_bus_if.rsp_ready = (state == S_STREAMING) && req_sent_q;

    // Output assignments
    assign cm_num = cm_select; 
    assign cm0_data = data_chunk;
    assign cm1_data = data_chunk;

    // assign done_streaming = (cm0_valid_q && (cm0_addr == bitstream_addr_dec)) || 
    //                         (cm1_valid_q && (cm1_addr == bitstream_addr_dec));

    assign done_streaming = (cm_select == 0 && cm0_valid_q && cm0_addr == bitstream_addr_dec) ||
                            (cm_select == 1 && cm1_valid_q && cm1_addr == bitstream_addr_dec);

    always_comb begin
        state_n = state;
        chunk_count_d = chunk_count_q; 
        cm_select_n = cm_select; 
        cm0_addr_n = cm0_addr; 
        cm1_addr_n = cm1_addr;
        data_chunk_n = data_chunk; 
        addr_d = addr_q;
        cm0_valid_d = cm0_valid_q;
        cm1_valid_d = cm1_valid_q;
        req_sent_d = req_sent_q;
        load_chunk_en_d = '0; 
        
        // Registered chunk enable usage
        cm0_chunk_en = (cm_select == 1'b0) ? load_chunk_en_q : '0;
        cm1_chunk_en = (cm_select == 1'b1) ? load_chunk_en_q : '0;


        unique case (state)
            S_IDLE: begin
                req_sent_d = 1'b0;
                if(meta_valid) begin 
                    if (!done_streaming) begin
                        // --- FIX START ---
                        // Only toggle if we have valid data (Ping-Pong).
                        // On a cold start (both invalid), force target to 0.
                        if (cm0_valid_q || cm1_valid_q) 
                            cm_select_n = ~cm_select; 
                        else 
                            cm_select_n = 1'b0;
                        // --- FIX END ---

                        addr_d = bitstream_addr_dec; 
                        state_n = S_STREAMING;
                        chunk_count_d = '0; 
                        
                        // Setup the target buffer (invalidate it before filling)
                        if (cm_select_n == 1'b0) begin
                            cm0_addr_n = bitstream_addr_dec;
                            cm0_valid_d = 1'b0; 
                        end else begin
                            cm1_addr_n = bitstream_addr_dec;
                            cm1_valid_d = 1'b0; 
                        end
                    end 
                    
                    // NOTE: The `else if` block here is essentially dead code.
                    // `done_streaming` is logic that checks (Valid AND AddrMatch).
                    // If `done_streaming` is TRUE, we don't enter the first `if`.
                    // If `done_streaming` is FALSE, we enter the first `if` immediately.
                    // The `else if` is never reached. You can safely remove it.
                end
            end

            S_STREAMING: begin 
                // 1. Send Request
                if (!req_sent_q) begin
                    if (req_fire) begin
                        req_sent_d = 1'b1; 
                    end
                end else begin
                    if (rsp_fire) begin
                        data_chunk_n = cache_bus_if.rsp_data.data;
                        load_chunk_en_d = (1'b1 << chunk_count_q);
                        chunk_count_d = chunk_count_q + 1'b1;
                        req_sent_d = 1'b0;
                        if(chunk_count_q == NUM_CHUNKS - 1) begin
                            state_n = S_DONE;
                        end else begin
                            addr_d = addr_q + OFFSET;
                        end
                    end
                end
            end

            S_DONE: begin
                state_n = S_IDLE;
                if(cm_select == 1'b1) begin 
                    cm1_valid_d = 1'b1;
                end else begin
                    cm0_valid_d = 1'b1;
                end
            end
            default: begin
                state_n = S_IDLE;
            end
        endcase

    end

    always_ff @(posedge clk) begin
        if(rst) begin
            state <= S_IDLE;
            chunk_count_q <= '0;
            cm_select <= 1'b0;
            data_chunk <= '0;
            cm0_addr <= '0;
            cm1_addr <= '0;
            addr_q <= '0;
            cm0_valid_q <= 1'b0;
            cm1_valid_q <= 1'b0;
            load_chunk_en_q <= '0;
            req_sent_q <= 1'b0;
        end else begin
            state <= state_n;
            chunk_count_q <= chunk_count_d;
            cm0_addr <= cm0_addr_n;
            cm1_addr <= cm1_addr_n;
            data_chunk <= data_chunk_n;
            cm_select <= cm_select_n;
            addr_q <= addr_d;
            cm0_valid_q <= cm0_valid_d;
            cm1_valid_q <= cm1_valid_d;
            load_chunk_en_q <= load_chunk_en_d;
            req_sent_q <= req_sent_d;
        end
    end
endmodule

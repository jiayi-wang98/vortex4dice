


module bitstream_fetch_load #(
    parameter int BITSTREAM_ADDR_WIDTH = 32,
    parameter int BITSTREAM_SIZE = 2056,
    parameter int CHUNK_SIZE = 512, //bits (may need to change)
    parameter int NUM_CHUNKS = BITSTREAM_SIZE/CHUNK_SIZE
)(
    input logic clk,
    input logic rst_n,

    //from decoder
    input logic addr_valid,
    output logic bitstream_fetch_ready,
    input logic [BITSTREAM_ADDR_WIDTH-1:0] bitstream_addr,

    //p-graph buffers (stream bitstream) -> bitstream fetcher acts as control module for cgra buffers
    output logic [CHUNK_SIZE-1:0] cm0_data,
    output logic [NUM_CHUNKS-1:0] cm0_chunk_en,

    output logic [CHUNK_SIZE-1:0] cm1_data,
    output logic [NUM_CHUNKS-1:0] cm1_chunk_en,

    //to valid checker
    output logic done_streaming,

    //status field may not need
    // output logic bitstream_load_active,

    //cache interface
    stream_if.target cache_stream,

    //to FDR EX buffer
    output logic cm_num
);  

    localparam int COUNTER_BITS = $clog2(NUM_CHUNKS+1);
    localparam int OFFSET = CHUNK_SIZE / 8; //this may need to be changed
    //it is the difference in address between the chunks assuming it is byte addressable
    //and chunk size is in bits.

    typedef enum logic [1:0] {
        S_IDLE,
        S_STREAMING,
        S_DONE //may not need
    } bitstream_fetch_state;

    bitstream_fetch_state state, state_n;


    // registered states
    // logic cm0_in_use, cm1_in_use, cm0_in_use_n, cm1_in_use_n;
    logic [BITSTREAM_ADDR_WIDTH-1:0] cm0_addr, cm1_addr, cm0_addr_n, cm1_addr_n;
    logic cm_select, cm_select_n;  // 0 = cm0, 1 = cm1

    logic [COUNTER_BITS-1:0] chunk_count_q, chunk_count_d; //how many chunks have been streamed

    // Data and done flag
    logic [CHUNK_SIZE-1:0] data_chunk, data_chunk_n;
    logic done_streaming_q, done_streaming_d;

    logic [BITSTREAM_ADDR_WIDTH-1:0] addr_q, addr_d;
    logic cm0_valid_d, cm1_valid_d, cm0_valid_q, cm1_valid_q 


    always_comb begin
        state_n = state;
        chunk_count_d = chunk_count_q; //what buffer to load it into
        cm_select_n = cm_select; 
        cm0_addr_n = cm0_addr; //next address defaults
        cm1_addr_n = cm1_addr;
        data_chunk_n = data_chunk; //next chunk
        done_streaming_d = 1'b0;
        cache_stream.ready = 1'b0; //handshake
        addr_d = addr_q;
        cm0_valid_d = cm0_valid_q;
        cm1_valid_d = cm1_valid_q;


        unique case (state)
            S_IDLE: begin
                if(enable_fetch) begin 
                    cm_select_n = ~cm_select;
                    if((bitstream_addr_dec == cm0_addr) && cm0_valid_q) begin
                        state_n = S_DONE;
                        cm_select_n = 1'b0;
                    end else if((bitstream_addr_dec == cm1_addr) && cm1_valid_q) begin
                        state_n = S_DONE;
                        cm_select_n = 1'b1;
                    end else begin
                        addr_d = bitstream_addr_dec;
                        state_n = S_STREAMING;
                        cache_stream.ready = 1'b0;
                        chunk_count_d = '0;
                        if (cm_select_n == 1'b0) begin
                            cm0_addr_n = bitstream_addr_dec;
                        end else begin
                            cm1_addr_n = bitstream_addr_dec;
                        end
                    end
                end
            end
            S_STREAMING: begin // need to determine how to increment the cache address
                cache_stream.ready = 1'b1;
                if(cache_stream.valid) begin 
                    data_chunk_n = cache_stream.data;
                    chunk_count_d = chunk_count_q + 1'b1;
                    addr_d = addr_q + OFFSET;
                    if(chunk_count_d == NUM_CHUNKS) begin
                        state_n = S_DONE;
                    end    
                end
            end
            S_DONE: begin
                state_n = S_IDLE;
                done_streaming_d = 1'b1;
                if(cm_select == 1) begin
                    cm1_valid_d = 1'b1;
                end else begin
                    cm0_valid_d = 1'b1;
                end
            end
        endcase
    end


    //asserts whether data should be streamed from the cache to the buffer
    logic load_enable;
    assign load_enable = (state == S_STREAMING) && cache_stream.valid;

    //determines what buffer / chunk number should be enabled and ready for inputs
    //PRETTY SURE THIS IS BROKEN
    assign cm0_chunk_en = (load_enable && (cm_select == 1'b0)) ? (1'b1 << chunk_count_q) : '0;
    assign cm1_chunk_en = (load_enable && (cm_select == 1'b1)) ? (1'b1 << chunk_count_q) : '0;

    //tells the next stage what buffer is full
    assign cm_num = cm_select;

    //sets the input data to the current latched data from the cache
    assign cm0_data = data_chunk;
    assign cm1_data = data_chunk;

    //sets flags
    assign done_streaming = done_streaming_q;
    assign bitstream_load_active = (state != S_IDLE);

    assign cache_stream.addr = addr_q;
    


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_IDLE;
            chunk_count_q <= '0;
            cm_select <= 1'b0;
            data_chunk <= '0;
            cm0_addr <= '0;
            cm1_addr <= '0;
            done_streaming_q <= 1'b0;
            addr_q <= '0;
            cm0_valid_q <= 1'b0;
            cm1_valid_q <= 1'b0;
        end else begin
            state <= state_n;
            chunk_count_q <= chunk_count_d;
            cm0_addr <= cm0_addr_n;
            cm1_addr <= cm1_addr_n;
            data_chunk <= data_chunk_n;
            done_streaming_q <= done_streaming_d;
            cm_select <= cm_select_n;
            addr_q <= addr_d;
            cm0_valid_q <= cm0_valid_d;
            cm1_valid_q <= cm1_valid_d;
        end
    end
endmodule
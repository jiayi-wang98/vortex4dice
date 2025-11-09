/*
Bitstream fetch module, streams it from cache, stores in buffer, then sends it to CGRA buffer when ready
    -wondering if this needs to be changed-> no buffer in module?



I'm going to assume the bits per cycle in is the same as bits per cycle out, if that is not the
    case the code will need to be modified
*/



module bitstream_fetch_load #(
    parameter BITSTREAM_ADDR_WIDTH = 32,
    parameter MAX_BITSTREAM_SIZE = 256,
    parameter BITS_PER_CYCLE = 64,
    parameter BUFFER_DEPTH = 2 // must be power of 2
) (
    input logic clk,
    input logic rst_n,

    //from decoder
    input logic start_fetch_decoder,
    input logic [BITSTREAM_ADDR_WIDTH-1:0] bitstream_addr,
    input logic [7:0] bitstream_length,

    //from p-graph cache (stream bitstream)
    input logic cache_stream_ready
    output logic cache_stream_valid
    input logic [BITS_PER_CYCLE-1:0] in_bitstream,

    //to cgra buffer config (stream bitstream)
    input logic cgra_buffer_ready,
    output logic cgra_buffer_valid,
    output logic [BITS_PER_CYCLE-1:0] out_bitstream,
    // may need input to know what cm_num is chosen (will be assuming that is the case)
    //logic to determine which to put the stream into will be easy to implement

    //to valid checker
    output logic bitstream_load_valid,

    //to FDR EX buffer
    output logic cm_num,
);  

    typedef enum logic [1:0] {
        S_IDLE         = 2'b00, //
        S_SEND_REQ     = 2'b01, //
        S_WAIT_RESP    = 2'b10, //
        S_STREAMING    = 2'b11  //
    } meta_fetch_states;

    meta_fetch_states state, state_n;


    always_comb begin
        unique case (state)
            S_IDLE: begin

            end
            S_SEND_REQ: begin

            end
            S_WAIT_RESP: begin

            end
            S_WAIT_RESP: begin

            end
            default: begin

            end
        endcase
    end

    logic buffer_full, buffer_empty;
    //BUFFER (need to figure out how to empty it)
    sync_fifo #(
        .DATA_WIDTH (BITS_PER_CYCLE),
        .DEPTH (BUFFER_DEPTH)
    ) bitstream_fetch_buffer (
        .clk               (clk),   
        .rst_n             (rst_n),    
        .push              (),
        .push_data         (),        
        .pop               (),        
        .pop_data          (),        
        .pop_data_valid,   (),            
        .empty             (),             
        .full              (),              
        .count             ()   
    )




    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_IDLE;

        end else begin
            state <= state_n;
;
        end
    end

endmodule
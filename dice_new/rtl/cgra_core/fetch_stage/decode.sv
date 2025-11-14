//make this module fully elastic. Add handshakes between all connections.
//need to figure out what handshake there should be with the branch handler
//this may need to be updated when the branch handler module is written


//SWITCH FROM FSM TO FLAGS
import frontend_pkg::*;


module decode #(
    parameter MASK_WIDTH = 512

)(
    input logic clk,
    input logic rst_n,

    //from meta fetch unit
    input pgraph_meta_t metadata_in,
    input logic meta_valid,
    output logic decode_ready_meta,

    //to bitstream fetch unit
    input logic bitstream_fetcher_ready,
    output logic [31:0] bitstream_addr_dec,
    output logic addr_valid, //one cycle signal

    //branch handler
    output logic [31:0] branch_metadata,
    output logic branch_meta_valid,
    input logic branch_handler_ready,


    input logic [MASK_WIDTH-1:0] real_active_thread_mask,
    input logic mask_valid,
    output logic decode_ready_for_mask,

    //to valid checker (decide if this should have a handshake)
    output logic decode_done, //real active thread mask has been determined
    output logic is_barrier, //need to look into this

    //to fdr stage barrier (make sure it is synchronized)
    output pgraph_meta_t metadata_out,
    output logic [MASK_WIDTH-1:0] active_thread_mask
);

    typedef enum logic [1:0] {
        S_IDLE          = 2'b00,
        S_SEND_REQ      = 2'b01, //decoupled req to branch handler and bitstream fetch
        S_WAIT_RESP     = 2'b10, //wait for response from the active thread mask -> bitstream fetch sends to valid check on its own
        S_DONE          = 2'b11 //have to determine valid check's behavior
    } decode_states;


    decode_states state, state_n;

    logic [MASK_WIDTH-1:0] active_thread_mask_q, active_thread_mask_d;
    logic decode_done_q ,decode_done_d;
    pgraph_meta_t meta_q, meta_d;
    logic enable_fetch_q, enable_fetch_d;


    always_comb begin
        enable_fetch_d = 1'b0;
        state_n = state;
        meta_d = meta_q;
        decode_done_d = decode_done_q;
        active_thread_mask_d = active_thread_mask_q;

        unique case (state)
            S_IDLE: begin
                if(new_meta) begin
                    state_n = S_MASK_WAIT;
                    meta_d = metadata_in;
                    enable_fetch_d = 1'b1; //this may also go to the branch handler to signal there is something new
                    decode_done_d = 1'b0;
                end
            end
            S_MASK_WAIT: begin
                if(mask_valid) begin
                    state_n = S_IDLE;
                    decode_done_d = 1'b1;
                    active_thread_mask_d = real_active_thread_mask;
                end
            end
        endcase


    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            decode_done_q <= 1'b0;
            meta_q <= '0;
            state <= IDLE;
            enable_fetch_q <= 1'b0;
            active_thread_mask_q <= '0;
        end else begin
            decode_done_q <= decode_done_d;
            meta_q <= meta_d;
            state <= state_n;
            active_thread_mask_q <= active_thread_mask_d;
            enable_fetch_q <= enable_fetch_d;
        end
    end


    assign decode_done = decode_done_q; //synchronously tells the valid checker if the docode (correct mask fetched) is done
    assign is_barrier = meta_q.barrier; //tells the valid checker if the registered metadata contains a barrier
    assign meta_d = metadata_in; //next metadata is always the data that the meta fetcher has
    assign metadata_out = meta_q; //metadata out is always the registered metadata
    assign active_thread_mask = active_thread_mask_q; //the output active thread mask is the registered thread mask
    assign enable_fetch = enable_fetch_q; //signle cycle fetch signal to the bitstream fetch unit when the metadata changes
    assign bitstream_addr_dec = metadata_q.bitstream_addr; //bitstream address to bitstream fetch

    
endmodule
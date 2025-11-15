
import frontend_pkg::*; //frontend package for metadata structure

module meta_fetch #(
    parameter PC_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,

    //from CS/FDR barrier
    input logic schedule_valid,
    input logic [PC_WIDTH-1:0] pc,
    output logic fetch_ready,
    //request channel to cache
    input logic req_ready,
    output logic req_valid,
    output logic [ADDR_WIDTH-1:0] req_addr,
    
    //response channel from cache
    input logic resp_valid,
    output logic resp_ready,
    input pgraph_meta_t incoming_meta,

    //to decoder
    output pgraph_meta_t outgoing_meta,
    output logic meta_valid,
    input logic decode_ready
);

    // FSM states
    typedef enum logic [1:0] {
        S_IDLE         = 2'b00, // fetcher is ready for a new pc (other parts of Fetch stage may not be tho)
        S_SEND_REQ     = 2'b01, // send req for metadata to cache
        S_WAIT_RESP    = 2'b10, // waiting for response from cache
        S_META_OUT     = 2'b11 //added state for outputting metadata so that reasserting ready signal is easier and we don't get stuck in our decoder handshake
    } meta_fetch_states;

    meta_fetch_states state_q, state_d;

    // q is current, d is next
    logic [PC_WIDTH-1:0] pc_q, pc_d;  
    pgraph_meta_t metadata_q, metadata_d;
    logic metadata_valid_q, metadata_valid_d;

    assign meta_valid = metadata_valid_q;
    assign outgoing_meta = metadata_q;
    assign fetch_ready = (state_q == S_IDLE); //if the module is idle it is able to accept 
    // new pc
    assign req_valid = (state_q == S_SEND_REQ);
    assign req_addr = pc_q;
    assign resp_ready = (state_q == S_WAIT_RESP);

    always_comb begin
        state_d = state_q;
        pc_d = pc_q;
        metadata_valid_d = metadata_valid_q;
        metadata_d = metadata_q;

        unique case (state_q)
            S_IDLE: begin
                if(schedule_valid && fetch_ready) begin // should i add something about if the current metadata isn't valid or will the produce bugs when reset?
                    state_d = S_SEND_REQ;
                    pc_d = pc;
                    metadata_valid_d = 1'b0;
                    metadata_d = '0; //doesn't matter
                end
            end
            S_SEND_REQ: begin
                if(req_valid && req_ready) begin // if fetcher and cache are both ready to send address / start communicating
                    state_d = S_WAIT_RESP;
                end
            end
            S_WAIT_RESP: begin
                if(resp_valid && resp_ready) begin // if fetcher and cache are both ready to send address / start communicating
                    state_d = S_META_OUT;
                    metadata_d = incoming_meta;
                    metadata_valid_d = 1'b1;
                end
            end
            S_META_OUT: begin
                if(metadata_valid_q && decode_ready) begin
                    state_d = S_IDLE;
                    metadata_valid_d = 1'b0;
                    metadata_d = '0;
                end
            end
        endcase

    end


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state_q <= S_IDLE;
            pc_q <= '0;
            metadata_valid_q <= 1'b0;
            metadata_q <= '0;
        end else begin
            state_q <= state_d;
            pc_q <= pc_d;
            metadata_valid_q <= metadata_valid_d;
            metadata_q <= metadata_d;
        end
    end

endmodule
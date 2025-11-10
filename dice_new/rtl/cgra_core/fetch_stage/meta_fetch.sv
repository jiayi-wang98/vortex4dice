/*
Inputs Modules:
-PC from the border with schedule stage
-Metadata from P-graph Cache

Output Modules:
-P-graph cache
-Decoder

*/


//TRY TO DEFINE A STRUCTURE FOR METADATA ----> NEED TO DETERMINE HOW IT IS STORED IN THE CACHE

/*
BITSTREAM_ADDR     | 32-bit         | Address of the corresponding CGRA configuration bitstream
BITSTREAM_LENGTH   | 8-bit          | Bitstream size in bytes
UNROLLING_FACTOR   | 2-bit          | Max thread unrolling factor (see Section 4.2.1)
LAT                | 8-bit          | CGRA fabric latency for the p-graph
IN_REGS            | 34-bit bitmap  | Input registers bitmap of the p-graph
OUT_REGS           | 34-bit bitmap  | Direct output registers bitmap from CGRA fabric of the p-graph
LD_DEST_REGS       | 8 × 6-bit      | Destination register indexes for memory loads (max request ports × index width)
NUM_STORES         | 3-bit          | Number of stores per thread of this p-graph
BRANCH_*           | 32-bit         | Branch/Jump metadata associated with this p-graph
BARRIER            | 1-bit bool     | Barrier indicator, all previous blocks must finish before executing this p-graph
PARAMETER_LOAD     | 1-bit bool     | 1 if the p-graph only loads constants into the shared constant buffer (see Section 4)

*/


//Pretty sure this isn't valid ready

module meta_fetch #(
    parameter PC_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,

    //from CS/FDR barrier
    input logic [PC_WIDTH-1:0] pc,

    
    //request channel to cache
    input logic req_ready,
    output logic req_valid,
    output logic [ADDR_WIDTH-1:0] req_addr,
    
    //response channel from cache
    input logic resp_valid,
    output logic resp_ready,
    input pgraph_meta_t incoming_meta,



    //to decoder
    output pgraph_meta_t outgoing_meta, //done
    output logic meta_valid //done

);

    import frontend_pkg::*; //frontend package for metadata structure

    // FSM states
    typedef enum logic [1:0] {
        S_IDLE         = 2'b00, // fetcher is waiting for pc to change
        S_SEND_REQ     = 2'b01, // send req for metadata to cache
        S_WAIT_RESP    = 2'b10 // waiting for response from cache
    } meta_fetch_states;

    meta_fetch_states state, state_n;

    // q is current, d is next
    logic [PC_WIDTH-1:0] pc_q, pc_d;  
    pgraph_meta_t metadata_q, metadata_d;
    logic metadata_valid_q, metadata_valid_d;


    assign meta_valid = metadata_valid_q;
    assign outgoing_meta = metadata_q;


    always_comb begin
        //defaults
        state_n = state;
        pc_d = pc_q;
        metadata_valid_d = metadata_valid_q;
        metadata_d = metadata_q;

        req_valid = 1'b0;
        req_addr = pc_q; // need to figure out if this just goes with the pc or other parts of the p-graph
        resp_ready = 1'b0;

        unique case (state)
            S_IDLE: begin
                if(pc != pc_q) begin // should i add something about if the current metadata isn't valid or will the produce bugs when reset?
                    state_n = S_SEND_REQ;
                    pc_d = pc;
                    metadata_valid_d = '0;
                    metadata_d = '0;
                end
            end
            S_SEND_REQ: begin
                req_valid = 1'b1;
                req_addr = ; //need to figure out how this is determined
                if(req_valid && req_ready) begin // if fetcher and cache are both ready to send address / start communicating
                    state_n = S_WAIT_RESP;
                end
            end
            S_WAIT_RESP: begin
                resp_ready = 1'b1;
                if(resp_valid && resp_ready) begin // if fetcher and cache are both ready to send address / start communicating
                    state_n = S_IDLE;
                    metadata_d = incoming_meta; // figure out if this can/should be turned into a structure or something
                    metadata_valid_d = 1'b1;
                end
            end
            default: begin
                state_n = S_IDLE;
                pc_d = '0;
                metadata_valid_d = '0;
                metadata_d = '0;
            end
        endcase

    end


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_IDLE;
            pc_q <= '0;
            metadata_valid_q <= 1'b0;
            metadata_q <= '0;
        end else begin
            state <= state_n;
            pc_q <= pc_d;
            metadata_valid_q <= metadata_valid_d;
            metadata_q <= metadata_d;
        end
    end

endmodule
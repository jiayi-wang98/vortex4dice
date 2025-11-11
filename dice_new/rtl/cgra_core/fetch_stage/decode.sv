
//need to determine what should be synchronous

module decode #(
    parameter MASK_WIDTH = 512

)(
    input logic clk,
    input logic rst_n,

    //from meta fetch unit
    input pgraph_meta_t metadata_in,
    input logic new_meta,

    //to bitstream fetch unit
    output logic [31:0] bitstream_addr_dec,
    output logic enable_fetch, //one cycle signal

    //branch handler
    output logic [31:0] branch_metadata,
    input logic [MASK_WIDTH-1:0] real_active_thread_mask,
    input logic mask_valid,

    //to valid checker
    output logic decode_done, //real active thread mask has been determined
    output logic is_barrier,

    //to fdr stage barrier
    output pgraph_meta_t metadata_out,
    output logic [MASK_WIDTH-1:0] active_thread_mask
);

    import frontend_pkg::*;


    typedef enum logic {
        S_IDLE,
        S_MASK_WAIT
    } decode_states;

    decode_states state, state_n;

    logic [MASK_WIDTH-1:0] active_thread_mask_q;
    logic decode_done_q ,decode_done_d;
    pgraph_meta_t meta_q, meta_d;
    logic enable_fetch_q, enable_fetch_d;

    always_comb begin
        enable_fetch_d = 1'b0;
        state_n = state;
        meta_d = meta_q;
        decode_done_d = decode_done_q;

        unique case (state)
            S_IDLE: begin
                if(new_meta) begin
                    state_n = S_FETCH;
                    meta_d = metadata_in;
                    enable_fetch_d = 1'b1; //this may also go to the branch handler to signal there is something new
                    decode_done_d = 1'b0;
                end
            end
            S_MASK_WAIT: begin
                if(mask_valid) begin
                    state_n = S_IDLE;
                    decode_done_d = 1'b1;
                end
            end
        endcase


    end

    /*what is synchronous:
        -meta_q
        -decode_done_q
    */
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
            active_thread_mask_q <= real_active_thread_mask;
            enable_fetch_q <= enable_fetch_d;
        end
    end


    assign decode_done = decode_done_q; //synchronously tells the valid checker if the docode (correct mask fetched) is done
    assign is_barrier = metadata.barrier; //tells the valid checker if the registered metadata contains a barrier
    assign meta_d = metadata_in; //next metadata is always the data that the meta fetcher has
    assign metadata_out = meta_q; //metadata out is always the registered metadata
    assign active_thread_mask = active_thread_mask_q; //the output active thread mask is the registered thread mask
    assign enable_fetch = enable_fetch_q; //signle cycle fetch signal to the bitstream fetch unit when the metadata changes
    
endmodule
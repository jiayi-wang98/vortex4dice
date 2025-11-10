
//need to determine what should be synchronous

/*TO DO: 
-figure out how we know if the active thread mask is correct,
this signal needs to go to the valid check
-determine what should be synchronous vs asynch in this module

*/
module decode #(
    parameter MASK_WIDTH = 512

)(
    input logic clk,
    input logic rst_n,

    //from meta fetch unit
    input pgraph_meta_t metadata_in,


    //to bitstream fetch unit
    output logic [31:0] bitstream_addr_dec,
    output logic enable_fetch, //one cycle signal

    //branch handler
    output logic [31:0] branch_metadata,
    input logic [MASK_WIDTH-1:0] real_active_thread_mask,
    input logic thread_mask_valid,


    //to valid checker
    output logic decode_done, //real active thread mask has been determined
    output logic is_barrier,

    //to fdr stage barrier
    output pgraph_meta_t metadata_out,
    output logic [MASK_WIDTH-1:0] active_thread_mask
);
    import frontend_pkg::*;


    assign decode_done = decode_done_q;
    assign is_barrier = metadata.barrier;
    assign 


    logic [MASK_WIDTH-1:0] active_thread_mask_q;
    logic decode_done_q;
    pgraph_meta_t meta_q, meta_d;


    always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        active_thread_mask_q <= '0;
        decode_done_q <= 0;
    end else begin
        if (mask_valid) begin
            active_thread_mask_q <= real_active_thread_mask;
            decode_done_q <= 1;
        end else begin
            decode_done_q <= 0;
        end
    end
end

endmodule
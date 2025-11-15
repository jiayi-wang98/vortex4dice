
import frontend_pkg::*;


module decode #(
    parameter MASK_WIDTH = 512

)(
    input logic clk,
    input logic rst_n,

    //from meta fetch unit
    input pgraph_meta_t meta_in_data,
    input logic meta_in_valid,
    output logic meta_in_ready,

    //to bitstream fetch unit
    output logic [31:0] bitstream_addr,
    output logic enable_fetch, //one cycle signal

    //branch handler
    output logic [31:0] branch_metadata,
    output logic branch_req_valid, //one cycle


    input logic [MASK_WIDTH-1:0] real_active_thread_mask,
    input logic mask_valid,

    //to valid checker (decide if this should have a handshake)
    output logic decode_valid,
    input logic decode_ready, //when everything in the valid checker is ready to go it 
    //sends this signal and decode knows it can accept something new
    output logic is_barrier, //need to look into this

    //to fdr stage barrier (make sure it is synchronized)
    output pgraph_meta_t metadata_out,
    output logic [MASK_WIDTH-1:0] mask
);

    logic [MASK_WIDTH-1:0] active_thread_mask_q;
    pgraph_meta_t meta_q;
    logic enable_fetch_q;
    logic branch_req_valid_q;
    logic meta_valid;
    logic waiting_for_mask;

    assign mask = active_thread_mask_q;
    assign is_barrier = meta_q.barrier;
    assign metadata_out = meta_q;
    assign enable_fetch = enable_fetch_q;
    assign branch_metadata = meta_q.branch_meta;
    assign branch_req_valid = branch_req_valid_q;
    assign meta_in_ready = !meta_valid;
    assign decode_valid = meta_valid && !waiting_for_mask;
    assign bitstream_addr = meta_valid ? meta_q.bitstream_addr : '0; //if the metadata is valid
    //this is the address if not it is automatically 0
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            meta_q <= '0;
            active_thread_mask_q <= '0;
            meta_valid <= 1'b0;
            waiting_for_mask <= 1'b0;
            enable_fetch_q <= 1'b0;
            branch_req_valid_q <= 1'b0;
        end else begin
            enable_fetch_q <= 1'b0;
            branch_req_valid_q <= 1'b0;
            if(meta_in_valid && meta_in_ready) begin
                meta_q <= meta_in_data;
                meta_valid <= 1'b1;
                waiting_for_mask <= 1'b1;
                active_thread_mask_q <= '0;
                enable_fetch_q <= 1'b1;
                branch_req_valid_q <= 1'b1;
            end
            if (mask_valid && waiting_for_mask) begin
                active_thread_mask_q <= real_active_thread_mask;
                waiting_for_mask <= 1'b0;
            end
            if(decode_valid && decode_ready) begin
                meta_valid <= 1'b0;
                waiting_for_mask <= 1'b0;
            end
        end
    end
endmodule
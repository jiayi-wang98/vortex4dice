import dice_pkg::*;
import frontend_pkg::*;
/*
The is assuming the change to no longer need the 'barrier' info
*/

module decode #(
    parameter int THREAD_ID_WIDTH = 9,
    parameter int MASK_WIDTH = (1 << THREAD_ID_WIDTH),
    parameter int BITSTREAM_ADDR_WIDTH = 32,
    parameter int BITSTREAM_LENGTH_WIDTH = 8

)(
    //from meta fetch unit
    input pgraph_meta_t metadata_in,
    input logic meta_in_valid,

    //to bitstream fetch unit
    output logic [BITSTREAM_ADDR_WIDTH-1:0] bitstream_addr,
    output logic bitstream_addr_valid, // Now a level signal indicating valid metadata
    output logic [BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length,

    //branch handler
    output logic [31:0] branch_metadata,
    output logic branch_req_valid,


    input logic [MASK_WIDTH-1:0] real_active_thread_mask,
    input logic mask_valid,

    //to valid checker
    output logic decode_valid, //mask done

    //to fdr stage barrier
    output pgraph_meta_t metadata_out,
    output logic [MASK_WIDTH-1:0] mask_out
);

    // Combinational assignments
    assign mask_out = real_active_thread_mask; 
    assign metadata_out = metadata_in;

    assign bitstream_addr_valid = meta_in_valid;
    assign bitstream_addr = metadata_in.bitstream_addr;
    assign bitstream_length = metadata_in.bitstream_length;

    assign branch_metadata = metadata_in.branch_meta;
    assign branch_req_valid = meta_in_valid;
    
    assign decode_valid = mask_valid;
    

endmodule

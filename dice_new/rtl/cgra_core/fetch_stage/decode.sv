import dice_pkg::*;
import frontend_pkg::*; 

module decode (

    input  pgraph_meta_t        metadata_in,
    input  logic                meta_in_valid,

    output logic [BITSTREAM_ADDR_WIDTH-1:0]   bitstream_addr,
    output logic                              bitstream_addr_valid, 
    output logic [BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length,

    output logic [31:0]         branch_metadata,
    output logic                branch_req_valid,
    input  thread_mask_t        real_active_thread_mask,
    input  logic                mask_valid,

    output logic                decode_valid, 
    
    output pgraph_meta_t        metadata_out,
    output thread_mask_t        mask_out
);

    // Bitstream Fetch
    assign bitstream_addr       = metadata_in.bitstream_addr;
    assign bitstream_length     = metadata_in.bitstream_length;
    assign bitstream_addr_valid = meta_in_valid;

    // Branch Handler
    assign branch_metadata      = metadata_in.branch_meta;
    assign branch_req_valid     = meta_in_valid;

    // FDR / Pipeline
    assign metadata_out         = metadata_in;
    assign mask_out             = real_active_thread_mask;
    assign decode_valid         = mask_valid;

endmodule
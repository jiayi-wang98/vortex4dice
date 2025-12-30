
//AS OF NOW THIS MODULE IS JUST A ROUTER
module decode (
    input dice_frontend_pkg::pgraph_meta_t metadata_in,
    input logic         meta_in_valid, //keeping

    input dice_frontend_pkg::thread_mask_t real_active_thread_mask,  //branch handler - to be packed
    //To bitstream Fetcher
    output logic [dice_pkg::DICE_ADDR_WIDTH-1:0] bitstream_addr,
    output logic bitstream_addr_valid,
    output logic [dice_frontend_pkg::BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length,

    //To branch handler
    output dice_frontend_pkg::branch_meta_t branch_metadata,  //contains divergence info/jmp info
    output logic         branch_req_valid,

    //To valid checker
    output logic      is_barrier,  // may remove
    output dice_frontend_pkg::fdr_meta_t meta_out
);

  // Bitstream Fetch
  assign bitstream_addr       = metadata_in.bitstream_addr;
  assign bitstream_length     = metadata_in.bitstream_length;
  assign bitstream_addr_valid = meta_in_valid;

  // Branch Handler
  assign branch_metadata      = metadata_in.branch_meta;
  assign branch_req_valid     = meta_in_valid;


  // valid checker
  assign is_barrier           = metadata_in.barrier;


  always_comb begin
    meta_out.bitstream_length = metadata_in.bitstream_length;
    meta_out.in_regs          = metadata_in.in_regs;
    meta_out.out_regs         = metadata_in.out_regs;
    meta_out.ld_dest_regs     = metadata_in.ld_dest_regs;
    meta_out.num_stores       = metadata_in.num_stores;
    meta_out.unrolling_factor = metadata_in.unrolling_factor;
    meta_out.lat              = metadata_in.lat;
    meta_out.parameter_load   = metadata_in.parameter_load;
    meta_out.active_mask      = real_active_thread_mask;
  end

endmodule



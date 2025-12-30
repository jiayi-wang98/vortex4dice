import dice_pkg::*;

/*
CONDITIONS FOR VALID TO BE ASSERTED:
1) Bitstream Loaded
2) E-block prefetch cleared or not prefetch block
3) Valid mask
4) Barrier condition met - NEED TO FIGURE OUT WHO UPDATES THIS IN THE STATUS TABLE (says decoder does / decoder keeps track of it
and gets the info from the retire table. I assume it will be easier to have the decoder just read from the status table
and have a separate controller for the status table -> will make decoder assuming that)
*/


//TO DO: Ensure that the prefetch and unresolved divergence is correct -> WHAT IS HAPPENING WITH BARRIER
module valid_check (

    //from decoder (if it is 1 then all prev blocks must finish before ex this p graph)
    input logic barrier_indicator,
    input logic mask_valid,

    //from CS, FDR buffer
    input logic [DICE_ADDR_WIDTH-1:0] eblock_pc,
    input logic prefetch_block,

    //from SIMT_Stack
    input logic [DICE_ADDR_WIDTH-1:0] simt_stack_pc,  // "next pc"


    input logic bitstream_loaded,

    //from cta status table
    input logic unresolved_div,
    input logic barrier,


    //to FDR DE buffer
    output logic fdr_valid,
    input  logic ex_ready,

    // Feedback to Fetch Stage
    output logic fire_eblock
);

  //intermediate signals
  logic pc_match;  //if the pc from the simt stack and the pc from schedule match
  logic prefetch_ok; // if it is either not a prefetch block, or the prefetch condition has been cleared
  logic bitstream_ok;  //if bitstream is loaded
  logic mask_ok;  //if mask is valid
  logic barrier_ok;  //if barrier condition is met
  logic no_divergence;  //MAY NEED TO MODIFY


  logic can_issue;  // true if all conditions are valid

  assign pc_match = eblock_pc == simt_stack_pc;
  assign prefetch_ok = !prefetch_block;  //NEED TO MODIFY
  assign bitstream_ok = bitstream_loaded;
  assign mask_ok = mask_valid;
  assign barrier_ok = barrier || (!barrier_indicator); // Assuming barrier input means "barrier done"
  assign no_divergence = !unresolved_div;

  //checks if all conditions are true
  assign can_issue = pc_match         &&
                       prefetch_ok      &&
                       bitstream_ok     &&
                       barrier_ok       &&
                       mask_ok          &&
                       no_divergence;

  // Output to DE Stage
  assign fdr_valid = can_issue;

  // Feedback to Fetch Stage (Fire when valid AND accepted by next stage)
  assign fire_eblock = can_issue && ex_ready;

  // Ready signal (Pass through backpressure/completion)
  assign valid_ready = fire_eblock;

endmodule

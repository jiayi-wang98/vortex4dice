//FIGURE OUT WHAT THE INITIAL RECONVERGENCE PC SHOULD BE

`include "dice_define.vh"


module cta_controller #(
    parameter int MAX_NUM_CTA = 4,
    parameter int CTA_INDEX_WIDTH = $clog2(MAX_NUM_CTA),
    parameter int THREAD_WIDTH = 256,  // must match active_cta_table & SIMT stack design
    parameter int PC_WIDTH = 32  // must match simt_stack_controller
) (
    input logic clk,
    input logic rst,

    //cta dispatcher interface
    input  logic                     in_cta_valid,
    input  dice_pkg::dice_cta_desc_t in_cta_desc,
    output logic                     in_cta_ready,

    input  logic                   comp_cta_ready,
    output logic                   comp_cta_valid,
    output dice_pkg::dice_cta_id_t comp_cta_id,


    //active cta table
    output logic                       pop_valid,
    input  logic [CTA_INDEX_WIDTH-1:0] pop_hw_cta_id,

    input  logic                                add_ready,
    output logic                                add_valid,
    output dice_cta_desc_t                      add_cta_info,
    output logic           [DICE_TID_WIDTH-1:0] add_cta_size,  //ensure this is correct


    //SIMT Stack Controller
    output logic init_valid,
    input logic init_ready,
    output logic [$clog2(MAX_NUM_CTA)-1:0] init_hw_cta_id,
    output logic [1:0] init_hw_cta_size,  // 00=1 stack, 01=2 stacks, 11=4 stacks
    output logic [PC_WIDTH-1:0] init_pc,
    output logic [PC_WIDTH-1:0] init_reconvergence_pc,

    //cta status table
    input dice_pkg::cta_status [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_table
    //interface to initiate table
    //interface to remove from table
);


  // ------------------------------------------------------------
  // Handshake: accept CTA only when *both*:
  //  - active_cta_table can allocate it (add_ready)
  //  - SIMT stack controller can initialize (init_ready)
  //
  // This guarantees we use the same hw_cta_id (next_empty_cta_index)
  // for both the active table and the SIMT stack(s) in the same cycle.
  // ------------------------------------------------------------
  assign in_cta_ready = add_ready && init_ready;  //can accept from dispatcher


  assign add_valid = in_cta_valid && init_ready;  //can add to the active cta table
  assign add_cta_info = in_cta_desc;  //the info that will be given to active cta tabls
  assign add_cta_size = in_cta_desc.kernel_desc.cta_size.x
                            * in_cta_desc.kernel_desc.cta_size.y
                            * in_cta_desc.kernel_desc.cta_size.z; //size for active cta table



  // ------------------------------------------------------------
  // Encode hw_cta_size (number of stacks) from CTA thread count
  //   hw_cta_size encodings (per simt_stack_controller docs):
  //     2'b00 -> 1 stack (256 threads)
  //     2'b01 -> 2 stacks (512 threads)
  //     2'b11 -> 4 stacks (1024 threads)
  // ------------------------------------------------------------
  function automatic logic [1:0] encode_hw_cta_size(input logic [DICE_TID_WIDTH:0] cta_size);
    // Thresholds sized to match cta_size exactly
    logic [DICE_TID_WIDTH:0] thr1;
    logic [DICE_TID_WIDTH:0] thr2;
    begin
      thr1 = (DICE_TID_WIDTH + 1)'(THREAD_WIDTH);
      thr2 = (DICE_TID_WIDTH + 1)'(2 * THREAD_WIDTH);

      if (cta_size <= thr1) encode_hw_cta_size = 2'b00;
      else if (cta_size <= thr2) encode_hw_cta_size = 2'b01;
      else encode_hw_cta_size = 2'b11;
    end
  endfunction


  // SIMT Stack Controller
  assign init_valid            = in_cta_valid && add_ready;
  assign init_hw_cta_id        = next_empty_cta_index;
  // num stacks
  assign init_hw_cta_size      = encode_hw_cta_size(add_cta_size);
  // initial pc
  assign init_pc               = in_cta_desc.kernel_desc.start_pc;
  assign init_reconvergence_pc = '0;  //THIS NEEDS TO BE SORTED OUT



  // CTA Status Table


endmodule

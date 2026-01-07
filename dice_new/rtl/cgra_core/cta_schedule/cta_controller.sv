`include "dice_define.vh"

module cta_controller
  import dice_pkg::*;
  import dice_frontend_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    //cta dispatcher interface
    cta_dispatch_if.slave  dispatch_if,
    cta_complete_if.master complete_if,

    //active cta table
    output logic pop_valid_o,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0] pop_hw_cta_id_o,
    input logic pop_ready_i,  // Backpressure from active_cta_table
    input logic add_ready_i,
    output logic add_valid_o,
    output dice_cta_desc_t add_cta_info_o,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0] add_cta_size_o,  //ensure this is correct
    input logic [DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index_i,
    input logic [DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_status_i,  // Validity bitmap
    input logic pop_out_valid_i,
    input dice_cta_id_t pop_out_cta_id_i,

    //SIMT Stack Controller
    output logic init_valid_o,
    input logic init_ready_i,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0] init_hw_cta_id_o,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0] init_hw_cta_size_o,  // 00=1 stack, 01=2 stacks, 11=4 stacks
    output logic [DICE_ADDR_WIDTH-1:0] init_pc_o,
    output logic [DICE_ADDR_WIDTH-1:0] init_reconvergence_pc_o,

    //cta status table
    input dice_cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_table_i, //THIS NEEDS TO BE CHANGED TO JUST SHOW THE IMPORTANT INFORMATION
    output logic clear_entry_valid_o,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id_o
);


  assign dispatch_if.ready = add_ready_i && init_ready_i;  //can accept from dispatcher

  assign add_valid_o = dispatch_if.valid && init_ready_i;  //can add to the active cta table
  assign add_cta_info_o = dispatch_if.data;  //the info that will be given to active cta tabls
  assign add_cta_size_o = dispatch_if.data.kernel_desc.cta_size.x
                            * dispatch_if.data.kernel_desc.cta_size.y
                            * dispatch_if.data.kernel_desc.cta_size.z; //size for active cta table



  // Encode hw_cta_size (number of stacks) from CTA thread count
  //   hw_cta_size encodings (per simt_stack_controller docs):
  //     2'b00 -> 1 stack (256 threads)
  //     2'b01 -> 2 stacks (512 threads)
  //     2'b11 -> 4 stacks (1024 threads)
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
  assign init_valid_o            = dispatch_if.valid && add_ready_i;
  assign init_hw_cta_id_o        = next_empty_cta_index_i;
  // num stacks
  assign init_hw_cta_size_o      = encode_hw_cta_size(add_cta_size_o);
  // initial pc
  assign init_pc_o               = dispatch_if.data.kernel_desc.start_pc;
  assign init_reconvergence_pc_o = '1;  // Set to all 1s to avoid matching valid PC 0




  // Completion Logic

  // Round-robin pointer for fairness
  logic [DICE_HW_CTA_ID_WIDTH-1:0] completion_ptr_q;
  logic [DICE_HW_CTA_ID_WIDTH-1:0] victim_id;
  logic victim_found;

  // Round-robin arbiter to find a completed CTA
  always_ff @(posedge clk_i) begin
    if (rst_i == 1'b1) completion_ptr_q <= '0;
    else completion_ptr_q <= completion_ptr_q + 1'b1;
  end

  // Combinational search starting from completion_ptr_q to find a retirement candidate
  always_comb begin
    victim_found = 1'b0;
    victim_id = '0;

    // We need to check all slots
    for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
      // Calculate index wrapping around based on ptr
      logic [DICE_HW_CTA_ID_WIDTH-1:0] idx;
      idx = completion_ptr_q + i[DICE_HW_CTA_ID_WIDTH-1:0];

      // Check if this CTA is valid AND has NO pending eblocks
      // We assume input 'active_cta_status_i' tells us validity (see added IO)
      if ((active_cta_status_i[idx] == 1'b1) &&
              (cta_status_table_i[idx].has_pending_eblock == 1'b0) &&
              (victim_found == 1'b0)) begin
        victim_found = 1'b1;
        victim_id = idx;
      end
    end
  end

  // Flow control: Only pop if we are not currently waiting for a previous pop to clear
  // (pop_out_valid_i indicates a previous pop is still in the output buffer/handshake)
  assign pop_valid_o = victim_found && (pop_out_valid_i == 1'b0);
  assign pop_hw_cta_id_o = victim_id;

  assign clear_entry_valid_o = pop_valid_o;  // Clear status same cycle we pop
  assign clear_entry_hw_id_o = victim_id;

  // Pass through the Active Table output to the Dispatcher
  assign complete_if.valid = pop_out_valid_i;
  assign complete_if.cta_id = pop_out_cta_id_i;



`ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_i == 1'b0) begin
      if (pop_valid_o == 1'b1) begin
        assert (cta_status_table_i[pop_hw_cta_id_o].has_pending_eblock == 1'b0)
        else $error("PopOnlyCompleted: Popping CTA with pending eblocks");
      end

      assert (!$isunknown(pop_valid_o))
      else $error("ControlOutputs: pop_valid_o is X");
      assert (!$isunknown(clear_entry_valid_o))
      else $error("ControlOutputs: clear_entry_valid_o is X");
      assert (!$isunknown(init_valid_o))
      else $error("ControlOutputs: init_valid_o is X");
    end
  end
`endif

endmodule

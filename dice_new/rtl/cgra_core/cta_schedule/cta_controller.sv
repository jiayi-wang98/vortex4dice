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
    output logic [CTA_INDEX_WIDTH-1:0] pop_hw_cta_id,
    input  logic                       pop_ready,  // Backpressure from active_cta_table

    input  logic                                add_ready,
    output logic                                add_valid,
    output dice_pkg::dice_cta_desc_t            add_cta_info,
    output logic           [dice_pkg::DICE_TID_WIDTH-1:0] add_cta_size,  //ensure this is correct


    //SIMT Stack Controller
    output logic init_valid,
    input logic init_ready,
    output logic [$clog2(MAX_NUM_CTA)-1:0] init_hw_cta_id,
    output logic [1:0] init_hw_cta_size,  // 00=1 stack, 01=2 stacks, 11=4 stacks
    output logic [PC_WIDTH-1:0] init_pc,
    output logic [PC_WIDTH-1:0] init_reconvergence_pc,

    //cta status table
    input dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_table,
    output logic clear_entry_valid,
    output logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id,

    // Active CTA Table Status
    input logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index,
    input logic [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_status, // Validity bitmap

    // Active CTA Table Pop Return Interface
    input logic pop_out_valid,
    input dice_pkg::dice_cta_id_t pop_out_cta_id
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
  function automatic logic [1:0] encode_hw_cta_size(input logic [dice_pkg::DICE_TID_WIDTH:0] cta_size);
    // Thresholds sized to match cta_size exactly
    logic [dice_pkg::DICE_TID_WIDTH:0] thr1;
    logic [dice_pkg::DICE_TID_WIDTH:0] thr2;
    begin
      thr1 = (dice_pkg::DICE_TID_WIDTH + 1)'(THREAD_WIDTH);
      thr2 = (dice_pkg::DICE_TID_WIDTH + 1)'(2 * THREAD_WIDTH);

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
  assign init_reconvergence_pc = '1;  // Set to all 1s to avoid matching valid PC 0




  // ------------------------------------------------------------
  // Completion Logic
  // ------------------------------------------------------------

  // Round-robin pointer for fairness
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] completion_ptr;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] victim_id;
  logic victim_found;

  // Round-robin arbiter to find a completed CTA
  always_ff @(posedge clk) begin
      if (rst) completion_ptr <= '0;
      else completion_ptr <= completion_ptr + 1'b1;
  end

  // Combinational search starting from completion_ptr to find a retirement candidate
  always_comb begin
      victim_found = 1'b0;
      victim_id = '0;

      // We need to check all slots
      for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
          // Calculate index wrapping around based on ptr
          logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] idx;
          idx = completion_ptr + i[dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0];

          // Check if this CTA is valid AND has NO pending eblocks
          // We assume input 'active_cta_status' tells us validity (see added IO)
          if (active_cta_status[idx] && !cta_status_table[idx].has_pending_eblock && !victim_found) begin
              victim_found = 1'b1;
              victim_id = idx;
          end
      end
  end

  // Flow control: Only pop if we are not currently waiting for a previous pop to clear
  // (pop_out_valid indicates a previous pop is still in the output buffer/handshake)
  assign pop_valid = victim_found && !pop_out_valid;
  assign pop_hw_cta_id = victim_id;

  assign clear_entry_valid = pop_valid; // Clear status same cycle we pop
  assign clear_entry_hw_id = victim_id;

  // Pass through the Active Table output to the Dispatcher
  assign comp_cta_valid = pop_out_valid;
  assign comp_cta_id = pop_out_cta_id;



  `ifndef SYNTHESIS
  always_ff @(posedge clk) begin
      if (!rst) begin
          if (pop_valid) begin
              assert (!cta_status_table[pop_hw_cta_id].has_pending_eblock)
              else $error("PopOnlyCompleted: Popping CTA with pending eblocks");
          end

          assert (!$isunknown(pop_valid)) else $error("ControlOutputs: pop_valid is X");
          assert (!$isunknown(clear_entry_valid)) else $error("ControlOutputs: clear_entry_valid is X");
          assert (!$isunknown(init_valid)) else $error("ControlOutputs: init_valid is X");
      end
  end
  `endif

endmodule

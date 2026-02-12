// Branch Handler: updates SIMT stack, status table, and active thread mask




/*
IDEA FOR STATUS TABLE INTERFACE:
have a 3 bit bitmapped signal that tells the status table what fields to update
(predicted_pc, unresolved control, barrier condition)

Time multiplex the status table updates and prioritize current fdr eblock updates over pending updates
*/



module branch_handler
  import dice_frontend_pkg::*;
  import dice_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    // Valid Check
    input logic fire_eblock_i,
    input logic flush_i,

    // Status table
    output branch_predict_interface_t branch_predict_info_o,
    output logic                      branch_predict_info_we_o,

    // Decode
    input branch_meta_t branch_meta_i,
    input logic branch_meta_valid_i, // stays valid for many cycles
    output thread_mask_t real_active_thread_mask_o,
    output logic real_active_thread_mask_valid_o,

    // CS -> FDR Stage buffer
    input logic prefetch_block_i, // This will stay the same until the next eblock but should be registered
    input thread_mask_t prefetch_active_mask_i,
    input logic [DICE_ADDR_WIDTH-1:0] pc_i,
    input cta_size_e cta_size_i,
    input logic [DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id_i,
    
    // bh_buffer
    input thread_mask_t bh_buffer_pred_i,
    input logic bh_buffer_valid_i,
    output logic bh_buffer_consumed_o,

    // SIMT Stacks
    output logic update_valid_o,
    input logic update_ready_i,
    output simt_stack_update_t simt_stack_update_o  
);

  //--- Rising edge detection for branch_meta_valid_i ---
  logic branch_meta_valid_rise;

  rising_edge_detector u_branch_meta_valid_rise (
      .clk_i  (clk_i),
      .rst_i  (rst_i),
      .sig_i  (branch_meta_valid_i),
      .rise_o (branch_meta_valid_rise)
  );

  //--- Branch Info FIFO ---
  logic bh_fifo_push; // new stuff gets pushed every time an eblock is fired
  logic bh_fifo_pop; // pop when front of queue has been written to simt stack and status table or doesn't need to be written
  branch_info_t bh_fifo_data_in;
  branch_info_t bh_fifo_data_out;
  logic bh_fifo_full; 
  logic bh_fifo_empty; // invalidates the top of the queue

  bh_fifo #(
      .DEPTH(3)
  ) u_bh_fifo (
      .clk_i  (clk_i),
      .rst_i  (rst_i),
      .push_i (bh_fifo_push),
      .pop_i  (bh_fifo_pop),
      .data_i (bh_fifo_data_in),
      .data_o (bh_fifo_data_out),
      .full_o (bh_fifo_full),
      .empty_o(bh_fifo_empty)
  );

 











  

  // The fdr branch metadata register is ready to accept new data when it doesn't need to write to the status table or the simt stack
  // and it has already been pushed to the fifo which happens 1 cycle after the eblock is fired
  // When these conditions are met or the stage is flushed, the waiting for new meta flag is set.
  
  






  

















  assign update_valid_o = (buffer_state_q == UPDATE_STACK);
  assign bh_fifo_pop = (buffer_state_q == UPDATE_STATUS && from_queue_q);

  //--- Mask FSM ---
  typedef enum logic [1:0] {
      MASK_IDLE,
      REAL_MASK
  } curr_eblock_mask_state_e;

  curr_eblock_mask_state_e curr_eblock_mask_state_q, curr_eblock_mask_state_d;

  always_comb begin
    curr_eblock_mask_state_d = curr_eblock_mask_state_q;
    case (curr_eblock_mask_state_q)
      MASK_IDLE: begin
        if (branch_meta_valid_i && ((prefetched_eblock_q && empty_buffer_fired) || ~prefetched_eblock_q))
          curr_eblock_mask_state_d = REAL_MASK;
      end
      REAL_MASK: begin
        if (fire_eblock_i || flush_i)
          curr_eblock_mask_state_d = MASK_IDLE;
      end
      default: curr_eblock_mask_state_d = MASK_IDLE;
    endcase
  end

  //--- Sequential: buffer FSM + simple registers ---
  always_ff @(posedge clk_i or posedge rst_i) begin
      if (rst_i) begin
        curr_eblock_updated_q    <= 1'b0;
        from_queue_q             <= 1'b0;
        stack_update_buffer_q    <= '0;
        buffer_state_q           <= BUF_IDLE;
        prefetched_eblock_q      <= 1'b0;
        empty_buffer_fired       <= 1'b0;
        curr_eblock_mask_state_q <= MASK_IDLE;
      end else begin
        if (fire_eblock_i || flush_i)
          curr_eblock_updated_q <= 1'b0;
        else
          curr_eblock_updated_q <= curr_eblock_updated_d;

        from_queue_q             <= from_queue_d;
        stack_update_buffer_q    <= stack_update_buffer_d;
        buffer_state_q           <= buffer_state_d;
        prefetched_eblock_q      <= prefetch_block_i;
        empty_buffer_fired       <= (buffer_state_q == UPDATE_STATUS);
        curr_eblock_mask_state_q <= curr_eblock_mask_state_d;
      end
  end

  //--- Real active thread mask output ---
  assign real_active_thread_mask_valid_o = (curr_eblock_mask_state_q == REAL_MASK);
  thread_mask_t calculated_real_active_thread_mask;

  //TODO: Ensure that this calculation is correct
  assign calculated_real_active_thread_mask = prefetch_active_mask_i & bh_buffer_pred_i;
  assign real_active_thread_mask_o = (prefetched_eblock_q) ? calculated_real_active_thread_mask : prefetch_active_mask_i;

endmodule

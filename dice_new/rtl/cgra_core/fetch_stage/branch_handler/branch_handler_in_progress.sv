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
    output logic real_active_thread_mask_valid_o, // I DON'T THINK WE NEED THIS

    // CS -> FDR Stage buffer
    input logic prefetch_block_i, // This will stay the same until the next eblock but should be registered
    input thread_mask_t cs_active_mask_i,
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

  bh_curr_meta u_bh_curr_meta (
      .clk_i                        (clk_i),
      .rst_i                        (rst_i),
      .new_meta_pulse_i             (branch_meta_valid_rise),
      .meta_valid_i                 (),
      .branch_meta_i                (),
      .pc_i                         (),
      .hw_cta_id_i                  (),
      .cta_size_i                   (),
      .prefetch_block_i             (),
      .flush_i                      (),
      .pushed_to_fifo_pulse_i       (),
      .wr_to_simt_i                 (),
      .wr_to_status_table_i         (),
      .bh_done_o                    (),
      .valid_o                      (),
      .branch_info_o                (),
      .predict_pc_o                 (),
      .unresolved_control_o         (),
      .is_return_o                  (),
      .next_pc_o                    (),
      .pending_wr_to_simt_o         (),
      .pending_wr_to_status_table_o ()
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








  //--- Real Active Thread Mask ---
  thread_mask_t calculated_real_active_thread_mask_q, calculated_real_active_thread_mask_d;

  always_ff @(posedge clk) begin
    if (rst_i) begin
      calculated_real_active_thread_mask_q <= '0;
    end else begin
      calculated_real_active_thread_mask_q <= calculated_real_active_thread_mask_d;
    end
  end

  // Always updates when the mask in the bh_buffer is for the currn cta_hw_id
  always_comb begin
    calculated_real_active_thread_mask_d = calculated_real_active_thread_mask_q;
    if(branch_meta_valid_i && prefetch_block_i && (hw_cta_id_i == bh_fifo_data_out.hw_cta_id) && bh_buffer_valid_i) begin
      calculated_real_active_thread_mask_d = cs_active_mask_i & bh_buffer_pred_i;
    end else if (branch_meta_valid_i) begin
      calculated_real_active_thread_mask_d = cs_active_mask_i;
    end
  end

  assign real_active_thread_mask_o = calculated_real_active_thread_mask_q;

endmodule

module bh_curr_meta 
    import dice_frontend_pkg::*;
    import dice_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    input logic flush_i,
    input logic new_meta_pulse_i,          // rising edge of branch_meta_valid from parent
    input logic pushed_to_fifo_pulse_i,    // parent tells us our data was pushed to FIFO
    input branch_meta_t branch_meta_i,
    input logic [DICE_ADDR_WIDTH-1:0] pc_i,
    input logic [DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id_i,
    input cta_size_e cta_size_i,
    input logic prefetch_block_i,
    input logic wr_to_simt_i,              // parent signals SIMT write completed
    input logic wr_to_status_table_i,      // parent signals status table write completed

    output branch_info_t branch_info_o,
    output logic valid_o,
    output logic [DICE_ADDR_WIDTH-1:0] predict_pc_o,
    output logic pending_wr_to_simt_o,
    output logic pending_wr_to_status_table_o
);


  //--- Divergent branch detection (reserved for future use) ---
  // logic is_divergent_branch;
  // assign is_divergent_branch = new_meta_pulse_i
  //                            && branch_meta_i.branch_ena
  //                            && ~branch_meta_i.branch_uni;

  //--- BTFN prediction: backwards (taken_pc < pc) -> taken; forwards -> not-taken ---
  logic [DICE_ADDR_WIDTH-1:0] taken_pc_calc;
  logic [DICE_ADDR_WIDTH-1:0] not_taken_pc_calc;
  logic [DICE_ADDR_WIDTH-1:0] reconv_pc_calc;
  logic predict_taken;

  assign taken_pc_calc     = pc_i + (branch_meta_i.branch_jump_target_offset * DICE_METADATA_WIDTH);
  assign not_taken_pc_calc = pc_i + DICE_METADATA_WIDTH; // ALSO NEXT PC IF NO BRANCH
  assign reconv_pc_calc    = pc_i + (branch_meta_i.branch_reconv_offset * DICE_METADATA_WIDTH);
  assign predict_taken     = (taken_pc_calc < pc_i);


  //--- Register that holds the branch meta and predicted pc for the current eblock ---
  branch_info_t               fdr_branch_meta_q;
  logic                       fdr_branch_meta_valid_q;
  logic [DICE_ADDR_WIDTH-1:0] fdr_branch_predict_pc_q;
  logic                       prefetched_eblock_q;
  // TODO: Add divergent branch detection for the simt stack


  //--- Eblock committed flag: set when parent pushes to FIFO, used for prefetch gating ---
  logic eblock_committed_q;

  always_ff @(posedge clk_i) begin
      if (rst_i || flush_i) // need to add another condition here for after the old block is done
          eblock_committed_q <= 1'b0;
      else if (pushed_to_fifo_pulse_i)
          eblock_committed_q <= 1'b1;
  end

  //--- Written-to tracking ---
  logic fdr_reg_written_to_simt_stack_q, fdr_reg_written_to_simt_stack_d;
  logic fdr_reg_written_to_status_table_q, fdr_reg_written_to_status_table_d;

  logic fdr_reg_need_to_write_to_status_table;
  logic fdr_reg_need_to_write_to_simt_stack;

  // Latch the write-done signals
  assign fdr_reg_written_to_simt_stack_d   = fdr_reg_written_to_simt_stack_q   || wr_to_simt_i;
  assign fdr_reg_written_to_status_table_d = fdr_reg_written_to_status_table_q || wr_to_status_table_i;

  // Divergent branch or return -> needs status table write
  // Only assert after committed for prefetch blocks
  assign fdr_reg_need_to_write_to_status_table = fdr_branch_meta_valid_q
                                             && (~prefetched_eblock_q || eblock_committed_q)
                                             && (fdr_branch_meta_q.branch_ena
                                             && ~fdr_branch_meta_q.branch_uni
                                             || fdr_branch_meta_q.is_return)
                                             && ~fdr_reg_written_to_status_table_q;

  // Non-branch or uniform branch -> needs SIMT stack write
  // Only assert after committed for prefetch blocks
  assign fdr_reg_need_to_write_to_simt_stack = fdr_branch_meta_valid_q
                                           && (~prefetched_eblock_q || eblock_committed_q)
                                           && (~fdr_branch_meta_q.branch_ena
                                           || fdr_branch_meta_q.branch_uni)
                                           && ~fdr_reg_written_to_simt_stack_q;

  //--- Metadata capture register ---
  always_ff @(posedge clk_i) begin
      if (rst_i) begin
          fdr_branch_meta_valid_q <= 1'b0;
          fdr_branch_meta_q       <= '0;
          fdr_branch_predict_pc_q <= '0;
          prefetched_eblock_q     <= 1'b0;
      end else if (flush_i) begin
          fdr_branch_meta_valid_q <= 1'b0;
      end else if (new_meta_pulse_i) begin
          fdr_branch_meta_valid_q                     <= 1'b1;
          fdr_branch_meta_q.hw_cta_id                 <= hw_cta_id_i;
          fdr_branch_meta_q.cta_size                  <= cta_size_i;
          fdr_branch_meta_q.branch_ena                <= branch_meta_i.branch_ena;
          fdr_branch_meta_q.branch_uni                <= branch_meta_i.branch_uni;
          fdr_branch_meta_q.branch_taken_pc           <= taken_pc_calc;
          fdr_branch_meta_q.branch_not_taken_pc       <= not_taken_pc_calc;
          fdr_branch_meta_q.branch_reconvergence_pc   <= reconv_pc_calc;
          fdr_branch_meta_q.branch_neg_pred           <= branch_meta_i.branch_neg_pred;
          fdr_branch_meta_q.is_return                 <= branch_meta_i.is_return;
          fdr_branch_predict_pc_q                     <= predict_taken ? taken_pc_calc : not_taken_pc_calc;
          prefetched_eblock_q                         <= prefetch_block_i;
      end
  end

  //--- Written-to tracking registers: clear on new metadata arrival ---
  always_ff @(posedge clk_i) begin
      if (rst_i) begin
          fdr_reg_written_to_simt_stack_q   <= 1'b0;
          fdr_reg_written_to_status_table_q <= 1'b0;
      end else if (flush_i || new_meta_pulse_i) begin
          fdr_reg_written_to_simt_stack_q   <= 1'b0;
          fdr_reg_written_to_status_table_q <= 1'b0;
      end else begin
          fdr_reg_written_to_simt_stack_q   <= fdr_reg_written_to_simt_stack_d;
          fdr_reg_written_to_status_table_q <= fdr_reg_written_to_status_table_d;
      end
  end

  //--- Output assignments ---
  assign branch_info_o                = fdr_branch_meta_q;
  assign valid_o                      = fdr_branch_meta_valid_q;
  assign predict_pc_o                 = fdr_branch_predict_pc_q;
  assign pending_wr_to_simt_o         = fdr_reg_need_to_write_to_simt_stack;
  assign pending_wr_to_status_table_o = fdr_reg_need_to_write_to_status_table;

endmodule
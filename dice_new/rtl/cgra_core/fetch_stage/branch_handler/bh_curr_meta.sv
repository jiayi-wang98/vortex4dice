/*
Overview:

This module holds the information for the eblock in the FDR stage


CS/FDR stage border is now going to be controlled by this module so we don't need to register some stuff


    - i think this could be simplified a lot but for the time being i am keeping it as is for readability
    - probably don't need to register the branch meta, we can just pass it through
*/


module bh_curr_meta 
    import dice_frontend_pkg::*;
    import dice_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    // New Metadata
    input logic new_meta_pulse_i,
    
    input branch_meta_t branch_meta_i,
    input logic [DICE_ADDR_WIDTH-1:0] pc_i,
    input logic [DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id_i,
    input cta_size_e cta_size_i,
    input logic prefetch_block_i,

    // Signals that control the current eblock's lifecycle
    input logic flush_i,
    input logic pushed_to_fifo_pulse_i,    // parent tells us our data was pushed to FIFO (this is the same as the old fire_eblock_i)
    input logic wr_to_simt_i,              // parent signals SIMT write completed
    input logic wr_to_status_table_i,      // parent signals status table write completed

    output logic fdr_stage_buffer_ready_o,

    // Status
    output logic valid_o,

    // To FIFO
    output branch_info_t branch_info_o,
    
    // To status table
    output logic [DICE_ADDR_WIDTH-1:0] predict_pc_o,
    output logic unresolved_control_o,
    output logic is_return_o,

    // To SIMT Stack
    output logic [DICE_ADDR_WIDTH-1:0] next_pc_o,

    // Pending operations
    output logic pending_wr_to_simt_o,
    output logic pending_wr_to_status_table_o
);


  //--- CORRECT: COMBINATIONAL LOGIC FOR DIVERGENT BRANCH DETECTION ---
  logic is_divergent_branch;
  assign is_divergent_branch = branch_meta_i.branch_ena && ~branch_meta_i.branch_uni;

  //--- CORRECT: COMBINATIONAL LOGIC FOR BRANCH PC CALCULATION ---
  logic [DICE_ADDR_WIDTH-1:0] taken_pc_calc;
  logic [DICE_ADDR_WIDTH-1:0] not_taken_pc_calc;
  logic [DICE_ADDR_WIDTH-1:0] reconv_pc_calc;
  logic predict_taken;

  assign taken_pc_calc     = pc_i + (branch_meta_i.branch_jump_target_offset * DICE_METADATA_WIDTH);
  assign not_taken_pc_calc = pc_i + DICE_METADATA_WIDTH; // ALSO NEXT PC IF NO BRANCH
  assign reconv_pc_calc    = pc_i + (branch_meta_i.branch_reconv_offset * DICE_METADATA_WIDTH);
  assign predict_taken     = (taken_pc_calc < pc_i);



  //--- CORRECT: REGISTERS THAT HOLD CURRENT INFORMATION ---
  branch_info_t               fdr_branch_meta_q;
  logic                       fdr_branch_meta_valid_q;
  
  // Determine what we write to the status table and simt stack
  logic                       divergent_branch_q;

  // Status Table Info
  logic [DICE_ADDR_WIDTH-1:0] fdr_branch_predict_pc_q;
  logic                       is_return_q;

  // SIMT Stack Info
  logic [DICE_ADDR_WIDTH-1:0] next_pc_q;
  
  
  // Internal signals to orchestrate writes to status table and simt stack
  logic                       unresolved_control_q;
  logic                       eblock_pushed_to_fifo_q, eblock_pushed_to_fifo_d;


  assign eblock_pushed_to_fifo_d = pushed_to_fifo_pulse_i || eblock_pushed_to_fifo_q;

  //--- Metadata capture register ---
  always_ff @(posedge clk_i) begin
      if (rst_i) begin
          fdr_branch_meta_q       <= '0;
          fdr_branch_meta_valid_q <= 1'b0;
          divergent_branch_q      <= 1'b0;
          fdr_branch_predict_pc_q <= '0;
          is_return_q             <= 1'b0;
          next_pc_q               <= '0;
          unresolved_control_q    <= 1'b0;
          eblock_pushed_to_fifo_q <= 1'b0;          
      end else if (flush_i) begin
          fdr_branch_meta_valid_q <= 1'b0;
          unresolved_control_q    <= 1'b0;
          eblock_pushed_to_fifo_q <= 1'b0;
      end else if (new_meta_pulse_i) begin
        // to fifo
          fdr_branch_meta_q.hw_cta_id                 <= hw_cta_id_i;
          fdr_branch_meta_q.cta_size                  <= cta_size_i;
          fdr_branch_meta_q.branch_ena                <= branch_meta_i.branch_ena;
          fdr_branch_meta_q.branch_uni                <= branch_meta_i.branch_uni;
          fdr_branch_meta_q.branch_taken_pc           <= taken_pc_calc;
          fdr_branch_meta_q.branch_not_taken_pc       <= not_taken_pc_calc;
          fdr_branch_meta_q.branch_reconvergence_pc   <= reconv_pc_calc;
          fdr_branch_meta_q.branch_neg_pred           <= branch_meta_i.branch_neg_pred;
          
          eblock_pushed_to_fifo_q                     <= 1'b0;
          fdr_branch_meta_valid_q                     <= 1'b1;
          divergent_branch_q                          <= is_divergent_branch;
          fdr_branch_predict_pc_q                     <= predict_taken ? taken_pc_calc : not_taken_pc_calc;
          is_return_q                                 <= branch_meta_i.is_return;

          // eventually may need more calculations
          next_pc_q                                   <= branch_meta_i.branch_ena ? taken_pc_calc : not_taken_pc_calc;
          unresolved_control_q                        <= prefetch_block_i;


      end else begin
        eblock_pushed_to_fifo_q <= eblock_pushed_to_fifo_d;
        if (pushed_to_fifo_pulse_i)
          unresolved_control_q <= 1'b0;
      end
  end

  //--- Tracks if the current eblock has been written to the simt stack and status table ---
  logic written_to_simt_stack_q, written_to_simt_stack_d;
  logic written_to_status_table_q, written_to_status_table_d;

  // Signals that indicate if the current eblock has to write to the status table and simt stack
  // It is possible that the current eblock is a prefetch block, so we need to wait for it to be fired
  // before writing to the status table and simt stack
  logic need_to_write_to_status_table;
  logic need_to_write_to_simt_stack;

  assign need_to_write_to_status_table = divergent_branch_q || is_return_q;
  assign need_to_write_to_simt_stack = divergent_branch_q || ~is_return_q;

  //--- Written-to tracking registers: clear on new metadata arrival ---
  always_ff @(posedge clk_i) begin
      if (rst_i) begin
          written_to_simt_stack_q   <= 1'b0;
          written_to_status_table_q <= 1'b0;
      end else if (flush_i || new_meta_pulse_i) begin
          written_to_simt_stack_q   <= 1'b0;
          written_to_status_table_q <= 1'b0;
      end else begin
          written_to_simt_stack_q   <= written_to_simt_stack_d;
          written_to_status_table_q <= written_to_status_table_d;
      end
  end

  assign written_to_simt_stack_d   = wr_to_simt_i || written_to_simt_stack_q;
  assign written_to_status_table_d = wr_to_status_table_i || written_to_status_table_q;



  //--- Output assignments---
  assign fdr_stage_buffer_ready_o = (~need_to_write_to_status_table || written_to_status_table_q) 
                                    && (~need_to_write_to_simt_stack || written_to_simt_stack_q)
                                    && eblock_pushed_to_fifo_q
                                    && fdr_branch_meta_valid_q;

  assign valid_o                      = fdr_branch_meta_valid_q;
  assign branch_info_o                = fdr_branch_meta_q;
  assign predict_pc_o                 = fdr_branch_predict_pc_q;
  assign unresolved_control_o         = divergent_branch_q;
  assign is_return_o                  = is_return_q;
  
  //--- Pending write signals: assert when we need to write but haven't yet ---
  assign pending_wr_to_simt_o = need_to_write_to_simt_stack 
                                && ~written_to_simt_stack_q 
                                && fdr_branch_meta_valid_q 
                                && ~wr_to_simt_i 
                                && ~unresolved_control_q;

  assign pending_wr_to_status_table_o = need_to_write_to_status_table 
                                && ~written_to_status_table_q 
                                && fdr_branch_meta_valid_q 
                                && ~wr_to_status_table_i 
                                && ~unresolved_control_q;

  assign next_pc_o = next_pc_q;

endmodule

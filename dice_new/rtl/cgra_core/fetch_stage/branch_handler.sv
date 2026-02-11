// Branch Handler: updates SIMT stack, status table, and active thread mask

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
    input logic branch_meta_valid_i,
    output thread_mask_t real_active_thread_mask_o,
    output logic real_active_thread_mask_valid_o,

    // CS -> FDR Stage buffer
    input logic prefetch_block_i,
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

  //--- Stack update buffer ---
  simt_stack_update_t stack_update_buffer_q, stack_update_buffer_d;
  logic prefetched_eblock_q;
  logic empty_buffer_fired;

  //--- Divergent branch detection ---
  logic is_divergent_branch;
  assign is_divergent_branch = branch_meta_valid_i
                             && branch_meta_i.branch_ena
                             && ~branch_meta_i.branch_uni;

  //--- BTFN prediction: backwards (taken_pc < pc) -> taken; forwards -> not-taken ---
  logic [DICE_ADDR_WIDTH-1:0] taken_pc_calc;
  logic [DICE_ADDR_WIDTH-1:0] not_taken_pc_calc;
  logic [DICE_ADDR_WIDTH-1:0] reconv_pc_calc;
  logic predict_taken;

  assign taken_pc_calc     = pc_i + (branch_meta_i.branch_jump_target_offset * DICE_METADATA_WIDTH);
  assign not_taken_pc_calc = pc_i + DICE_METADATA_WIDTH;
  assign reconv_pc_calc    = pc_i + (branch_meta_i.branch_reconv_offset * DICE_METADATA_WIDTH);
  assign predict_taken     = (taken_pc_calc < pc_i);

  //--- Branch Info FIFO ---
  logic bh_fifo_push;
  logic bh_fifo_pop;
  branch_info_t bh_fifo_data_in;
  branch_info_t bh_fifo_data_out;
  logic bh_fifo_full;
  logic bh_fifo_empty;

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

  //--- Pending register for prefetch-deferred FIFO push ---
  branch_info_t               branch_pending_q;
  logic                       branch_pending_valid_q;
  logic [DICE_ADDR_WIDTH-1:0] pending_predict_pc_q;

  always_ff @(posedge clk_i) begin
      if (rst_i) begin
          branch_pending_valid_q <= 1'b0;
          branch_pending_q       <= '0;
          pending_predict_pc_q   <= '0;
      end else if (flush_i) begin
          branch_pending_valid_q <= 1'b0;
      end else if (prefetched_eblock_q && is_divergent_branch) begin
          branch_pending_valid_q                     <= 1'b1;
          branch_pending_q.hw_cta_id                 <= hw_cta_id_i;
          branch_pending_q.cta_size                  <= cta_size_i;
          branch_pending_q.next_pc                   <= taken_pc_calc;
          branch_pending_q.branch_not_taken_pc       <= not_taken_pc_calc;
          branch_pending_q.branch_reconvergence_pc   <= reconv_pc_calc;
          branch_pending_q.branch_neg_pred           <= branch_meta_i.branch_neg_pred;
          branch_pending_q.is_return                 <= branch_meta_i.is_return;
          branch_pending_q.valid                     <= 1'b1;
          pending_predict_pc_q                       <= predict_taken ? taken_pc_calc : not_taken_pc_calc;
      end else if (fire_eblock_i && branch_pending_valid_q) begin
          branch_pending_valid_q <= 1'b0;
      end
  end

  //--- Stack update output ---
  assign simt_stack_update_o = stack_update_buffer_q;

  //--- Buffer FSM ---
  typedef enum logic [1:0] {
      BUF_IDLE,
      UPDATE_STACK,
      UPDATE_STATUS
  } buffer_state_e;

  buffer_state_e buffer_state_q, buffer_state_d;
  logic curr_eblock_updated_q, curr_eblock_updated_d;
  logic from_queue_q, from_queue_d;

  always_comb begin
      buffer_state_d        = buffer_state_q;
      curr_eblock_updated_d = curr_eblock_updated_q;
      from_queue_d          = from_queue_q;
      stack_update_buffer_d = stack_update_buffer_q;
      branch_predict_info_o = '0;
      branch_predict_info_we_o = 1'b0;
      bh_fifo_push          = 1'b0;
      bh_fifo_data_in       = '0;
      bh_buffer_consumed_o  = 1'b0;

      case (buffer_state_q)
          BUF_IDLE: begin
            // Non-divergent / uniform branch -> update current FDR eblock
            if (~curr_eblock_updated_d && ~prefetched_eblock_q && branch_meta_valid_i
                && (~branch_meta_i.branch_ena || (branch_meta_i.branch_ena && branch_meta_i.branch_uni))) begin
              buffer_state_d = UPDATE_STACK;
              stack_update_buffer_d.hw_cta_id              = hw_cta_id_i;
              stack_update_buffer_d.hw_cta_size             = cta_size_i;
              stack_update_buffer_d.update_with_divergence  = 1'b0;
              stack_update_buffer_d.update_next_pc          = branch_meta_i.branch_ena
                  ? pc_i + (branch_meta_i.branch_jump_target_offset * DICE_METADATA_WIDTH)
                  : pc_i + DICE_METADATA_WIDTH;
              stack_update_buffer_d.predicate_regs_value    = '1;
              stack_update_buffer_d.branch_not_taken_pc     = '1;
              stack_update_buffer_d.branch_reconvergence_pc = '1;
              curr_eblock_updated_d = 1'b1;
              from_queue_d = 1'b0;

            // Drain queued divergent branches
            end else if (bh_buffer_valid_i && ~bh_fifo_empty) begin
              buffer_state_d = UPDATE_STACK;
              stack_update_buffer_d.hw_cta_id              = bh_fifo_data_out.hw_cta_id;
              stack_update_buffer_d.hw_cta_size             = bh_fifo_data_out.cta_size;
              stack_update_buffer_d.update_with_divergence  = 1'b1;
              stack_update_buffer_d.update_next_pc          = bh_fifo_data_out.next_pc;
              stack_update_buffer_d.predicate_regs_value    = bh_buffer_pred_i;
              stack_update_buffer_d.branch_not_taken_pc     = bh_fifo_data_out.branch_not_taken_pc;
              stack_update_buffer_d.branch_reconvergence_pc = bh_fifo_data_out.branch_reconvergence_pc;
              from_queue_d = 1'b1;
              bh_buffer_consumed_o = 1'b1;
            end

            // FIFO push: non-prefetch divergent branch (immediate, at most once per eblock)
            if (~prefetched_eblock_q && is_divergent_branch && ~bh_fifo_full) begin
                bh_fifo_push                            = 1'b1;
                bh_fifo_data_in.hw_cta_id               = hw_cta_id_i;
                bh_fifo_data_in.cta_size                = cta_size_i;
                bh_fifo_data_in.next_pc                 = taken_pc_calc;
                bh_fifo_data_in.branch_not_taken_pc     = not_taken_pc_calc;
                bh_fifo_data_in.branch_reconvergence_pc = reconv_pc_calc;
                bh_fifo_data_in.branch_neg_pred         = branch_meta_i.branch_neg_pred;
                bh_fifo_data_in.is_return               = branch_meta_i.is_return;
                bh_fifo_data_in.valid                   = 1'b1;

                // Status table: mark divergence + BTFN predict_pc
                branch_predict_info_o.hw_cta_id                    = hw_cta_id_i;
                branch_predict_info_o.unresolved_control_divergence = 1'b1;
                branch_predict_info_o.predict_pc                   = predict_taken ? taken_pc_calc : not_taken_pc_calc;
                branch_predict_info_o.is_return                    = branch_meta_i.is_return;
                branch_predict_info_we_o                           = 1'b1;
            end

            // TODO: ENSURE THAT THIS HAPPENS EVEN IF WE AREN'T IN IDLE
            if (fire_eblock_i && branch_pending_valid_q && ~bh_fifo_full) begin
                bh_fifo_push    = 1'b1;
                bh_fifo_data_in = branch_pending_q;

                branch_predict_info_o.hw_cta_id                    = branch_pending_q.hw_cta_id;
                branch_predict_info_o.unresolved_control_divergence = 1'b1;
                branch_predict_info_o.predict_pc                   = pending_predict_pc_q;
                branch_predict_info_o.is_return                    = branch_pending_q.is_return;
                branch_predict_info_we_o                           = 1'b1;
            end
          end

          UPDATE_STACK: begin
              if (update_ready_i && update_valid_o) begin
                  buffer_state_d = UPDATE_STATUS;
              end
              if (from_queue_q) begin
                branch_predict_info_o.hw_cta_id = stack_update_buffer_q.hw_cta_id;
                branch_predict_info_o.unresolved_control_divergence = 1'b0;
                branch_predict_info_o.is_return = 1'b0;
                branch_predict_info_o.predict_pc = '1;
              end else begin
                branch_predict_info_o.hw_cta_id = hw_cta_id_i;
                branch_predict_info_o.unresolved_control_divergence = 1'b0;
                branch_predict_info_o.is_return = branch_meta_i.is_return;
                branch_predict_info_o.predict_pc = '1;
              end           
          end

          UPDATE_STATUS: begin
            buffer_state_d = BUF_IDLE;
            branch_predict_info_we_o = 1'b1;
          end

          default: begin
              buffer_state_d = BUF_IDLE;
          end
      endcase

      // Mask path: consume bh_buffer if not already consumed by queue drain
      if (~bh_buffer_consumed_o
          && curr_eblock_mask_state_q == MASK_IDLE && branch_meta_valid_i
          && prefetched_eblock_q && empty_buffer_fired && bh_buffer_valid_i)
          bh_buffer_consumed_o = 1'b1;
  end

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

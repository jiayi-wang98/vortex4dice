module branch_resolver
  import dice_pkg::*;
  import dice_frontend_pkg::*;
(
    input  logic                                          clk_i,
    input  logic                                          rst_i,
    input  logic                                          flush_i,

    // From Decoder
    input  branch_meta_t                                  branch_metadata_i,
    input  logic                                          branch_req_valid_i,
    input  logic [DICE_ADDR_WIDTH-1:0]                    current_pc_i,

    // From CS Stage
    input  logic [DICE_HW_CTA_ID_WIDTH-1:0]               hw_cta_id_i,
    input  thread_mask_t                                  init_thread_mask_i,

    // CTA Status (read-only for current CTA)
    input  dice_cta_status_t                              cta_status_i,

    // Predicate RF Interface
    output logic                                          prf_req_o,
    output logic [DICE_HW_CTA_ID_WIDTH+$clog2(DICE_PR_NUM)-1:0] prf_raddr_o,
    input  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0]      prf_rdata_i,

    // SIMT Stack Controller Interface
    output logic                                          update_valid_o,
    output logic                                          update_with_divergence_o,
    output logic [DICE_ADDR_WIDTH-1:0]                    update_next_pc_o,
    output logic [DICE_ADDR_WIDTH-1:0]                    branch_not_taken_pc_o,
    output logic [DICE_ADDR_WIDTH-1:0]                    branch_reconvergence_pc_o,
    output logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0]      predicate_regs_value_o,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0]               update_hw_cta_id_o,
    input  logic                                          update_ready_i,

    // To Decoder (mask output)
    output thread_mask_t                                  real_active_thread_mask_o,
    output logic                                          mask_valid_o,

    // To CTA Status Table (branch prediction)
    output branch_predict_interface_t                     predict_interface_o,
    output logic                                          predict_we_o,

    // Pending Branch Table (exposed for divergence_monitor read)
    output pending_branch_info_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] pending_branch_table_o
);

  // FSM States
  typedef enum logic [2:0] {
    StateIdle,
    StateCheckDeps,
    StateWaitStack,
    StateDone
  } state_e;

  state_e current_state_q, next_state;

  // Internal Signals
  logic  is_branch_op;
  logic  is_uniform;
  logic  is_conditional;
  logic  is_return;
  logic  dependency_resolved;

  // Return instruction detection (from metadata)
  assign is_return = branch_metadata_i.is_return;

  // Computed PC values
  logic                 [DICE_ADDR_WIDTH-1:0]        fallthrough_pc;
  logic                 [DICE_ADDR_WIDTH-1:0]        jump_target_pc;
  logic                 [DICE_ADDR_WIDTH-1:0]        reconv_target_pc;

  // Registered values for multi-cycle operation
  logic         [DICE_HW_CTA_ID_WIDTH-1:0]   hw_cta_id_q;
  branch_meta_t                              branch_metadata_q;
  logic         [DICE_ADDR_WIDTH-1:0]        current_pc_q;
  logic                                      is_return_q;
  thread_mask_t                              init_thread_mask_q;
  logic                                      is_uniform_q;
  logic                                      is_conditional_q;
  logic                                      dependency_resolved_q;
  logic         [DICE_ADDR_WIDTH-1:0]        fallthrough_pc_q;
  logic         [DICE_ADDR_WIDTH-1:0]        jump_target_pc_q;
  logic         [DICE_ADDR_WIDTH-1:0]        reconv_target_pc_q;

  // Pending branch table storage
  pending_branch_info_t                              pending_branch_table_q[DICE_NUM_MAX_CTA_PER_CORE];

  // Branch Type Detection
  assign is_branch_op = branch_req_valid_i && branch_metadata_i.branch_ena;
  assign is_uniform = is_branch_op && branch_metadata_i.branch_uni;
  assign is_conditional = is_branch_op && !branch_metadata_i.branch_uni;

  // Dependency check - can resolve if no pending eblocks for this CTA
  assign dependency_resolved = !cta_status_i.has_pending_eblock;

  // PC Calculations
  assign fallthrough_pc   = current_pc_i + DICE_METADATA_WIDTH;
  assign jump_target_pc   = current_pc_i + (DICE_ADDR_WIDTH'(branch_metadata_i.branch_jump_target_offset) * DICE_METADATA_WIDTH);
  assign reconv_target_pc = current_pc_i + (DICE_ADDR_WIDTH'(branch_metadata_i.branch_reconv_offset) * DICE_METADATA_WIDTH);

  // FSM Next State Logic
  always_comb begin
    next_state = current_state_q;

    if (flush_i) begin
      next_state = StateIdle;
    end else begin
      case (current_state_q)
        StateIdle: begin
          if (branch_req_valid_i) begin
            next_state = StateCheckDeps;
          end
        end

        StateCheckDeps: begin
          if (is_return_q) begin
            // Return instruction - no stack update needed, just pass mask
            next_state = StateDone;
          end else if (is_uniform_q || (is_conditional_q && dependency_resolved_q)) begin
            // Can resolve immediately - wait for stack
            next_state = StateWaitStack;
          end else if (is_conditional_q && !dependency_resolved_q) begin
            // Must defer - store and predict
            next_state = StateDone;
          end else begin
            // No branch - just pass through
            next_state = StateDone;
          end
        end

        StateWaitStack: begin
          if (update_ready_i) begin
            next_state = StateDone;
          end
        end

        StateDone: begin
          next_state = StateIdle;
        end

        default: begin
          next_state = StateIdle;
        end
      endcase
    end
  end

  // FSM Sequential Logic
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      current_state_q       <= StateIdle;
      hw_cta_id_q           <= '0;
      branch_metadata_q     <= '0;
      current_pc_q          <= '0;
      is_return_q           <= 1'b0;
      init_thread_mask_q    <= '0;
      is_uniform_q          <= 1'b0;
      is_conditional_q      <= 1'b0;
      dependency_resolved_q <= 1'b0;
      fallthrough_pc_q      <= '0;
      jump_target_pc_q      <= '0;
      reconv_target_pc_q    <= '0;

      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        pending_branch_table_q[i] <= '0;
      end
    end else begin
      current_state_q <= next_state;

      // Capture inputs when new request arrives
      if (current_state_q == StateIdle && branch_req_valid_i) begin
        hw_cta_id_q           <= hw_cta_id_i;
        branch_metadata_q     <= branch_metadata_i;
        current_pc_q          <= current_pc_i;
        is_return_q           <= is_return;
        init_thread_mask_q    <= init_thread_mask_i;
        is_uniform_q          <= is_uniform;
        is_conditional_q      <= is_conditional;
        dependency_resolved_q <= dependency_resolved;
        fallthrough_pc_q      <= fallthrough_pc;
        jump_target_pc_q      <= jump_target_pc;
        reconv_target_pc_q    <= reconv_target_pc;
      end

      // Store to pending branch table when deferring
      if (current_state_q == StateCheckDeps && is_conditional_q && !dependency_resolved_q) begin
        pending_branch_table_q[hw_cta_id_q].pred_reg     <= branch_metadata_q.branch_pred_reg;
        pending_branch_table_q[hw_cta_id_q].neg_pred     <= branch_metadata_q.branch_neg_pred;
        pending_branch_table_q[hw_cta_id_q].taken_pc     <= jump_target_pc_q;
        pending_branch_table_q[hw_cta_id_q].not_taken_pc <= fallthrough_pc_q;
        pending_branch_table_q[hw_cta_id_q].reconv_pc    <= reconv_target_pc_q;
      end
    end
  end

  // Predicate RF Interface
  always_comb begin
    prf_req_o   = 1'b0;
    prf_raddr_o = '0;

    if (current_state_q == StateCheckDeps || current_state_q == StateWaitStack) begin
      if (is_conditional_q && dependency_resolved_q) begin
        prf_req_o   = 1'b1;
        prf_raddr_o = {hw_cta_id_q, branch_metadata_q.branch_pred_reg};
      end
    end
  end

  // SIMT Stack Controller Interface
  always_comb begin
    update_valid_o            = 1'b0;
    update_with_divergence_o  = 1'b0;
    update_next_pc_o          = '0;
    branch_not_taken_pc_o     = '0;
    branch_reconvergence_pc_o = '0;
    predicate_regs_value_o    = '0;
    update_hw_cta_id_o        = '0;

    // Don't send stack updates during flush
    if (current_state_q == StateWaitStack && !flush_i) begin
      update_valid_o     = 1'b1;
      update_hw_cta_id_o = hw_cta_id_q;

      if (is_uniform_q) begin
        // Uniform branch - no divergence, just update PC
        update_with_divergence_o = 1'b0;
        update_next_pc_o         = jump_target_pc_q;
      end else if (is_conditional_q) begin
        // Conditional branch - send predicate values for divergence analysis
        update_with_divergence_o  = 1'b1;
        update_next_pc_o          = jump_target_pc_q;
        branch_not_taken_pc_o     = fallthrough_pc_q;
        branch_reconvergence_pc_o = reconv_target_pc_q;
        // Apply predicate polarity
        predicate_regs_value_o    = branch_metadata_q.branch_neg_pred ? ~prf_rdata_i : prf_rdata_i;
      end
    end
  end

  // Output to Decoder (active thread mask)
  always_comb begin
    real_active_thread_mask_o = init_thread_mask_q;
    mask_valid_o              = 1'b0;

    // Don't assert mask valid during flush
    if (current_state_q == StateDone && !flush_i) begin
      mask_valid_o = 1'b1;
      // For non-divergence cases, use the init mask
      // For deferred branches, also use init mask (prediction)
      real_active_thread_mask_o = init_thread_mask_q;
    end
  end

  // CTA Status Table Interface (branch prediction)
  always_comb begin
    predict_interface_o = '0;
    predict_we_o        = 1'b0;

    // Don't write prediction during flush
    if (current_state_q == StateCheckDeps && !flush_i) begin
      predict_interface_o.hw_cta_id  = hw_cta_id_q;
      predict_interface_o.is_return  = is_return_q;
      predict_interface_o.is_barrier = 1'b0;

      if (is_conditional_q && !dependency_resolved_q) begin
        // Deferring branch - set prediction
        predict_we_o = 1'b1;
        predict_interface_o.unresolved_control_divergence = 1'b1;
        predict_interface_o.predict_pc = fallthrough_pc_q;
      end else if (is_return_q) begin
        // Return instruction
        predict_we_o = 1'b1;
      end
    end
  end

  // Pending Branch Table Output
  always_comb begin
    for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
      pending_branch_table_o[i] = pending_branch_table_q[i];
    end
  end

endmodule

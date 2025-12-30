//NOTES AND POTENTIAL ISSUES:
//circular pointer could result in stalls if it wraps around to an eblock
//that is waiting for a long latency load/store

//the priority schedule was changed so it starts from id+1, ensure that is correct


import dice_pkg::*;
import dice_frontend_pkg::*;


module cta_scheduler #(
    parameter MAX_EBLOCK = DICE_NUM_MAX_CTA_PER_CORE + 4  //localparam?
) (
    input logic clk,
    input logic rst,
    input logic enable, // Enable signal for scheduler operation

    // Active CTA Table
    input active_cta_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries,

    //CTA STATUS TABLE
    input cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_entries,

    //SIMT STACK
    //do i need this: stack_top_valid
    input logic [DICE_NUM_MAX_CTA_PER_CORE-1:0][DICE_ADDR_WIDTH-1:0] cta_next_pc,
    input logic [DICE_NUM_MAX_CTA_PER_CORE-1:0][   THREAD_WIDTH-1:0] stack_top_active_mask,


    // External interface to invalidate committed e-blocks
    input logic                            eblock_commit_valid,
    input logic [DICE_EBLOCK_ID_WIDTH-1:0] eblock_commit_id,

    // Scheduler outputs
    cta_sched_if.master scheduled_eblock
);

  // E-block tracking table
  logic [               MAX_EBLOCK-1:0] eblock_live;
  logic [     DICE_EBLOCK_ID_WIDTH-1:0] eblock_ptr;  // Circular pointer for e-block allocation

  // PC history for locality scheduling
  logic [          DICE_ADDR_WIDTH-1:0] previous_pc;
  logic                                 pc_history_valid;

  // Round-robin tracking
  logic [        DICE_CTA_ID_WIDTH-1:0] last_dispatched_cta;

  // Internal scheduling signals
  logic [DICE_NUM_MAX_CTA_PER_CORE-1:0] priority_match;
  logic [DICE_NUM_MAX_CTA_PER_CORE-1:0] non_branch_candidates;
  logic [DICE_NUM_MAX_CTA_PER_CORE-1:0] any_valid_candidates;

  logic                                 priority_found;
  logic                                 non_branch_found;
  logic                                 any_valid_found;

  logic [        DICE_CTA_ID_WIDTH-1:0] selected_cta_id;
  logic                                 selection_valid;
  logic                                 selected_from_branch_resolving;

  //unpack struct
  logic [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_valid, cta_branch_resolving;
  always_comb begin
    for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
      cta_valid[i] = active_cta_entries[i].cta_valid;
      cta_branch_resolving[i] = cta_status_entries[i].is_prefetch;
    end
  end


  // Priority 1: PC locality matching (next_pc matches previous_pc)
  always_comb begin
    priority_match = '0;
    priority_found = 1'b0;

    if (pc_history_valid) begin
      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        if (cta_valid[i] && (cta_next_pc[i] == previous_pc)) begin
          priority_match[i] = 1'b1;
          priority_found = 1'b1;
        end
      end
    end
  end


  // Priority 2: Non-branch resolving CTAs (round-robin among valid && !branch_resolving)
  always_comb begin
    non_branch_candidates = cta_valid & ~cta_branch_resolving;
    non_branch_found = |non_branch_candidates;
  end

  // Priority 3: Any valid CTAs (round-robin among all valid)
  always_comb begin
    any_valid_candidates = cta_valid;
    any_valid_found = |any_valid_candidates;
  end

  // Selection logic with priority encoding
  always_comb begin
    selected_cta_id = '0;
    selection_valid = 1'b0;
    selected_from_branch_resolving = 1'b0;

    if (priority_found) begin
      // Priority 1: Select first matching PC locality
      selection_valid = 1'b1;
      // for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
      //     if (priority_match[i]) begin
      //         selected_cta_id = i[DICE_CTA_ID_WIDTH-1:0];
      //         selected_from_branch_resolving = cta_branch_resolving[i];
      //         break;
      //     end
      // end

      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        automatic logic [DICE_CTA_ID_WIDTH-1:0] check_idx;
        check_idx = (last_dispatched_cta + 1 + i) & (DICE_NUM_MAX_CTA_PER_CORE - 1);

        if (priority_match[check_idx]) begin
          selected_cta_id = check_idx;
          selection_valid = 1'b1;
          selected_from_branch_resolving = cta_branch_resolving[check_idx];
          break;
        end
      end

    end else if (non_branch_found) begin
      // Priority 2: Round-robin among non-branch resolving CTAs
      selection_valid = 1'b1;
      selected_from_branch_resolving = 1'b0;  // By definition, not branch resolving

      // Start from next CTA after last dispatched
      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        automatic logic [DICE_CTA_ID_WIDTH-1:0] check_idx;
        check_idx = (last_dispatched_cta + 1 + i) & (DICE_NUM_MAX_CTA_PER_CORE - 1);
        if (non_branch_candidates[check_idx]) begin
          selected_cta_id = check_idx;
          break;
        end
      end

    end else if (any_valid_found) begin
      // Priority 3: Round-robin among any valid CTAs (including branch resolving)
      selection_valid = 1'b1;

      // Start from next CTA after last dispatched
      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        automatic logic [DICE_CTA_ID_WIDTH-1:0] check_idx;
        check_idx = (last_dispatched_cta + 1 + i) & (DICE_NUM_MAX_CTA_PER_CORE - 1);
        if (any_valid_candidates[check_idx]) begin
          selected_cta_id = check_idx;
          selected_from_branch_resolving = cta_branch_resolving[check_idx];
          break;
        end
      end
    end
  end

  // Output assignments
  always_comb begin
    scheduled_eblock.valid = enable && selection_valid && !eblock_live[eblock_ptr];
    scheduled_eblock.data.schedule_hw_cta_id = selected_cta_id;
    scheduled_eblock.data.schedule_next_pc        = selected_from_branch_resolving ? cta_status_entries[selected_cta_id].predict_pc : cta_next_pc[selected_cta_id];
    scheduled_eblock.data.schedule_eblock_id = eblock_ptr;
    scheduled_eblock.data.schedule_active_mask = stack_top_active_mask[selected_cta_id];
    scheduled_eblock.data.schedule_prefetch_block = selected_from_branch_resolving;
    scheduled_eblock.data.schedule_cta_id = active_cta_entries[selected_cta_id].cta_id;
    scheduled_eblock.data.schedule_grid_size = active_cta_entries[selected_cta_id].grid_size;
    scheduled_eblock.data.schedule_cta_size = active_cta_entries[selected_cta_id].cta_size;
    scheduled_eblock.data.schedule_kernel_id = active_cta_entries[selected_cta_id].kernel_id;
    scheduled_eblock.data.schedule_smem_per_cta = active_cta_entries[selected_cta_id].smem_per_cta;
    scheduled_eblock.data.schedule_hw_cta_size = active_cta_entries[selected_cta_id].hw_cta_size;
  end


  // Sequential logic for state updates
  always_ff @(posedge clk) begin
    if (rst) begin
      // Reset all state
      eblock_live <= '0;
      eblock_ptr <= '0;
      previous_pc <= '0;
      pc_history_valid <= 1'b0;
      last_dispatched_cta <= '1;
    end else begin
      // Handle e-block commit (invalidation)
      if (eblock_commit_valid) begin
        eblock_live[eblock_commit_id] <= 1'b0;
      end

      // Handle successful scheduling
      if (enable && scheduled_eblock.valid && scheduled_eblock.ready) begin
        // Allocate current e-block and advance pointer
        eblock_live[eblock_ptr] <= 1'b1;
        if (eblock_ptr == MAX_EBLOCK - 1) begin
          eblock_ptr <= '0;
        end else begin
          eblock_ptr <= eblock_ptr + 1;
        end

        // Update PC history for locality tracking
        previous_pc <= selected_from_branch_resolving
                            ? cta_status_entries[selected_cta_id].predict_pc
                            : cta_next_pc[selected_cta_id];

        pc_history_valid <= 1'b1;

        // Update last dispatched CTA for round-robin
        last_dispatched_cta <= selected_cta_id;
      end
    end
  end

  // Debug and assertions
  // `ifndef SYNTHESIS
  // always @(posedge clk) begin
  //     if (rst_n) begin
  //         // Check for e-block exhaustion
  //         if (schedule_valid && schedule_ready && eblock_live[eblock_ptr]) begin
  //             $warning("CTA Scheduler: E-block %d already live, allocation conflict", eblock_ptr);
  //         end

  //         // Verify selection logic
  //         if (schedule_valid && !cta_valid[selected_cta_id]) begin
  //             $error("CTA Scheduler: Selected invalid CTA %d", selected_cta_id);
  //         end

  //         // Check commit bounds
  //         if (eblock_commit_valid && eblock_commit_id >= MAX_EBLOCK) begin
  //             $error("CTA Scheduler: Invalid e-block commit ID %d", eblock_commit_id);
  //         end
  //     end
  // end

  // // Performance monitoring
  // logic [31:0] priority_schedule_count;
  // logic [31:0] non_branch_schedule_count;
  // logic [31:0] any_valid_schedule_count;

  // always_ff @(posedge clk or negedge rst_n) begin
  //     if (!rst_n) begin
  //         priority_schedule_count <= '0;
  //         non_branch_schedule_count <= '0;
  //         any_valid_schedule_count <= '0;
  //     end else if (enable && schedule_valid && schedule_ready) begin
  //         if (priority_found) begin
  //             priority_schedule_count <= priority_schedule_count + 1;
  //         end else if (non_branch_found) begin
  //             non_branch_schedule_count <= non_branch_schedule_count + 1;
  //         end else if (any_valid_found) begin
  //             any_valid_schedule_count <= any_valid_schedule_count + 1;
  //         end
  //     end
  // end
  // `endif

endmodule

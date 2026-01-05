// =============================================================================
// DRAFT Branch Handler Module (v2 - with bug fixes)
// =============================================================================
// This is a DRAFT implementation - do not replace the existing branch_handler.sv
// 
// Purpose: Handle branch resolution, drive SIMT stack controller, and provide
// active thread mask to FDR stage.
//
// Metadata Fields (from compiler output):
//   BRANCH = 1/0          - Is this a branch instruction
//   BRANCH_UNI = 0/1      - Is branch uniform (all threads same direction)
//   BRANCH_PRED = (%pN)   - Predicate register (5-bit index)
//   BRANCH_TARGET = N     - Branch target PC offset
//   BRANCH_RECVPC = N     - Reconvergence PC offset
//   RET                   - Return instruction
//
// branch_metadata[31:0] encoding (PROPOSED):
//   [0]      - is_branch: 1 if branch instruction
//   [1]      - is_uniform: 1 if uniform branch (BRANCH_UNI)
//   [2]      - is_return: 1 if return instruction (RET)
//   [7:3]    - predicate_reg_idx: 5-bit predicate register index
//   [15:8]   - branch_target_offset: 8-bit target PC offset (relative)
//   [23:16]  - reconvergence_offset: 8-bit reconvergence PC offset (relative)
//   [31:24]  - reserved
//
// CHANGELOG v2:
//   - Fixed WAIT_STACK_COMPLETE condition to wait for update_ready to reassert
//   - Fixed hw_cta_size -> num_stacks conversion (was using bit shift, now case)
//   - Added predicate_values_reg to capture predicates on request
//   - Non-branch now also updates stack with sequential PC
//   - Added downstream ready handshake for MASK_READY state
//   - Fixed return instruction mask handling
// =============================================================================

import dice_pkg::*;
import frontend_pkg::*;

module draft_branch_handler #(
    parameter PC_WIDTH    = 32,
    parameter NUM_STACK   = 4,
    parameter THREAD_WIDTH = 256,
    parameter MAX_NUM_CTA = 4
) (
    input logic clk,
    input logic rst_n,

    // =========================================================================
    // From Decoder
    // =========================================================================
    input logic [31:0] branch_metadata,
    input logic        branch_req_valid,

    // =========================================================================
    // From Scheduler (CS stage)
    // =========================================================================
    input logic [$clog2(MAX_NUM_CTA)-1:0] schedule_hw_cta_id,
    input logic [           PC_WIDTH-1:0] schedule_next_pc,        // PC that was scheduled
    input logic                           schedule_cta_predicted,  // Was prefetched
    input logic [                    1:0] hw_cta_size,             // CTA size encoding

    // =========================================================================
    // Metadata length for sequential PC advancement
    // =========================================================================
    input logic [7:0] metadata_length,  // Length of current pgraph

    // =========================================================================
    // From Execution Backend / Register File (ACTIVE PREDICATE VALUES)
    // =========================================================================
    input logic [NUM_STACK*THREAD_WIDTH-1:0] predicate_values,

    // =========================================================================
    // SIMT Stack Controller Interface
    // =========================================================================
    // Request to stack controller
    output logic                              stack_update_valid,
    output logic                              stack_update_with_divergence,
    output logic [              PC_WIDTH-1:0] stack_update_next_pc,
    output logic [              PC_WIDTH-1:0] stack_branch_not_taken_pc,
    output logic [              PC_WIDTH-1:0] stack_branch_reconvergence_pc,
    output logic [NUM_STACK*THREAD_WIDTH-1:0] stack_predicate_values,
    output logic [     $clog2(NUM_STACK)-1:0] stack_hw_cta_id,
    output logic [                       1:0] stack_hw_cta_size,

    // Response from stack controller
    input logic                                   stack_update_ready,
    input logic [NUM_STACK-1:0]                   stack_top_valid,
    input logic [NUM_STACK-1:0][    PC_WIDTH-1:0] stack_top_next_pc,
    input logic [NUM_STACK-1:0][THREAD_WIDTH-1:0] stack_top_active_mask,
    input logic [NUM_STACK-1:0]                   stack_empty,

    // =========================================================================
    // CTA Status / Scheduler Feedback
    // =========================================================================
    output logic [MAX_NUM_CTA-1:0] cta_branch_resolving,

    // =========================================================================
    // Outputs to Decoder / FDR
    // =========================================================================
    output thread_mask_t real_active_thread_mask,
    output logic         mask_valid,

    // =========================================================================
    // Downstream Handshake
    // =========================================================================
    input logic downstream_ready,  // Downstream can accept output

    // =========================================================================
    // Return Detection (to CTA lifecycle management)
    // =========================================================================
    output logic is_return_instruction
);

  // =========================================================================
  // Branch Metadata Decoding
  // =========================================================================
  logic       meta_is_branch;
  logic       meta_is_uniform;
  logic       meta_is_return;
  logic [4:0] meta_pred_reg_idx;
  logic [7:0] meta_target_offset;
  logic [7:0] meta_reconvergence_offset;

  assign meta_is_branch            = branch_metadata[0];
  assign meta_is_uniform           = branch_metadata[1];
  assign meta_is_return            = branch_metadata[2];
  assign meta_pred_reg_idx         = branch_metadata[7:3];
  assign meta_target_offset        = branch_metadata[15:8];
  assign meta_reconvergence_offset = branch_metadata[23:16];

  // =========================================================================
  // FSM States
  // =========================================================================
  typedef enum logic [2:0] {
    IDLE,                 // Waiting for branch request
    WAIT_STACK_ACCEPT,    // Waiting for stack controller to accept update (valid/ready handshake)
    WAIT_STACK_COMPLETE,  // Waiting for stack controller FSM to return to IDLE
    MASK_READY            // Mask is ready to output, waiting for downstream
  } state_t;

  state_t current_state, next_state;

  // =========================================================================
  // Registered Variables
  // =========================================================================
  logic [   $clog2(MAX_NUM_CTA)-1:0] hw_cta_id_reg;
  logic [                       1:0] hw_cta_size_reg;
  logic [              PC_WIDTH-1:0] current_pc_reg;
  logic                              is_branch_reg;
  logic                              is_uniform_reg;
  logic                              is_return_reg;
  logic [              PC_WIDTH-1:0] branch_target_reg;
  logic [              PC_WIDTH-1:0] branch_not_taken_reg;
  logic [              PC_WIDTH-1:0] branch_reconvergence_reg;
  logic [NUM_STACK*THREAD_WIDTH-1:0] predicate_values_reg;  // FIX: Register predicates
  logic [                       7:0] metadata_length_reg;  // For sequential PC calc

  // Per-CTA resolving state
  logic [           MAX_NUM_CTA-1:0] cta_resolving_reg;

  // Track if we need stack update (for return, we don't)
  logic                              needs_stack_update_reg;

  // =========================================================================
  // Computed Values for Offset -> Absolute PC
  // =========================================================================
  logic [              PC_WIDTH-1:0] branch_target_pc;
  logic [              PC_WIDTH-1:0] branch_not_taken_pc;
  logic [              PC_WIDTH-1:0] branch_reconvergence_pc;
  logic [              PC_WIDTH-1:0] sequential_next_pc;

  // Target = current_pc + offset
  assign branch_target_pc        = schedule_next_pc + {24'b0, meta_target_offset};
  // Not-taken = current_pc + metadata_length (sequential to next pgraph)
  assign branch_not_taken_pc     = schedule_next_pc + {24'b0, metadata_length};
  // Reconvergence = current_pc + reconvergence_offset
  assign branch_reconvergence_pc = schedule_next_pc + {24'b0, meta_reconvergence_offset};
  // Sequential = current_pc + metadata_length
  assign sequential_next_pc      = schedule_next_pc + {24'b0, metadata_length};

  // =========================================================================
  // Convert hw_cta_size to number of stacks (FIX: was using bit shift)
  // =========================================================================
  // hw_cta_size: 00=1 stack, 01=2 stacks, 11=4 stacks
  logic [2:0] num_active_stacks;
  logic [2:0] num_active_stacks_comb;  // For input path

  always_comb begin
    case (hw_cta_size)
      2'b00:   num_active_stacks_comb = 3'd1;
      2'b01:   num_active_stacks_comb = 3'd2;
      2'b11:   num_active_stacks_comb = 3'd4;
      default: num_active_stacks_comb = 3'd1;
    endcase
  end

  always_comb begin
    case (hw_cta_size_reg)
      2'b00:   num_active_stacks = 3'd1;
      2'b01:   num_active_stacks = 3'd2;
      2'b11:   num_active_stacks = 3'd4;
      default: num_active_stacks = 3'd1;
    endcase
  end

  // =========================================================================
  // Active Mask Extraction from Stack
  // =========================================================================
  logic [NUM_STACK*THREAD_WIDTH-1:0] combined_active_mask;
  logic                              all_stacks_valid;

  always_comb begin
    combined_active_mask = '0;
    all_stacks_valid = 1'b1;

    for (int i = 0; i < NUM_STACK; i++) begin
      // Check if this stack belongs to current CTA
      if (i >= hw_cta_id_reg && i < (hw_cta_id_reg + num_active_stacks)) begin
        if (stack_top_valid[i]) begin
          combined_active_mask[(i - hw_cta_id_reg) * THREAD_WIDTH +: THREAD_WIDTH] = 
                        stack_top_active_mask[i];
        end else begin
          all_stacks_valid = 1'b0;
        end
      end
    end
  end

  // =========================================================================
  // FSM Next State Logic
  // =========================================================================
  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (branch_req_valid) begin
          if (meta_is_return) begin
            // Return instruction - get current mask from stack, no update needed
            // But we still need to wait for stack_top_valid
            next_state = MASK_READY;  // Stack should already be valid from previous
          end else begin
            // All other cases (branch or non-branch) need stack update
            next_state = WAIT_STACK_ACCEPT;
          end
        end
      end

      WAIT_STACK_ACCEPT: begin
        // Wait for stack controller to accept our update request
        // stack_update_ready is high when controller is IDLE
        if (stack_update_ready) begin
          // Request accepted, now wait for FSM to complete
          next_state = WAIT_STACK_COMPLETE;
        end
      end

      WAIT_STACK_COMPLETE: begin
        // Stack controller FSM is processing. Wait for it to return to IDLE.
        // When it does, update_ready goes high AND stack outputs become valid.
        // 
        // FIX: The stack_update_ready signal goes from:
        //   - HIGH (IDLE, we can send request)
        //   - LOW (processing, after we send valid)
        //   - HIGH (IDLE again, processing complete)
        // So we need to detect the rising edge back to ready.
        // However, since we enter this state AFTER stack_update_ready was seen,
        // we know update_ready is now LOW. We wait for it to go HIGH again.
        if (stack_update_ready && all_stacks_valid) begin
          next_state = MASK_READY;
        end
      end

      MASK_READY: begin
        // Wait for downstream to consume our output
        if (downstream_ready) begin
          next_state = IDLE;
        end
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

  // =========================================================================
  // FSM Sequential Logic
  // =========================================================================
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state            <= IDLE;
      hw_cta_id_reg            <= '0;
      hw_cta_size_reg          <= '0;
      current_pc_reg           <= '0;
      is_branch_reg            <= 1'b0;
      is_uniform_reg           <= 1'b0;
      is_return_reg            <= 1'b0;
      branch_target_reg        <= '0;
      branch_not_taken_reg     <= '0;
      branch_reconvergence_reg <= '0;
      predicate_values_reg     <= '0;
      metadata_length_reg      <= '0;
      cta_resolving_reg        <= '0;
      needs_stack_update_reg   <= 1'b0;
    end else begin
      current_state <= next_state;

      // Capture inputs when new request arrives
      if (current_state == IDLE && branch_req_valid) begin
        hw_cta_id_reg            <= schedule_hw_cta_id;
        hw_cta_size_reg          <= hw_cta_size;
        current_pc_reg           <= schedule_next_pc;
        is_branch_reg            <= meta_is_branch;
        is_uniform_reg           <= meta_is_uniform;
        is_return_reg            <= meta_is_return;
        branch_target_reg        <= branch_target_pc;
        branch_not_taken_reg     <= branch_not_taken_pc;
        branch_reconvergence_reg <= branch_reconvergence_pc;
        predicate_values_reg     <= predicate_values;  // FIX: Capture predicates
        metadata_length_reg      <= metadata_length;
        needs_stack_update_reg   <= !meta_is_return;  // All except return need stack update

        // Set resolving flag for potentially divergent branches
        // (uniform branches might still diverge if predicate check fails)
        if (meta_is_branch && !meta_is_uniform) begin
          cta_resolving_reg[schedule_hw_cta_id] <= 1'b1;
        end
      end

      // Clear resolving flag when resolution completes
      if (current_state == WAIT_STACK_COMPLETE && next_state == MASK_READY) begin
        cta_resolving_reg[hw_cta_id_reg] <= 1'b0;
      end
    end
  end

  // =========================================================================
  // Stack Controller Interface
  // =========================================================================
  always_comb begin
    // Default values
    stack_update_valid            = 1'b0;
    stack_update_with_divergence  = 1'b0;
    stack_update_next_pc          = '0;
    stack_branch_not_taken_pc     = '0;
    stack_branch_reconvergence_pc = '0;
    stack_predicate_values        = '0;
    stack_hw_cta_id               = '0;
    stack_hw_cta_size             = '0;

    case (current_state)
      WAIT_STACK_ACCEPT: begin
        // Assert valid until accepted
        stack_update_valid     = 1'b1;
        stack_hw_cta_id        = hw_cta_id_reg;
        stack_hw_cta_size      = hw_cta_size_reg;
        stack_predicate_values = predicate_values_reg;  // FIX: Use registered value

        if (!is_branch_reg) begin
          // Non-branch: sequential PC advancement, no divergence
          stack_update_with_divergence = 1'b0;
          stack_update_next_pc         = current_pc_reg + {24'b0, metadata_length_reg};
        end else if (is_uniform_reg) begin
          // Uniform branch: update PC, no divergence
          // The stack controller will check if all-taken or all-not-taken
          // For truly uniform (BRANCH_UNI=1), we still send as divergence=0
          // and just provide the target. The controller will handle it.
          stack_update_with_divergence = 1'b0;
          stack_update_next_pc         = branch_target_reg;
        end else begin
          // Potentially divergent branch
          stack_update_with_divergence  = 1'b1;
          stack_update_next_pc          = branch_target_reg;  // Taken target
          stack_branch_not_taken_pc     = branch_not_taken_reg;  // Not-taken PC
          stack_branch_reconvergence_pc = branch_reconvergence_reg;  // Reconvergence
        end
      end

      default: begin
        // Keep defaults
      end
    endcase
  end

  // =========================================================================
  // Output Logic
  // =========================================================================

  // Active thread mask from stack
  always_comb begin
    if (current_state == MASK_READY) begin
      // Use mask from stack (truncate to thread_mask_t width)
      real_active_thread_mask = combined_active_mask[DICE_NUM_MAX_THREADS_PER_CORE-1:0];
    end else begin
      // Default - all threads active (conservative fallback)
      real_active_thread_mask = '1;
    end
  end

  // Mask valid - only when we're in MASK_READY state
  assign mask_valid = (current_state == MASK_READY);

  // Return detection
  assign is_return_instruction = is_return_reg && (current_state == MASK_READY);

  // CTA resolving status for scheduler
  assign cta_branch_resolving = cta_resolving_reg;

  // =========================================================================
  // Debug Assertions
  // =========================================================================
`ifndef SYNTHESIS
  // Track previous state for edge detection
  state_t prev_state;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) prev_state <= IDLE;
    else prev_state <= current_state;
  end

  always @(posedge clk) begin
    if (rst_n) begin
      // Debug state transitions
      if (current_state != prev_state) begin
        $display("[Branch Handler] State: %s -> %s (CTA=%0d, branch=%b, uniform=%b, return=%b)",
                 prev_state.name(), current_state.name(), hw_cta_id_reg, is_branch_reg,
                 is_uniform_reg, is_return_reg);
      end

      // Check for stuck in WAIT_STACK_ACCEPT
      if (current_state == WAIT_STACK_ACCEPT && !stack_update_ready) begin
        // Expected - waiting for stack
      end

      // Warn if stack not valid when expected
      if (current_state == MASK_READY && !all_stacks_valid) begin
        $warning("[Branch Handler] MASK_READY but not all stacks valid!");
      end

      // Ensure we don't have conflicting requests
      if (branch_req_valid && current_state != IDLE) begin
        $warning("[Branch Handler] New request while busy (state=%s)", current_state.name());
      end
    end
  end
`endif

endmodule

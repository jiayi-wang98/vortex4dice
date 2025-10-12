module cta_scheduler #(
    parameter MAX_NUM_CTA = 4,
    parameter PC_WIDTH = 32,
    parameter CTA_ID_WIDTH = $clog2(MAX_NUM_CTA),
    parameter EBLOCK_ID_WIDTH = $clog2(MAX_NUM_CTA + 4),
    parameter MAX_EBLOCK = MAX_NUM_CTA + 4
)(
    input logic clk,
    input logic rst_n,
    input logic enable,  // Enable signal for scheduler operation
    
    // CTA inputs from CTA table and SIMT stack
    input logic [MAX_NUM_CTA-1:0] cta_valid,
    input logic [MAX_NUM_CTA-1:0] cta_branch_resolving,
    input logic [MAX_NUM_CTA-1:0][PC_WIDTH-1:0] cta_next_pc,
    
    // External interface to invalidate committed e-blocks
    input logic eblock_commit_valid,
    input logic [EBLOCK_ID_WIDTH-1:0] eblock_commit_id,
    
    // Scheduler outputs
    output logic schedule_valid,
    output logic [CTA_ID_WIDTH-1:0] schedule_hw_cta_id,
    output logic [PC_WIDTH-1:0] schedule_next_pc,
    output logic [EBLOCK_ID_WIDTH-1:0] schedule_eblock_id,
    output logic schedule_cta_predicted,  // 1 if selected CTA is branch resolving
    
    // Ready signal - can accept new schedule request
    input logic schedule_ready
);

    // E-block tracking table
    logic [MAX_EBLOCK-1:0] eblock_live;
    logic [EBLOCK_ID_WIDTH-1:0] eblock_ptr;  // Circular pointer for e-block allocation
    
    // PC history for locality scheduling
    logic [PC_WIDTH-1:0] previous_pc;
    logic pc_history_valid;
    
    // Round-robin tracking
    logic [CTA_ID_WIDTH-1:0] last_dispatched_cta;
    
    // Internal scheduling signals
    logic [MAX_NUM_CTA-1:0] priority_match;
    logic [MAX_NUM_CTA-1:0] non_branch_candidates;
    logic [MAX_NUM_CTA-1:0] any_valid_candidates;
    
    logic priority_found;
    logic non_branch_found;
    logic any_valid_found;
    
    logic [CTA_ID_WIDTH-1:0] selected_cta_id;
    logic selection_valid;
    logic selected_from_branch_resolving;
    
    // Priority 1: PC locality matching (next_pc matches previous_pc)
    always_comb begin
        priority_match = '0;
        priority_found = 1'b0;
        
        if (pc_history_valid) begin
            for (int i = 0; i < MAX_NUM_CTA; i++) begin
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
            for (int i = 0; i < MAX_NUM_CTA; i++) begin
                if (priority_match[i]) begin
                    selected_cta_id = i[CTA_ID_WIDTH-1:0];
                    selected_from_branch_resolving = cta_branch_resolving[i];
                    break;
                end
            end
            
        end else if (non_branch_found) begin
            // Priority 2: Round-robin among non-branch resolving CTAs
            selection_valid = 1'b1;
            selected_from_branch_resolving = 1'b0;  // By definition, not branch resolving
            
            // Start from next CTA after last dispatched
            for (int i = 0; i < MAX_NUM_CTA; i++) begin
                automatic logic [CTA_ID_WIDTH-1:0] check_idx;
                check_idx = (last_dispatched_cta + 1 + i) & (MAX_NUM_CTA-1);
                if (non_branch_candidates[check_idx]) begin
                    selected_cta_id = check_idx;
                    break;
                end
            end
            
        end else if (any_valid_found) begin
            // Priority 3: Round-robin among any valid CTAs (including branch resolving)
            selection_valid = 1'b1;
            
            // Start from next CTA after last dispatched
            for (int i = 0; i < MAX_NUM_CTA; i++) begin
                automatic logic [CTA_ID_WIDTH-1:0] check_idx;
                check_idx = (last_dispatched_cta + 1 + i) & (MAX_NUM_CTA-1);
                if (any_valid_candidates[check_idx]) begin
                    selected_cta_id = check_idx;
                    selected_from_branch_resolving = cta_branch_resolving[check_idx];
                    break;
                end
            end
        end
    end
    
    // Output assignments
    assign schedule_valid = enable && selection_valid && !eblock_live[eblock_ptr];  // Only valid if enabled and e-block available
    assign schedule_hw_cta_id = selected_cta_id;
    assign schedule_next_pc = selection_valid ? cta_next_pc[selected_cta_id] : '0;
    assign schedule_eblock_id = eblock_ptr;
    assign schedule_cta_predicted = selected_from_branch_resolving;
    
    // Sequential logic for state updates
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
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
            if (enable && schedule_valid && schedule_ready) begin
                // Allocate current e-block and advance pointer
                eblock_live[eblock_ptr] <= 1'b1;
                eblock_ptr <= (eblock_ptr + 1) & (MAX_EBLOCK-1);
                
                // Update PC history for locality tracking
                previous_pc <= cta_next_pc[selected_cta_id];
                pc_history_valid <= 1'b1;
                
                // Update last dispatched CTA for round-robin
                last_dispatched_cta <= selected_cta_id;
            end
        end
    end
    
    // Debug and assertions
    `ifndef SYNTHESIS
    always @(posedge clk) begin
        if (rst_n) begin
            // Check for e-block exhaustion
            if (schedule_valid && schedule_ready && eblock_live[eblock_ptr]) begin
                $warning("CTA Scheduler: E-block %d already live, allocation conflict", eblock_ptr);
            end
            
            // Verify selection logic
            if (schedule_valid && !cta_valid[selected_cta_id]) begin
                $error("CTA Scheduler: Selected invalid CTA %d", selected_cta_id);
            end
            
            // Check commit bounds
            if (eblock_commit_valid && eblock_commit_id >= MAX_EBLOCK) begin
                $error("CTA Scheduler: Invalid e-block commit ID %d", eblock_commit_id);
            end
        end
    end
    
    // Performance monitoring
    logic [31:0] priority_schedule_count;
    logic [31:0] non_branch_schedule_count;
    logic [31:0] any_valid_schedule_count;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            priority_schedule_count <= '0;
            non_branch_schedule_count <= '0;
            any_valid_schedule_count <= '0;
        end else if (enable && schedule_valid && schedule_ready) begin
            if (priority_found) begin
                priority_schedule_count <= priority_schedule_count + 1;
            end else if (non_branch_found) begin
                non_branch_schedule_count <= non_branch_schedule_count + 1;
            end else if (any_valid_found) begin
                any_valid_schedule_count <= any_valid_schedule_count + 1;
            end
        end
    end
    `endif

endmodule
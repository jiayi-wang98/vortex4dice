module simt_stack_controller #(
    parameter STACK_DEPTH = 32,
    parameter PC_WIDTH = 32,
    parameter THREAD_WIDTH = 256,
    parameter METADATA_LENGTH_WIDTH = 8,
    parameter NUM_STACK = 4
)(
    input logic clk,
    input logic rst_n,
    
    // CTA configuration
    input logic [$clog2(NUM_STACK)-1:0] hw_cta_id,
    input logic [1:0] hw_cta_size,  // 00=1 stack, 01=2 stacks, 11=4 stacks
    
    // Update request interface (valid/ready handshake)
    input logic update_valid,
    input logic update_with_divergence,  // 0 = no divergence, 1 = with divergence
    input logic [PC_WIDTH-1:0] update_next_pc,  // No divergence: next PC, With divergence: branch taken PC
    
    // Divergence case inputs (only used when update_with_divergence = 1)
    input logic [NUM_STACK*THREAD_WIDTH-1:0] predicate_regs_value,
    input logic [PC_WIDTH-1:0] branch_not_taken_pc,
    input logic [PC_WIDTH-1:0] branch_reconvergence_pc,
    
    output logic update_ready,
    
    // Initialization interface (higher priority)
    input logic init_valid,
    input logic [$clog2(NUM_STACK)-1:0] init_hw_cta_id,
    input logic [1:0] init_hw_cta_size,
    input logic [PC_WIDTH-1:0] init_pc,
    input logic [PC_WIDTH-1:0] init_reconvergence_pc,
    output logic init_ready,
    
    // Stack top outputs (when not busy) - combined from active stacks
    output logic [NUM_STACK-1:0] stack_top_valid,
    output logic [NUM_STACK-1:0][PC_WIDTH-1:0] stack_top_next_pc,
    output logic [NUM_STACK-1:0][PC_WIDTH-1:0] stack_top_reconvergence_pc,
    output logic [NUM_STACK-1:0][THREAD_WIDTH-1:0] stack_top_active_mask,
    
    // Stack status - individual stack status
    output logic [NUM_STACK-1:0] stack_empty,
    output logic [NUM_STACK-1:0] stack_full
);

    logic [$clog2(NUM_STACK)-1:0] hw_cta_id_reg;
    logic [1:0] hw_cta_size_reg;

    // Calculate number of active stacks based on CTA size
    // hw_cta_size represents additional stacks beyond the base stack
    logic [2:0] num_active_stacks;
    always_comb begin
        case (hw_cta_size_reg)
            2'b00: num_active_stacks = 3'd1;  // hw_cta_id only (1 stack)
            2'b01: num_active_stacks = 3'd2;  // hw_cta_id + hw_cta_id+1 (2 stacks)
            2'b11: num_active_stacks = 3'd4;  // hw_cta_id through hw_cta_id+3 (4 stacks)
            default: num_active_stacks = 3'd1;
        endcase
    end
    
    // Calculate effective thread width based on CTA size
    logic [$clog2(NUM_STACK*THREAD_WIDTH+1)-1:0] effective_thread_width;
    always_comb begin
        case (hw_cta_size_reg)
            2'b00: effective_thread_width = THREAD_WIDTH;      // 256 threads
            2'b01: effective_thread_width = 2 * THREAD_WIDTH;  // 512 threads
            2'b11: effective_thread_width = 4 * THREAD_WIDTH;  // 1024 threads
            default: effective_thread_width = THREAD_WIDTH;
        endcase
    end

    // FSM states
    typedef enum logic [2:0] {
        IDLE,
        READ_TOP,
        MODIFY_TOP,
        PUSH_FIRST,
        PUSH_SECOND,
        POP_STACK,
        INIT_PUSH,
        FINAL_READ
    } state_t;
    
    state_t current_state, next_state;
    
    // Internal registers for multi-cycle operations
    logic update_with_divergence_reg;
    logic [PC_WIDTH-1:0] update_next_pc_reg;
    logic [NUM_STACK*THREAD_WIDTH-1:0] predicate_regs_value_reg;
    logic [PC_WIDTH-1:0] branch_not_taken_pc_reg;
    logic [PC_WIDTH-1:0] branch_reconvergence_pc_reg;
    
    // Registers for init operation
    logic [PC_WIDTH-1:0] init_pc_reg;
    logic [PC_WIDTH-1:0] init_reconvergence_pc_reg;
    
    // Per-stack signals
    logic [NUM_STACK-1:0] stack_push;
    logic [NUM_STACK-1:0] stack_modify_top;
    logic [NUM_STACK-1:0] stack_pop;
    logic [NUM_STACK-1:0] stack_read_top;
    logic [NUM_STACK-1:0] stack_out_valid;
    logic [NUM_STACK-1:0] stack_empty_individual;
    logic [NUM_STACK-1:0] stack_full_individual;
    
    logic [PC_WIDTH-1:0] stack_push_next_pc [NUM_STACK];
    logic [PC_WIDTH-1:0] stack_push_reconvergence_pc [NUM_STACK];
    logic [THREAD_WIDTH-1:0] stack_push_active_mask [NUM_STACK];
    logic [PC_WIDTH-1:0] stack_top_next_pc_int [NUM_STACK];
    logic [PC_WIDTH-1:0] stack_top_reconvergence_pc_int [NUM_STACK];
    logic [THREAD_WIDTH-1:0] stack_top_active_mask_int [NUM_STACK];
    
    // Combined stack signals
    logic combined_stack_out_valid;
    logic [PC_WIDTH-1:0] combined_stack_top_next_pc;
    logic [PC_WIDTH-1:0] combined_stack_top_reconvergence_pc;
    logic [NUM_STACK*THREAD_WIDTH-1:0] combined_stack_top_active_mask;
    
    // Computed values for divergence analysis
    logic [NUM_STACK*THREAD_WIDTH-1:0] taken_active_mask;
    logic [NUM_STACK*THREAD_WIDTH-1:0] not_taken_active_mask;
    logic [NUM_STACK*THREAD_WIDTH-1:0] effective_active_mask;
    logic all_taken, all_not_taken, has_divergence;
    
    // Operation control signals - combinational _next signals
    logic need_pop_next, need_modify_top_next, need_push_first_next, need_push_second_next;
    
    // Operation control signals - registered
    logic need_pop_reg, need_modify_top_reg, need_push_first_reg, need_push_second_reg;
    logic [PC_WIDTH-1:0] new_top_pc_reg;
    logic [PC_WIDTH-1:0] new_top_reconvergence_pc_reg;
    logic [NUM_STACK*THREAD_WIDTH-1:0] new_top_active_mask_reg;
    logic [PC_WIDTH-1:0] push_pc_1_reg, push_pc_2_reg;
    logic [PC_WIDTH-1:0] push_reconvergence_pc_1_reg, push_reconvergence_pc_2_reg;
    logic [NUM_STACK*THREAD_WIDTH-1:0] push_active_mask_1_reg, push_active_mask_2_reg;
    
    // Generate individual SIMT stacks
    genvar i;
    generate
        for (i = 0; i < NUM_STACK; i++) begin : gen_stacks
            simt_stack #(
                .STACK_DEPTH(STACK_DEPTH),
                .PC_WIDTH(PC_WIDTH),
                .THREAD_WIDTH(THREAD_WIDTH)
            ) stack_inst (
                .clk(clk),
                .rst_n(rst_n),
                .push(stack_push[i]),
                .modify_top(stack_modify_top[i]),
                .push_next_pc(stack_push_next_pc[i]),
                .push_reconvergence_pc(stack_push_reconvergence_pc[i]),
                .push_active_mask(stack_push_active_mask[i]),
                .pop(stack_pop[i]),
                .read_top(stack_read_top[i]),
                .top_next_pc(stack_top_next_pc_int[i]),
                .top_reconvergence_pc(stack_top_reconvergence_pc_int[i]),
                .top_active_mask(stack_top_active_mask_int[i]),
                .out_valid(stack_out_valid[i]),
                .stack_empty(stack_empty_individual[i]),
                .stack_full(stack_full_individual[i])
            );
        end
    endgenerate
    
    // Combine stack outputs based on CTA configuration
    always_comb begin
        logic all_active_valid;
        int mask_offset;
        combined_stack_out_valid = 1'b0;
        combined_stack_top_next_pc = '0;
        combined_stack_top_reconvergence_pc = '0;
        combined_stack_top_active_mask = '0;
        
        // Check if all active stacks have valid output
        all_active_valid = 1'b1;
        for (int j = 0; j < NUM_STACK; j++) begin
            if (j >= hw_cta_id_reg && j < (hw_cta_id_reg + num_active_stacks)) begin
                all_active_valid &= stack_out_valid[j];
            end
        end
        
        if (all_active_valid) begin
            combined_stack_out_valid = 1'b1;
            // Use the PC from the first active stack (they should all be the same for valid operations)
            combined_stack_top_next_pc = stack_top_next_pc_int[hw_cta_id_reg];
            combined_stack_top_reconvergence_pc = stack_top_reconvergence_pc_int[hw_cta_id_reg];
            
            // Combine active masks from all active stacks
            for (int j = 0; j < NUM_STACK; j++) begin
                if (j >= hw_cta_id_reg && j < (hw_cta_id_reg + num_active_stacks)) begin
                    mask_offset = (j - hw_cta_id_reg) * THREAD_WIDTH;
                    combined_stack_top_active_mask[mask_offset +: THREAD_WIDTH] = 
                        stack_top_active_mask_int[j];
                end else begin
                    mask_offset = j * THREAD_WIDTH;
                    combined_stack_top_active_mask[mask_offset +: THREAD_WIDTH] = '0;
                end
            end
        end
    end
    
    // Output individual stack status directly
    assign stack_empty = stack_empty_individual;
    assign stack_full = stack_full_individual;
    
    // Extract effective active mask based on CTA size
    always_comb begin
        case (hw_cta_size_reg)
            2'b00: effective_active_mask = combined_stack_top_active_mask[THREAD_WIDTH-1:0];
            2'b01: effective_active_mask = combined_stack_top_active_mask[2*THREAD_WIDTH-1:0];
            2'b11: effective_active_mask = combined_stack_top_active_mask;
            default: effective_active_mask = combined_stack_top_active_mask[THREAD_WIDTH-1:0];
        endcase
    end
    
    // FSM next state logic - uses combinational _next signals for immediate decisions
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (init_valid) begin
                    next_state = INIT_PUSH;
                end else if (update_valid) begin
                    next_state = READ_TOP;
                end
            end
            
            READ_TOP: begin
                if (combined_stack_out_valid) begin
                    if (need_pop_next) begin
                        next_state = POP_STACK;
                    end else if (need_modify_top_next) begin
                        next_state = MODIFY_TOP;
                    end else if (need_push_first_next) begin
                        next_state = PUSH_FIRST;
                    end else begin
                        next_state = IDLE;  // No operation needed
                    end
                end
            end
            
            MODIFY_TOP: begin
                if (need_push_first_reg) begin
                    next_state = PUSH_FIRST;
                end else begin
                    next_state = FINAL_READ;
                end
            end
            
            PUSH_FIRST: begin
                if (need_push_second_reg) begin
                    next_state = PUSH_SECOND;
                end else begin
                    next_state = FINAL_READ;
                end
            end
            
            PUSH_SECOND: begin
                next_state = FINAL_READ;
            end
            
            POP_STACK: begin
                next_state = FINAL_READ;
            end
            
            INIT_PUSH: begin
                next_state = FINAL_READ;
            end
            
            FINAL_READ: begin
                if (combined_stack_out_valid || stack_empty) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // Divergence analysis logic - operates on effective thread width
    always_comb begin
        logic [NUM_STACK*THREAD_WIDTH-1:0] effective_predicate;
        
        // Extract effective predicate based on CTA size
        case (hw_cta_size_reg)
            2'b00: effective_predicate = {{(NUM_STACK-1)*THREAD_WIDTH{1'b0}}, predicate_regs_value_reg[THREAD_WIDTH-1:0]};
            2'b01: effective_predicate = {{(NUM_STACK-2)*THREAD_WIDTH{1'b0}}, predicate_regs_value_reg[2*THREAD_WIDTH-1:0]};
            2'b11: effective_predicate = predicate_regs_value_reg;
            default: effective_predicate = {{(NUM_STACK-1)*THREAD_WIDTH{1'b0}}, predicate_regs_value_reg[THREAD_WIDTH-1:0]};
        endcase
        
        taken_active_mask = effective_active_mask & effective_predicate;
        not_taken_active_mask = effective_active_mask & ~effective_predicate;
        all_taken = (taken_active_mask == effective_active_mask) && (effective_active_mask != 0);
        all_not_taken = (not_taken_active_mask == effective_active_mask) && (effective_active_mask != 0);
        has_divergence = !all_taken && !all_not_taken && (effective_active_mask != 0);
    end
    
    // Operation decision logic - combinational for immediate state decisions using _next signals
    always_comb begin
        // Default values
        need_pop_next = 1'b0;
        need_modify_top_next = 1'b0;
        need_push_first_next = 1'b0;
        need_push_second_next = 1'b0;
        
        if (current_state == READ_TOP && combined_stack_out_valid) begin
            if (!update_with_divergence_reg) begin
                // Update top without control divergence
                if (update_next_pc_reg == combined_stack_top_reconvergence_pc) begin
                    need_pop_next = 1'b1;
                end else begin
                    need_modify_top_next = 1'b1;
                end
                
            end else begin
                // Update top with control divergence  
                if (all_taken) begin
                    // All threads take the branch
                    if (update_next_pc_reg == combined_stack_top_reconvergence_pc) begin
                        need_pop_next = 1'b1;
                    end else begin
                        need_modify_top_next = 1'b1;
                    end
                    
                end else if (all_not_taken) begin
                    // All threads don't take the branch
                    if (branch_not_taken_pc_reg == combined_stack_top_reconvergence_pc) begin
                        need_pop_next = 1'b1;
                    end else begin
                        need_modify_top_next = 1'b1;
                    end
                    
                end else if (has_divergence) begin
                    // Real divergence cases
                    if ((update_next_pc_reg != branch_reconvergence_pc_reg) && 
                        (branch_not_taken_pc_reg != branch_reconvergence_pc_reg) && 
                        (branch_reconvergence_pc_reg != combined_stack_top_reconvergence_pc)) begin
                        // Case 2: Push two new entries
                        need_modify_top_next = 1'b1;
                        need_push_first_next = 1'b1;
                        need_push_second_next = 1'b1;
                        
                    end else if ((update_next_pc_reg == branch_reconvergence_pc_reg) && 
                               (branch_reconvergence_pc_reg != combined_stack_top_reconvergence_pc)) begin
                        // Case 3: Push one entry for not taken
                        need_modify_top_next = 1'b1;
                        need_push_first_next = 1'b1;
                        
                    end else if ((branch_not_taken_pc_reg == branch_reconvergence_pc_reg) && 
                               (branch_reconvergence_pc_reg == combined_stack_top_reconvergence_pc)) begin
                        // Case 4: Update top to taken branch
                        need_modify_top_next = 1'b1;
                        
                    end else if ((update_next_pc_reg == branch_reconvergence_pc_reg) && 
                               (branch_reconvergence_pc_reg == combined_stack_top_reconvergence_pc)) begin
                        // Case 1: Update top to not taken branch
                        need_modify_top_next = 1'b1;
                    end
                end
            end
        end
    end
    
    // Distribute signals to individual stacks based on active configuration
    always_comb begin
        int mask_offset;
        // Initialize all stacks to inactive
        for (int j = 0; j < NUM_STACK; j++) begin
            stack_push[j] = 1'b0;
            stack_modify_top[j] = 1'b0;
            stack_pop[j] = 1'b0;
            stack_read_top[j] = 1'b0;
            stack_push_next_pc[j] = '0;
            stack_push_reconvergence_pc[j] = '0;
            stack_push_active_mask[j] = '0;
        end
        
        // Always read from all stacks to keep outputs valid
        for (int j = 0; j < NUM_STACK; j++) begin
            stack_read_top[j] = 1'b1;
        end
        
        // Activate only the stacks in the current CTA for operations
        for (int j = 0; j < NUM_STACK; j++) begin
            if (j >= hw_cta_id_reg && j < (hw_cta_id_reg + num_active_stacks)) begin
                case (current_state)
                    MODIFY_TOP: begin
                        stack_push[j] = 1'b1;
                        stack_modify_top[j] = 1'b1;
                        stack_push_next_pc[j] = new_top_pc_reg;
                        stack_push_reconvergence_pc[j] = new_top_reconvergence_pc_reg;
                        // Distribute active mask across stacks
                        mask_offset = (j - hw_cta_id_reg) * THREAD_WIDTH;
                        stack_push_active_mask[j] = new_top_active_mask_reg[mask_offset +: THREAD_WIDTH];
                    end
                    
                    PUSH_FIRST: begin
                        stack_push[j] = 1'b1;
                        stack_push_next_pc[j] = push_pc_1_reg;
                        stack_push_reconvergence_pc[j] = push_reconvergence_pc_1_reg;
                        // Distribute active mask across stacks
                        mask_offset = (j - hw_cta_id_reg) * THREAD_WIDTH;
                        stack_push_active_mask[j] = push_active_mask_1_reg[mask_offset +: THREAD_WIDTH];
                    end
                    
                    PUSH_SECOND: begin
                        stack_push[j] = 1'b1;
                        stack_push_next_pc[j] = push_pc_2_reg;
                        stack_push_reconvergence_pc[j] = push_reconvergence_pc_2_reg;
                        // Distribute active mask across stacks
                        mask_offset = (j - hw_cta_id_reg) * THREAD_WIDTH;
                        stack_push_active_mask[j] = push_active_mask_2_reg[mask_offset +: THREAD_WIDTH];
                    end
                    
                    POP_STACK: begin
                        stack_pop[j] = 1'b1;
                    end
                    
                    INIT_PUSH: begin
                        stack_push[j] = 1'b1;
                        stack_modify_top[j] = 1'b0;
                        stack_push_next_pc[j] = init_pc_reg;
                        stack_push_reconvergence_pc[j] = init_reconvergence_pc_reg;
                        stack_push_active_mask[j] = '1;  // All threads active
                    end
                endcase
            end
        end
    end
    
    // Output assignments - convert unpacked arrays to packed arrays
    assign update_ready = (current_state == IDLE && !init_valid);
    assign init_ready = (current_state == IDLE);
    
    // Convert unpacked arrays to packed arrays for outputs
    // stack_top_valid is always available when stack has data (not dependent on state)
    always_comb begin
        for (int j = 0; j < NUM_STACK; j++) begin
            stack_top_valid[j] = stack_out_valid[j] && !stack_empty_individual[j];
            stack_top_next_pc[j] = stack_top_next_pc_int[j];
            stack_top_reconvergence_pc[j] = stack_top_reconvergence_pc_int[j];
            stack_top_active_mask[j] = stack_top_active_mask_int[j];
        end
    end
    
    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            update_with_divergence_reg <= 1'b0;
            update_next_pc_reg <= '0;
            predicate_regs_value_reg <= '0;
            branch_not_taken_pc_reg <= '0;
            branch_reconvergence_pc_reg <= '0;
            hw_cta_id_reg <= '0;
            hw_cta_size_reg <= '0;
            init_pc_reg <= '0;
            init_reconvergence_pc_reg <= '0;
            
            // Reset operation control registers
            need_pop_reg <= 1'b0;
            need_modify_top_reg <= 1'b0;
            need_push_first_reg <= 1'b0;
            need_push_second_reg <= 1'b0;
            new_top_pc_reg <= '0;
            new_top_reconvergence_pc_reg <= '0;
            new_top_active_mask_reg <= '0;
            push_pc_1_reg <= '0;
            push_pc_2_reg <= '0;
            push_reconvergence_pc_1_reg <= '0;
            push_reconvergence_pc_2_reg <= '0;
            push_active_mask_1_reg <= '0;
            push_active_mask_2_reg <= '0;
            
        end else begin
            current_state <= next_state;
            
            // Capture inputs on valid request, init has higher priority
            if (current_state == IDLE && init_valid) begin
                init_pc_reg <= init_pc;
                init_reconvergence_pc_reg <= init_reconvergence_pc;
                hw_cta_id_reg <= init_hw_cta_id;
                hw_cta_size_reg <= init_hw_cta_size;
            end else if (current_state == IDLE && update_valid) begin
                update_with_divergence_reg <= update_with_divergence;
                update_next_pc_reg <= update_next_pc;
                predicate_regs_value_reg <= predicate_regs_value;
                branch_not_taken_pc_reg <= branch_not_taken_pc;
                branch_reconvergence_pc_reg <= branch_reconvergence_pc;
                hw_cta_id_reg <= hw_cta_id;
                hw_cta_size_reg <= hw_cta_size;
            end
            
            // Register operation control values using _next signals
            if (current_state == READ_TOP && combined_stack_out_valid) begin
                // Simply assign _next to _reg
                need_pop_reg <= need_pop_next;
                need_modify_top_reg <= need_modify_top_next;
                need_push_first_reg <= need_push_first_next;
                need_push_second_reg <= need_push_second_next;
                
                // Store operation parameters based on what operations are needed
                if (!update_with_divergence_reg) begin
                    // No divergence case
                    if (need_modify_top_next) begin
                        new_top_pc_reg <= update_next_pc_reg;
                        new_top_reconvergence_pc_reg <= combined_stack_top_reconvergence_pc;
                        new_top_active_mask_reg <= effective_active_mask;
                    end
                    
                end else begin
                    // With divergence case
                    if (all_taken) begin
                        if (need_modify_top_next) begin
                            new_top_pc_reg <= update_next_pc_reg;
                            new_top_reconvergence_pc_reg <= combined_stack_top_reconvergence_pc;
                            new_top_active_mask_reg <= effective_active_mask;
                        end
                        
                    end else if (all_not_taken) begin
                        if (need_modify_top_next) begin
                            new_top_pc_reg <= branch_not_taken_pc_reg;
                            new_top_reconvergence_pc_reg <= combined_stack_top_reconvergence_pc;
                            new_top_active_mask_reg <= effective_active_mask;
                        end
                        
                    end else if (has_divergence) begin
                        if ((update_next_pc_reg != branch_reconvergence_pc_reg) && 
                            (branch_not_taken_pc_reg != branch_reconvergence_pc_reg) && 
                            (branch_reconvergence_pc_reg != combined_stack_top_reconvergence_pc)) begin
                            // Case 2: Push two new entries
                            new_top_pc_reg <= branch_reconvergence_pc_reg;
                            new_top_reconvergence_pc_reg <= combined_stack_top_reconvergence_pc;
                            new_top_active_mask_reg <= effective_active_mask;
                            push_pc_1_reg <= update_next_pc_reg;  // taken target
                            push_reconvergence_pc_1_reg <= branch_reconvergence_pc_reg;
                            push_active_mask_1_reg <= taken_active_mask;
                            push_pc_2_reg <= branch_not_taken_pc_reg;
                            push_reconvergence_pc_2_reg <= branch_reconvergence_pc_reg;
                            push_active_mask_2_reg <= not_taken_active_mask;
                            
                        end else if ((update_next_pc_reg == branch_reconvergence_pc_reg) && 
                                   (branch_reconvergence_pc_reg != combined_stack_top_reconvergence_pc)) begin
                            // Case 3: Push one entry for not taken
                            new_top_pc_reg <= branch_reconvergence_pc_reg;
                            new_top_reconvergence_pc_reg <= combined_stack_top_reconvergence_pc;
                            new_top_active_mask_reg <= effective_active_mask;
                            push_pc_1_reg <= branch_not_taken_pc_reg;
                            push_reconvergence_pc_1_reg <= branch_reconvergence_pc_reg;
                            push_active_mask_1_reg <= not_taken_active_mask;
                            
                        end else if ((branch_not_taken_pc_reg == branch_reconvergence_pc_reg) && 
                                   (branch_reconvergence_pc_reg == combined_stack_top_reconvergence_pc)) begin
                            // Case 4: Update top to taken branch
                            new_top_pc_reg <= update_next_pc_reg;  // taken target
                            new_top_reconvergence_pc_reg <= combined_stack_top_reconvergence_pc;
                            new_top_active_mask_reg <= taken_active_mask;
                            
                        end else if ((update_next_pc_reg == branch_reconvergence_pc_reg) && 
                                   (branch_reconvergence_pc_reg == combined_stack_top_reconvergence_pc)) begin
                            // Case 1: Update top to not taken branch
                            new_top_pc_reg <= branch_not_taken_pc_reg;
                            new_top_reconvergence_pc_reg <= combined_stack_top_reconvergence_pc;
                            new_top_active_mask_reg <= not_taken_active_mask;
                        end
                    end
                end
            end
        end
    end
    
    // Debug assertions
    `ifndef SYNTHESIS
    always @(posedge clk) begin
        if (rst_n) begin
            if (update_valid && update_ready && (hw_cta_id + hw_cta_size >= NUM_STACK)) begin
                $error("SIMT Stack Controller: CTA configuration exceeds available stacks (hw_cta_id=%0d, hw_cta_size=%0d, max=%0d)", 
                       hw_cta_id, hw_cta_size, NUM_STACK);
            end
            
            if (init_valid && init_ready && (init_hw_cta_id + init_hw_cta_size >= NUM_STACK)) begin
                $error("SIMT Stack Controller: Init CTA configuration exceeds available stacks (init_hw_cta_id=%0d, init_hw_cta_size=%0d, max=%0d)", 
                       init_hw_cta_id, init_hw_cta_size, NUM_STACK);
            end
            
            // Debug state transitions and operations
            if (current_state != next_state) begin
                $display("SIMT Controller: State %0s -> %0s", current_state.name(), next_state.name());
            end
            
            // Debug operation decisions in READ_TOP
            if (current_state == READ_TOP && combined_stack_out_valid) begin
                $display("SIMT Controller: READ_TOP analysis - pop=%b, modify=%b, push1=%b, push2=%b", 
                         need_pop_next, need_modify_top_next, need_push_first_next, need_push_second_next);
                if (need_modify_top_next) begin
                    $display("SIMT Controller: Will use new_top_pc=0x%h in next cycle", 
                             !update_with_divergence_reg ? update_next_pc_reg :
                             all_taken ? update_next_pc_reg :
                             all_not_taken ? branch_not_taken_pc_reg : 
                             branch_reconvergence_pc_reg);
                end
            end
        end
    end
    `endif

endmodule
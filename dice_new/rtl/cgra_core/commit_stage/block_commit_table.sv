module block_commit_table #(
    parameter MAX_NUM_CTA = 4,
    parameter MAX_EBLOCK = MAX_NUM_CTA + 4
) (
    input  logic                                    clk,
    input  logic                                    rst_n,
    
    // Entry insert interface
    input  logic                                    insert_valid,
    input  logic [$clog2(MAX_NUM_CTA)-1:0]         insert_hw_cta_id,
    input  logic [$clog2(MAX_EBLOCK)-1:0]          insert_e_block_id,
    input  logic [13:0]                            insert_pending_reads,
    input  logic [13:0]                            insert_pending_writes,
    
    // Pending read/write update interface
    input  logic                                    update_valid,
    input  logic [$clog2(MAX_EBLOCK)-1:0]          update_e_block_id,
    input  logic                                    update_is_write,      // 0: read, 1: write
    input  logic [3:0]                             update_reduce_count,  // max 8
    
    // E-block commit interface
    output logic                                    pop_valid,
    output logic [$clog2(MAX_EBLOCK)-1:0]          pop_e_block_id,
    input  logic                                    pop_ready,

    //status outputs
    output logic [MAX_NUM_CTA-1:0]         hw_cta_pending
);

    // Table entry structure
    typedef struct packed {
        logic                                       valid;
        logic [$clog2(MAX_NUM_CTA)-1:0]           hw_cta_id;
        logic [$clog2(MAX_EBLOCK)-1:0]            e_block_id;
        logic [13:0]                               pending_reads;
        logic [13:0]                               pending_writes;
    } table_entry_t;
    
    // Table storage
    table_entry_t commit_table [MAX_EBLOCK];
    
    // Round-robin priority pointer
    logic [$clog2(MAX_EBLOCK)-1:0] rr_ptr;
    
    // Internal signals
    logic [MAX_EBLOCK-1:0] ready_to_commit;
    logic [$clog2(MAX_EBLOCK)-1:0] commit_idx;
    logic commit_found;
    
    // Entry insert logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize all entries as invalid
            for (int i = 0; i < MAX_EBLOCK; i++) begin
                commit_table[i].valid <= 1'b0;
                commit_table[i].hw_cta_id <= '0;
                commit_table[i].e_block_id <= '0;
                commit_table[i].pending_reads <= '0;
                commit_table[i].pending_writes <= '0;
            end
        end else begin
            // Handle insert
            if (insert_valid) begin
                `ifndef SYNTHESIS
                if (commit_table[insert_e_block_id].valid) begin
                    $error("Error: Attempting to insert into occupied entry %0d at time %0t", 
                           insert_e_block_id, $time);
                end
                `endif
                
                commit_table[insert_e_block_id].valid <= 1'b1;
                commit_table[insert_e_block_id].hw_cta_id <= insert_hw_cta_id;
                commit_table[insert_e_block_id].e_block_id <= insert_e_block_id;
                commit_table[insert_e_block_id].pending_reads <= insert_pending_reads;
                commit_table[insert_e_block_id].pending_writes <= insert_pending_writes;
            end
            
            // Handle pending count updates
            if (update_valid && commit_table[update_e_block_id].valid) begin
                if (update_is_write) begin
                    // Update pending writes
                    `ifndef SYNTHESIS
                    if (commit_table[update_e_block_id].pending_writes < update_reduce_count) begin
                        $error("Error: Pending writes underflow for entry %0d. Current: %0d, Reduce: %0d at time %0t",
                               update_e_block_id, commit_table[update_e_block_id].pending_writes, 
                               update_reduce_count, $time);
                    end
                    `endif
                    commit_table[update_e_block_id].pending_writes <= 
                        commit_table[update_e_block_id].pending_writes - update_reduce_count;
                end else begin
                    // Update pending reads
                    `ifndef SYNTHESIS
                    if (commit_table[update_e_block_id].pending_reads < update_reduce_count) begin
                        $error("Error: Pending reads underflow for entry %0d. Current: %0d, Reduce: %0d at time %0t",
                               update_e_block_id, commit_table[update_e_block_id].pending_reads, 
                               update_reduce_count, $time);
                    end
                    `endif
                    commit_table[update_e_block_id].pending_reads <= 
                        commit_table[update_e_block_id].pending_reads - update_reduce_count;
                end
            end
            
            // Handle commit/pop
            if (pop_valid && pop_ready) begin
                commit_table[commit_idx].valid <= 1'b0;
            end
        end
    end
    
    // Check which entries are ready to commit
    always_comb begin
        for (int i = 0; i < MAX_EBLOCK; i++) begin
            ready_to_commit[i] = commit_table[i].valid && 
                                (commit_table[i].pending_reads == 14'd0) && 
                                (commit_table[i].pending_writes == 14'd0);
        end
    end
    
    // Round-robin priority logic for commit selection
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rr_ptr <= '0;
        end else if (pop_valid && pop_ready) begin
            // Update round-robin pointer after successful commit
            if (rr_ptr == MAX_EBLOCK - 1)
                rr_ptr <= '0;
            else
                rr_ptr <= rr_ptr + 1'b1;
        end
    end
    
    // Find next entry to commit using round-robin priority
    always_comb begin
        commit_found = 1'b0;
        commit_idx = '0;
        
        // Search from current rr_ptr to end
        for (int i = 0; i < MAX_EBLOCK; i++) begin
            logic [$clog2(MAX_EBLOCK)-1:0] idx;
            idx = (rr_ptr + i) % MAX_EBLOCK;
            if (ready_to_commit[idx] && !commit_found) begin
                commit_found = 1'b1;
                commit_idx = idx;
            end
        end
    end
    
    // Output assignments
    assign pop_valid = commit_found;
    assign pop_e_block_id = commit_idx;

    //output for each hw_cta
    always_comb begin
        hw_cta_pending = '0;
        for (int i = 0; i < MAX_EBLOCK; i++) begin
            if (commit_table[i].valid) begin
                hw_cta_pending[commit_table[i].hw_cta_id] = 1'b1;
            end
        end
    end
    
    // Assertions for verification
    `ifndef SYNTHESIS
    // Check that e_block_id matches the table index
    always_ff @(posedge clk) begin
        if (rst_n && insert_valid) begin
            assert(insert_e_block_id < MAX_EBLOCK) 
                else $error("Invalid e_block_id %0d exceeds MAX_EBLOCK %0d", 
                           insert_e_block_id, MAX_EBLOCK);
        end
        
        if (rst_n && update_valid) begin
            assert(update_e_block_id < MAX_EBLOCK) 
                else $error("Invalid update e_block_id %0d exceeds MAX_EBLOCK %0d", 
                           update_e_block_id, MAX_EBLOCK);
            assert(update_reduce_count <= 4'd8) 
                else $error("Invalid reduce count %0d exceeds maximum of 8", 
                           update_reduce_count);
        end
    end
    `endif

endmodule
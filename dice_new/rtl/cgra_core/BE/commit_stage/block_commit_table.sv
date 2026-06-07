// =============================================================================
// block_commit_table
// -----------------------------------------------------------------------------
// Unified rewrite (MODULE #9) for the full DICE core.
//
// Combines:
//   * Mini_Dice dice_brt's multi-bank read-reduction retire interface
//     (read_reduce_count_i [2**DICE_EBLOCK_ID_WIDTH][R_W], plus the
//      store/exec single-eblock retire ports), and
//   * dice_new's per-hw-cta pending tracking — an insert_hw_cta_id_i input and a
//     VECTOR hw_cta_pending_o [2**DICE_HW_CTA_ID_WIDTH] output so that
//     cta_status_table (via block_retire_status_t) still sees per-CTA pending.
//
// Mirrors Mini_Dice rtl/cgra_core/BE/commit_stage/block_commit_table.sv for the
// retire/commit datapath (insert FF, multi-bank read reduction, store/exec
// reduction, round-robin commit pop) and re-adds the dice_new hw_cta_id field +
// vector status output that the original dice_new block_commit_table exposed.
// =============================================================================
module block_commit_table
    import dice_pkg::*,
           DE_pkg::*;
#(
    parameter int R_W = PENDING_MEM_COUNT_WIDTH,
    parameter int S_W = PENDING_MEM_COUNT_WIDTH
) (
    input  logic                                    clk_i,
    input  logic                                    rst_i,

    // Entry insert interface
    input  logic                                    insert_valid_i,
    input  logic [DICE_HW_CTA_ID_WIDTH-1:0]         insert_hw_cta_id_i,
    input  logic [DICE_EBLOCK_ID_WIDTH-1:0]         insert_e_block_id_i,
    input  logic [R_W-1:0]                          insert_pending_reads_i,
    input  logic [S_W-1:0]                          insert_pending_stores_i,

    // Pending read update interface — per-eblock reduction counts produced by
    // the RF retire bundle (dice_brt reduces up to DICE_NUM_BANKS pops/cycle).
    input  logic [2**DICE_EBLOCK_ID_WIDTH-1:0][R_W-1:0] read_reduce_count_i,

    // Pending store update interface — store AW/W retire and per-eblock
    // execution-done token, each reducing one store credit.
    input  logic                                    store_update_valid_i,
    input  logic [DICE_EBLOCK_ID_WIDTH-1:0]         store_update_e_block_id_i,
    input  logic                                    exec_update_valid_i,
    input  logic [DICE_EBLOCK_ID_WIDTH-1:0]         exec_update_e_block_id_i,

    // E-block commit interface
    output logic                                    pop_valid_o,
    output logic [DICE_EBLOCK_ID_WIDTH-1:0]         pop_e_block_id_o,
    input  logic                                    pop_ready_i,

    // Per-hw-cta pending status — bit[i] high while CTA i has any live e-block.
    // Width matches block_retire_status_t.hw_cta_pending used by
    // cta_status_table (2**DICE_HW_CTA_ID_WIDTH == DICE_NUM_MAX_CTA_PER_CORE).
    output logic [2**DICE_HW_CTA_ID_WIDTH-1:0]      hw_cta_pending_o
);

    // Table entry structure
    typedef struct packed {
        logic                            valid;
        logic [DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id;
        logic [DICE_EBLOCK_ID_WIDTH-1:0] e_block_id;
        logic [R_W-1:0]                  pending_reads;
        logic [S_W-1:0]                  pending_stores;
    } table_entry_t;

    // Table storage
    table_entry_t commit_table [2**DICE_EBLOCK_ID_WIDTH];

    // Round-robin priority pointer
    logic [DICE_EBLOCK_ID_WIDTH-1:0] rr_ptr;

    // Internal signals
    logic [2**DICE_EBLOCK_ID_WIDTH-1:0] ready_to_commit;
    logic [DICE_EBLOCK_ID_WIDTH-1:0] commit_idx;
    logic commit_found;
    logic [2**DICE_EBLOCK_ID_WIDTH-1:0][S_W-1:0] store_reduce_count;

    // Reduce the store/exec retire events into one count per eblock. Both events
    // can target distinct eblocks in the same cycle.
    always_comb begin
        store_reduce_count = '0;
        if (store_update_valid_i) begin
            store_reduce_count[store_update_e_block_id_i] =
                store_reduce_count[store_update_e_block_id_i] + S_W'(1);
        end
        if (exec_update_valid_i) begin
            store_reduce_count[exec_update_e_block_id_i] =
                store_reduce_count[exec_update_e_block_id_i] + S_W'(1);
        end
    end

    // Entry insert / retire / pop logic
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            // Initialize all entries as invalid
            for (int i = 0; i < 2**DICE_EBLOCK_ID_WIDTH; i++) begin
                commit_table[i].valid          <= 1'b0;
                commit_table[i].hw_cta_id       <= '0;
                commit_table[i].e_block_id      <= '0;
                commit_table[i].pending_reads   <= '0;
                commit_table[i].pending_stores  <= '0;
            end
        end else begin
            // Handle insert
            if (insert_valid_i) begin
                commit_table[insert_e_block_id_i].valid         <= 1'b1;
                commit_table[insert_e_block_id_i].hw_cta_id      <= insert_hw_cta_id_i;
                commit_table[insert_e_block_id_i].e_block_id     <= insert_e_block_id_i;
                commit_table[insert_e_block_id_i].pending_reads  <= insert_pending_reads_i;
                commit_table[insert_e_block_id_i].pending_stores <= insert_pending_stores_i;
            end

            // Handle pending read count updates (load RF writebacks). The RF can
            // retire multiple banks in one cycle, so the per-eblock reduction
            // count is applied directly.
            for (int i = 0; i < 2**DICE_EBLOCK_ID_WIDTH; i++) begin
                if ((read_reduce_count_i[i] != '0) && commit_table[i].valid) begin
                    commit_table[i].pending_reads <=
                        commit_table[i].pending_reads - read_reduce_count_i[i];
                end
            end

            // Handle pending store count updates. Store AW/W retire events and
            // the per-eblock execution-done token both use this counter.
            for (int i = 0; i < 2**DICE_EBLOCK_ID_WIDTH; i++) begin
                if ((store_reduce_count[i] != '0) && commit_table[i].valid) begin
                    commit_table[i].pending_stores <=
                        commit_table[i].pending_stores - store_reduce_count[i];
                end
            end

            // Handle commit/pop
            if (pop_valid_o && pop_ready_i) begin
                commit_table[commit_idx].valid <= 1'b0;
            end
        end
    end

    // Check which entries are ready to commit
    always_comb begin
        for (int i = 0; i < 2**DICE_EBLOCK_ID_WIDTH; i++) begin
            ready_to_commit[i] = commit_table[i].valid
                               & (commit_table[i].pending_reads  == '0)
                               & (commit_table[i].pending_stores == '0);
        end
    end

    // Round-robin priority logic for commit selection
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            rr_ptr <= '0;
        end else if (pop_valid_o && pop_ready_i) begin
            // Update round-robin pointer after successful commit
            if (rr_ptr == 2**DICE_EBLOCK_ID_WIDTH - 1)
                rr_ptr <= '0;
            else
                rr_ptr <= rr_ptr + 1'b1;
        end
    end

    // Find next entry to commit using round-robin priority
    always_comb begin
        commit_found = 1'b0;
        commit_idx   = '0;

        // Search from current rr_ptr forward (circular)
        for (int i = 0; i < 2**DICE_EBLOCK_ID_WIDTH; i++) begin
            logic [DICE_EBLOCK_ID_WIDTH-1:0] idx;
            idx = (rr_ptr + i) % 2**DICE_EBLOCK_ID_WIDTH;
            if (ready_to_commit[idx] && !commit_found) begin
                commit_found = 1'b1;
                commit_idx   = idx;
            end
        end
    end

    // Output assignments
    assign pop_valid_o      = commit_found;
    assign pop_e_block_id_o = commit_idx;

    // Per-hw-cta pending: a CTA is pending while any of its e-blocks is still
    // live in the table.
    always_comb begin
        hw_cta_pending_o = '0;
        for (int i = 0; i < 2**DICE_EBLOCK_ID_WIDTH; i++) begin
            if (commit_table[i].valid) begin
                hw_cta_pending_o[commit_table[i].hw_cta_id] = 1'b1;
            end
        end
    end

    // =========================================================================
    // Assertions for verification
    // =========================================================================
`ifndef SYNTHESIS
    // No double-insert: target slot must be empty on an insert
    assert_no_double_insert: assert property (
        @(posedge clk_i) disable iff (rst_i)
        insert_valid_i |-> !commit_table[insert_e_block_id_i].valid
    ) else $error("Error: Attempting to insert into occupied entry %0d at time %0t",
                  insert_e_block_id_i, $time);

    // Insert e_block_id must be a valid table index
    assert_insert_id_in_range: assert property (
        @(posedge clk_i) disable iff (rst_i)
        insert_valid_i |-> (insert_e_block_id_i < 2**DICE_EBLOCK_ID_WIDTH)
    ) else $error("Invalid e_block_id %0d exceeds DICE_EBLOCK_ID_WIDTH %0d",
                  insert_e_block_id_i, 2**DICE_EBLOCK_ID_WIDTH);

    always_ff @(posedge clk_i) begin
        if (!rst_i) begin
            for (int i = 0; i < 2**DICE_EBLOCK_ID_WIDTH; i++) begin
                if ((read_reduce_count_i[i] != '0) && commit_table[i].valid
                    && (commit_table[i].pending_reads < read_reduce_count_i[i])) begin
                    $error("Error: Pending reads underflow for entry %0d. Current: %0d, Reduce: %0d at time %0t",
                           i, commit_table[i].pending_reads, read_reduce_count_i[i], $time);
                end
                if ((store_reduce_count[i] != '0) && commit_table[i].valid
                    && (commit_table[i].pending_stores < store_reduce_count[i])) begin
                    $error("Error: Pending stores underflow for entry %0d. Current: %0d, Reduce: %0d at time %0t",
                           i, commit_table[i].pending_stores, store_reduce_count[i], $time);
                end
            end
        end
    end
`endif // SYNTHESIS

endmodule

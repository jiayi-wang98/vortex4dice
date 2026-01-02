module dispatcher(
    input logic clk,
    input logic rst_n,
    
    // Input signals
    input logic [1:0] unrolling_factor,         // 0=1, 1=2, 2=4 way unrolling
    input logic [65:0] input_register_bitmap,   // 32 GPR + 32 Constant + 2 Predicate registers
    input logic [1023:0] active_mask,           // 1024-bit active mask
    input logic [1:0] cta_size,                 // 0=256, 1=512, 2=1024
    input logic fetch_done,                     // Previous stage ready signal
    
    // Write-back interface for scoreboards
    input logic wb_valid,                       // Valid signal for write-back command
    input logic [1023:0] wb_tid_bitmap,         // 1024-bit bitmap of TIDs to release registers
    input logic [7:0] ld_dest_reg,             // Register number to be released (0-31:GPR, 32-63:Const, 64-65:Pred)
    
    // Ready-to-dispatch FIFO pop interface
    input logic dispatch_fifo_pop,       // Pop signals for ready-to-dispatch FIFO
    
    // Output signals - dispatched threads
    output logic [9:0] dispatch_tid_0,         // TID for lane 0
    output logic dispatch_valid_0,             // Valid for lane 0
    output logic [9:0] dispatch_tid_1,         // TID for lane 1
    output logic dispatch_valid_1,             // Valid for lane 1
    output logic [9:0] dispatch_tid_2,         // TID for lane 2
    output logic dispatch_valid_2,             // Valid for lane 2
    output logic [9:0] dispatch_tid_3,         // TID for lane 3
    output logic dispatch_valid_3,             // Valid for lane 3
    output logic dispatch_fifo_empty,        // 1 if ALL FIFOs are empty
    
    // Status outputs
    output logic dispatcher_busy,              // Dispatcher is active
    output logic dispatcher_done               // Current CTA dispatch complete
);
    
    // Next thread logic signals
    logic thread_fifo_pop;
    logic [9:0] thread_next_tid_0, thread_next_tid_1, thread_next_tid_2, thread_next_tid_3;
    logic thread_valid_0, thread_valid_1, thread_valid_2, thread_valid_3;
    logic thread_fifo_data_valid;
    logic thread_fifo_empty, thread_fifo_full;
    logic thread_chunk_done;
    logic restart;
    logic [255:0] current_chunk;           // 256-bit chunk from active mask
    logic [1:0] chunk_base_addr;           // Current chunk index (0-3)
    logic [1:0] latched_unrolling_factor;  // Latched unrolling factor
    
    // Scoreboard signals
    logic [31:0] gpr_bitmap;                   // GPR portion of input registers
    logic [31:0] const_bitmap;                 // Constant portion of input registers
    logic [1:0] pred_bitmap;                   // Predicate portion of input registers
    logic collision [4];                       // Collision results from regular scoreboards
    logic const_collision;                     // Collision result from constant scoreboard
    logic [7:0] check_tid [4];                 // TIDs to check for collision
    logic [7:0] reserve_tid [4];               // TIDs to reserve
    logic [3:0] sb_rd_valid;                   // Read valid signals for scoreboards
    logic [3:0] sb_rsv_valid;                  // Reserve valid signals for scoreboards
    logic const_rd_valid;                      // Read valid for constant scoreboard
    logic const_rsv_valid;                     // Reserve valid for constant scoreboard
    // syn_keep
    logic [255:0] wb_tid_sb [4];               // Write-back bitmaps for each scoreboard
    
    // Ready-to-dispatch FIFO signals
    logic [10:0] ready_fifo_push_data [4];
    logic [10:0] ready_fifo_pop_data [4];
    logic [3:0] ready_fifo_pop_data_valid;
    logic [3:0] ready_fifo_empty;
    logic [3:0] ready_fifo_full;
    logic last_chunk_done; // Indicates if the last chunk is done processing

    logic [1:0] lane_sb_sel [4];              // Which scoreboard (0-3) for each lane
    logic [3:0] lane_collision;               // Per-lane collision results
    logic [3:0] sb_rd_valid_per_sb [4];       // [scoreboard][lane] - tracks which lanes check which SB
    logic [3:0] sb_rsv_valid_per_sb [4];      // [scoreboard][lane] - for reserve operations

    
    // ============================================================
    // Component Instantiations
    // ============================================================

    dispatcher_fsm dispatcher_fsm_inst (
        .current_chunk(current_chunk),
        .gpr_bitmap(gpr_bitmap),
        .const_bitmap(const_bitmap),
        .chunk_base_addr(chunk_base_addr),
        .latched_unrolling_factor(latched_unrolling_factor),
        .pred_bitmap(pred_bitmap),
        .dispatcher_busy(dispatcher_busy),
        .dispatcher_done(dispatcher_done),
        .restart(restart),

        .active_mask(active_mask),
        .input_register_bitmap(input_register_bitmap),
        .unrolling_factor(unrolling_factor),
        .cta_size(cta_size),
        .dispatch_valid_0(dispatch_valid_0),
        .dispatch_valid_1(dispatch_valid_1),
        .dispatch_valid_2(dispatch_valid_2),
        .dispatch_valid_3(dispatch_valid_3),
        .fetch_done(fetch_done),
        .thread_chunk_done(thread_chunk_done),
        .dispatch_fifo_empty(dispatch_fifo_empty),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Next Thread Logic Top - Updated interface with chunk_done
    next_thread_logic_top next_thread_top (
        .clk(clk),
        .rst_n(rst_n),
        .unrolling_factor(latched_unrolling_factor),
        .active_mask_chunk(current_chunk),
        .chunk_base_addr(chunk_base_addr),
        .restart(restart),
        .fifo_pop(thread_fifo_pop),
        .next_tid_0(thread_next_tid_0),
        .next_tid_1(thread_next_tid_1),
        .next_tid_2(thread_next_tid_2),
        .next_tid_3(thread_next_tid_3),
        .valid_0(thread_valid_0),
        .valid_1(thread_valid_1),
        .valid_2(thread_valid_2),
        .valid_3(thread_valid_3),
        .fifo_data_valid(thread_fifo_data_valid),
        .fifo_empty(thread_fifo_empty),
        .fifo_full(thread_fifo_full),
        .chunk_done(thread_chunk_done)
    );
    
    // Extract TIDs for scoreboard checking (only when data is valid)
    assign check_tid[0] = thread_next_tid_0[7:0];  // Use lower 8 bits of TID
    assign check_tid[1] = thread_next_tid_1[7:0];
    assign check_tid[2] = thread_next_tid_2[7:0];
    assign check_tid[3] = thread_next_tid_3[7:0];
    
    assign reserve_tid[0] = ready_fifo_pop_data[0][7:0];
    assign reserve_tid[1] = ready_fifo_pop_data[1][7:0];
    assign reserve_tid[2] = ready_fifo_pop_data[2][7:0];
    assign reserve_tid[3] = ready_fifo_pop_data[3][7:0];

    // Extract scoreboard selectro from upper TID bits
    assign lane_sb_sel[0] = thread_next_tid_0[9:8];  // Which scoreboard lane 0 should check
    assign lane_sb_sel[1] = thread_next_tid_1[9:8];
    assign lane_sb_sel[2] = thread_next_tid_2[9:8];
    assign lane_sb_sel[3] = thread_next_tid_3[9:8];
    
    // Valid signals for scoreboards - only check when thread FIFO has valid data
    always_comb begin
        // Initialize: no lanes checking any scoreboards
        for (int sb = 0; sb < 4; sb++) begin
            sb_rd_valid_per_sb[sb] = 4'b0000;
            sb_rsv_valid_per_sb[sb] = 4'b0000;
        end
        
        // Route READ requests: each valid lane checks its target scoreboard
        if (thread_fifo_data_valid && thread_valid_0)
            sb_rd_valid_per_sb[lane_sb_sel[0]][0] = 1'b1;
        if (thread_fifo_data_valid && thread_valid_1)
            sb_rd_valid_per_sb[lane_sb_sel[1]][1] = 1'b1;
        if (thread_fifo_data_valid && thread_valid_2)
            sb_rd_valid_per_sb[lane_sb_sel[2]][2] = 1'b1;
        if (thread_fifo_data_valid && thread_valid_3)
            sb_rd_valid_per_sb[lane_sb_sel[3]][3] = 1'b1;
        
        // Route RESERVE requests: based on TID from ready FIFO
        if (sb_rsv_valid[0]) // If lane 0 is reserving
            sb_rsv_valid_per_sb[ready_fifo_pop_data[0][9:8]][0] = 1'b1;
        if (sb_rsv_valid[1])
            sb_rsv_valid_per_sb[ready_fifo_pop_data[1][9:8]][1] = 1'b1;
        if (sb_rsv_valid[2])
            sb_rsv_valid_per_sb[ready_fifo_pop_data[2][9:8]][2] = 1'b1;
        if (sb_rsv_valid[3])
            sb_rsv_valid_per_sb[ready_fifo_pop_data[3][9:8]][3] = 1'b1;
    end
    
    // Aggregate: each scoreboard's rd_valid is OR of all lanes checking it
    assign sb_rd_valid[0] = |sb_rd_valid_per_sb[0];  
    assign sb_rd_valid[1] = |sb_rd_valid_per_sb[1];  
    assign sb_rd_valid[2] = |sb_rd_valid_per_sb[2];  
    assign sb_rd_valid[3] = |sb_rd_valid_per_sb[3];  

    always_comb begin
        for (int lane = 0; lane < 4; lane++) begin
            // Each lane gets collision result from its target scoreboard
            lane_collision[lane] = collision[lane_sb_sel[lane]];
        end
    end

    // Constant scoreboard valid signals (OR of all lanes)
    assign const_rd_valid = |sb_rd_valid;    // Check constants if any lane needs checking
    assign const_rsv_valid = |sb_rsv_valid;  // Reserve constants if any lane is reserving
    
    // Distribute 1024-bit wb_tid_bitmap to 4 scoreboards based on upper 2 bits
    // Only pass write-back signals when wb_valid is asserted
    always_comb begin
        if (wb_valid) begin
            wb_tid_sb[0] = wb_tid_bitmap[255:0];    // TIDs 0-255   (upper 2 bits = 00)
            wb_tid_sb[1] = wb_tid_bitmap[511:256];  // TIDs 256-511 (upper 2 bits = 01)
            wb_tid_sb[2] = wb_tid_bitmap[767:512];  // TIDs 512-767 (upper 2 bits = 10)
            wb_tid_sb[3] = wb_tid_bitmap[1023:768]; // TIDs 768-1023(upper 2 bits = 11)
        end else begin
            // No write-back when not valid
            wb_tid_sb[0] = 256'b0;
            wb_tid_sb[1] = 256'b0;
            wb_tid_sb[2] = 256'b0;
            wb_tid_sb[3] = 256'b0;
        end
    end
    
    // Scoreboards for collision detection (4 scoreboards, one for each TID range)
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_scoreboards
            scoreboard sb (
                .clk(clk),
                .rst_n(rst_n),
                .input_regs_map({pred_bitmap, gpr_bitmap}), // Direct from input: 32GPR + 2PR (34 bits)
                .rd_tid(check_tid[i]),
                .rd_valid(sb_rd_valid[i]),              // Valid signal for read operation
                .rsv_tid(reserve_tid[i]),
                .rsv_valid(sb_rsv_valid[i]),            // Valid signal for reserve operation
                .wb_tid_bitmap(wb_tid_sb[i]),           // Each scoreboard gets its 256-bit slice
                .ld_dest_reg(ld_dest_reg[6:0]),         // Convert to 7 bits for scoreboard (GPR+Pred only)
                .wb_valid(wb_valid && ((ld_dest_reg <= 8'd31) || (ld_dest_reg >= 8'd64))), // Valid for GPR+Pred only
                .collision(collision[i])
            );
        end
    endgenerate
    
    // Constant scoreboard for shared constant collision detection
    constant_scoreboard #(.NUM_CONSTANT_REGS(32)) const_sb (
        .clk(clk),
        .rst_n(rst_n),
        .input_const_map(const_bitmap),         // 32-bit constant register map
        .rd_valid(const_rd_valid),              // Valid when any lane needs checking
        .rsv_const_map(const_bitmap),           // Reserve the same constants
        .rsv_valid(const_rsv_valid),            // Valid when any lane is reserving
        .wb_const_bitmap(32'b1 << (ld_dest_reg - 8'd32)),  // Single constant register to release
        .wb_valid(wb_valid && (ld_dest_reg >= 8'd32) && (ld_dest_reg <= 8'd63)),  // Valid only for constant regs
        .collision(const_collision)
    );
    
    // Thread FIFO pop control - pop when no collision and can push to ready FIFOs
    logic all_lane_can_dispatch;
    always_comb begin
        all_lane_can_dispatch = 1'b1;
        case (latched_unrolling_factor)
            2'b00: all_lane_can_dispatch = !lane_collision[0] && !const_collision; // 1-way
            2'b01: all_lane_can_dispatch = !lane_collision[0] && !lane_collision[1] && !const_collision; // 2-way
            2'b10: all_lane_can_dispatch = !lane_collision[0] && !lane_collision[1] && !lane_collision[2] && !lane_collision[3] && !const_collision; // 4-way
            default: all_lane_can_dispatch = 1'b1; // Invalid unrolling factor
        endcase
    end


    logic ready_fifo_not_full;
    assign ready_fifo_not_full = !ready_fifo_full[0] && !ready_fifo_full[1] && !ready_fifo_full[2] && !ready_fifo_full[3];
    
    assign thread_fifo_pop = !thread_fifo_empty && all_lane_can_dispatch && ready_fifo_not_full;
    
    // Collision-free dispatch logic
    logic [3:0] ready_fifo_push_en; // per-lane push enable
    always_comb begin
        // NEW: Calculating per-lane push enable
        for (int i = 0; i < 4; i++) begin
            ready_fifo_push_en[i] = thread_fifo_data_valid && 
                                (i == 0 ? thread_valid_0 :
                                 i == 1 ? thread_valid_1 :
                                 i == 2 ? thread_valid_2 : thread_valid_3) &&
                                !lane_collision[i] && 
                                !const_collision && 
                                !ready_fifo_full[i];
        end
        // Push data assignments (unchanged)
        ready_fifo_push_data[0] = {thread_valid_0, thread_next_tid_0};
        ready_fifo_push_data[1] = {thread_valid_1, thread_next_tid_1};
        ready_fifo_push_data[2] = {thread_valid_2, thread_next_tid_2};
        ready_fifo_push_data[3] = {thread_valid_3, thread_next_tid_3};
    end
    
    // Ready-to-dispatch FIFOs using sync_fifo module
    generate
        for (i = 0; i < 4; i++) begin : gen_ready_fifos
            sync_fifo #(
                .DATA_WIDTH(11),        // 11 bits: {valid, tid[9:0]}
                .DEPTH(4)               // 4 entries deep
            ) ready_fifo (
                .clk(clk),
                .rst_n(rst_n),
                .push(ready_fifo_push_en[i]),
                .push_data(ready_fifo_push_data[i]),
                .pop(dispatch_fifo_pop),
                .pop_data(ready_fifo_pop_data[i]),
                .pop_data_valid(ready_fifo_pop_data_valid[i]),
                .empty(ready_fifo_empty[i]),
                .full(ready_fifo_full[i]),
                .count() // Unused
            );
        end
    endgenerate
    
    // Output assignments - using registered FIFO outputs
    assign dispatch_tid_0 = ready_fifo_pop_data[0][9:0];
    assign dispatch_valid_0 = ready_fifo_pop_data_valid[0] && ready_fifo_pop_data[0][10];
    assign dispatch_tid_1 = ready_fifo_pop_data[1][9:0];
    assign dispatch_valid_1 = ready_fifo_pop_data_valid[1] && ready_fifo_pop_data[1][10];
    assign dispatch_tid_2 = ready_fifo_pop_data[2][9:0];
    assign dispatch_valid_2 = ready_fifo_pop_data_valid[2] && ready_fifo_pop_data[2][10];
    assign dispatch_tid_3 = ready_fifo_pop_data[3][9:0];
    assign dispatch_valid_3 = ready_fifo_pop_data_valid[3] && ready_fifo_pop_data[3][10];
    
    // OLD: does not take into account unrolling differences
    // assign dispatch_fifo_empty = ready_fifo_empty[0] && ready_fifo_empty[1] && 
    //                              ready_fifo_empty[2] && ready_fifo_empty[3];

    // NEW: Unrolling-aware logic
    logic dispatch_fifo_empty_comb;
    always_comb begin
        case (latched_unrolling_factor)
            2'b00: begin // 1-way unrolling
                // Only FIFO 0 matters
                dispatch_fifo_empty_comb = ready_fifo_empty[0];
            end
            
            2'b01: begin // 2-way unrolling
                // FIFOs 0 and 1 matter
                dispatch_fifo_empty_comb = ready_fifo_empty[0] && ready_fifo_empty[1];
            end
            
            2'b10: begin // 4-way unrolling
                // All 4 FIFOs matter
                dispatch_fifo_empty_comb = ready_fifo_empty[0] && ready_fifo_empty[1] && 
                                        ready_fifo_empty[2] && ready_fifo_empty[3];
            end
            
            default: begin
                // Shouldn't happen, but default to all empty
                dispatch_fifo_empty_comb = 1'b1;
            end
        endcase
    end

    assign dispatch_fifo_empty = dispatch_fifo_empty_comb;
endmodule
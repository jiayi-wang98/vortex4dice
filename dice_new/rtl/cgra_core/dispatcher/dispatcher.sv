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

    // FSM states
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        DISPATCHING = 2'b01,
        DONE        = 2'b10
    } fsm_state_t;
    
    fsm_state_t current_state, next_state;
    
    // Internal registers
    logic [1:0] latched_unrolling_factor;
    logic [65:0] latched_input_regs;
    logic [1023:0] latched_active_mask;
    logic [1:0] latched_cta_size;
    logic [9:0] dispatched_count;
    logic [1:0] chunk_counter;
    logic [9:0] cta_total_size;
    //logic [9:0] active_thread_count;           // Count of active threads in CTA
    
    // Count active threads in the CTA
    //always_comb begin
    //    active_thread_count = 10'b0;
    //    for (int i = 0; i < 1024; i++) begin
    //        if (latched_active_mask[i]) begin
    //            active_thread_count = active_thread_count + 1'b1;
    //        end
    //    end
    //end
    
    // Calculate total CTA size
    always_comb begin
        case (latched_cta_size)
            2'b00: cta_total_size = 10'd256;
            2'b01: cta_total_size = 10'd512;
            2'b10: cta_total_size = 10'd1023;  // Fix: 1024 doesn't fit in 10 bits
            default: cta_total_size = 10'd256;
        endcase
    end
    
    // Calculate maximum chunks needed
    logic [1:0] max_chunks;
    always_comb begin
        case (latched_cta_size)
            2'b00: max_chunks = 2'b00;        // 1 chunk (0)
            2'b01: max_chunks = 2'b01;        // 2 chunks (0-1)
            2'b10: max_chunks = 2'b11;        // 4 chunks (0-3)
            default: max_chunks = 2'b00;
        endcase
    end
    
    // Chunk selection
    logic [255:0] current_chunk;
    logic [1:0] chunk_base_addr;
    
    always_comb begin
        chunk_base_addr = chunk_counter;
        
        case (chunk_counter)
            2'b00: current_chunk = latched_active_mask[255:0];     // Chunk 0
            2'b01: current_chunk = latched_active_mask[511:256];   // Chunk 1
            2'b10: current_chunk = latched_active_mask[767:512];   // Chunk 2
            2'b11: current_chunk = latched_active_mask[1023:768];  // Chunk 3
        endcase
    end
    
    // Next thread logic signals
    logic thread_fifo_pop;
    logic [9:0] thread_next_tid_0, thread_next_tid_1, thread_next_tid_2, thread_next_tid_3;
    logic thread_valid_0, thread_valid_1, thread_valid_2, thread_valid_3;
    logic thread_fifo_data_valid;
    logic thread_fifo_empty, thread_fifo_full;
    logic thread_chunk_done;
    logic restart;
    
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
    logic [255:0] wb_tid_sb [4];               // Write-back bitmaps for each scoreboard
    
    // Ready-to-dispatch FIFO signals
    logic ready_fifo_push;
    logic [10:0] ready_fifo_push_data [4];
    logic [10:0] ready_fifo_pop_data [4];
    logic [3:0] ready_fifo_pop_data_valid;
    logic [3:0] ready_fifo_empty;
    logic [3:0] ready_fifo_full;
    logic last_chunk_done; // Indicates if the last chunk is done processing
    
    // Check if all processing is done
    logic all_processing_done;
    assign all_processing_done = last_chunk_done && dispatch_fifo_empty;
    
    // Extract register bitmaps from latched input
    assign gpr_bitmap = latched_input_regs[31:0];      // GPR (bits 0-31)
    assign const_bitmap = latched_input_regs[63:32];   // Constants (bits 32-63)
    assign pred_bitmap = latched_input_regs[65:64];    // Predicates (bits 64-65)
    
    // FSM - State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // FSM - Next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (fetch_done) begin
                    next_state = DISPATCHING;
                end
            end
            
            DISPATCHING: begin
                // Check if all active threads are dispatched AND all processing is done
                if (all_processing_done) begin
                    next_state = DONE;
                end
            end
            
            DONE: begin
                // Stay in DONE until new fetch_done
                if (fetch_done) begin
                    next_state = DISPATCHING;
                end else begin
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    // FSM - Output and control logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latched_unrolling_factor <= 2'b0;
            latched_input_regs <= 66'b0;
            latched_active_mask <= 1024'b0;
            latched_cta_size <= 2'b0;
            dispatched_count <= 10'b0;
            chunk_counter <= 2'b0;
            last_chunk_done <= 1'b0;
            restart <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (fetch_done) begin
                        // Latch all inputs
                        latched_unrolling_factor <= unrolling_factor;
                        latched_input_regs <= input_register_bitmap;
                        latched_active_mask <= active_mask;
                        latched_cta_size <= cta_size;
                        dispatched_count <= 10'b0;
                        chunk_counter <= 2'b0;
                    end
                end
                
                DISPATCHING: begin
                    // Increment dispatched count when threads are successfully dispatched
                    logic [2:0] dispatched_this_cycle;
                    dispatched_this_cycle = dispatch_valid_0 + dispatch_valid_1 + 
                                          dispatch_valid_2 + dispatch_valid_3;
                    dispatched_count <= dispatched_count + dispatched_this_cycle;
                    
                    // Advance chunk counter when current chunk is done
                    if (thread_chunk_done) begin
                        if(chunk_counter < max_chunks) begin
                            chunk_counter <= chunk_counter + 1'b1;
                            restart <= 1'b1;
                        end else begin
                            chunk_counter <= max_chunks; // Reset to 0 if max chunks reached
                            last_chunk_done <= 1'b1; // Indicate last chunk is done
                        end
                    end 

                end
                
                DONE: begin
                    if (fetch_done) begin
                        // Start new CTA
                        latched_unrolling_factor <= unrolling_factor;
                        latched_input_regs <= input_register_bitmap;
                        latched_active_mask <= active_mask;
                        latched_cta_size <= cta_size;
                        dispatched_count <= 10'b0;
                        chunk_counter <= 2'b0;
                    end
                end
            endcase
        end
    end
    
    // Status outputs
    assign dispatcher_busy = (current_state == DISPATCHING);
    assign dispatcher_done = (current_state == DONE);
    
    // ============================================================
    // Component Instantiations
    // ============================================================
    
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
    
    // Valid signals for scoreboards - only check when thread FIFO has valid data
    assign sb_rd_valid[0] = thread_fifo_data_valid && thread_valid_0;
    assign sb_rd_valid[1] = thread_fifo_data_valid && thread_valid_1;
    assign sb_rd_valid[2] = thread_fifo_data_valid && thread_valid_2;
    assign sb_rd_valid[3] = thread_fifo_data_valid && thread_valid_3;
    
    assign sb_rsv_valid[0] = ready_fifo_pop_data_valid[0] && ready_fifo_pop_data[0][10];
    assign sb_rsv_valid[1] = ready_fifo_pop_data_valid[1] && ready_fifo_pop_data[1][10];
    assign sb_rsv_valid[2] = ready_fifo_pop_data_valid[2] && ready_fifo_pop_data[2][10];
    assign sb_rsv_valid[3] = ready_fifo_pop_data_valid[3] && ready_fifo_pop_data[3][10];
    
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
            2'b00: all_lane_can_dispatch = !collision[0] && !const_collision; // 1-way
            2'b01: all_lane_can_dispatch = !collision[0] && !collision[1] && !const_collision; // 2-way
            2'b10: all_lane_can_dispatch = !collision[0] && !collision[1] && !collision[2] && !collision[3] && !const_collision; // 4-way
            default: all_lane_can_dispatch = 1'b1; // Invalid unrolling factor
        endcase
    end


    logic ready_fifo_not_full;
    assign ready_fifo_not_full = !ready_fifo_full[0] && !ready_fifo_full[1] && !ready_fifo_full[2] && !ready_fifo_full[3];
    
    assign thread_fifo_pop = !thread_fifo_empty && all_lane_can_dispatch && ready_fifo_not_full;
    
    // Collision-free dispatch logic
    always_comb begin
        ready_fifo_push =  thread_fifo_data_valid && thread_valid_0 && !collision[0] && !const_collision && ready_fifo_not_full;
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
                .push(ready_fifo_push),
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
    
    assign dispatch_fifo_empty = ready_fifo_empty[0] && ready_fifo_empty[1] && 
                                  ready_fifo_empty[2] && ready_fifo_empty[3];
endmodule
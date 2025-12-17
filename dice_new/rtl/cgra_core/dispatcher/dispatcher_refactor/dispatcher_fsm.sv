module dispatcher_fsm (
    output logic [255:0] current_chunk,
    output logic [31:0] gpr_bitmap,
    output logic [31:0] const_bitmap,
    output logic [1:0] chunk_base_addr,
    output logic [1:0] latched_unrolling_factor,
    output logic [1:0] pred_bitmap,
    output logic dispatcher_busy,
    output logic dispatcher_done,
    output logic restart,

    input logic [1023:0] active_mask,
    input logic [65:0] input_register_bitmap,
    input logic [1:0] unrolling_factor,
    input logic [1:0] cta_size,
    input logic dispatch_valid_0,
    input logic dispatch_valid_1,
    input logic dispatch_valid_2,
    input logic dispatch_valid_3,
    input logic fetch_done,
    input logic thread_chunk_done,
    input logic dispatch_fifo_empty,
    input logic clk, rst_n
); 
    
    // Intermediate logic
    logic [1023:0] latched_active_mask;
    logic [65:0] latched_input_regs;
    logic [9:0] dispatched_count;
    logic [1:0] latched_cta_size;
    logic [1:0] last_chunk_done;
    logic [1:0] chunk_counter;
    logic latch_inputs,
          update_count,
          deassert_restart,
          incr_counter,
          rst_counter, 
          assert_restart, 
          last_chunk_fin,
          start_new_cta; // Control signals

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
    always_comb begin
        chunk_base_addr = chunk_counter;
        
        case (chunk_counter)
            2'b00: current_chunk = latched_active_mask[255:0];     // Chunk 0
            2'b01: current_chunk = latched_active_mask[511:256];   // Chunk 1
            2'b10: current_chunk = latched_active_mask[767:512];   // Chunk 2
            2'b11: current_chunk = latched_active_mask[1023:768];  // Chunk 3
        endcase
    end

    // Extract register bitmaps from latched input
    assign gpr_bitmap = latched_input_regs[31:0];      // GPR (bits 0-31)
    assign const_bitmap = latched_input_regs[63:32];   // Constants (bits 32-63)
    assign pred_bitmap = latched_input_regs[65:64];    // Predicates (bits 64-65)

    dispatcher_df dispatcher_dataflow_inst (
        .latched_active_mask(latched_active_mask),
        .latched_input_regs(latched_input_regs),
        .dispatched_count(dispatched_count),
        .latched_unrolling_factor(latched_unrolling_factor),
        .latched_cta_size(latched_cta_size),
        .chunk_counter(chunk_counter),
        .last_chunk_done(last_chunk_done),
        .restart(restart),

        .active_mask(active_mask),
        .input_register_bitmap(input_register_bitmap),
        .unrolling_factor(unrolling_factor),
        .cta_size(cta_size),
        .dispatch_valid_0(dispatch_valid_0),
        .dispatch_valid_1(dispatch_valid_1),
        .dispatch_valid_2(dispatch_valid_2),
        .dispatch_valid_3(dispatch_valid_3),
        .max_chunks(max_chunks),
        
        .latch_inputs(latch_inputs),
        .update_count(update_count),
        .deassert_restart(deassert_restart),
        .incr_counter(incr_counter),
        .rst_counter(rst_counter),
        .assert_restart(assert_restart),
        .last_chunk_fin(last_chunk_fin),
        .start_new_cta(start_new_cta),
        .clk(clk),
        .rst_n(rst_n)
    );

    dispatcher_ctrl dispatcher_control_inst (
        .latch_inputs(latch_inputs),
        .update_count(update_count),
        .deassert_restart(deassert_restart),
        .incr_counter(incr_counter),
        .rst_counter(rst_counter),
        .assert_restart(assert_restart),
        .last_chunk_fin(last_chunk_fin),
        .start_new_cta(start_new_cta),
        .dispatcher_busy(dispatcher_busy),
        .dispatcher_done(dispatcher_done),

        .fetch_done(fetch_done),
        .thread_chunk_done(thread_chunk_done),
        .last_chunk_done(last_chunk_done),
        .dispatch_fifo_empty(dispatch_fifo_empty),
        .chunk_counter(chunk_counter),
        .max_chunks(max_chunks),
        .clk(clk),
        .rst_n(rst_n)
    );

endmodule
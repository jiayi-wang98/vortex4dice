module dispatcher_dataflow #(
)(
    // Output Data
    output logic [1023:0] latched_active_mask,
    output logic [65:0] latched_input_regs,
    output logic [9:0] dispatched_count,
    output logic [1:0] latched_unrolling_factor,
    output logic [1:0] latched_cta_size,
    output logic [1:0] chunk_counter,
    output logic [1:0] last_chunk_done,
    output logic restart,
    
    // Input Data
    input logic [1023:0] active_mask,
    input logic [65:0] input_register_bitmap,
    input logic [1:0] unrolling_factor,
    input logic [1:0] cta_size,
    input logic dispatch_valid_0, dispatch_valid_1,
                dispatch_valid_2, dispatch_valid_3,
    input logic max_chunks,

    // Control Signals
    input logic latch_inputs,
    input logic update_count,
    input logic deassert_restart,
    input logic incr_counter,
    input logic rst_counter, 
    input logic assert_restart, 
    input logic last_chunk_fin,
    input logic start_new_cta,
    input logic clk, rst_n
)

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            latched_unrolling_factor <= 2'b0;
            latched_input_regs <= 66'b0;
            latched_active_mask <= 1024'b0;
            latched_cta_size <= 2'b0;
            dispatched_count <= 10'b0;
            chunk_counter <= 2'b0;
            last_chunk_done <= 1'b0;
            restart <= 1'b0;
        end

        if (latch_inputs) begin
            latched_unrolling_factor <= unrolling_factor;
            latched_input_regs <= input_register_bitmap;
            latched_active_mask <= active_mask;
            latched_cta_size <= cta_size;
            dispatched_count <= 10'b0;
            chunk_counter <= 2'b0;
            restart <= 1'b1;
        end

        if (update_count) begin
            dispatched_count <= dispatched_count + (dispatch_valid_0 + dispatch_valid_1 + 
                                          dispatch_valid_2 + dispatch_valid_3);
        end

        if (deassert_restart) begin
            restart <= 1'b0;
        end

        if (incr_counter) begin
            chunk_counter <= chunk_counter + 2'b01;
        end

        if (assert_restart) begin
            restart <= 1'b1;
        end

        if (rst_counter) begin
            chunk_counter <= max_chunks;
        end

        if (last_chunk_fin) begin
            last_chunk_done <= 1'b1;
        end

        if (start_new_cta) begin
            latched_unrolling_factor <= unrolling_factor;
            latched_input_regs <= input_register_bitmap;
            latched_active_mask <= active_mask;
            latched_cta_size <= cta_size;
            dispatched_count <= 10'b0;
            chunk_counter <= 2'b0;
            last_chunk_done <= 1'b0;
        end
    end
endmodule
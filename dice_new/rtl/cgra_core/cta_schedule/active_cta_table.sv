
//NOTE: AS OF NOW THIS ONLY WORKS IF THE CTA ONLY OCCUPIES ONE SLOT IN THE TABLE
// This is an issue that needs to be addressed.
// if pop signal is sent, but buffer hasn't been consumed there may be data corruption
// THERE ARE ISSUES WITH THE POP INTERFACE. IT MAY NEED BACKPRESSURE.


import dice_pkg::*;
import dice_frontend_pkg::*;

module active_cta_table #(
    //should this be changed to max_threads / max_ctas?
    parameter THREAD_WIDTH = 256  // Base thread width per CTA table entry
)(
    input logic clk,
    input logic rst,


    // Add new entry interface (table is slave)
    output logic                            add_ready,
    input logic                             add_valid,
    input dice_cta_desc_t                   add_cta_info, 
    input [DICE_TID_WIDTH-1:0]              add_cta_size, //ensure this is correct
    

    // Pop interface
    input logic pop_valid,
    input logic [DICE_HW_CTA_ID_WIDTH-1:0] pop_hw_cta_id, //which one to pop


    // Output popped CTA interface (table is master)
    output logic                                out_valid,
    input   logic                               out_ready,
    output dice_cta_id_t                        out_cta_id,
    output logic [DICE_TID_WIDTH-1:0]           out_cta_size, //ensure this is correct
    output logic [DICE_KERNEL_ID_WIDTH-1:0]     out_kernel_id,

    
    // Status outputs
    output active_cta_t active_cta_entries [DICE_NUM_MAX_CTA_PER_CORE-1:0],

    //output flags
    output logic full,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index
);

    // Calculate number of entries needed for a CTA
    // Optimized for power-of-2 THREAD_WIDTH using bit shifts
    function automatic logic [DICE_HW_CTA_ID_WIDTH:0] calc_entries_needed(input logic [DICE_TID_WIDTH-1:0] cta_size);
        // For power-of-2 THREAD_WIDTH, we can use bit shifts
        // entries_needed = ceil(cta_size / THREAD_WIDTH) = (cta_size + THREAD_WIDTH - 1) >> log2(THREAD_WIDTH)
        logic [DICE_TID_WIDTH-1:0] adjusted_size;
        adjusted_size = cta_size + THREAD_WIDTH - 1;
        return adjusted_size >> $clog2(THREAD_WIDTH);
    endfunction


    // CTA table entry structure
    typedef struct packed {
        logic                                              is_primary;      // True for the first entry of a multi-entry CTA
        logic [$clog2(DICE_NUM_MAX_CTA_PER_CORE):0]        entries_used;    // Number of entries used by this CTA
        active_cta_t                                       entry_info;
    } cta_entry_t;


    // CTA table storage
    cta_entry_t cta_table [DICE_NUM_MAX_CTA_PER_CORE-1:0]; // from dice package
    
    // Output buffer for popped entries
    logic                                             output_buffer_valid;
    dice_cta_id_t                                     output_buffer_cta_id;
    logic [DICE_TID_WIDTH-1:0]                        output_buffer_cta_size; //not sure if this is correct
    logic [DICE_KERNEL_ID_WIDTH-1:0]                  output_buffer_kernel_id;
    

    // Internal signals - simplified
    logic [DICE_HW_CTA_ID_WIDTH-1:0] empty_index;
    logic found_empty;
    logic [DICE_HW_CTA_ID_WIDTH:0] entries_needed;
    

    // Calculate entries needed for incoming CTA
    assign entries_needed = calc_entries_needed(add_cta_size);
    
    // Find next empty entry - simplified since we assume requests won't exceed available space
    always_comb begin
        found_empty = 1'b0;
        empty_index = '0;
        
        // Simple search for first empty slot - no need to check consecutive availability
        for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
            if (!cta_table[i].entry_info.cta_valid && !found_empty) begin
                empty_index = i[DICE_HW_CTA_ID_WIDTH-1:0];
                found_empty = 1'b1;
            end
        end
    end
    
    // Output assignments - simplified
    assign full = !found_empty;
    assign next_empty_cta_index = empty_index;
    assign add_ready = found_empty; // Simplified: assume request will always fit if space exists
    
    // Output interface
    assign out_valid = output_buffer_valid;
    assign out_cta_id = output_buffer_cta_id;
    assign out_cta_size = output_buffer_cta_size;
    assign out_kernel_id = output_buffer_kernel_id;

    logic pop_this_cycle;
    logic output_consumed_this_cycle;

    // CTA valid outputs and status information - only from primary entries
    always_comb begin
        for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin            
            if (cta_table[i].entry_info.cta_valid && cta_table[i].is_primary) begin
                active_cta_entries[i] = cta_table[i].entry_info;
            end else begin
                active_cta_entries[i] = '0;
            end
        end
    end
    

    // Main table logic
    always_ff @(posedge clk) begin
        logic [DICE_HW_CTA_ID_WIDTH:0] entries_to_clear;
        if (rst) begin
            // Reset all entries
            for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
                cta_table[i] <= 1'b0;
            end
            // Reset output buffer
            output_buffer_valid <= 1'b0;
            output_buffer_cta_id <= '0;
            output_buffer_cta_size <= '0;
            output_buffer_kernel_id <= '0;
            
        end else begin
            // Handle simultaneous pop and output buffer operations
            
            pop_this_cycle = pop_valid && cta_table[pop_hw_cta_id].entry_info.cta_valid;
            output_consumed_this_cycle = out_valid && out_ready;
            
            if (pop_this_cycle && output_consumed_this_cycle) begin
                // Pop and output in same cycle - directly replace buffer contents
                output_buffer_valid <= 1'b1;
                output_buffer_cta_id <= cta_table[pop_hw_cta_id].entry_info.cta_id;
                output_buffer_cta_size <= cta_table[pop_hw_cta_id].entry_info.hw_cta_size;
                output_buffer_kernel_id <= cta_table[pop_hw_cta_id].entry_info.kernel_id;
                
                // Clear all entries used by this CTA
                entries_to_clear = cta_table[pop_hw_cta_id].entries_used;
                
                for (int j = 0; j < DICE_NUM_MAX_CTA_PER_CORE; j++) begin
                    if (j >= pop_hw_cta_id && j < (pop_hw_cta_id + entries_to_clear)) begin
                        cta_table[j] <= '0;
                    end
                end
                
            end else if (pop_this_cycle && !output_buffer_valid) begin
                // Pop when buffer is empty - store in buffer
                output_buffer_valid <= 1'b1;
                output_buffer_cta_id <= cta_table[pop_hw_cta_id].entry_info.cta_id;
                output_buffer_cta_size <= cta_table[pop_hw_cta_id].entry_info.hw_cta_size;
                output_buffer_kernel_id <= cta_table[pop_hw_cta_id].entry_info.kernel_id;
                
                // Clear all entries used by this CTA
                entries_to_clear = cta_table[pop_hw_cta_id].entries_used;
                
                for (int j = 0; j < DICE_NUM_MAX_CTA_PER_CORE; j++) begin
                    if (j >= pop_hw_cta_id && j < (pop_hw_cta_id + entries_to_clear)) begin
                        cta_table[j] <= '0;
                    end
                end
                
            end else if (output_consumed_this_cycle) begin
                // Only output buffer consumed - clear buffer
                output_buffer_valid <= 1'b0;
                output_buffer_cta_id <= '0;
                output_buffer_cta_size <= '0;
                output_buffer_kernel_id <= '0;
            end
            // If pop_this_cycle && output_buffer_valid && !output_consumed_this_cycle
            // then we can't pop because buffer is full - pop is ignored
            
            // Handle add operation
            if (add_valid && add_ready) begin
                // Allocate consecutive entries for this CTA
                for (int j = 0; j < DICE_NUM_MAX_CTA_PER_CORE; j++) begin
                    if (j >= empty_index && j < (empty_index + entries_needed)) begin
                        if (j == empty_index) begin
                            cta_table[j].entry_info.cta_id <= add_cta_info.cta_id;
                            cta_table[j].entry_info.grid_size <= add_cta_info.kernel_desc.grid_size;
                            cta_table[j].entry_info.cta_size <= add_cta_info.kernel_desc.cta_size;
                            cta_table[j].entry_info.kernel_id <= add_cta_info.kernel_desc.kernel_id;
                            cta_table[j].entry_info.smem_per_cta <= add_cta_info.kernel_desc.smem_per_cta;
                            cta_table[j].entry_info.hw_cta_size <= add_cta_size;
                        end else begin
                            // Non-primary entries have no meaningful data (but store entries_used for cleanup)
                            cta_table[j] <= '0;
                        end
                        cta_table[j].entry_info.cta_valid <= 1'b1;
                        cta_table[j].is_primary <= (j == empty_index); // Only first entry is primary
                        cta_table[j].entries_used <= entries_needed;
                    end
                end
            end
        end
    end

endmodule
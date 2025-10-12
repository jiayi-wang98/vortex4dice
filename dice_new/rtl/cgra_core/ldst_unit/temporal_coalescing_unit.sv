module temporal_coalescing_unit#(
    parameter int number_of_max_coalesced_interval = 8, // Maximum number of clk cycles to hold internal commands
    parameter int cache_line_size = 32, // Size of a cache line in bytes
    parameter int number_of_max_coalesced_commands = cache_line_size/4, // Maximum number of commands that can be coalesced
    parameter int base_address_offset = $clog2(cache_line_size), // Width of base address offset in bits
    parameter int base_tid_address_offset = $clog2(number_of_max_coalesced_commands) // Width of base TID address offset in bits
)
(
    input logic clk,                     // Clock signal
    input logic rst_n,                   // Active low reset signal
    
    //input memory commands
    input logic incmd_valid,                // Input command valid signal
    input logic [3:0] incmd_block_id,       // Input command block ID
    input logic [9:0] incmd_tid,            // Input command thread ID
    input logic incmd_write_enable,         // Write enable signal
    input logic [63:0] incmd_write_data,    // Data to write
    input logic [7:0] incmd_write_mask,     // 1 means no write, 0 means write
    input logic [63:0] incmd_address,       // Address for the command
    input logic [1:0] incmd_size,          // Size of the command (e.g., 00=1B, 01=2B, 10=4B, 11=8B)
    input logic [6:0] incmd_ld_dest_reg,    // Load destination register
    //ready signal
    output logic incmd_ready,            // Ready signal for input command

    //output memory commands
    output logic outcmd_valid,              // Output command valid signal
    output logic [3:0] outcmd_block_id,     // Output command block ID
    output logic [9:0] outcmd_base_tid,     // Output command thread ID
    output logic [7:0] outcmd_tid_bitmap,  // Bitmap of TIDs for the command
    output logic outcmd_write_enable,       // Write enable signal
    output logic [cache_line_size*8-1:0] outcmd_write_data,  // Data to write
    output logic [cache_line_size-1:0] outcmd_write_mask, // 1 means no write, 0 means write
    output logic [63:0] outcmd_address,     // Address for the command
    output logic [1:0] outcmd_size,        // Size of the command (e.g., 00=1B, 01=2B, 10=4B, 11=8B)
    output logic [6:0] outcmd_ld_dest_reg,  // Load destination register
    output logic [number_of_max_coalesced_commands-1:0][base_address_offset-1:0] outcmd_address_map, //map from tid bitmap to address_offset

    //status signals
    input logic outcmd_ready                   // Ready signal to control flow
);

    parameter int total_output_cmd_width = 4 + 10 + 8 + 1 + cache_line_size*8 + cache_line_size + 64 + 2 + 7 + number_of_max_coalesced_commands * base_address_offset;
    // Coalescing interval counter
    logic [$clog2(number_of_max_coalesced_interval)-1:0] interval_counter;
    logic interval_timeout;
    assign interval_timeout = (interval_counter == (number_of_max_coalesced_interval - 1));

    // Buffer control signals
    logic buffer_incmd_valid;
    logic buffer_update_new;
    logic buffer_clear;
    logic buffer_can_coalesce;

    // Buffer output signals
    logic buffer_outcmd_valid;
    logic [3:0] buffer_outcmd_block_id;
    logic [9:0] buffer_outcmd_base_tid;
    logic [7:0] buffer_outcmd_tid_bitmap;
    logic buffer_outcmd_write_enable;
    logic [cache_line_size*8-1:0] buffer_outcmd_write_data;
    logic [cache_line_size-1:0] buffer_outcmd_write_mask;
    logic [63:0] buffer_outcmd_address;
    logic [1:0] buffer_outcmd_size;
    logic [6:0] buffer_outcmd_ld_dest_reg;
    logic [number_of_max_coalesced_commands-1:0] [base_address_offset-1:0] buffer_outcmd_address_map;

    logic output_valid;

    logic fifo_full;
    logic fifo_not_full;
    logic fifo_empty;
    logic fifo_pop;

    assign fifo_not_full = !fifo_full;

    // Input command base address for comparison
    logic [63:0] incmd_base_address;
    assign incmd_base_address = {incmd_address[63:base_address_offset], {base_address_offset{1'b0}}};

    // Interval counter logic - only counts when there are active buffers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            interval_counter <= '0;
        end else begin
            if (buffer_clear) begin
                interval_counter <= '0;  // Reset counter after output is popped
            end else if (buffer_outcmd_valid  && !interval_timeout) begin
                interval_counter <= interval_counter + 1'b1;  // Only count when buffers are active and not timeout
            end
            // Counter stays at current value when no buffers are active
        end
    end


    // Input commnd will be sent to all buffers that are in COALESCING state
    assign buffer_incmd_valid = incmd_valid;

    // gather if any existing command can coalesce with the new command
    assign incmd_ready = buffer_can_coalesce || fifo_not_full || !buffer_outcmd_valid ; // either can coalesce, buffer will be cleared, or buffer is empty.

    // buffer update logic, update_new can overwrite clear.
    assign buffer_update_new = incmd_valid && incmd_ready && !buffer_can_coalesce;
    assign buffer_clear = fifo_not_full && output_valid;

    assign output_valid = buffer_outcmd_valid && (!buffer_can_coalesce || interval_timeout); //either can not coalesce or timeout

    assign outcmd_valid = !fifo_empty; // output command is valid only when buffer can output and ready to receive

    assign fifo_pop = outcmd_ready && outcmd_valid; // pop from FIFO when ready and valid

    // Generate coalesce buffer instances
    memory_cmd_coalesce_buffer #(
        .cache_line_size(cache_line_size),
        .number_of_max_coalesced_commands(number_of_max_coalesced_commands),
        .base_address_offset(base_address_offset),
        .base_tid_address_offset(base_tid_address_offset)
    ) coalesce_buffer_inst (
        .clk(clk),
        .rst_n(rst_n),
        .clear(buffer_clear),
        .update_new(buffer_update_new),
        .incmd_valid(buffer_incmd_valid),
        .incmd_block_id(incmd_block_id),
        .incmd_tid(incmd_tid),
        .incmd_write_enable(incmd_write_enable),
        .incmd_write_data(incmd_write_data),
        .incmd_write_mask(incmd_write_mask),
        .incmd_address(incmd_address),
        .incmd_size(incmd_size),
        .incmd_ld_dest_reg(incmd_ld_dest_reg),
        .can_coalesce(buffer_can_coalesce),
        .outcmd_valid(buffer_outcmd_valid),
        .outcmd_block_id(buffer_outcmd_block_id),
        .outcmd_base_tid(buffer_outcmd_base_tid),
        .outcmd_tid_bitmap(buffer_outcmd_tid_bitmap),
        .outcmd_write_enable(buffer_outcmd_write_enable),
        .outcmd_write_data(buffer_outcmd_write_data),
        .outcmd_write_mask(buffer_outcmd_write_mask),
        .outcmd_address(buffer_outcmd_address),
        .outcmd_size(buffer_outcmd_size),
        .outcmd_ld_dest_reg(buffer_outcmd_ld_dest_reg),
        .outcmd_address_map(buffer_outcmd_address_map)
    );


    sync_fifo_read_unreg #(
        .DATA_WIDTH(total_output_cmd_width),
        .DEPTH(2)
    ) output_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .push(buffer_clear),
        .push_data({buffer_outcmd_block_id, 
                    buffer_outcmd_base_tid, 
                    buffer_outcmd_tid_bitmap, 
                    buffer_outcmd_write_enable, 
                    buffer_outcmd_write_data, 
                    buffer_outcmd_write_mask, 
                    buffer_outcmd_address, 
                    buffer_outcmd_size, 
                    buffer_outcmd_ld_dest_reg,
                    buffer_outcmd_address_map}),
        .pop(fifo_pop),
        .pop_data({outcmd_block_id, 
                    outcmd_base_tid, 
                    outcmd_tid_bitmap, 
                    outcmd_write_enable, 
                    outcmd_write_data, 
                    outcmd_write_mask, 
                    outcmd_address, 
                    outcmd_size, 
                    outcmd_ld_dest_reg,
                    outcmd_address_map}),
        .pop_data_valid(),
        .empty(fifo_empty),
        .full(fifo_full),
        .count()
    );

endmodule
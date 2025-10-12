module constant_scoreboard #(
    parameter int NUM_CONSTANT_REGS = 32    // Number of constant registers
)(
    input logic clk,
    input logic rst_n,
    
    // Input signals
    input logic [NUM_CONSTANT_REGS-1:0] input_const_map,  // Constant register bitmap from input
    input logic rd_valid,                                 // Valid signal for read/collision check
    input logic [NUM_CONSTANT_REGS-1:0] rsv_const_map,    // Constant registers to reserve
    input logic rsv_valid,                                // Valid signal for reserve operation
    input logic [NUM_CONSTANT_REGS-1:0] wb_const_bitmap,  // Constant registers to release
    input logic wb_valid,                                 // Write-back valid signal
    
    // Output signals
    output logic collision                                // Collision detection result
);

    // Internal storage - single entry for all threads since constants are shared
    logic [NUM_CONSTANT_REGS-1:0] pending_constants;
    
    // Update logic for pending constants register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pending_constants <= {NUM_CONSTANT_REGS{1'b0}};  // Clear all pending bits
        end else begin
            // Apply reservation and write-back updates only when valid
            if (wb_valid && rsv_valid) begin
                // Both write-back and reserve: apply both operations
                pending_constants <= (pending_constants | rsv_const_map) & (~wb_const_bitmap);
            end else if (wb_valid) begin
                // Only write-back: release completed constants
                pending_constants <= pending_constants & (~wb_const_bitmap);
            end else if (rsv_valid) begin
                // Only reserve: add new pending constants
                pending_constants <= pending_constants | rsv_const_map;
            end
            // If neither valid, no change to pending_constants
        end
    end
    
    // Collision detection - check if any requested constant is already pending
    always_comb begin
        if (rd_valid) begin
            logic [NUM_CONSTANT_REGS-1:0] collision_check;
            
            // Bitwise AND between pending constants and input constant map
            collision_check = pending_constants & input_const_map;
            
            // Collision occurs if any bit is set
            collision = |collision_check;
        end else begin
            // No collision when read is not valid
            collision = 1'b0;
        end
    end

endmodule
module simt_stack #(
    parameter STACK_DEPTH = 32,
    parameter PC_WIDTH = 32,
    parameter THREAD_WIDTH = 256,
    parameter STACK_INDEX_WIDTH = $clog2(STACK_DEPTH)
)(
    input logic clk,
    input logic rst_n,
    
    // Push interface (can also modify top when modify_top is asserted)
    input logic push,
    input logic modify_top,  // When 1, don't increment stack, just update top
    input logic [PC_WIDTH-1:0] push_next_pc,
    input logic [PC_WIDTH-1:0] push_reconvergence_pc,
    input logic [THREAD_WIDTH-1:0] push_active_mask,
    
    // Pop interface
    input logic pop,
    
    // Read top interface
    input logic read_top,  // Request to read top of stack
    
    // Stack top outputs (registered - valid next cycle after read_top)
    output logic [PC_WIDTH-1:0] top_next_pc,
    output logic [PC_WIDTH-1:0] top_reconvergence_pc,
    output logic [THREAD_WIDTH-1:0] top_active_mask,
    output logic out_valid,  // Indicates top outputs are valid
    
    // Stack status outputs
    output logic stack_empty,
    output logic stack_full
);

    // Constants
    localparam ENTRY_WIDTH = PC_WIDTH + PC_WIDTH + THREAD_WIDTH;
    
    // Stack pointer (0 = empty, points to top of stack + 1)
    logic [STACK_INDEX_WIDTH:0] stack_ptr;  // Extra bit to represent STACK_DEPTH
    
    // Output valid register
    logic out_valid_reg;
    
    // RAM interface signals
    logic ram_wr_en, ram_rd_en;
    logic [STACK_INDEX_WIDTH-1:0] ram_wr_addr, ram_rd_addr;
    logic [ENTRY_WIDTH-1:0] ram_wr_data, ram_rd_data;
    
    // Pack/unpack functions for RAM data
    function [ENTRY_WIDTH-1:0] pack_entry(
        input logic [PC_WIDTH-1:0] next_pc,
        input logic [PC_WIDTH-1:0] reconvergence_pc,
        input logic [THREAD_WIDTH-1:0] active_mask
    );
        return {next_pc, reconvergence_pc, active_mask};
    endfunction
    
    function logic [PC_WIDTH-1:0] unpack_next_pc(input [ENTRY_WIDTH-1:0] entry);
        return entry[ENTRY_WIDTH-1:PC_WIDTH+THREAD_WIDTH];
    endfunction
    
    function logic [PC_WIDTH-1:0] unpack_reconvergence_pc(input [ENTRY_WIDTH-1:0] entry);
        return entry[PC_WIDTH+THREAD_WIDTH-1:THREAD_WIDTH];
    endfunction
    
    function logic [THREAD_WIDTH-1:0] unpack_active_mask(input [ENTRY_WIDTH-1:0] entry);
        return entry[THREAD_WIDTH-1:0];
    endfunction
    
    // Instantiate DICE RAM for stack entries
`ifndef NO_SRAM
    sram_0rw1r1w_320_32_freepdk45 stack_ram (
        .clk0(clk),
        .csb0(~ram_wr_en),
        .addr0(ram_wr_addr),
        .din0(ram_wr_data),
        .clk1(clk),
        .csb1(~ram_rd_en),
        .addr1(ram_rd_addr),
        .dout1(ram_rd_data)
    );

`else
    dice_ram_1w1r #(
        .DATA_WIDTH(ENTRY_WIDTH),
        .DEPTH(STACK_DEPTH)
    ) stack_ram (
        .clk(clk),
        .wr_en(ram_wr_en),
        .wr_addr(ram_wr_addr),
        .wr_data(ram_wr_data),
        .rd_en(ram_rd_en),
        .rd_addr(ram_rd_addr),
        .rd_data(ram_rd_data)
    );
`endif
    // Stack status
    assign stack_empty = (stack_ptr == 0);
    assign stack_full = (stack_ptr == STACK_DEPTH);
    
    // Top of stack outputs - directly from RAM (registered)
    assign top_next_pc = unpack_next_pc(ram_rd_data);
    assign top_reconvergence_pc = unpack_reconvergence_pc(ram_rd_data);
    assign top_active_mask = unpack_active_mask(ram_rd_data);
    assign out_valid = out_valid_reg;
    
    // Control logic for RAM operations
    always_comb begin
        // Default values
        ram_wr_en = 1'b0;
        ram_rd_en = 1'b0;
        ram_wr_addr = '0;
        ram_rd_addr = '0;
        ram_wr_data = '0;
        
        if (push && !stack_full) begin
            if (modify_top && stack_ptr > 0) begin
                // Modify top: write to current top location
                ram_wr_en = 1'b1;
                ram_wr_addr = stack_ptr - 1;
                ram_wr_data = pack_entry(push_next_pc, push_reconvergence_pc, push_active_mask);
            end else if (!modify_top) begin
                // Normal push: write to next location
                ram_wr_en = 1'b1;
                ram_wr_addr = stack_ptr;
                ram_wr_data = pack_entry(push_next_pc, push_reconvergence_pc, push_active_mask);
            end
        end
        
        // Read top of stack when requested
        if (read_top && stack_ptr > 0) begin
            ram_rd_en = 1'b1;
            ram_rd_addr = stack_ptr - 1;  // Top of stack
        end
    end
    
    // Sequential logic for stack pointer management and output valid
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stack_ptr <= '0;
            out_valid_reg <= 1'b0;
            
        end else begin
            // Handle stack pointer updates
            if (push && !stack_full && !modify_top) begin
                // Normal push: increment stack pointer
                stack_ptr <= stack_ptr + 1;
                
            end else if (pop && !stack_empty) begin
                // Pop: decrement stack pointer
                stack_ptr <= stack_ptr - 1;
            end
            // modify_top doesn't change stack_ptr
            
            // Handle output valid - becomes valid one cycle after read_top
            if (read_top && stack_ptr > 0) begin
                out_valid_reg <= 1'b1;
            end else begin
                out_valid_reg <= 1'b0;
            end
        end
    end
    
    // Assertions for debugging
    `ifndef SYNTHESIS
    always @(posedge clk) begin
        if (rst_n) begin
            if (push && stack_full) begin
                $error("SIMT Stack overflow: trying to push when stack is full");
            end
            if (pop && stack_empty) begin
                $error("SIMT Stack underflow: trying to pop empty stack");
            end
            if (modify_top && stack_empty) begin
                $error("SIMT Stack: trying to modify top of empty stack");
            end
        end
    end
    `endif

endmodule
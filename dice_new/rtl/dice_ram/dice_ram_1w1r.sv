// 1 Write 1 Read RAM - Separate read and write ports
module dice_ram_1w1r #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 1024,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input logic clk,
    
    // Write port
    input logic wr_en,
    input logic [ADDR_WIDTH-1:0] wr_addr,
    input logic [DATA_WIDTH-1:0] wr_data,
    
    // Read port
    input logic rd_en,
    input logic [ADDR_WIDTH-1:0] rd_addr,
    output logic [DATA_WIDTH-1:0] rd_data
);

    // RAM storage array
    logic [DATA_WIDTH-1:0] ram_array [DEPTH-1:0];
    logic [DATA_WIDTH-1:0] rd_data_reg;
    
    assign rd_data = rd_data_reg;
    
    // Write operation
    always_ff @(posedge clk) begin
        if (wr_en) begin
            ram_array[wr_addr] <= wr_data;
        end
    end
    
    // Read operation
    always_ff @(posedge clk) begin
        if (rd_en) begin
            rd_data_reg <= ram_array[rd_addr];
        end
    end

endmodule
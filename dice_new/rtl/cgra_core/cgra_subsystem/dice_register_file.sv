module dice_register_file #(
    parameter int NUM_BANK = 4,
    parameter int WIDTH = 32,
    parameter int DEPTH = 512,
    parameter int ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic              clk,
    input  logic              rst_n,
    // Read port
    input  logic [NUM_BANK-1:0]    rd_en,
    input  logic [NUM_BANK*ADDR_WIDTH-1:0] rd_addr,
    output logic [NUM_BANK*WIDTH-1:0] rd_data,
    // Write port
    input  logic [NUM_BANK-1:0]    wr_en,
    input  logic [NUM_BANK*ADDR_WIDTH-1:0] wr_addr,
    input  logic [NUM_BANK*WIDTH-1:0] wr_data
);

    genvar i;
    generate
        for (i = 0; i < NUM_BANK; i++) begin : gen_bank
            simple_ram #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH)
            ) bank_ram (
                .clk     (clk),
                .wr_en   (wr_en[i]),
                .wr_addr (wr_addr[(i+1)*ADDR_WIDTH-1:i*ADDR_WIDTH]),
                .wr_data (wr_data[(i+1)*WIDTH-1:i*WIDTH]),
                .rd_en   (rd_en[i]),
                .rd_addr (rd_addr[(i+1)*ADDR_WIDTH-1:i*ADDR_WIDTH]),
                .rd_data (rd_data[(i+1)*WIDTH-1:i*WIDTH])
            );
        end
    endgenerate

endmodule
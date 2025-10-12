// simple_ram.sv
module simple_ram #(
  parameter WIDTH = 32,
  parameter DEPTH = 512,
  parameter ADDR_WIDTH = $clog2(DEPTH)
)(
  input  logic              clk,
  // Write
  input  logic              wr_en,
  input  logic [ADDR_WIDTH-1:0] wr_addr,
  input  logic [WIDTH-1:0]  wr_data,
  // Read
  input  logic              rd_en,
  input  logic [ADDR_WIDTH-1:0] rd_addr,
  output logic [WIDTH-1:0]  rd_data
);

  logic [WIDTH-1:0] mem [0:DEPTH-1];

  always_ff @(posedge clk) begin
    if (wr_en)
      mem[wr_addr] <= wr_data;
  end

  always @(posedge clk) begin
    if (rd_en)
      rd_data = mem[rd_addr];
  end

  // Optional initialization for simulation
  initial begin
    for (int i = 0; i < DEPTH; i++)
      mem[i] = '0;
  end
endmodule

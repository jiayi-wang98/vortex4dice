module bh_fifo 
  import dice_frontend_pkg::*;
#(
  parameter int unsigned DEPTH  = 16
) (
  input  logic                  clk_i,
  input  logic                  rst_i,

  input  logic                  push_i,
  input  logic                  pop_i,
  input  branch_info_t          data_i,

  output branch_info_t          data_o,
  output logic                  full_o,
  output logic                  empty_o
);

  // Memory array
  branch_info_t mem [DEPTH];
  
  // Read/write pointers
  logic [$clog2(DEPTH)-1:0] rd_ptr;
  logic [$clog2(DEPTH)-1:0] wr_ptr;
  logic [$clog2(DEPTH):0]   count;
  
  // Status signals
  assign empty_o = (count == 0);
  assign full_o  = (count == DEPTH);
  assign data_o  = mem[rd_ptr];
  
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      rd_ptr <= '0;
      wr_ptr <= '0;
      count  <= '0;
    end else begin
      // Handle push
      if (push_i && !full_o) begin
        mem[wr_ptr] <= data_i;
        wr_ptr <= (wr_ptr + 1) % DEPTH;
        count <= count + 1;
      end
      
      // Handle pop
      if (pop_i && !empty_o) begin
        rd_ptr <= (rd_ptr + 1) % DEPTH;
        count <= count - 1;
      end
    end
  end

endmodule

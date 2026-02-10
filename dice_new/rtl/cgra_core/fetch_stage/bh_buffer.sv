module bh_buffer
  import dice_frontend_pkg::*;
  import dice_pkg::*;
  #(
    parameter DATA_WIDTH = 32
  )
  (
    input  logic                                     clk_i,
    input  logic                                     rst_i,

    input  logic [DATA_WIDTH-1:0]                    data_in_i,
    input  logic [TID_WIDTH-1:0]                     tid_offset_i,
    input  logic                                     valid_in_i,
    output logic                                     ready_in_o,



    output logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] pred_out_o,
    output logic                                     valid_out_o,
    input  logic                                     ready_out_i
  );

  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] pred_buffer;


  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      pred_buffer <= '0;
    end else begin
      if (valid_in_i && ready_in_o) begin
        pred_buffer[tid_offset_i:tid_offset_i+DATA_WIDTH-1] <= data_in_i;
      end
    end
  end


endmodule

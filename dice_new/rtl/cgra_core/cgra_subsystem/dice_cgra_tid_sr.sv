module dice_cgra_tid_sr #(
    parameter int TOTAL_TID   = 512,
    parameter int TID_WIDTH   = $clog2(TOTAL_TID),
    parameter int MAX_LATENCY = 32
)(
    input  logic                             clk,
    input  logic                             rst_n,
    // latency control
    input  logic                             clr,   // flush pipe
    input  logic [$clog2(MAX_LATENCY+1)-1:0] latency,

    input  logic [TID_WIDTH-1:0]             in_tid,
    input  logic                             in_valid,

    output logic [TID_WIDTH-1:0]            out_tid,
    output logic                            out_valid
);

  //-------------------------------
  // Latency shifter
  //-------------------------------
  latency_pipe #(
    .WIDTH(TID_WIDTH+1),
    .MAX_PIPE_STAGE(MAX_LATENCY)
  ) tid_sr_pipe_inst (
    .clk      (clk),
    .rst_n    (rst_n),
    .clr      (clr),
    .latency  (latency),
    .in_data  ({in_valid, in_tid}),    // valid as MSB
    .out_data ({out_valid, out_tid})
  );

endmodule

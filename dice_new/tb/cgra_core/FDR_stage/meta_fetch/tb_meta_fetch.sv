`timescale 1ns/1ps

import frontend_pkg::*;

module tb_meta_fetch;

  localparam int PC_WIDTH   = 32;
  localparam int ADDR_WIDTH = 32;

  logic                   clk;
  logic                   rst_n;

  logic                   schedule_valid;
  logic [PC_WIDTH-1:0]    pc;
  logic                   fetch_ready;

  logic                   req_ready;
  logic                   req_valid;
  logic [ADDR_WIDTH-1:0]  req_addr;

  logic                   resp_valid;
  logic                   resp_ready;
  pgraph_meta_t           incoming_meta;

  pgraph_meta_t           outgoing_meta;
  logic                   meta_valid;
  logic                   decode_ready;

  meta_fetch #(
    .PC_WIDTH   (PC_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
  ) dut (
    .clk           (clk),
    .rst_n         (rst_n),
    .schedule_valid(schedule_valid),
    .pc            (pc),
    .fetch_ready   (fetch_ready),
    .req_ready     (req_ready),
    .req_valid     (req_valid),
    .req_addr      (req_addr),
    .resp_valid    (resp_valid),
    .resp_ready    (resp_ready),
    .incoming_meta (incoming_meta),
    .outgoing_meta (outgoing_meta),
    .meta_valid    (meta_valid),
    .decode_ready  (decode_ready)
  );

  //TO SHOW WAVEFORMS
   initial begin
      //dump fsdb
      $fsdbDumpfile("tb_meta_fetch.fsdb");
      $fsdbDumpvars(“+all”);
    end


  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n          = 1'b0;
    schedule_valid = 1'b0;
    pc             = '0;
    req_ready      = 1'b0;
    resp_valid     = 1'b0;
    incoming_meta  = '0;
    decode_ready   = 1'b0;

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst_n = 1'b1;

    @(posedge clk);

    pc = 32'h0000_1000;
    schedule_valid = 1'b1;
    @(posedge clk);
    schedule_valid = 1'b0;

    req_ready = 1'b1;

    wait (req_valid == 1'b1);
    @(posedge clk);

    incoming_meta = '1;
    resp_valid    = 1'b1;
    @(posedge clk);
    resp_valid    = 1'b0;

    decode_ready = 1'b1;

    wait (meta_valid == 1'b1);
    @(posedge clk);
    decode_ready = 1'b0;

    repeat (5) @(posedge clk);
    $finish;
  end

endmodule

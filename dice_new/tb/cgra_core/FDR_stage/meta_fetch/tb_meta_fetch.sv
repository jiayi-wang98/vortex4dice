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
      $fsdbDumpvars("+all");
    end


  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
  // initialize
  rst_n          = 1'b0;
  schedule_valid = 1'b0;
  pc             = '0;
  req_ready      = 1'b0;
  resp_valid     = 1'b0;
  incoming_meta  = '0;
  decode_ready   = 1'b0;

  // reset sequence
  repeat (3) @(posedge clk);
  rst_n = 1'b1;
  $display("[%0t] Reset deasserted", $time);

  @(posedge clk);
  decode_ready   = 1'b1;
  pc             = 32'h0000_1000;
  schedule_valid = 1'b1;
  $display("[%0t] Sent schedule_valid with pc = %h", $time, pc);

  @(posedge clk);
  schedule_valid = 1'b0;

  req_ready = 1'b1;
  $display("[%0t] req_ready asserted", $time);

  wait (req_valid);
  $display("[%0t] req_valid observed, req_addr = %h", $time, req_addr);
  @(posedge clk);

  incoming_meta = '1;
  resp_valid    = 1'b1;
  $display("[%0t] resp_valid asserted, incoming_meta = %h",
            $time, incoming_meta);

  @(posedge clk);
  resp_valid = 1'b0;

  wait (meta_valid);
  $display("[%0t] meta_valid observed, outgoing_meta = %h",
            $time, outgoing_meta);

  @(posedge clk);
  decode_ready = 1'b0;

  repeat (5) @(posedge clk);
  $display("[%0t] Test finished", $time);
  $finish;
end


endmodule

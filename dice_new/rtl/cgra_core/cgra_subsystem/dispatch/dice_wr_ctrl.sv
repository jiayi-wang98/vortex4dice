`include "bsg_fifo_1r1w_small.sv"
`include "DE_pkg.sv"

import DE_pkg::*;

module dice_wr_ctrl #
(
      parameter WIDTH =  32
    , parameter DEPTH = 512
    , parameter ADDR_WIDTH = $clog2(width)
) 
(
      input logic         clk
    , input logic         reset

    // wr req from LDST and CGRA
    , input reg_wr_cmd   wr_cmd_cgra
    , input reg_wr_cmd   wr_cmd_ldst

    // forwarding for read
    , input reg_rd_cmd fw_req
    
    // stall from either buffer
    , output logic       stall
    // forwarding flags for each entry in buffer
    , output logic[7:0]         fw_hit_cgra
    , output logic[7:0]         fw_hit_ldst
    , output logic[WIDTH-1:0]   fw_data

    // signals out to register file
    , output logic[ADDR_WIDTH-1:0]   ws
    , output logic[WIDTH-1:0]        data
    , output logic                   we
);


// two buffers with forwarding flags for each entry. starting with 8 entries










    
endmodule
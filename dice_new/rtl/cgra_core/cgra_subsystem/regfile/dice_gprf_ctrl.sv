`include "DE_pkg.sv"
`include "dice_pkg.sv"



module dice_gprf_ctrl

import DE_pkg::*;
import dice_pkg::*;

#(
    parameter int NUM_PORTS = DICE_NUM_BANKS,
    parameter int DATA_WIDTH = DICE_REG_DATA_WIDTH,
    parameter int NUM_TID = 512,
    parameter int TID_WIDTH = $clog2(NUM_TID),
    parameter int DEPTH = NUM_TID,
    parameter int ADDR_WIDTH = $clog2(DEPTH)
)
(
      input  logic              clk_i
    , input  logic              reset_i

    // Read Input
    // take anywhere from 1 to 4 tids
    // take one bitmap
    // send to a new module called called read_org

    // valid ready for tid and bitmap
    , input logic                             rd_tid_valid_i
    , output logic                            rd_tid_ready_i


    , input logic [NUM_PORTS-1:0]        rd_en_i
    , input logic [(4*RF_ADDR_WIDTH)-1:0]     rd_tid_i
    , input logic [NUM_PORTS-1:0]             rd_bitmap_i
    , output logic [NUM_PORTS*DATA_WIDTH-1:0] rd_data_o


    // Write Input
    // ldst unit will give me write packets packaged by bank!
    , input reg_wr_cmd [NUM_PORTS-1:0]      cgra_wr_i
    , input logic                           cgra_valid_i
    , output logic                          cgra_ready_o
    
    , input reg_wr_cmd [NUM_PORTS-1:0]      ldst_wr_i
    , input logic                           ldst_valid_i
    , output logic                          ldst_ready_o
);

    logic [NUM_PORTS-1] rd_en;
    logic [NUM_PORTS*ADDR_WIDTH-1:0] rd_addr;
    logic [NUM_PORTS*DATA_WIDTH-1:0] rd_data;

    // Write port
    logic [NUM_BANK-1:0]    wr_en;
    logic [NUM_BANK*ADDR_WIDTH-1:0] wr_addr;
    logic [NUM_BANK*DATA_WIDTH-1:0] wr_data;

    dice_register_file#
    (
        .NUM_BANK   (NUM_PORTS)
        , .WIDTH      (DATA_WIDTH)
        , .DEPTH      (DEPTH)
        , .ADDR_WIDTH (ADDR_WIDTH)
    ) registers (
          .clk (clk_i)

        , .rd_en   (rd_en)
        , .rd_addr (rd_addr)
        , .rd_data (rd_data)

        , .wr_en   (wr_en)
        , .wr_addr (wr_addr)
        , .wr_data (wr_data)
    );



    genvar i;

    generate
        for (i = 0;  i < NUM_PORTS; i++) begin
            dice_wr_ctrl_bank#
            (
                  .WIDTH(DATA_WIDTH)
                , .
            ) u_wr_ctrl (
            );

            dice_rd_ctrl_bank#
            (
            ) w_rd_ctrl (
            );



        end
    endgenerate







endmodule

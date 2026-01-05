`include "DE_pkg.sv"
`include "dice_pkg.sv"


import DE_pkg::*;
import dice_pkg::*;

module dice_gprf_ctrl #(
    parameter int NUM_PORTS = DICE_NUM_BANKS,
    parameter int DATA_WIDTH = DICE_REG_DATA_WIDTH,
    parameter int NUM_TID = 512,
    parameter int DEPTH = NUM_TID,
    parameter int ADDR_WIDTH = $clog2(DEPTH)
)
(
      input  logic              clk_i
    , input  logic              reset_i

    // Read Input
    , input reg_rd_cmd [NUM_PORTS-1:0]        rd_i
    , output logic [NUM_PORTS*DATA_WIDTH-1:0] rd_data_o
    // Write Input
    , input   reg_wr_cmd [NUM_PORTS-1:0]      wr_i
    , input  logic [NUM_PORTS*DATA_WIDTH-1:0] wr_data
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
            ) u_wr_ctrl (
            );

            dice_rd_ctrl_bank#
            (
            ) w_rd_ctrl (
            );



        end
    endgenerate







endmodule

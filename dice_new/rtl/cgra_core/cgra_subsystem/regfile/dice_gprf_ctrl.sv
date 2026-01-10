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
    , output logic                            rd_tid_ready_o

    // some signal for unrolling factor to select
    , input logic                             rd_en_i
    , input logic [(4*TID_WIDTH)-1:0]         rd_tid_i
    , input logic [NUM_PORTS-1:0]             rd_bitmap_i
    , output logic [NUM_PORTS*DATA_WIDTH-1:0] rd_data_o


    // Write Input
    // ldst unit will give me write packets packaged by bank!
    , input reg_wr_cmd [NUM_PORTS-1:0]      cgra_wr_i
    , input logic                           cgra_valid_i

    , input reg_wr_cmd [NUM_PORTS-1:0]      ldst_wr_i
    , input logic                           ldst_valid_i
    , output logic                          ldst_ready_o
);

    logic [NUM_PORTS-1] rf_rd_en;
    logic [NUM_PORTS*ADDR_WIDTH-1:0] rf_rd_addr;
    logic [NUM_PORTS*DATA_WIDTH-1:0] rf_rd_data;

    // Write port
    logic [NUM_BANK-1:0]    rf_wr_en;
    logic [NUM_BANK*ADDR_WIDTH-1:0] rf_wr_addr;
    logic [NUM_BANK*DATA_WIDTH-1:0] rf_wr_data;


    // wr arbitration signals 
    logic [7:0] fw_hit_cgra;
    logic [7:0] fw_hit_ldst;
    logic [NUM_PORTS*DATA_WIDTH-1:0] fw_data;





    genvar i;

    
    
    generate
        for (i = 0;  i < NUM_PORTS; i++) begin
            dice_wr_ctrl_bank#
            (
                  .WIDTH(DATA_WIDTH)
                , .DEPTH (DEPTH)
                , .ADDR_WIDTH (ADDR_WIDTH)
                , .BUF_DEPTH (BUF_DEPTH)
            ) u_wr_ctrl (
                .clk_i (clk_i)
                , .reset_i (reset_i)
                , .wr_cgra_i (cgra_wr_i[i])
                , .cgra_valid_i (cgra_valid_i)
                , .wr_ldst_i (ldst_wr_i[i])
                , .ldst_valid_i (ldst_valid_i)
                , .fw_req_i (fw_req_i)
                , .stall_o (stall_o)
                , .fw_hit_cgra_o (fw_hit_cgra[i])
                , .fw_hit_ldst_o (fw_hit_ldst[i])
                , .fw_data_o (fw_data[i*DATA_WIDTH +: DATA_WIDTH])
                , .ws_o (rf_wr_addr[i*ADDR_WIDTH +: ADDR_WIDTH])
                , .data_o (rf_wr_data[i*DATA_WIDTH +: DATA_WIDTH])
                , .we_o (rf_wr_en[i])
            );

            dice_rd_ctrl_bank#
            (
                .WIDTH (DATA_WIDTH)
                , .DEPTH (DEPTH)
                , .ADDR_WIDTH (ADDR_WIDTH)
            ) w_rd_ctrl (
                .clk_i (clk_i)
                , .reset_i (reset_i)
                , .reg_data_i (rf_rd_data[i*DATA_WIDTH +: DATA_WIDTH])
                , .fw_data_i (fw_data[i*DATA_WIDTH +: DATA_WIDTH])
                , .fw_valid_i (fw_hit_cgra[i] || fw_hit_ldst[i])
                , .data_o (rd_data_o[i*DATA_WIDTH +: DATA_WIDTH])
            );



        end
    endgenerate

    
    dice_read_org#
    (
        .NUM_PORTS (NUM_PORTS)
        , .DATA_WIDTH (DATA_WIDTH)
        , .NUM_TID (NUM_TID)
        , .TID_WIDTH (TID_WIDTH)
        , .DEPTH (DEPTH)
        , .ADDR_WIDTH (ADDR_WIDTH)
    ) read_org (
        .clk_i (clk_i)
        , .reset_i (reset_i)
        , .rd_tid_valid_i (rd_tid_valid_i)
        , .rd_tid_ready_o (rd_tid_ready_o)
        //  TODO: eventually we will add support for multiple tids with an unrolling factor input
        , .rd_en_i (rd_en_i)
        , .rd_tid_i (rd_tid_i)
        , .rd_bitmap_i (rd_bitmap_i)
        , .rd_sel_o (rf_rd_addr)
        , .rd_valid_o (rf_rd_en)
    );

    

    dice_register_file#
    (
        .NUM_BANK   (NUM_PORTS)
        , .WIDTH      (DATA_WIDTH)
        , .DEPTH      (DEPTH)
        , .ADDR_WIDTH (ADDR_WIDTH)
    ) registers (
          .clk (clk_i)

        , .rd_en   (rf_rd_en)
        , .rd_addr (rf_rd_addr)
        , .rd_data (rf_rd_data)

        , .wr_en   (rf_wr_en)
        , .wr_addr (rf_wr_addr)
        , .wr_data (rf_wr_data)
    );





endmodule

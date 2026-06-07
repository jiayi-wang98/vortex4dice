`include "DE_pkg.sv"
`include "dice_pkg.sv"



module dice_rf_ctrl

import DE_pkg::*;
import dice_pkg::*;

#(
    parameter int NUM_PORTS = DICE_NUM_BANKS,
    parameter int DATA_WIDTH = DICE_REG_DATA_WIDTH,
    parameter int NUM_TID = 512,
    parameter int TID_WIDTH = $clog2(NUM_TID),
    parameter int DEPTH = NUM_TID,
    parameter int ADDR_WIDTH = $clog2(DEPTH),
    parameter int NUM_SPECIAL_REG = 16,
    parameter int MAX_CTA_ID = 65535,
    parameter int CTA_ID_WIDTH = $clog2(MAX_CTA_ID),
    parameter int BUF_DEPTH = 8,
    // Per-slice blockIdx table depth + slice id width for dice_special_reg. The
    // upper HW_CTA_ID_WIDTH bits of a TID select which co-scheduled CTA slice
    // owns the read; the frontend loads one slice's blockIdx per cycle.
    parameter int MAX_CTA_PER_CORE = DICE_NUM_MAX_CTA_PER_CORE,
    parameter int HW_CTA_ID_WIDTH  = (MAX_CTA_PER_CORE > 1) ? $clog2(MAX_CTA_PER_CORE) : 1
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
    , input logic [1:0]                       rd_unroll_factor_i
    , input logic                             rd_en_i
    , input logic [(4*TID_WIDTH)-1:0]         rd_tid_i
    , input logic [NUM_PORTS-1:0]             rd_bitmap_i
    , output logic [NUM_PORTS*DATA_WIDTH-1:0] rd_data_o
    , output logic                            rf_rd_valid_o
    // TODO: add v_o signal for cgra, so when rf_v_o and disp_v_o, compute

    // -----------------------------------------------------------------------
    // RETIRE / COMMIT passthrough (additive). Latched with the read launch on
    // rd_tid_valid_i and replayed on the launch side so the CGRA writeback /
    // commit path can attribute results to the right thread + e-block. The
    // existing 1-way sim path leaves these unconnected (defaults to 0/sentinel).
    // -----------------------------------------------------------------------
    , output logic [TID_WIDTH-1:0]                          tid_o
    , input  logic [EBLOCK_ID_W-1:0]                        e_block_id_i
    , output logic [EBLOCK_ID_W-1:0]                        e_block_id_o
    , input  logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] ld_dest_regs_i
    , input  logic [$clog2(NUM_MEM_PORTS+1)-1:0]            num_stores_i
    , output logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] ld_dest_regs_o
    , output logic [$clog2(NUM_MEM_PORTS+1)-1:0]            num_stores_o

    // CONST read path for the fabric lane map. Registered to match the 1-cycle
    // GPR/special read latency. dice_core concatenates this with GPR banks 0..15
    // to build the 24-lane launch bus = {GPR[0..15], Const[0..7]}.
    , output logic [DICE_NUM_CONST*DATA_WIDTH-1:0]          rd_const_data_o

    // LOAD-RETIRE outputs (per-bank GPR + special). Assert when a writeback FIFO
    // pops; carry the popped writeback's e-block id for the commit/retire table.
    , output logic [NUM_PORTS-1:0]                          ldst_pop_o
    , output logic [NUM_PORTS-1:0][EBLOCK_ID_W-1:0]         ldst_pop_e_block_id_o
    , output logic                                          ldst_special_pop_o
    , output logic [EBLOCK_ID_W-1:0]                        ldst_special_pop_e_block_id_o
    , output logic                                          ldst_special_ready_o


    // Write Input
    // ldst unit will give me write packets packaged by bank!
    , input logic [(4*TID_WIDTH)-1:0]           cgra_tid_i
    , input logic [(NUM_PORTS*DATA_WIDTH)-1:0]  cgra_data_i
    , input logic [NUM_PORTS-1:0]               wr_bitmap_i
    , input logic                               cgra_valid_i

    , input cache_wr_cmd                    ldst_wr_i
    , input logic                           ldst_valid_i
    , output logic                          ldst_ready_o


    // Constant registers, supplied per-launch; feed the fabric's const lanes via
    // rd_const_data_o (below). The special registers (threadIdx / blockIdx /
    // blockDim / gridDim) are now consumed DIRECTLY by the regenerated CGRA fabric
    // (dedicated dice_top inputs), so dice_special_reg and its select / per-slice /
    // out_data ports were removed from this RF.
    , input logic [NUM_SPECIAL_REG*DATA_WIDTH-1:0] const_reg_i
);

    logic [NUM_PORTS-1:0] rf_rd_en;
    logic [NUM_PORTS*ADDR_WIDTH-1:0] rf_rd_addr;
    logic [NUM_PORTS*DATA_WIDTH-1:0] rf_rd_data;

    // Write port
    logic [NUM_PORTS-1:0]    rf_wr_en;
    logic [NUM_PORTS*ADDR_WIDTH-1:0] rf_wr_addr;
    logic [NUM_PORTS*DATA_WIDTH-1:0] rf_wr_data;


    // wr arbitration signals 
    // logic [NUM_PORTS*7:0] fw_hit_cgra;
    // logic [NUM_PORTS*7:0] fw_hit_ldst;
    // logic [NUM_PORTS*DATA_WIDTH-1:0] fw_data;

    // logic [NUM_PORTS*DICE_TID_WIDTH-1:0] fw_req_i;

    logic [NUM_PORTS-1:0] stall_o;

    assign ldst_ready_o = ~(|stall_o);

    // assign fw_req_i = rf_rd_addr;

    reg_wr_cmd cgra_wr_li [NUM_PORTS-1:0];

    logic [NUM_PORTS-1:0] wr_bitmap_r;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            wr_bitmap_r <= '0;
        end else begin
            wr_bitmap_r <= wr_bitmap_i;
        end
    end


    genvar i;
    generate 
        for (i = 0; i < NUM_PORTS; i++) begin
            assign cgra_wr_li[i].data = cgra_data_i[i*DATA_WIDTH +: DATA_WIDTH];
            assign cgra_wr_li[i].mask = wr_bitmap_r[i];
            // Only assign the lowest TID from the cgra_tid_i bus (corresponds to the lowest bits)
            // no unrolling factor for now
            assign cgra_wr_li[i].tid = cgra_tid_i[0 +: TID_WIDTH];
            // CGRA writes do not carry an e-block id (only LDST writebacks retire).
            assign cgra_wr_li[i].e_block_id = '0;
        end
    endgenerate

    ldst_wr_cmd [NUM_PORTS-1:0] ldst_wr_li;

    assign ldst_wr_li = unpack_ldsr_wr(assemble_ldst_wr(ldst_wr_i));
    
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

                , .cgra_wr_i (cgra_wr_li[i])
                , .cgra_valid_i (cgra_valid_i)
                ,.cgra_ready_o ()

                , .wr_ldst_i (ldst_wr_li[i])
                , .ldst_valid_i (ldst_valid_i)

                // , .fw_req_i (fw_req_i[i*DICE_TID_WIDTH +: DICE_TID_WIDTH])

                , .stall_o (stall_o[i])

                // , .fw_hit_cgra_o (fw_hit_cgra[i*8 +: 8])
                // , .fw_hit_ldst_o (fw_hit_ldst[i*8 +: 8])
                // , .fw_data_o (fw_data[i*DATA_WIDTH +: DATA_WIDTH])

                , .ldst_pop_o (ldst_pop_o[i])
                , .ldst_pop_e_block_id_o (ldst_pop_e_block_id_o[i])

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
                // , .fw_data_i (fw_data[i*DATA_WIDTH +: DATA_WIDTH])
                // , .fw_valid_i ('0) // no forwarding for now
                , .data_o (rd_data_o[i*DATA_WIDTH +: DATA_WIDTH])
            );



        end
    endgenerate

    // dice_special_reg removed: the CGRA fabric now takes threadIdx / blockIdx /
    // blockDim / gridDim on dedicated inputs, so the per-special-reg select mux
    // (and per-slice blockIdx table) here was redundant.


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

        , .rd_unroll_factor_i (rd_unroll_factor_i)
        , .rd_en_i (rd_en_i)
        , .rd_tid_i (rd_tid_i)
        , .rd_bitmap_i (rd_bitmap_i)

        , .rd_sel_o (rf_rd_addr)
        , .rd_en_o (rf_rd_en)
        , .rd_valid_o (rf_rd_valid_o)
    );

    

    dice_register_file
     registers (
          .clk (clk_i)

        , .rd_addr (rf_rd_addr)
        , .rd_data (rf_rd_data)

        , .wr_en   (shift_bitmap(rf_wr_en, rf_wr_addr[0 +: TID_WIDTH]))
        , .wr_addr (rf_wr_addr)
        , .wr_data (rf_wr_data)
    );

    // =====================================================================
    // CONST read path for the fabric lane map.
    // The 8 constant registers are supplied per-launch on const_reg_i (the
    // lower DICE_NUM_CONST of NUM_SPECIAL_REG feed the const path). Register
    // them on rd_tid_valid_i so rd_const_data_o lines up with the 1-cycle
    // GPR read latency (mirror Mini_Dice's const_rd_r).
    // =====================================================================
    logic [DICE_NUM_CONST-1:0][DATA_WIDTH-1:0] const_rd_r;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            const_rd_r <= '0;
        end else if (rd_tid_valid_i) begin
            for (int j = 0; j < DICE_NUM_CONST; j++) begin
                const_rd_r[j] <= const_reg_i[j*DATA_WIDTH +: DATA_WIDTH];
            end
        end
    end

    generate
        for (i = 0; i < DICE_NUM_CONST; i++) begin : gen_const_rd
            assign rd_const_data_o[i*DATA_WIDTH +: DATA_WIDTH] = const_rd_r[i];
        end
    endgenerate

    // =====================================================================
    // RETIRE / COMMIT metadata passthrough.
    // Latch the launch metadata when a read is issued and replay it on the
    // launch side, so the registered launch data and metadata stay aligned
    // (mirror Mini_Dice dice_rf_ctrl). tid_o uses the lowest dispatched TID.
    // =====================================================================
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            tid_o        <= '0;
            e_block_id_o <= '0;
            num_stores_o <= '0;
            for (int j = 0; j < NUM_MEM_PORTS; j++) begin
                ld_dest_regs_o[j] <= DICE_REG_ADDR_WIDTH'(31);
            end
        end else if (rd_tid_valid_i) begin
            tid_o          <= rd_tid_i[0 +: TID_WIDTH];
            e_block_id_o   <= e_block_id_i;
            num_stores_o   <= num_stores_i;
            ld_dest_regs_o <= ld_dest_regs_i;
        end
    end

    // =====================================================================
    // Special-register (const) LOAD-RETIRE outputs.
    // In dice_new the const/special regs are driven directly from const_reg_i /
    // dice_special_reg, not from an LDST writeback FIFO, so there is no special
    // writeback to pop. Tie off with defined defaults: always ready, never pops.
    // =====================================================================
    assign ldst_special_pop_o            = 1'b0;
    assign ldst_special_pop_e_block_id_o = '0;
    assign ldst_special_ready_o          = 1'b1;





endmodule

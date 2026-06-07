`include "DE_pkg.sv"
`include "dice_pkg.sv"

// =============================================================================
// dice_pred_rf : SRAM-banked predicate register file.
//
// Dedicated 1-bit-wide predicate RF, structurally mirroring the 32-bit GPR RF
// (dice_rf_ctrl.sv) but at DICE_NUM_PRED (=8) banks of 1-bit data, NUM_TID-deep.
//
// Mirrored from dice_rf_ctrl.sv:
//   * launch-side registering of the write bitmap (wr_bitmap_r), copied from
//     dice_rf_ctrl.sv:105-113.
//   * per-bank read organization: a read bitmap + TID select the row, banks are
//     read in parallel (analogous to dice_read_org -> dice_register_file ->
//     dice_rd_ctrl_bank in dice_rf_ctrl.sv:217-254).
//   * registered read-valid pulse (rf_rd_valid_o), copied from
//     dice_read_org.sv:95-101.
//   * dice_ram_1w1r behavioral 1w1r banks for storage (same primitive the GPR
//     dice_register_file instantiates, dice_register_file.sv:20-31).
//
// Difference vs GPR RF: predicates are a small fixed set (PR0..PR7), so each
// predicate register maps to ONE fixed bank — there is NO 32-way cyclic
// shift_bitmap() swizzle (that swizzle is specific to spreading a wide GPR
// register across DICE_NUM_BANKS banks). The TID is the row address; the
// per-bank bitmap selects which predicate banks participate. CTA-id is carried
// implicitly in the upper bits of the TID, exactly as in the GPR RF (the row
// address is the full DICE_TID_WIDTH TID).
// =============================================================================

module dice_pred_rf

import DE_pkg::*;
import dice_pkg::*;

#(
      parameter int NUM_PRED    = DICE_NUM_PRED                  // # predicate banks (8)
    , parameter int DATA_WIDTH  = 1                              // 1-bit predicate
    , parameter int NUM_TID     = `DICE_NUM_MAX_THREADS_PER_CORE // 512 rows
    , parameter int TID_WIDTH   = DICE_TID_WIDTH                 // $clog2(512) = 9
    , parameter int DEPTH       = NUM_TID
    , parameter int ADDR_WIDTH  = $clog2(DEPTH)
    , parameter int EBLOCK_ID_WIDTH = DICE_EBLOCK_ID_WIDTH
)
(
      input  logic                       clk_i
    , input  logic                       reset_i

    // -------------------------------------------------------------------------
    // Read (predicate launch) side — driven by the dispatcher, same TID scheme
    // as the GPR RF read path (dice_rf_ctrl.sv:33-42).
    // -------------------------------------------------------------------------
    , input  logic                       rd_tid_valid_i
    , input  logic [TID_WIDTH-1:0]       rd_tid_i
    , input  logic [NUM_PRED-1:0]        rd_pred_bitmap_i   // which pred banks to read
    , output logic [NUM_PRED-1:0]        rd_pred_data_o     // 1 bit per pred bank
    , output logic                       rf_rd_valid_o

    // -------------------------------------------------------------------------
    // Write (CGRA result) side — driven by the fabric's ext_pred_o, registered
    // bitmap like dice_rf_ctrl.sv:105-120.
    // -------------------------------------------------------------------------
    , input  logic [TID_WIDTH-1:0]       cgra_tid_i
    , input  logic [NUM_PRED-1:0]        cgra_pred_i        // 1 bit per pred bank
    , input  logic [NUM_PRED-1:0]        cgra_pred_wr_bitmap_i
    , input  logic                       cgra_valid_i

    // -------------------------------------------------------------------------
    // e_block_id passthrough (cheap: registered alongside the read pulse so the
    // launch-side consumer can re-tag the predicate read with its e-block).
    // -------------------------------------------------------------------------
    , input  logic [EBLOCK_ID_WIDTH-1:0] rd_e_block_id_i
    , output logic [EBLOCK_ID_WIDTH-1:0] rd_e_block_id_o
);

    // -------------------------------------------------------------------------
    // Per-bank RAM interface buses.
    // -------------------------------------------------------------------------
    logic [NUM_PRED-1:0]                 rf_rd_en;
    logic [NUM_PRED*ADDR_WIDTH-1:0]      rf_rd_addr;
    logic [NUM_PRED*DATA_WIDTH-1:0]      rf_rd_data;

    logic [NUM_PRED-1:0]                 rf_wr_en;
    logic [NUM_PRED*ADDR_WIDTH-1:0]      rf_wr_addr;
    logic [NUM_PRED*DATA_WIDTH-1:0]      rf_wr_data;

    // -------------------------------------------------------------------------
    // Launch-side registering of the write bitmap (mirrors dice_rf_ctrl.sv:105-113).
    // The CGRA presents the bitmap one cycle before the registered ext_pred data
    // settles, so the bitmap is registered to align with cgra_pred_i / cgra_valid_i.
    // -------------------------------------------------------------------------
    logic [NUM_PRED-1:0] cgra_pred_wr_bitmap_r;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            cgra_pred_wr_bitmap_r <= '0;
        end else begin
            cgra_pred_wr_bitmap_r <= cgra_pred_wr_bitmap_i;
        end
    end

    // -------------------------------------------------------------------------
    // WRITE path: each predicate bank is written at row=cgra_tid_i when the
    // registered bitmap bit is set and the CGRA write is valid. Predicates map
    // 1:1 to banks (no cyclic swizzle), so the bank index IS the predicate index.
    // (Structurally analogous to the per-bank dice_wr_ctrl_bank fan-out in
    //  dice_rf_ctrl.sv:131-161, simplified to a direct 1-bit write since there
    //  is no LDST writeback contention on predicates.)
    // -------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < NUM_PRED; i++) begin : gen_wr
            assign rf_wr_en[i]                              = cgra_valid_i & cgra_pred_wr_bitmap_r[i];
            assign rf_wr_addr[i*ADDR_WIDTH +: ADDR_WIDTH]   = cgra_tid_i[ADDR_WIDTH-1:0];
            assign rf_wr_data[i*DATA_WIDTH +: DATA_WIDTH]   = cgra_pred_i[i];
        end
    endgenerate

    // -------------------------------------------------------------------------
    // READ organization: drive each bank's read address with the launch TID and
    // its enable with the read bitmap (mirrors dice_read_org.sv routing, minus
    // the GPR 32-bank shift_bitmap swizzle which does not apply to predicates).
    // -------------------------------------------------------------------------
    generate
        for (i = 0; i < NUM_PRED; i++) begin : gen_rd
            assign rf_rd_en[i]                            = rd_tid_valid_i & rd_pred_bitmap_i[i];
            assign rf_rd_addr[i*ADDR_WIDTH +: ADDR_WIDTH] = rd_tid_i[ADDR_WIDTH-1:0];
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Storage: one dice_ram_1w1r per predicate bank (same primitive used by the
    // GPR dice_register_file, dice_register_file.sv:20-31), 1-bit wide.
    // -------------------------------------------------------------------------
    generate
        for (i = 0; i < NUM_PRED; i++) begin : gen_bank
            dice_ram_1w1r #(
                  .DATA_WIDTH (DATA_WIDTH)
                , .DEPTH      (DEPTH)
                , .ADDR_WIDTH (ADDR_WIDTH)
            ) u_pred_bank (
                  .clk     (clk_i)
                , .wr_en   (rf_wr_en[i])
                , .wr_addr (rf_wr_addr[i*ADDR_WIDTH +: ADDR_WIDTH])
                , .wr_data (rf_wr_data[i*DATA_WIDTH +: DATA_WIDTH])
                , .rd_addr (rf_rd_addr[i*ADDR_WIDTH +: ADDR_WIDTH])
                , .rd_data (rf_rd_data[i*DATA_WIDTH +: DATA_WIDTH])
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Read output. dice_ram_1w1r has a 1-cycle read latency, so the data appears
    // the cycle after rd_tid_valid_i — aligned with the registered rf_rd_valid_o
    // and e_block_id passthrough below. Gate each bank's output by the registered
    // read-enable so unselected predicates read 0.
    // -------------------------------------------------------------------------
    logic [NUM_PRED-1:0] rf_rd_en_q;

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            rf_rd_en_q <= '0;
        end else begin
            rf_rd_en_q <= rf_rd_en;
        end
    end

    generate
        for (i = 0; i < NUM_PRED; i++) begin : gen_rd_out
            assign rd_pred_data_o[i] = rf_rd_en_q[i] & rf_rd_data[i*DATA_WIDTH +: DATA_WIDTH];
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Registered read-valid pulse + e_block_id passthrough, aligned to the
    // 1-cycle RAM read latency (mirrors dice_read_org.sv:95-101).
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            rf_rd_valid_o   <= 1'b0;
            rd_e_block_id_o <= '0;
        end else begin
            rf_rd_valid_o   <= rd_tid_valid_i;
            rd_e_block_id_o <= rd_e_block_id_i;
        end
    end

endmodule

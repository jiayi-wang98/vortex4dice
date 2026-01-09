module dice_read_org
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

    // output
    , output logic [NUM_PORTS*TID_WIDTH-1:0] rd_sel_o 
    , output logic [NUM_PORTS-1:0]           rd_valid_o

);

    // Extract first TID from packed input
    logic [TID_WIDTH-1:0] tid;
    logic [$clog2(DICE_NUM_BANKS)-1:0] bank_idx;

    // Grab the first TID and compute its bank index
    assign tid = rd_tid_i[0 +: TID_WIDTH];
    assign bank_idx = bank_select(tid, rd_bitmap_i[$clog2(DICE_NUM_REGS)-1:0]);

    // Ready when enabled
    assign rd_tid_ready_o = rd_en_i;

    // Swizzle logic: route TID to its calculated bank position
    always_comb begin
        // Initialize outputs to zero
        rd_sel_o = '0;
        rd_valid_o = '0;

        if (rd_en_i && rd_tid_valid_i) begin
            // Insert TID at the bank position in output vector
            rd_sel_o[bank_idx*TID_WIDTH +: TID_WIDTH] = tid;
            // Set valid bit for this bank
            rd_valid_o[bank_idx] = 1'b1;
        end
    end

endmodule
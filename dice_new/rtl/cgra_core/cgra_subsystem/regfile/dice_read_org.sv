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
    assign tid = rd_tid_i[0 +: TID_WIDTH];

    // Compute shift amount from tid (tid mod NUM_PORTS)
    logic [$clog2(NUM_PORTS)-1:0] shift_amt;
    assign shift_amt = tid[$clog2(NUM_PORTS)-1:0];

    // Circular left shift of bitmap by shift_amt
    // result = (bitmap << shift_amt) | (bitmap >> (NUM_PORTS - shift_amt))
    logic [NUM_PORTS-1:0] shifted_bitmap;
    assign shifted_bitmap = (rd_bitmap_i << shift_amt) 
                          | (rd_bitmap_i >> (NUM_PORTS - shift_amt));

    // Ready when enabled
    assign rd_tid_ready_o = rd_en_i;

    // Swizzle logic: route TID to banks where shifted bitmap has 1s
    always_comb begin
        // Initialize outputs to zero
        rd_sel_o = '0;
        rd_valid_o = '0;

        if (rd_en_i && rd_tid_valid_i) begin
            // Set valid bits from shifted bitmap
            rd_valid_o = shifted_bitmap;

            // For each bank with valid bit set, place the TID
            for (int i = 0; i < NUM_PORTS; i++) begin
                if (shifted_bitmap[i]) begin
                    rd_sel_o[i*TID_WIDTH +: TID_WIDTH] = tid;
                end
            end
        end
    end

endmodule
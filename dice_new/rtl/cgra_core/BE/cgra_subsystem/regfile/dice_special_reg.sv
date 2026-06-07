// can hold a constant 32bit value and tid.x, tid.y, tid.z, ntid.x, ntid.y, ntid.z, ctaid.x, ctaid.y, ctaid.z, nctaid.x, nctaid.y, nctaid.z
//
// blockIdx (ctaid_x/y/z, nctaid_x/y/z) is held as a PER-SLICE table with
// MAX_CTA_PER_CORE entries. An aggregate e-block with hw_cta_size>1 co-schedules
// N DISTINCT CTAs on this core, each occupying a distinct hardware-CTA slice and
// owning its own blockIdx. A thread's slice id is the upper HW_CTA_ID_WIDTH bits
// of its TID (rd_tid_i[TID_WIDTH-1 -: HW_CTA_ID_WIDTH]).
//
// Write/load path: the frontend populates one slice's blockIdx per cycle via
// slice_wr_en_i + slice_wr_idx_i, with the ctaid_*/nctaid_* inputs as the write
// data. Read path: when a special reg is requested for a thread, the returned
// blockIdx is selected from the slice owning that thread (rd_tid_i upper bits).
//
// When MAX_CTA_PER_CORE == 1 this degenerates to the original single-entry
// register: there is exactly one table entry, the slice index is forced to 0,
// and behavior is bit-identical to the pre-table implementation.
module dice_special_reg#(
    parameter int DATA_WIDTH = 32,
    parameter int NUM_TID = 512,
    parameter int TID_WIDTH = $clog2(NUM_TID),
    parameter int MAX_CTA_ID = 65535,
    parameter int CTA_ID_WIDTH = $clog2(MAX_CTA_ID),
    // Per-slice blockIdx table depth. Defaults to DICE_NUM_MAX_CTA_PER_CORE (=4)
    // for the full DICE core. Set to 1 to recover single-entry behavior.
    parameter int MAX_CTA_PER_CORE = 4,
    // Width of the slice id = TID upper bits. Mirrors DICE_HW_CTA_ID_WIDTH.
    // Guarded against width-0 when MAX_CTA_PER_CORE == 1.
    parameter int HW_CTA_ID_WIDTH = (MAX_CTA_PER_CORE > 1) ? $clog2(MAX_CTA_PER_CORE) : 1
)(
    input logic clk_i,
    input logic reset_i,
    input logic clear_i,

    //config
    input logic rd_en,
    input logic [3:0] rd_sel,
    // Requesting thread id. Its upper HW_CTA_ID_WIDTH bits select which CTA slice
    // (and therefore which blockIdx table entry) is returned for ctaid_*/nctaid_*.
    input logic [TID_WIDTH-1:0] rd_tid_i,

    //dispatcher input
    input logic [DATA_WIDTH-1:0] const_data, //constant value register
    input logic [TID_WIDTH-1:0] tid_x,
    input logic [TID_WIDTH-1:0] tid_y,
    input logic [TID_WIDTH-1:0] tid_z,
    input logic [TID_WIDTH-1:0] ntid_x,
    input logic [TID_WIDTH-1:0] ntid_y,
    input logic [TID_WIDTH-1:0] ntid_z,

    // Per-slice blockIdx load path. ctaid_*/nctaid_* are the write data; assert
    // slice_wr_en_i to latch them into the entry selected by slice_wr_idx_i.
    input logic                       slice_wr_en_i,
    input logic [HW_CTA_ID_WIDTH-1:0] slice_wr_idx_i,
    input logic [CTA_ID_WIDTH-1:0] ctaid_x,
    input logic [CTA_ID_WIDTH-1:0] ctaid_y,
    input logic [CTA_ID_WIDTH-1:0] ctaid_z,
    input logic [CTA_ID_WIDTH-1:0] nctaid_x,
    input logic [CTA_ID_WIDTH-1:0] nctaid_y,
    input logic [CTA_ID_WIDTH-1:0] nctaid_z,
    //output
    output logic [DATA_WIDTH-1:0] out_data
);

    // Per-slice blockIdx table. One entry per co-scheduled hardware CTA slice.
    logic [CTA_ID_WIDTH-1:0] ctaid_x_tbl  [MAX_CTA_PER_CORE-1:0];
    logic [CTA_ID_WIDTH-1:0] ctaid_y_tbl  [MAX_CTA_PER_CORE-1:0];
    logic [CTA_ID_WIDTH-1:0] ctaid_z_tbl  [MAX_CTA_PER_CORE-1:0];
    logic [CTA_ID_WIDTH-1:0] nctaid_x_tbl [MAX_CTA_PER_CORE-1:0];
    logic [CTA_ID_WIDTH-1:0] nctaid_y_tbl [MAX_CTA_PER_CORE-1:0];
    logic [CTA_ID_WIDTH-1:0] nctaid_z_tbl [MAX_CTA_PER_CORE-1:0];

    // Read-side slice index = requesting TID's upper HW_CTA_ID_WIDTH bits.
    // Collapses to 0 (a constant) when there is a single slice.
    logic [HW_CTA_ID_WIDTH-1:0] rd_slice_idx;
    if (MAX_CTA_PER_CORE > 1) begin : gen_rd_slice_idx
        assign rd_slice_idx = rd_tid_i[TID_WIDTH-1 -: HW_CTA_ID_WIDTH];
    end else begin : gen_rd_slice_idx_single
        assign rd_slice_idx = '0;
    end

    // Selected blockIdx for the requesting thread's slice.
    logic [CTA_ID_WIDTH-1:0] sel_ctaid_x;
    logic [CTA_ID_WIDTH-1:0] sel_ctaid_y;
    logic [CTA_ID_WIDTH-1:0] sel_ctaid_z;
    logic [CTA_ID_WIDTH-1:0] sel_nctaid_x;
    logic [CTA_ID_WIDTH-1:0] sel_nctaid_y;
    logic [CTA_ID_WIDTH-1:0] sel_nctaid_z;

    assign sel_ctaid_x  = ctaid_x_tbl [rd_slice_idx];
    assign sel_ctaid_y  = ctaid_y_tbl [rd_slice_idx];
    assign sel_ctaid_z  = ctaid_z_tbl [rd_slice_idx];
    assign sel_nctaid_x = nctaid_x_tbl[rd_slice_idx];
    assign sel_nctaid_y = nctaid_y_tbl[rd_slice_idx];
    assign sel_nctaid_z = nctaid_z_tbl[rd_slice_idx];

    // Per-slice blockIdx table write/load. Frontend populates one slice per cycle
    // as CTAs are scheduled. Reset/clear wipe all entries.
    always_ff @(posedge clk_i) begin
        if (reset_i || clear_i) begin
            for (int s = 0; s < MAX_CTA_PER_CORE; s++) begin
                ctaid_x_tbl[s]  <= '0;
                ctaid_y_tbl[s]  <= '0;
                ctaid_z_tbl[s]  <= '0;
                nctaid_x_tbl[s] <= '0;
                nctaid_y_tbl[s] <= '0;
                nctaid_z_tbl[s] <= '0;
            end
        end else if (slice_wr_en_i) begin
            ctaid_x_tbl[slice_wr_idx_i]  <= ctaid_x;
            ctaid_y_tbl[slice_wr_idx_i]  <= ctaid_y;
            ctaid_z_tbl[slice_wr_idx_i]  <= ctaid_z;
            nctaid_x_tbl[slice_wr_idx_i] <= nctaid_x;
            nctaid_y_tbl[slice_wr_idx_i] <= nctaid_y;
            nctaid_z_tbl[slice_wr_idx_i] <= nctaid_z;
        end
    end

    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            out_data <= '0;
        end else if (clear_i) begin
            out_data <= '0;
        end else if (rd_en) begin
            case (rd_sel)
                4'd0: out_data <= const_data;
                4'd1: out_data <= {{(DATA_WIDTH-TID_WIDTH){1'b0}}, tid_x};
                4'd2: out_data <= {{(DATA_WIDTH-TID_WIDTH){1'b0}}, tid_y};
                4'd3: out_data <= {{(DATA_WIDTH-TID_WIDTH){1'b0}}, tid_z};
                4'd4: out_data <= {{(DATA_WIDTH-TID_WIDTH){1'b0}}, ntid_x};
                4'd5: out_data <= {{(DATA_WIDTH-TID_WIDTH){1'b0}}, ntid_y};
                4'd6: out_data <= {{(DATA_WIDTH-TID_WIDTH){1'b0}}, ntid_z};
                4'd7:  out_data <= {{(DATA_WIDTH-CTA_ID_WIDTH){1'b0}}, sel_ctaid_x};
                4'd8:  out_data <= {{(DATA_WIDTH-CTA_ID_WIDTH){1'b0}}, sel_ctaid_y};
                4'd9:  out_data <= {{(DATA_WIDTH-CTA_ID_WIDTH){1'b0}}, sel_ctaid_z};
                4'd10: out_data <= {{(DATA_WIDTH-CTA_ID_WIDTH){1'b0}}, sel_nctaid_x};
                4'd11: out_data <= {{(DATA_WIDTH-CTA_ID_WIDTH){1'b0}}, sel_nctaid_y};
                4'd12: out_data <= {{(DATA_WIDTH-CTA_ID_WIDTH){1'b0}}, sel_nctaid_z};
                default: out_data <= '0;
            endcase
        end
    end

endmodule

// `include "bsg_defines.sv"
`include "DE_pkg.sv"
`include "dice_pkg.sv"


import DE_pkg::*;
import dice_pkg::*;

typedef struct packed {
    logic                                        valid;
    logic[DICE_TID_WIDTH-1:0]                    tid;
    logic[DICE_ADDR_WIDTH-1:0]                   data;
} entry_s;

module reg_wr_buffer #(
      parameter int WIDTH      = 32
    , parameter int ADDR_WIDTH = $clog2(512)
    , parameter int DEPTH      = 8   // must be 8 for the casez below
) (
      input  logic            clk_i
    , input  logic            reset_i

    // incoming write command
    , input  reg_wr_cmd       wr_i

    // forwarding read command
    , input  reg_rd_cmd       fw_req_i

    // pop oldest entry (writeback consumed)
    , input  logic            pop_i

    // status
    , output logic            full_o
    , output logic            empty_o

    // writeback (oldest entry)
    , output logic [ADDR_WIDTH-1:0] wb_addr_o
    , output logic [WIDTH-1:0]      wb_data_o
    , output logic                  wb_valid_o

    // forwarding info
    , output logic [DEPTH-1:0]      fw_hit_o
    , output logic [WIDTH-1:0]      fw_data_o
    , output logic                  fw_data_valid_o
);

    localparam int ptr_width_lp = $clog2(DEPTH);

    // ----------------------------------------------------------------
    // Pointer tracker (no storage)
    // ----------------------------------------------------------------
    logic [ptr_width_lp-1:0] wptr_r, rptr_r, rptr_n;
    logic                    full, empty;

    logic enq_li, deq_li;

    // Enqueue when we have a write and not full
    assign enq_li = wr_i.we & ~full;
    // Dequeue when pop requested and not empty
    assign deq_li = pop_i   & ~empty;

    bsg_fifo_tracker #(
        .els_p(DEPTH)
    ) fifo_track (
        .clk_i     (clk_i),
        .reset_i   (reset_i),
        .enq_i     (enq_li),
        .deq_i     (deq_li),
        .wptr_r_o  (wptr_r),
        .rptr_r_o  (rptr_r),
        .rptr_n_o  (rptr_n),
        .full_o    (full),
        .empty_o   (empty)
    );

    assign full_o  = full;
    assign empty_o = empty;

    // ----------------------------------------------------------------
    // 1R/1W memory (shadow bufferfer) fully visible for forwarding
    // ----------------------------------------------------------------


    entry_s buffer [DEPTH];

    integer i;
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            for (i = 0; i < DEPTH; i++) begin
                buffer[i].valid <= 1'b0;
                buffer[i].tid   <= '0;
                buffer[i].data  <= '0;
            end
        end else begin
            // Dequeue: invalidate oldest entry
            if (deq_li && !empty) begin
                buffer[rptr_r].valid <= 1'b0;
            end

            // Enqueue: write new entry at current write pointer
            if (enq_li && !full) begin
                buffer[wptr_r].valid <= 1'b1;
                buffer[wptr_r].tid   <= wr_i.tid;
                // buffer[wptr_r].addr  <= wr_i.ws[ADDR_WIDTH-1:0];
                buffer[wptr_r].data  <= wr_i.data[WIDTH-1:0];
            end
        end
    end

    // ----------------------------------------------------------------
    // Oldest entry for writeback (at rptr_r)
    // ----------------------------------------------------------------
    always_comb begin
        wb_addr_o  = buffer[rptr_r].tid;
        wb_data_o  = buffer[rptr_r].data;
        wb_valid_o = buffer[rptr_r].valid & ~empty;
    end

    // ----------------------------------------------------------------
    // Forwarding:
    //  - fw_hit_o[i] marks all matching entries by physical index
    //  - Youngest priority: newest is at wptr_r-1, then wptr_r-2, ...
    //    We build an "age_hits" vector in age order and use casez.
    // ----------------------------------------------------------------
    logic [DEPTH-1:0] hit_vec;
    logic [DEPTH-1:0] age_hits;
    logic [ptr_width_lp-1:0] sel_idx;
    logic [ptr_width_lp-1:0] idx_rel;
    logic [ptr_width_lp-1:0] off;    



    always_comb begin
        fw_hit_o        = '0;
        fw_data_o       = '0;
        fw_data_valid_o = 1'b0;

        hit_vec         = '0;
        age_hits        = '0;
        sel_idx         = '0;

        if (fw_req_i.re) begin
            // mark all physical hits
            for (int j = 0; j < DEPTH[ptr_width_lp-1:0]; j++) begin
                if (buffer[j].valid &&
                    buffer[j].tid  == fw_req_i.tid) begin
                    hit_vec[j] = 1'b1;
                end
            end

            // map hits into age order:
            // age_hits[0] = newest (wptr_r - 1)
            // age_hits[1] = next   (wptr_r - 2)
            // ...
            for (off = 0; off < DEPTH; off++) begin
                idx_rel = wptr_r - (off + 1);
                age_hits[off] = hit_vec[idx_rel];
            end

            // expose physical hit map
            fw_hit_o = hit_vec;

            // priority on age_hits: bit 0 is youngest
            casez (age_hits)
                8'b???????1: sel_idx = wptr_r - 1;
                8'b??????10: sel_idx = wptr_r - 2;
                8'b?????100: sel_idx = wptr_r - 3;
                8'b????1000: sel_idx = wptr_r - 4;
                8'b???10000: sel_idx = wptr_r - 5;
                8'b??100000: sel_idx = wptr_r - 6;
                8'b?1000000: sel_idx = wptr_r - 7;
                8'b10000000: sel_idx = wptr_r - 8;
                default:     sel_idx = '0;
            endcase

            if (|age_hits) begin
                fw_data_o       = buffer[sel_idx].data;
                fw_data_valid_o = 1'b1;
            end
        end
    end

endmodule

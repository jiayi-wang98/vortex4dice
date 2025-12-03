// Single-entry "buffer" to replace a reg_wr_buffer instance for CGRA.
// Same external ports; no fifo tracker.
//
// - Accepts a write when slot is empty OR it's being popped this cycle.
// - pop_i drains the slot.
// - Forwarding prefers this slot at the top level; here we just expose hit/data.
//
// DEPTH is only used to size fw_hit_o; only bit 0 is meaningful.

module reg_wr_single_entry #(
      parameter int WIDTH      = 32
    , parameter int ADDR_WIDTH = $clog2(512)
    , parameter int DEPTH      = 8   // keep interface-compatible (fw_hit_o width)
) (
    input  logic                 clk_i,
    input  logic                 rstn_i,

    // incoming write command
    input  reg_wr_cmd            wr_i,

    // forwarding read command
    input  reg_rd_cmd            fw_req_i,

    // pop oldest entry (writeback consumed)
    input  logic                 pop_i,

    // status
    output logic                 full_o,
    output logic                 empty_o,

    // writeback (oldest entry)
    output logic [ADDR_WIDTH-1:0] wb_addr_o,
    output logic [WIDTH-1:0]      wb_data_o,
    output logic                  wb_valid_o,

    // forwarding info
    output logic                  fw_hit_o,
    output logic [WIDTH-1:0]      fw_data_o,
    output logic                  fw_data_valid_o
);

    // Single-slot storage
    typedef struct packed {
        logic                                        valid;
        logic[$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0] tid;
        logic[ADDR_WIDTH-1:0]                        addr;
        logic[WIDTH-1:0]                             data;
    } entry_s;

    entry_s q, n;

    // Status
    assign full_o   = q.valid;
    assign empty_o  = ~q.valid;

    // Writeback view
    assign wb_addr_o  = q.addr;
    assign wb_data_o  = q.data;
    assign wb_valid_o = q.valid;

    // Next-state logic
    always_comb begin
        n = q;

        // Drain on pop
        if (pop_i && q.valid) begin
            n.valid = 1'b0;
        end

        // Accept write if slot free OR we’re draining this cycle
        if (wr_i.we && (!q.valid || (pop_i && q.valid))) begin
            n.valid = 1'b1;
            n.tid   = wr_i.tid;
            n.addr  = wr_i.ws[ADDR_WIDTH-1:0];
            n.data  = wr_i.data[WIDTH-1:0];
        end
    end

    // State register
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            q.valid <= 1'b0;
            q.tid   <= '0;
            q.addr  <= '0;
            q.data  <= '0;
        end else begin
            q <= n;
        end
    end

    // Forwarding
    always_comb begin
        fw_hit_o         = '0;
        fw_data_o        = '0;
        fw_data_valid_o  = 1'b0;

        if (fw_req_i.re &&
            q.valid &&
            (q.tid  == fw_req_i.tid) &&
            (q.addr == fw_req_i.rs[ADDR_WIDTH-1:0])) begin
            fw_hit_o        = 1'b1;
            fw_data_o       = q.data;
            fw_data_valid_o = 1'b1;
        end
    end

endmodule
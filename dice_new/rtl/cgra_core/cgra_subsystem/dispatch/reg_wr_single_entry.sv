// Single-entry CGRA write buffer with valid/ready handshake.
// - CGRA side:  in_valid/in_ready
// - RF side:    out_valid/out_ready
// - Latest write wins; supports in+out in same cycle (no bubble).

module reg_wr_single #(
      parameter int WIDTH      = 32
    , parameter int ADDR_WIDTH = $clog2(512)
) (
    input  logic        clk_i,
    input  logic        reset_i,

    // Upstream CGRA write interface
    input  logic        cgra_valid_i,
    output logic        cgra_ready_o,
    input  reg_wr_cmd   cgra_wr_i,

    // Downstream interface to RF arbiter (CGRA has priority there)
    output logic        valid_o,
    output reg_wr_cmd   cmd_o,

    // Forwarding interface
    input  reg_rd_cmd   fw_req_i,
    output logic        fw_hit_o,
    output logic [WIDTH-1:0] fw_data_o,
    output logic        fw_data_valid_o
);

    // One-entry register + valid bit
    reg_wr_cmd entry_r;
    logic      valid_r;

     reg_wr_cmd cmd_r;
    logic      valid_r;

    // Capture latest CGRA write each cycle
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            valid_r <= 1'b0;
            cmd_r   <= '0;
        end else begin
            valid_r <= cgra_valid_i;
            if (cgra_valid_i) cmd_r <= cgra_wr_i;
        end
    end

    assign valid_o = valid_r;
    assign cmd_o   = cmd_r;

    // TODO: implement read forwarding

    // // ------------------------------------------------------------
    // // Forwarding: single-entry, trivial
    // // ------------------------------------------------------------
    // always_comb begin
    //     fw_hit_o         = 1'b0;
    //     fw_data_o        = '0;
    //     fw_data_valid_o  = 1'b0;

    //     if (fw_req_i.re && valid_r && entry_r.we &&
    //         (entry_r.tid == fw_req_i.tid) &&
    //         (entry_r.ws  == fw_req_i.rs[ADDR_WIDTH-1:0])) begin
    //         fw_hit_o        = 1'b1;
    //         fw_data_o       = entry_r.data;
    //         fw_data_valid_o = 1'b1;
    //     end
    // end

endmodule

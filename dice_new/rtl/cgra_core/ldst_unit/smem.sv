module smem #(
    parameter DATA_W = 256,
    parameter ADDR_W = 27,
    parameter TAG_W  = 69,
    parameter MEM_DEPTH = 128
)(
    input  logic clk,
    input  logic rst,

    // Memory request interface
    input  logic mem_req_valid,
    output logic mem_req_ready,
    input  logic mem_req_rw, // 1 = write, 0 = read
    input  logic [ADDR_W-1:0] mem_req_addr,
    input  logic [DATA_W-1:0] mem_req_data,
    input  logic [DATA_W/8-1:0] mem_req_byteen,
    input  logic [47:0] mem_req_tag,

    // Memory response interface
    output logic mem_rsp_valid,
    input  logic mem_rsp_ready,
    output logic [DATA_W/4-1:0] mem_rsp_data,
    output logic [TAG_W-1:0] mem_rsp_tag
);
    
    int idx;
    // ------------------------------
    // Internal storage
    // ------------------------------
    logic [DATA_W-1:0] mem [0:MEM_DEPTH-1];

    // Output registers and pending buffer
    logic rd_valid;
    logic [DATA_W-1:0] read_data;
    logic [TAG_W-1:0] rd_tag;

    logic pending_valid;
    logic [DATA_W-1:0] pending_data;
    logic [TAG_W-1:0] pending_tag;

    // Request ready combinational
    assign mem_req_ready = 1'b1;

    // ------------------------------
    // Single always_ff block
    // ------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int idx = 0; idx < MEM_DEPTH; idx++) begin
              mem[idx] <= idx; // preload memory on reset
            end
            rd_valid      <= 1'b0;
            read_data     <= '0;
            rd_tag        <= '0;
            pending_valid <= 1'b0;
            pending_data  <= '0;
            pending_tag   <= '0;
            mem_rsp_valid <= 1'b0;
            mem_rsp_data  <= '0;
            mem_rsp_tag   <= '0;
        end else begin
            // ----------------------
            // Handle memory requests
            // ----------------------
            if (mem_req_valid) begin
                if (mem_req_rw) begin
                    // Write
                    for (int i = 0; i < DATA_W/8; i++) begin
                        if (!mem_req_byteen[i])
                            mem[mem_req_addr][8*i +: 8] <= mem_req_data[8*i +: 8];
                    end
                end else begin
                    // Read
                    if (!rd_valid) begin
                        rd_valid   <= 1'b1;
                        read_data  <= mem[mem_req_addr];
                        rd_tag     <= mem_req_tag;
                    end else if (!pending_valid) begin
                        pending_valid <= 1'b1;
                        pending_data  <= mem[mem_req_addr];
                        pending_tag   <= mem_req_tag;
                    end else begin
                        $error("smem: read overflow, both rd_valid and pending_valid busy");
                    end
                end
            end

            // ----------------------
            // Drive memory response
            // ----------------------
            if (!mem_rsp_valid && rd_valid) begin
                mem_rsp_valid <= 1'b1;
                mem_rsp_data  <= read_data;
                mem_rsp_tag   <= rd_tag;
                rd_valid      <= 1'b0;

                // Move pending to output if exists
                if (pending_valid) begin
                    read_data     <= pending_data;
                    rd_tag        <= pending_tag;
                    pending_valid <= 1'b0;
                    rd_valid      <= 1'b1;
                end
            end

            // Clear response when accepted
            if (mem_rsp_valid && mem_rsp_ready) begin
                mem_rsp_valid <= 1'b0;
            end
        end
    end

endmodule

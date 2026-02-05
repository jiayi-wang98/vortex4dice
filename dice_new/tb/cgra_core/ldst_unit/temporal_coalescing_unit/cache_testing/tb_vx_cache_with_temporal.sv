module tb_vx_cache_with_temporal;

    parameter CLK_PERIOD = 2.5;
    parameter int CACHE_LINE_SIZE = 32;
    parameter int TID_WIDTH = 10;
    parameter int DATA_WIDTH = 64;
    parameter int ADDR_WIDTH = 32;
    parameter int EBLOCK_ID_WIDTH = 4;
    parameter int NUMBER_OF_MAX_COALESCED_COMMANDS = 8;
    parameter int NUMBER_OF_MAX_COALESCED_INTERVAL = 8;
    parameter int MAX_REG_WIDTH = 7;
    parameter int TID_BITMAP_WIDTH = 8;
    parameter int NUM_REQS = 1;
    parameter int MEM_PORTS = 1;
    parameter OUTCMD_TAG_WIDTH = 69;
    parameter MSHR_SIZE = 16;
    parameter MSHR_BITS = $clog2(MSHR_SIZE);
    parameter MEM_TAG_WIDTH = OUTCMD_TAG_WIDTH + MSHR_BITS;
    parameter MEM_ADDR_WIDTH = ADDR_WIDTH - $clog2(CACHE_LINE_SIZE); 

    // --- Signals --
    bit clk, rst;
    bit incmd_valid;
    bit [EBLOCK_ID_WIDTH-1:0] incmd_block_id;
    bit [TID_WIDTH-1:0] incmd_tid;
    bit incmd_write_enable;
    bit [DATA_WIDTH-1:0] incmd_write_data;
    bit [DATA_WIDTH/8-1:0] incmd_write_mask;
    bit [ADDR_WIDTH-1:0] incmd_address;
    bit [1:0] incmd_size;
    bit [MAX_REG_WIDTH-1:0] incmd_ld_dest_reg;
    bit outcmd_ready, core_rsp_ready;

    bit mem_req_ready;
    bit mem_rsp_valid;
    bit [255:0] mem_rsp_data;
    bit [MEM_TAG_WIDTH-1:0] mem_rsp_tag;

    logic [DATA_WIDTH-1:0] core_rsp_data;
    logic core_rsp_valid;
    logic [OUTCMD_TAG_WIDTH-1:0] core_rsp_tag;

    logic mem_req_valid, mem_req_rw;
    logic [CACHE_LINE_SIZE-1:0] mem_req_byteen;
    logic [MEM_ADDR_WIDTH-1:0] mem_req_addr;
    logic [255:0] mem_req_data;
    logic [MEM_TAG_WIDTH-1:0] mem_req_tag;
    logic mem_rsp_ready;

    // --- Clock generation ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // --- Memory Instance ---
    smem #(
        .DATA_W(256),
        .ADDR_W(MEM_ADDR_WIDTH),
        .TAG_W(MEM_TAG_WIDTH)
    ) mem_inst (
        .clk(clk), .rst(rst),
        .mem_req_valid(mem_req_valid), .mem_req_ready(mem_req_ready),
        .mem_req_rw(mem_req_rw), .mem_req_addr(mem_req_addr),
        .mem_req_data(mem_req_data), .mem_req_byteen(mem_req_byteen),
        .mem_req_tag(mem_req_tag), .mem_rsp_valid(mem_rsp_valid),
        .mem_rsp_ready(mem_rsp_ready), .mem_rsp_data(mem_rsp_data),
        .mem_rsp_tag(mem_rsp_tag)
    );

    // --- DUT Instance ---
    VX_cache_with_temporal #(
        .NUMBER_OF_MAX_COALESCED_INTERVAL(NUMBER_OF_MAX_COALESCED_INTERVAL),
        .CACHE_LINE_SIZE(CACHE_LINE_SIZE),
        .NUMBER_OF_MAX_COALESCED_COMMANDS(NUMBER_OF_MAX_COALESCED_COMMANDS),
        .EBLOCK_ID_WIDTH(EBLOCK_ID_WIDTH),
        .TID_WIDTH(TID_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .MAX_REG_WIDTH(MAX_REG_WIDTH),
        .TID_BITMAP_WIDTH(TID_BITMAP_WIDTH),
        .NUM_REQS(NUM_REQS),
        .MEM_PORTS(MEM_PORTS)
    ) dut (
        .clk(clk), .rst(rst),
        .incmd_valid(incmd_valid), .incmd_block_id(incmd_block_id),
        .incmd_tid(incmd_tid), .incmd_write_enable(incmd_write_enable),
        .incmd_write_data(incmd_write_data), .incmd_write_mask(incmd_write_mask),
        .incmd_address(incmd_address), .incmd_size(incmd_size),
        .incmd_ld_dest_reg(incmd_ld_dest_reg), .outcmd_ready(outcmd_ready),
        .core_rsp_data(core_rsp_data), .core_rsp_valid(core_rsp_valid),
        .core_rsp_tag(core_rsp_tag), .core_rsp_ready(core_rsp_ready),
        .mem_req_valid(mem_req_valid), .mem_req_rw(mem_req_rw),
        .mem_req_byteen(mem_req_byteen), .mem_req_addr(mem_req_addr),
        .mem_req_data(mem_req_data), .mem_req_tag(mem_req_tag),
        .mem_req_ready(mem_req_ready), .mem_rsp_valid(mem_rsp_valid),
        .mem_rsp_data(mem_rsp_data), .mem_rsp_tag(mem_rsp_tag),
        .mem_rsp_ready(mem_rsp_ready)
    );

    // --- Helper Task ---
    task send_read_request(input [31:0] addr, input [TID_WIDTH-1:0] tid);
        begin
            @(posedge clk);
            incmd_valid   = 1;
            incmd_address = addr;
            incmd_tid     = tid;
            incmd_size    = 2'b11; // 8-byte read
            wait(dut.incmd_ready == 1'b1); 
            @(posedge clk);
            incmd_valid   = 0;
        end
    endtask

    // --- Monitor ---
    // Simple version: extraction from the tag
// Current: [MAX_REG_WIDTH + TID_BITMAP_WIDTH +: TID_WIDTH]
// New suggested slice based on your Verdi {4000} trace:
wire [9:0] rsp_tid = core_rsp_tag[17:8];
    always @(posedge clk) begin
        if (core_rsp_valid && core_rsp_ready) begin
            $display("[MONITOR] Time: %0t | TID: %0d | Data: %h", $time, rsp_tid, core_rsp_data);
        end
    end

   // --- Main Initial Block ---
    initial begin
        // Init
        incmd_valid = 0;
        outcmd_ready = 1;
        core_rsp_ready = 1; 
        
        // Reset
        rst = 1;
        #(CLK_PERIOD * 10);
        rst = 0;
        repeat(5) @(posedge clk);

        $display("--- Starting Memory Pattern Sweep (Adjusted for Word Alignment) ---");

        // Step 3: Read Walking 1s (Indices 0 to 7)
        // Shifting left by 2 to compensate for internal hardware divide-by-4
        for (int j = 0; j < 8; j++) begin
            send_read_request(.addr((j * 32) << 2), .tid(j));
            #(CLK_PERIOD * 10); 
        end

        // Step 4: Read 'AAAA' Pattern (Index 8)
        // 0x100 shifted becomes the target address
        send_read_request(.addr(32'h0000_0100 << 2), .tid(8));
        #(CLK_PERIOD * 10);

        // Step 5: Read '5555' Pattern (Index 12)
        send_read_request(.addr(32'h0000_0180 << 2), .tid(12));
        #(CLK_PERIOD * 10);

       $display("--- Testing Original Block Reading ---");
        // We stay on the same line (0xF00) but change the word offset
        send_read_request(.addr(32'h0000_0F00), .tid(120)); // Targets Word 0 (0000...deadbeef)
        send_read_request(.addr(32'h0000_0F08), .tid(121)); // Targets Word 1 (1111...deadbeef)
        send_read_request(.addr(32'h0000_0F10), .tid(122)); // Targets Word 2 (2222...deadbeef)
        send_read_request(.addr(32'h0000_0F18), .tid(123)); // Targets Word 3 (3333...deadbeef)
        // Long wait at the end to see the results
        #(CLK_PERIOD * 100);
        $display("--- Sweep Complete ---");
        $finish;
    end

    initial begin
        $fsdbDumpfile("tb_vx_cache_with_temporal.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule
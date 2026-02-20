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
    parameter OUTCMD_TAG_WIDTH = NUMBER_OF_MAX_COALESCED_COMMANDS * $clog2(CACHE_LINE_SIZE) + EBLOCK_ID_WIDTH + TID_WIDTH + TID_BITMAP_WIDTH + MAX_REG_WIDTH;
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

    logic [CACHE_LINE_SIZE*8-1:0] core_rsp_data; 
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
        .MEM_PORTS(MEM_PORTS),
        .OUTCMD_TAG_WIDTH(OUTCMD_TAG_WIDTH)
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

    // --- Read Task ---
    task send_read_request(input [31:0] addr, input [TID_WIDTH-1:0] tid);
    begin
        @(posedge clk);
        incmd_valid   = 1;
        incmd_address = addr;
        incmd_tid     = tid;
        incmd_write_enable = 0;
        incmd_size    = 2'b11; 
        
        wait(dut.incmd_ready == 1'b1); 
        @(posedge clk);
        incmd_valid   = 0;

        fork
            begin
                wait(core_rsp_valid == 1'b1);
                @(posedge clk); 
            end
            begin
                #(CLK_PERIOD * 300);
                $display("[TB] TIMEOUT waiting for read response addr=%h", addr);
            end
        join_any
        disable fork;
    end
    endtask

    // --- TASK: WRITE REQUEST ---
    task send_write_request(
        input [31:0] addr, 
        input [DATA_WIDTH-1:0] data, 
        input [DATA_WIDTH/8-1:0] mask, 
        input [TID_WIDTH-1:0] tid
    );
    begin
        @(posedge clk);
        incmd_valid        = 1;
        incmd_address      = addr;
        incmd_tid          = tid;
        incmd_write_enable = 1;
        incmd_write_data   = data;
        incmd_write_mask   = mask;
        incmd_size         = 2'b11;
        
        wait(dut.incmd_ready == 1'b1);
        @(posedge clk);
        incmd_valid        = 0;
        incmd_write_enable = 0;
    end
    endtask

    // --- Slicing the Tag to get TID info ---
    // Tag Structure from LSB: 
    // [39:0] AddressMap | [46:40] Reg | [54:47] Bitmap | [64:55] BaseTID | [68:65] BlockID
    wire [9:0] rsp_base_tid = core_rsp_tag[64:55];
    wire [7:0] rsp_bitmap   = core_rsp_tag[54:47];

    // Monitor
    always @(posedge clk) begin
        if (core_rsp_valid && core_rsp_ready) begin
            $display("[MONITOR] Time: %0t | BaseTID: %0d | Bitmap: %b | Full Line Data: %h", 
                     $time, rsp_base_tid, rsp_bitmap, core_rsp_data);
        end
    end

   initial begin
        // --- Initialization & Reset ---
        incmd_valid = 0;
        outcmd_ready = 1;
        core_rsp_ready = 1; 
        rst = 1;
        #(CLK_PERIOD * 10);
        rst = 0;
        repeat(5) @(posedge clk);

        // --- Step 1: Write Coalescing Test ---
        $display("--- Starting Write Coalescing Test (Addr 0x100) ---");
        
        // FIX 1: Change Mask from 8'hFF to 8'h00 (0 = Write Enable)
        send_write_request(32'h0000_0100, 64'h1111_1111_1111_1111, 8'h00, 0); 
        send_write_request(32'h0000_0108, 64'h2222_2222_2222_2222, 8'h00, 1); 
        send_write_request(32'h0000_0110, 64'h3333_3333_3333_3333, 8'h00, 2); 
        send_write_request(32'h0000_0118, 64'h4444_4444_4444_4444, 8'h00, 3); 

        // Wait for coalescing interval to flush
        #(CLK_PERIOD * 100);

        // --- Step 2: Read-Back Verification ---
        $display("--- Reading back Addr 0x100 ---");
        
        // FIX 2: Increased Timeout in logic below
        // We use a fork-join to handle the timeout gracefully
        fork
            begin
                send_read_request(32'h0000_0100, 0);
                send_read_request(32'h0000_0108, 0);
                send_read_request(32'h0000_0110, 0);
            end
            begin
                // Wait longer for Cold Miss (e.g., 2000 cycles)
                #(CLK_PERIOD * 2000); 
                if (core_rsp_valid == 0) begin
                    $display("[TB] CRITICAL TIMEOUT: Memory did not respond in time for Addr 0x100");
                end
            end
        join_any
        disable fork;

        #(CLK_PERIOD * 100);
        
        // --- Step 3: Linear Sweep ---
        $display("--- Starting Linear Word Sweep ---");
        for (int j = 0; j < 8; j++) begin
            send_read_request(.addr(j * 8), .tid(j)); 
            #(CLK_PERIOD * 50); 
        end

        #(CLK_PERIOD * 100);


        // Test 4: Temporal timeout
        $display("Temporal timeout");
        send_write_request(32'h0000_0200, 64'hABCD_DCBA_A4BE_A4BE, 8'h00, 3);
        #(CLK_PERIOD * 1000);

        send_read_request(32'h0000_0200, 0);
        #(CLK_PERIOD * 1000);

        $display("--- All Tests Complete ---");
        $finish;
    end

    initial begin
        $fsdbDumpfile("tb_vx_cache_with_temporal.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule
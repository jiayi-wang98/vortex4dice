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
    parameter int NUM_REQS = 4;
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

    task send_read_request(input [31:0] addr, input [TID_WIDTH-1:0] tid);
    begin
        @(posedge clk);
        incmd_valid   = 1;
        incmd_address = addr;
        incmd_tid     = tid;
        incmd_size    = 2'b11; // 8-byte read
        
        // Wait for the Cache to accept the address
        wait(dut.incmd_ready == 1'b1); 
        @(posedge clk);
        incmd_valid   = 0;

        // --- ADD THIS: Wait for the actual data to return ---
        $display("[TB] Sent Read Req for Addr: %h, waiting for response...", addr);
        fork
            begin
                wait(core_rsp_valid == 1'b1);
                $display("[TB] Received response for Addr: %h", addr);
            end
            begin
                #(CLK_PERIOD * 200); // Timeout safety
                if (!core_rsp_valid) $display("[TB] TIMEOUT: No response for Addr: %h", addr);
            end
        join_any
        disable fork; 
    end
endtask

    // --- Write Task ---
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
            incmd_write_enable = 1;        // Enable Write
            incmd_write_data   = data;     // Data to write
            incmd_write_mask   = mask;     // Byte-enable mask (e.g., 8'hFF)
            incmd_size         = 2'b00;    // 8-byte write
            
            wait(dut.incmd_ready == 1'b1); 
            @(posedge clk);
            incmd_valid        = 0;
            incmd_write_enable = 0;
        end
    endtask


    wire [9:0] rsp_tid = core_rsp_tag[64:55];      // Base TID
    wire [7:0] rsp_bitmap = core_rsp_tag[54:47];   // Bitmap showing which TID is active
    
    always @(posedge clk) begin
        if (core_rsp_valid && core_rsp_ready) begin
            $display("[MONITOR] Time: %0t | BaseTID: %0d | Bitmap: %b | Data: %h", 
                     $time, rsp_tid, rsp_bitmap, core_rsp_data);
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
    /*
    // --- Step 1: Verification of Write-Read Path ---
    $display("--- Starting Directed Write-Read Test ---");
    
    send_write_request(32'h0000_0F00, 64'hAAAA_AAAA_AAAA_AAAA, 8'hFF, 0); 
    send_write_request(32'h0000_0F08, 64'hBBBB_BBBB_BBBB_BBBB, 8'hFF, 0); 
    send_write_request(32'h0000_0F10, 64'hCCCC_CCCC_CCCC_CCCC, 8'hFF, 0); 
    
    #(CLK_PERIOD * 500); 
    
    // Read back
    send_read_request(32'h0000_0F00, 0);
    #(CLK_PERIOD * 20); // Small gap between reads
    send_read_request(32'h0000_0F08, 0);
    #(CLK_PERIOD * 20);
    send_read_request(32'h0000_0F10, 0);
    */
        $display("--- Starting Linear Word Sweep ---");
        for (int j = 0; j < 8; j++) begin
            send_read_request(.addr(j * 8), .tid(j)); 
            #(CLK_PERIOD * 10); 
        end

        #(CLK_PERIOD * 100);
        $display("--- All Tests Complete ---");
        $finish;
    end

    initial begin
        $fsdbDumpfile("tb_vx_cache_with_temporal.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule
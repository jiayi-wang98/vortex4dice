module tb_vx_cache_with_temporal;

    parameter CLK_PERIOD = 2.5;
    parameter int NUMBER_OF_MAX_COALESCED_COMMANDS = 8;
    parameter int NUMBER_OF_MAX_COALESCED_INTERVAL = 8;
    parameter int CACHE_LINE_SIZE = 32;
    parameter int BASE_ADDRESS_OFFSET = $clog2(CACHE_LINE_SIZE);
    parameter int BASE_TID_ADDRESS_OFFSET = $clog2(NUMBER_OF_MAX_COALESCED_COMMANDS);
    parameter int EBLOCK_ID_WIDTH = 4;
    parameter int TID_WIDTH = 10;
    parameter int DATA_WIDTH = 64;
    parameter int ADDR_WIDTH = 64;
    parameter int MAX_REG_WIDTH = 7;
    parameter int TID_BITMAP_WIDTH = NUMBER_OF_MAX_COALESCED_COMMANDS;
    parameter int WRITE_MASK_WIDTH = 8;
    parameter int NUM_REQS = 1;
    parameter int MEM_PORTS = 1; 
    parameter int NUM_BANKS = 1;
    parameter int OUTCMD_TAG_WIDTH = NUMBER_OF_MAX_COALESCED_COMMANDS * BASE_ADDRESS_OFFSET + EBLOCK_ID_WIDTH +
        TID_WIDTH + TID_BITMAP_WIDTH + MAX_REG_WIDTH;
    
    // DUT Inputs

    bit clk;
    bit rst;

    bit incmd_valid;
    bit [EBLOCK_ID_WIDTH-1:0] incmd_block_id;
    bit [TID_WIDTH-1:0] incmd_tid;
    bit incmd_write_enable;
    bit [DATA_WIDTH-1:0] incmd_write_data;
    bit [DATA_WIDTH/8-1:0] incmd_write_mask;
    bit [ADDR_WIDTH-1:0] incmd_address;
    bit [1:0] incmd_size;
    bit [MAX_REG_WIDTH-1:0] incmd_ld_dest_reg;
    bit outcmd_ready;

    bit core_rsp_ready;

    bit mem_req_ready;

    bit mem_rsp_valid;
    bit [DATA_WIDTH-1:0] mem_rsp_data;
    bit [OUTCMD_TAG_WIDTH-1:0] mem_rsp_tag;


    // TB outputs

    logic [DATA_WIDTH-1:0] core_rsp_data;
    logic core_rsp_valid;
    logic [OUTCMD_TAG_WIDTH-1:0] core_rsp_tag;
   

    logic mem_req_valid;
    logic mem_req_rw;
    logic [CACHE_LINE_SIZE-1:0] mem_req_byteen;
    logic [26:0] mem_req_addr;
    logic [255:0] mem_req_data;
    logic [46:0] mem_req_tag;

    logic mem_rsp_ready;
   

     // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    smem mem_inst (
        .clk(clk),
        .rst(rst),

        .mem_req_valid(mem_req_valid),
        .mem_req_ready(mem_req_ready),
        .mem_req_rw(mem_req_rw),
        .mem_req_addr(mem_req_addr),
        .mem_req_data(mem_req_data),
        .mem_req_byteen(mem_req_byteen),
        .mem_req_tag(mem_req_tag),

        .mem_rsp_valid(mem_rsp_valid),
        .mem_rsp_ready(mem_rsp_ready),
        .mem_rsp_data(mem_rsp_data),
        .mem_rsp_tag(mem_rsp_tag)
    );

    // Instantiate wrapper
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
    .clk(clk),
    .rst(rst),

    // input commands
    .incmd_valid(incmd_valid),
    .incmd_block_id(incmd_block_id),
    .incmd_tid(incmd_tid),
    .incmd_write_enable(incmd_write_enable),
    .incmd_write_data(incmd_write_data),
    .incmd_write_mask(incmd_write_mask),
    .incmd_address(incmd_address),
    .incmd_size(incmd_size),
    .incmd_ld_dest_reg(incmd_ld_dest_reg),
    .outcmd_ready(outcmd_ready),

    // core response
    .core_rsp_data(core_rsp_data),
    .core_rsp_valid(core_rsp_valid),
    .core_rsp_tag(core_rsp_tag),
    .core_rsp_ready(core_rsp_ready),

    // memory request
    .mem_req_valid(mem_req_valid),
    .mem_req_rw(mem_req_rw),
    .mem_req_byteen(mem_req_byteen),
    .mem_req_addr(mem_req_addr),
    .mem_req_data(mem_req_data),
    .mem_req_tag(mem_req_tag),
    .mem_req_ready(mem_req_ready),

    // memory response
    .mem_rsp_valid(mem_rsp_valid),
    .mem_rsp_data(mem_rsp_data),
    .mem_rsp_tag(mem_rsp_tag),
    .mem_rsp_ready(mem_rsp_ready)
);

    logic [DATA_WIDTH-1] write_data_temp = 'd0;
    int i, idx;
    // ----------------------
    // Reset sequence
    // ----------------------
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end 


    
    initial begin
    // Initialize inputs
    incmd_valid        = 0;
    incmd_block_id     = 0;
    incmd_tid          = 0;
    incmd_write_enable = 0;
    incmd_write_data   = 0;
    incmd_write_mask   = 0;
    incmd_address      = 0;
    incmd_size         = 0;
    incmd_ld_dest_reg  = 0;
    
    
        // Send 4 words to fill cache line
    for (i = 0; i < 128; i = i + 1) begin   
        @(posedge clk);
        // Issue the write
        incmd_valid        = 1;
        incmd_block_id     = 4'd1;
        incmd_tid          = i;
        incmd_write_enable = 1;
        incmd_write_data   = write_data_temp + i;  // 1,2,3,4
        incmd_write_mask   = 8'h00;
        incmd_address      = 64'd0 + i*4; // consecutive addresses
        incmd_size         = 2'b00;
        incmd_ld_dest_reg  = 7'd0;
        outcmd_ready = 1'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        //incmd_write_enable = 0; @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
         if (i == 65) begin
        incmd_write_enable = 0; @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    end
    
      
    // Wait a few cycles to let the command propagate
        //incmd_valid = 0; incmd_write_enable = 0; outcmd_ready = 0; @(posedge clk);
    end
        incmd_write_enable = 0; @(posedge clk);
        
        #1000

       
    $finish;
end

// Check that the core response data matches the expected memory content
always_ff @(posedge clk) begin
    if (core_rsp_valid && core_rsp_ready) begin
        // Assume your memory in TB is called mem_inst.mem
        assert(core_rsp_data == mem_inst.mem[core_rsp_tag[26:0]]) 
        else $error("Mismatch at time %0t: expected %h, got %h",
                    $time,
                    mem_inst.mem[core_rsp_tag[26:0]],
                    core_rsp_data);
    end
end


initial begin
    //dump fsdb
    $fsdbDumpfile("tb_vx_cache_with_temporal.fsdb");
    $fsdbDumpvars("+all");
    end
endmodule


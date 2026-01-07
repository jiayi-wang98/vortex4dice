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

    // Clock and reset
    bit clk;
    bit rst;
    
    // DUT input signals
    bit incmd_valid;
    bit [EBLOCK_ID_WIDTH-1:0] incmd_block_id;
    bit [TID_WIDTH-1:0] incmd_tid;
    bit incmd_write_enable;
    bit [DATA_WIDTH-1:0] incmd_write_data;
    bit [WRITE_MASK_WIDTH-1:0] incmd_write_mask;
    bit [ADDR_WIDTH-1:0] incmd_address;
    bit [1:0] incmd_size;
    bit [MAX_REG_WIDTH-1:0] incmd_ld_dest_reg;
    bit outcmd_ready;
    
    // DUT output signals
    logic incmd_ready;
    logic outcmd_valid;
    logic [EBLOCK_ID_WIDTH-1:0] outcmd_block_id;
    logic [TID_WIDTH-1:0] outcmd_base_tid;
    logic [TID_BITMAP_WIDTH-1:0] outcmd_tid_bitmap;
    logic outcmd_write_enable;
    logic [CACHE_LINE_SIZE*8-1:0] outcmd_write_data;
    logic [CACHE_LINE_SIZE-1:0] outcmd_write_mask;
    logic [ADDR_WIDTH-1:0] outcmd_address;
    logic [1:0] outcmd_size;
    logic [MAX_REG_WIDTH-1:0] outcmd_ld_dest_reg;
    logic [NUMBER_OF_MAX_COALESCED_COMMANDS-1:0][BASE_ADDRESS_OFFSET-1:0] outcmd_address_map;
    
    logic [DATA_WIDTH-1:0] cache_data;
    logic cache_valid;
    logic incmd_ready;
     // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    

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
        
        
        .cache_data(cache_data),
        .cache_valid(cache_valid)
    );
    logic [DATA_WIDTH-1] write_data_temp = 'd0;
    int i;
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
        // Wait until cache can accept the write
        while (!incmd_ready) @(posedge clk);

        // Issue the write
        incmd_valid        = 1;
        incmd_block_id     = 4'd1;
        incmd_tid          = i + 512;
        incmd_write_enable = 1;
        incmd_write_data   = write_data_temp + i;  // 1,2,3,4
        incmd_write_mask   = 8'h00;
        incmd_address      = 64'd0 + i*4; // consecutive addresses
        incmd_size         = 2'b00;
        incmd_ld_dest_reg  = 7'd0;
        outcmd_ready = 1'b1;
        incmd_ready = 1'b1;
        
        @(posedge clk);
        //incmd_valid = 0; incmd_write_enable = 0; outcmd_ready = 0; @(posedge clk);
    end
        outcmd_write_enable = 0; @(posedge clk);

        #10000

       
    $finish;
end

initial begin
$monitor("Time=%0t | incmd_valid=%b | incmd_ready=%b | outcmd_valid=%b | cache_data=%b |  | cache_valid=%b", 
         $time,
         incmd_valid,
         incmd_ready,
         outcmd_valid,
         cache_data,
         cache_valid);

end

initial begin
    //dump fsdb
    $fsdbDumpfile("tb_vx_cache_with_temporal.fsdb");
    $fsdbDumpvars("+all");
    end
endmodule


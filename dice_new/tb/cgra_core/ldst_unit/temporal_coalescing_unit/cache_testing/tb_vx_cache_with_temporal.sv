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
    
    // Memory bus interface array
    VX_mem_bus_if mem_bus_if_inst[MEM_PORTS] ();

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
        .incmd_ready(incmd_ready),
        .mem_bus_if(mem_bus_if_inst.master)
    );

    // ----------------------
    // Clock generation
    // ----------------------
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ----------------------
    // Reset sequence
    // ----------------------
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    // ----------------------
    // Tiny memory model
    // ----------------------
    logic [CACHE_LINE_SIZE*8-1:0] mem [0:255];

    always_ff @(posedge clk) begin
        // Memory interface handshake
        mem_bus_if_inst[0].req_ready <= 1'b1;
        mem_bus_if_inst[0].rsp_valid <= 1'b0;

        if (mem_bus_if_inst[0].req_valid) begin
            if (mem_bus_if_inst[0].req_data.rw) begin
                // STORE
                mem[mem_bus_if_inst[0].req_data.addr] <= mem_bus_if_inst[0].req_data.data;
            end else begin
                // LOAD
                mem_bus_if_inst[0].rsp_valid      <= 1'b1;
                mem_bus_if_inst[0].rsp_data.data <= mem[mem_bus_if_inst[0].req_data.addr];
                mem_bus_if_inst[0].rsp_data.tag  <= mem_bus_if_inst[0].req_data.tag;
            end
        end
    end

    // ----------------------
    // Stimulus: store then load
    // ----------------------
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
        outcmd_ready       = 1;

        // Wait for reset
        @(negedge rst);
        repeat (2) @(posedge clk);

        // ---- STORE 5 -> addr 1 ----
        incmd_valid        = 1;
        incmd_block_id     = 4'd1;
        incmd_tid          = 10'd0;
        incmd_write_enable = 1;
        incmd_write_data   = 64'd5;
        incmd_write_mask   = 8'hFF;
        incmd_address      = 64'd1;
        incmd_size         = 2'b00;
        incmd_ld_dest_reg  = 7'd0;
        @(posedge clk)
        @(posedge clk);
        incmd_valid = 0;
        incmd_write_enable = 0;

        // Wait a few cycles
        repeat(5) @(posedge clk);

        // ---- LOAD from addr 1 ----
        incmd_valid        = 1;
        incmd_write_enable = 0;
        incmd_address      = 64'd1;
        incmd_size         = 2'b00;
        incmd_ld_dest_reg  = 7'd1;

        @(posedge clk);
        incmd_valid = 0;

        // Wait for response from cache/memory
        wait(mem_bus_if_inst[0].rsp_valid);

        $display("LOAD RESULT: %0d", mem_bus_if_inst[0].rsp_data.data);

        $finish;
    end


    always @(posedge clk) begin
    $display("Time=%0t | req_valid=%b | req_ready=%b | req_data=%h | rsp_valid=%b | rsp_data=%h",
             $time,
             mem_bus_if_inst[0].req_valid,
             mem_bus_if_inst[0].req_ready,
             mem_bus_if_inst[0].req_data.data,
             mem_bus_if_inst[0].rsp_valid,
             mem_bus_if_inst[0].rsp_data.data);
end


endmodule

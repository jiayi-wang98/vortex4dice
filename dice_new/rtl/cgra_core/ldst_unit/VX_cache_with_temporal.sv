module VX_cache_with_temporal #(
    parameter int NUMBER_OF_MAX_COALESCED_INTERVAL = 8, // Maximum number of clk cycles to hold internal commands
    parameter int CACHE_LINE_SIZE = 32, // Size of a cache line in bytes
    parameter int NUMBER_OF_MAX_COALESCED_COMMANDS = CACHE_LINE_SIZE/4, // Maximum number of commands that can be coalesced
    parameter int BASE_ADDRESS_OFFSET = $clog2(CACHE_LINE_SIZE), // Width of base address offset in bits
    parameter int BASE_TID_ADDRESS_OFFSET = $clog2(NUMBER_OF_MAX_COALESCED_COMMANDS), // Width of base TID address offset in bits
    parameter int EBLOCK_ID_WIDTH = 4,
    parameter int TID_WIDTH = 10,
    parameter int DATA_WIDTH = 64,
    parameter int ADDR_WIDTH = 64,
    parameter int MAX_REG_WIDTH = 7,
    parameter int TID_BITMAP_WIDTH = NUMBER_OF_MAX_COALESCED_COMMANDS,
    parameter int NUM_REQS = 1,
    parameter int MEM_PORTS = 1 
)(
    input  logic clk,
    input  logic reset,

    input logic incmd_valid,                // Input command valid signal
    input logic [EBLOCK_ID_WIDTH-1:0] incmd_block_id,       // Input command block ID
    input logic [TID_WIDTH-1:0] incmd_tid,            // Input command thread ID
    input logic incmd_write_enable,         // Write enable signal
    input logic [DATA_WIDTH-1:0] incmd_write_data,    // Data to write
    input logic [DATA_WIDTH/8-1:0] incmd_write_mask,     // 1 means no write, 0 means write
    input logic [ADDR_WIDTH-1:0] incmd_address,       // Address for the command
    input logic [1:0] incmd_size,          // Size of the command (e.g., 00=1B, 01=2B, 10=4B, 11=8B)
    input logic [MAX_REG_WIDTH-1:0] incmd_ld_dest_reg,    // Load destination register
   
    VX_mem_bus_if.master    mem_bus_if [MEM_PORTS]
);

    logic outcmd_valid;
    logic [3:0] outcmd_block_id;
    logic [9:0] outcmd_base_tid;
    logic [7:0] outcmd_tid_bitmap;
    logic outcmd_write_enable;
    logic [LINE_SIZE*8-1:0] outcmd_write_data;
    logic [LINE_SIZE-1:0] outcmd_write_mask;
    logic [63:0] outcmd_address;
    logic [1:0] outcmd_size;
    logic [6:0] outcmd_ld_dest_reg;
    logic [7:0][5:0] outcmd_address_map;
    logic outcmd_ready;

    temporal_coalescing_unit temporal_inst (
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
        .outcmd_valid(outcmd_valid),
        .outcmd_block_id(outcmd_block_id),
        .outcmd_base_tid(outcmd_base_tid),
        .outcmd_tid_bitmap(outcmd_tid_bitmap),
        .outcmd_write_enable(outcmd_write_enable),
        .outcmd_write_data(outcmd_write_data),
        .outcmd_write_mask(outcmd_write_mask),
        .outcmd_address(outcmd_address),
        .outcmd_size(outcmd_size),
        .outcmd_ld_dest_reg(outcmd_ld_dest_reg),
        .outcmd_address_map(outcmd_address_map),
        .outcmd_ready(outcmd_ready) // always ready for simplicity
    );
    VX_mem_bus_if.slave #(
        .DATA_SIZE(DATA_WIDTH/8),
        // Tag include out_cmb_block_id, base_tid, tid_bitmap, ld destination register, address_map)

    )   request_if [NUM_REQS]; 
    assign request_if[0].req_valid = outcmd_valid;
    assign request_if[0].data.rw = outcmd_write_enable;
    assign outcmd_ready = request_if[0].req_ready
    assign data into cache?



    VX_cache cache_inst (
        .clk(clk),
        .reset(rst),
        .core_bus_if(request_if), // will wire manually below
        .mem_bus_if(mem_bus_if)   // tie memory ports as needed
    );

endmodule


   
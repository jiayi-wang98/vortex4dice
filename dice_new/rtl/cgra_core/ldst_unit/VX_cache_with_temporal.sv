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
    parameter int MEM_PORTS = 1, 
    parameter int NUM_BANKS = 1
)(
    input logic clk,
    input logic rst,

    input logic incmd_valid,                // Input command valid signal
    input logic [EBLOCK_ID_WIDTH-1:0] incmd_block_id,       // Input command block ID
    input logic [TID_WIDTH-1:0] incmd_tid,            // Input command thread ID
    input logic incmd_write_enable,         // Write enable signal
    input logic [DATA_WIDTH-1:0] incmd_write_data,    // Data to write
    input logic [DATA_WIDTH/8-1:0] incmd_write_mask,     // 1 means no write, 0 means write
    input logic [ADDR_WIDTH-1:0] incmd_address,       // Address for the command
    input logic [1:0] incmd_size,          // Size of the command (e.g., 00=1B, 01=2B, 10=4B, 11=8B)
    input logic [MAX_REG_WIDTH-1:0] incmd_ld_dest_reg,    // Load destination register
    input logic outcmd_ready,
    
    input logic [DATA_WIDTH-1:0] incmd_mem_data,
    
    input logic mem_req_ready,

    output logic mem_req_valid,
    output logic mem_req_rw,
    output logic [CACHE_LINE_SIZE-1:0] mem_req_byteen,
    output logic [26:0] mem_req_addr,
    output logic [255:0] mem_req_data,
    output logic [47:0] mem_req_tag,
    
    output logic mem_rsp_ready,

    output logic [DATA_WIDTH-1:0] cache_data,
    output logic cache_valid
    
);  
    logic core_req_ready;
    logic incmd_ready;           // Ready signal for input command
    logic cache_perf;
    logic outcmd_valid;              // Output command valid signal
    logic [EBLOCK_ID_WIDTH-1:0] outcmd_block_id;    // Output command block ID
    logic [TID_WIDTH-1:0] outcmd_base_tid;     // Output command thread ID
    logic [TID_BITMAP_WIDTH-1:0] outcmd_tid_bitmap;  // Bitmap of TIDs for the command
    logic outcmd_write_enable;       // Write enable signal
    logic [CACHE_LINE_SIZE*8-1:0] outcmd_write_data;  // Data to write
    logic [CACHE_LINE_SIZE-1:0] outcmd_write_mask; // 1 means no write, 0 means write
    logic [ADDR_WIDTH-1:0] outcmd_address;     // Address for the command
    logic [1:0] outcmd_size;        // Size of the command (e.g., 00=1B, 01=2B, 10=4B, 11=8B)
    logic [MAX_REG_WIDTH-1:0] outcmd_ld_dest_reg;  // Load destination register
    logic [NUMBER_OF_MAX_COALESCED_COMMANDS-1:0][BASE_ADDRESS_OFFSET-1:0] outcmd_address_map; //map from tid bitmap to address_offset
    
    logic mem_rsp_valid;
    
    typedef struct packed {
    logic [EBLOCK_ID_WIDTH-1:0] outcmd_block_id;
    logic [TID_WIDTH-1:0]       outcmd_base_tid;
    logic [TID_BITMAP_WIDTH-1:0] outcmd_tid_bitmap;
    logic [MAX_REG_WIDTH-1:0]   outcmd_ld_dest_reg;
    logic [NUMBER_OF_MAX_COALESCED_COMMANDS-1:0]
          [BASE_ADDRESS_OFFSET-1:0] outcmd_address_map;
    } outcmd_tag_t;

    outcmd_tag_t core_tag_req;
    outcmd_tag_t core_tag_rsp;
    outcmd_tag_t mem_tag_rsp;
    assign mem_tag_rsp = mem_req_tag;
    assign core_tag_req = {outcmd_block_id, outcmd_base_tid, outcmd_tid_bitmap, outcmd_ld_dest_reg, outcmd_address_map};
    

    typedef struct packed {
    logic [EBLOCK_ID_WIDTH-1:0] incmd_block_id;
    logic [TID_WIDTH-1:0]       incmd_base_tid;
    logic [TID_BITMAP_WIDTH-1:0] incmd_tid_bitmap;
    logic [MAX_REG_WIDTH-1:0]   incmd_ld_dest_reg;
    logic [NUMBER_OF_MAX_COALESCED_COMMANDS-1:0]
          [BASE_ADDRESS_OFFSET-1:0] incmd_address_map;
    } incmd_tag_t;


    localparam int OUTCMD_TAG_WIDTH = $bits(outcmd_tag_t);

    

    // Temporal instantiation 
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
        .outcmd_ready(outcmd_ready) 
    );

    always_comb begin
    mem_rsp_valid = 0; // Default value to avoid latches
    if (mem_req_valid && mem_req_ready) begin
        mem_rsp_valid = 1; // Blocking assignment
    end
end
    VX_cache_top #(
    .NUM_REQS(NUM_REQS),
    .LINE_SIZE(CACHE_LINE_SIZE),
    .NUM_BANKS(NUM_BANKS),
    .TAG_WIDTH(OUTCMD_TAG_WIDTH),
    .WORD_SIZE(8)
    ) cache_inst (
    .clk(clk),
    .reset(rst),
    .core_req_valid('{outcmd_valid}),            // Array literal with 1 element
    .core_req_rw('{outcmd_write_enable}),
    .core_req_byteen('{outcmd_write_mask}),
    .core_req_addr('{outcmd_address}),
    .core_req_flags('{default: 0}),
    .core_req_data('{outcmd_write_data}),
    .core_req_tag('{core_tag_req}),
    .core_req_ready('{core_req_ready}),


    .core_rsp_valid('{cache_valid}),
    .core_rsp_data('{cache_data}),
    .core_rsp_tag('{core_tag_rsp}),
    .core_rsp_ready('{incmd_ready}), 

    .mem_req_valid('{mem_req_valid}),
    .mem_req_rw('{mem_req_rw}),
    .mem_req_byteen('{mem_req_byteen}),
    .mem_req_addr('{mem_req_addr}),
    .mem_req_data('{mem_req_data}),
    .mem_req_tag('{mem_req_tag}),
    .mem_req_ready('{mem_req_ready}), 

    .mem_rsp_valid('{mem_rsp_valid}), 
    .mem_rsp_data('{incmd_mem_data}),
    .mem_rsp_tag('{core_tag_req}),
    .mem_rsp_ready('{mem_rsp_ready}) 
);


endmodule


   
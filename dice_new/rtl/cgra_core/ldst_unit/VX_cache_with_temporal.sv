module VX_cache_with_temporal #(
    parameter int NUMBER_OF_MAX_COALESCED_INTERVAL = 8, 
    parameter int CACHE_LINE_SIZE = 32,
    parameter int NUMBER_OF_MAX_COALESCED_COMMANDS = CACHE_LINE_SIZE/4,
    parameter int BASE_ADDRESS_OFFSET = $clog2(CACHE_LINE_SIZE), 
    parameter int BASE_TID_ADDRESS_OFFSET = $clog2(NUMBER_OF_MAX_COALESCED_COMMANDS),
    parameter int EBLOCK_ID_WIDTH = 4,
    parameter int TID_WIDTH = 10,
    parameter int DATA_WIDTH = 64,
    parameter int ADDR_WIDTH = 32,
    parameter int MAX_REG_WIDTH = 7,
    parameter int TID_BITMAP_WIDTH = NUMBER_OF_MAX_COALESCED_COMMANDS,
    parameter int NUM_REQS = 1,
    parameter int MEM_PORTS = 1, 
    parameter int NUM_BANKS = 1,
    parameter int MSHR_SIZE = 16,
    parameter MSHR_BITS = $clog2(MSHR_SIZE),
    parameter int OUTCMD_TAG_WIDTH = NUMBER_OF_MAX_COALESCED_COMMANDS * BASE_ADDRESS_OFFSET + EBLOCK_ID_WIDTH +
        TID_WIDTH + TID_BITMAP_WIDTH + MAX_REG_WIDTH,
    parameter MEM_TAG_WIDTH = OUTCMD_TAG_WIDTH + MSHR_BITS,
    parameter MEM_ADDR_WIDTH = ADDR_WIDTH - $clog2(CACHE_LINE_SIZE)
)(
    input logic clk,
    input logic rst,

    input logic incmd_valid,                
    input logic [EBLOCK_ID_WIDTH-1:0] incmd_block_id,       
    input logic [TID_WIDTH-1:0] incmd_tid,            
    input logic incmd_write_enable,         
    input logic [DATA_WIDTH-1:0] incmd_write_data,    
    input logic [DATA_WIDTH/8-1:0] incmd_write_mask,     
    input logic [ADDR_WIDTH-1:0] incmd_address,       
    input logic [1:0] incmd_size,          
    input logic [MAX_REG_WIDTH-1:0] incmd_ld_dest_reg,    
    input logic outcmd_ready,

    output logic [CACHE_LINE_SIZE*8-1:0] core_rsp_data, 
    output logic core_rsp_valid,
    output logic [OUTCMD_TAG_WIDTH-1:0] core_rsp_tag,
    input  logic core_rsp_ready,

    output logic mem_req_valid,
    output logic mem_req_rw,
    output logic [CACHE_LINE_SIZE-1:0] mem_req_byteen,
    output logic [MEM_ADDR_WIDTH-1:0] mem_req_addr,
    output logic [255:0] mem_req_data,
    output logic [MEM_TAG_WIDTH-1:0] mem_req_tag,
    input logic mem_req_ready,
    
    input logic mem_rsp_valid,
    input logic [255:0] mem_rsp_data,
    input logic [MEM_TAG_WIDTH-1:0] mem_rsp_tag,
    output logic mem_rsp_ready
);  

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
    
    logic core_req_ready;
    
    typedef struct packed {
    logic [EBLOCK_ID_WIDTH-1:0] outcmd_block_id;
    logic [TID_WIDTH-1:0]       outcmd_base_tid;
    logic [TID_BITMAP_WIDTH-1:0] outcmd_tid_bitmap;
    logic [MAX_REG_WIDTH-1:0]   outcmd_ld_dest_reg;
    logic [NUMBER_OF_MAX_COALESCED_COMMANDS-1:0]
          [BASE_ADDRESS_OFFSET-1:0] outcmd_address_map;
    } outcmd_tag_t; 
    
    outcmd_tag_t core_req_tag;

    assign core_req_tag = {
        outcmd_block_id,
        outcmd_base_tid,
        outcmd_tid_bitmap,
        outcmd_ld_dest_reg,
        outcmd_address_map
    };

    temporal_coalescing_unit # (
        .ADDR_WIDTH(ADDR_WIDTH)
    ) temporal_inst (
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
        .outcmd_ready(core_req_ready) 
    );

    VX_cache_top #(
        .NUM_REQS(1),          
        .LINE_SIZE(CACHE_LINE_SIZE), 
        .NUM_BANKS(1),         
        .TAG_WIDTH(OUTCMD_TAG_WIDTH),
        .WORD_SIZE(CACHE_LINE_SIZE), 
        .MEM_TAG_WIDTH(MEM_TAG_WIDTH)
    ) cache_inst (
        .clk(clk),
        .reset(rst),

        .core_req_valid('{outcmd_valid}),
        .core_req_rw('{outcmd_write_enable}),
        .core_req_byteen('{~outcmd_write_mask}), 
        .core_req_addr('{outcmd_address[ADDR_WIDTH-1 : BASE_ADDRESS_OFFSET]}),     
        .core_req_data('{outcmd_write_data}),   
        .core_req_tag('{core_req_tag}),
        .core_req_ready('{core_req_ready}),
        .core_req_flags('{default: 0}),

        .core_rsp_valid('{core_rsp_valid}),
        
        .core_rsp_data('{core_rsp_data}), 
        
        .core_rsp_tag('{core_rsp_tag}),
        .core_rsp_ready('{core_rsp_ready}),

        .mem_req_valid('{mem_req_valid}),
        .mem_req_rw('{mem_req_rw}),
        .mem_req_byteen('{mem_req_byteen}),
        .mem_req_addr('{mem_req_addr}),
        .mem_req_data('{mem_req_data}),
        .mem_req_tag('{mem_req_tag}),
        .mem_req_ready('{mem_req_ready}), 

        .mem_rsp_valid('{mem_rsp_valid}), 
        .mem_rsp_data('{mem_rsp_data}),
        .mem_rsp_tag('{mem_rsp_tag}),
        .mem_rsp_ready('{mem_rsp_ready})
    );
    
endmodule
// =============================================================================
// VX_cache_4temporal — 4 temporal coalescing units sharing ONE L1 cache.
//
// Architecture (replaces the 4->1 serializer + single-TMCU VX_cache_with_temporal):
//   CGRA port p  ->  temporal_coalescing_unit[p]  ->  VX_cache_top core_req[p]
//                                                       (NUM_REQS=4 request
//                                                        crossbar = the arbiter
//                                                        in front of the L1)
//   VX_cache_top core_rsp[0..3]  ->  round-robin merge  ->  single core_rsp out
//
// Each port coalesces independently (no pre-cache serialization), then the
// cache's built-in NUM_REQS->NUM_BANKS crossbar arbitrates the 4 coalesced
// streams before the L1. Responses are merged round-robin to a single stream; the
// per-response tag carries all (port-independent) metadata the consumer needs to
// expand the coalesced line in one cycle (DE_pkg assemble_ldst_wr / gen_wb_tid_bitmap).
// =============================================================================
module VX_cache_4temporal
  import dice_pkg::*;
  import DE_pkg::*;
#(
    parameter int NUM_REQS  = NUM_MEM_PORTS,   // one core request port per TMCU (=4)
    parameter int NUM_BANKS = 1,               // L1 banks (1 = full arbitration before the bank)
    parameter int MSHR_SIZE = 16,
    parameter int MSHR_BITS = $clog2(MSHR_SIZE),

    parameter int OUTCMD_TAG_WIDTH = (DICE_NUMBER_OF_MAX_COALESCED_COMMANDS * DICE_BASE_ADDRESS_OFFSET) +
                                     DICE_EBLOCK_ID_WIDTH +
                                     DICE_TID_WIDTH +
                                     DICE_TID_BITMAP_WIDTH +
                                     DICE_MAX_REG_WIDTH,
    parameter int MEM_TAG_WIDTH  = OUTCMD_TAG_WIDTH + MSHR_BITS,
    parameter int MEM_ADDR_WIDTH = DICE_ADDR_WIDTH - $clog2(DICE_CACHE_LINE_SIZE),
    parameter int SEL_W          = (NUM_REQS <= 1) ? 1 : $clog2(NUM_REQS)
)(
    input  logic clk,
    input  logic rst,

    // ---- 4 incmd ports (one per CGRA memory port) ----
    input  logic [NUM_REQS-1:0]                          incmd_valid,
    input  logic [NUM_REQS-1:0][DICE_EBLOCK_ID_WIDTH-1:0] incmd_block_id,
    input  logic [NUM_REQS-1:0][DICE_TID_WIDTH-1:0]      incmd_tid,
    input  logic [NUM_REQS-1:0]                          incmd_write_enable,
    input  logic [NUM_REQS-1:0][DICE_DATA_WIDTH-1:0]     incmd_write_data,
    input  logic [NUM_REQS-1:0][(DICE_DATA_WIDTH/8)-1:0] incmd_write_mask,
    input  logic [NUM_REQS-1:0][DICE_ADDR_WIDTH-1:0]     incmd_address,
    input  logic [NUM_REQS-1:0][1:0]                     incmd_size,
    input  logic [NUM_REQS-1:0][DICE_MAX_REG_WIDTH-1:0]  incmd_ld_dest_reg,
    output logic [NUM_REQS-1:0]                          incmd_ready,

    // ---- merged coalesced-line response (to RF writeback + scoreboard release) ----
    output logic [DICE_CACHE_LINE_SIZE*8-1:0] core_rsp_data,
    output logic                              core_rsp_valid,
    output logic [OUTCMD_TAG_WIDTH-1:0]       core_rsp_tag,
    input  logic                              core_rsp_ready,

    // ---- L1 mem-side (single mem port) ----
    output logic                              mem_req_valid,
    output logic                              mem_req_rw,
    output logic [DICE_CACHE_LINE_SIZE-1:0]   mem_req_byteen,
    output logic [MEM_ADDR_WIDTH-1:0]         mem_req_addr,
    output logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_req_data,
    output logic [MEM_TAG_WIDTH-1:0]          mem_req_tag,
    input  logic                              mem_req_ready,
    input  logic                              mem_rsp_valid,
    input  logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_rsp_data,
    input  logic [MEM_TAG_WIDTH-1:0]          mem_rsp_tag,
    output logic                              mem_rsp_ready
);

  typedef struct packed {
    logic [DICE_EBLOCK_ID_WIDTH-1:0]  outcmd_block_id;
    logic [DICE_TID_WIDTH-1:0]        outcmd_base_tid;
    logic [DICE_TID_BITMAP_WIDTH-1:0] outcmd_tid_bitmap;
    logic [DICE_MAX_REG_WIDTH-1:0]    outcmd_ld_dest_reg;
    logic [DICE_NUMBER_OF_MAX_COALESCED_COMMANDS-1:0]
          [DICE_BASE_ADDRESS_OFFSET-1:0] outcmd_address_map;
  } outcmd_tag_t;

  // ---- VX_cache_top NUM_REQS array ports (unpacked) ----
  logic                          core_req_valid_a [NUM_REQS];
  logic                          core_req_rw_a    [NUM_REQS];
  logic [DICE_CACHE_LINE_SIZE-1:0] core_req_byteen_a [NUM_REQS];
  logic [(DICE_ADDR_WIDTH-DICE_BASE_ADDRESS_OFFSET)-1:0] core_req_addr_a [NUM_REQS];
  logic [DICE_CACHE_LINE_SIZE*8-1:0] core_req_data_a [NUM_REQS];
  logic [OUTCMD_TAG_WIDTH-1:0]   core_req_tag_a   [NUM_REQS];
  logic                          core_req_ready_a [NUM_REQS];

  logic                          core_rsp_valid_a [NUM_REQS];
  logic [DICE_CACHE_LINE_SIZE*8-1:0] core_rsp_data_a [NUM_REQS];
  logic [OUTCMD_TAG_WIDTH-1:0]   core_rsp_tag_a   [NUM_REQS];
  logic                          core_rsp_ready_a [NUM_REQS];

  // ---- one TMCU per port; pack its outcmd into the cache request ----
  for (genvar p = 0; p < NUM_REQS; p++) begin : gen_tmcu
    logic                              o_valid;
    logic [DICE_EBLOCK_ID_WIDTH-1:0]   o_block_id;
    logic [DICE_TID_WIDTH-1:0]         o_base_tid;
    logic [DICE_TID_BITMAP_WIDTH-1:0]  o_tid_bitmap;
    logic                              o_write_enable;
    logic [DICE_CACHE_LINE_SIZE*8-1:0] o_write_data;
    logic [DICE_CACHE_LINE_SIZE-1:0]   o_write_mask;
    logic [DICE_ADDR_WIDTH-1:0]        o_address;
    logic [1:0]                        o_size;
    logic [DICE_MAX_REG_WIDTH-1:0]     o_ld_dest_reg;
    logic [DICE_NUMBER_OF_MAX_COALESCED_COMMANDS-1:0][DICE_BASE_ADDRESS_OFFSET-1:0] o_address_map;
    outcmd_tag_t o_tag;

    temporal_coalescing_unit u_tmcu (
        .clk(clk),
        .rst(rst),
        .incmd_valid(incmd_valid[p]),
        .incmd_block_id(incmd_block_id[p]),
        .incmd_tid(incmd_tid[p]),
        .incmd_write_enable(incmd_write_enable[p]),
        .incmd_write_data(incmd_write_data[p]),
        .incmd_write_mask(incmd_write_mask[p]),
        .incmd_address(incmd_address[p]),
        .incmd_size(incmd_size[p]),
        .incmd_ld_dest_reg(incmd_ld_dest_reg[p]),
        .incmd_ready(incmd_ready[p]),
        .outcmd_valid(o_valid),
        .outcmd_block_id(o_block_id),
        .outcmd_base_tid(o_base_tid),
        .outcmd_tid_bitmap(o_tid_bitmap),
        .outcmd_write_enable(o_write_enable),
        .outcmd_write_data(o_write_data),
        .outcmd_write_mask(o_write_mask),
        .outcmd_address(o_address),
        .outcmd_size(o_size),
        .outcmd_ld_dest_reg(o_ld_dest_reg),
        .outcmd_address_map(o_address_map),
        .outcmd_ready(core_req_ready_a[p])   // cache accepts this port's request
    );

    assign o_tag = '{
        outcmd_block_id:   o_block_id,
        outcmd_base_tid:   o_base_tid,
        outcmd_tid_bitmap: o_tid_bitmap,
        outcmd_ld_dest_reg: o_ld_dest_reg,
        outcmd_address_map: o_address_map
    };

    assign core_req_valid_a[p]  = o_valid;
    assign core_req_rw_a[p]     = o_write_enable;
    assign core_req_byteen_a[p] = ~o_write_mask;
    assign core_req_addr_a[p]   = o_address[DICE_ADDR_WIDTH-1 : DICE_BASE_ADDRESS_OFFSET];
    assign core_req_data_a[p]   = o_write_data;
    assign core_req_tag_a[p]    = o_tag;
  end

  // ---- the L1 cache with its NUM_REQS request crossbar ----
  VX_cache_top #(
      .NUM_REQS(NUM_REQS),
      .LINE_SIZE(DICE_CACHE_LINE_SIZE),
      .NUM_BANKS(NUM_BANKS),
      .TAG_WIDTH(OUTCMD_TAG_WIDTH),
      .WORD_SIZE(DICE_CACHE_LINE_SIZE),
      .MEM_TAG_WIDTH(MEM_TAG_WIDTH)
  ) cache_inst (
      .clk(clk),
      .reset(rst),

      .core_req_valid(core_req_valid_a),
      .core_req_rw(core_req_rw_a),
      .core_req_byteen(core_req_byteen_a),
      .core_req_addr(core_req_addr_a),
      .core_req_data(core_req_data_a),
      .core_req_tag(core_req_tag_a),
      .core_req_ready(core_req_ready_a),
      .core_req_flags('{default: 0}),

      .core_rsp_valid(core_rsp_valid_a),
      .core_rsp_data(core_rsp_data_a),
      .core_rsp_tag(core_rsp_tag_a),
      .core_rsp_ready(core_rsp_ready_a),

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

  // ---- round-robin merge of the 4 core_rsp ports into one stream ----
  // The merged tag carries all (port-independent) outcmd metadata the expander
  // needs; only one response drains at a time (the expander is serial anyway).
  logic [SEL_W-1:0] rr_ptr_q;
  logic [SEL_W-1:0] grant_idx;
  logic             grant_valid;

  always_comb begin
    grant_valid = 1'b0;
    grant_idx   = '0;
    for (int k = 0; k < NUM_REQS; k++) begin
      logic [SEL_W-1:0] idx;
      idx = rr_ptr_q + SEL_W'(k);          // natural wrap when NUM_REQS is power-of-2
      if (!grant_valid && core_rsp_valid_a[idx]) begin
        grant_valid = 1'b1;
        grant_idx   = idx;
      end
    end
  end

  assign core_rsp_valid = grant_valid;
  assign core_rsp_data  = core_rsp_data_a[grant_idx];
  assign core_rsp_tag   = core_rsp_tag_a[grant_idx];

  for (genvar i = 0; i < NUM_REQS; i++) begin : gen_rsp_ready
    assign core_rsp_ready_a[i] = grant_valid && (grant_idx == SEL_W'(i)) && core_rsp_ready;
  end

  always_ff @(posedge clk) begin
    if (rst)
      rr_ptr_q <= '0;
    else if (grant_valid && core_rsp_ready)
      rr_ptr_q <= grant_idx + SEL_W'(1);   // advance past the served port
  end

endmodule

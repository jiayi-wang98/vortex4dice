// =============================================================================
// dice_core — DICE CGRA core top for Vortex.
//
// Thin structural top mirroring Mini_Dice: it declares the external core ports
// (CTA launch + complete, metadata/bitstream read masters, data-cache backing
// memory), instantiates exactly TWO children — dice_frontend and dice_backend —
// and wires them with FLATTENED payload signals (no interfaces crossing the
// FE/BE boundary). The only datapath logic here is the VX_mem_bus_if struct
// adaptation for the data cache's backing-memory port.
//
// Hierarchy:
//   dice_core
//   ├─ dice_frontend : cta_schedule_stage, fdr_top
//   └─ dice_backend  : dice_eblock_tracker, dispatcher, dice_mem_dispatch_credit,
//                      dice_cgra_rf (RF + DORA fabric + launch + special + pred),
//                      dice_brt, dice_cgra_prog, dice_tmcu_mem_edge,
//                      dice_ldst_retire
//
// The CGRA fabric is the BUILT 32-bit DORA fabric dice_top (instantiated inside
// dice_cgra_rf); its build dir must be on the compile filelist.
// =============================================================================

module dice_core
  import dice_pkg::*;
  import dice_frontend_pkg::*;
  import DE_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    cta_dispatch_if.slave  cta_dispatch_if_inst,
    cta_complete_if.master cta_complete_if_inst,

    // Memory Bus Interfaces (to Vortex cache hierarchy)
    VX_mem_bus_if.master metacache_mem_if,
    VX_mem_bus_if.master bitstream_cache_mem_if,

    // Data-cache mem-side: the VX_cache_4temporal (data cache) lives INSIDE the
    // backend; its backing-memory request/response port is exported here so the
    // Vortex socket connects it to the next-level memory.
    // TODO(integration): tb_dice_core.sv must instantiate a VX_mem_bus_if
    // (DATA_SIZE = DICE_CACHE_LINE_SIZE, TAG_WIDTH = DCACHE_MEM_TAG_WIDTH) +
    // backing mem on this port.
    VX_mem_bus_if.master dcache_mem_if
);

  localparam int CM_CHUNK_COUNT = (DICE_BITSTREAM_SIZE + DICE_MEM_DATA_WIDTH - 1)
                                  / DICE_MEM_DATA_WIDTH;

  // ---------------------------------------------------------------------------
  // Frontend <-> Backend flattened glue
  // ---------------------------------------------------------------------------
  logic                            fdr_valid;
  fdr_t                            fdr_data;
  logic                            fdr_ready;

  logic [DICE_MEM_DATA_WIDTH-1:0]  cm0_data;
  logic [CM_CHUNK_COUNT-1:0]       cm0_chunk_en;
  logic [DICE_MEM_DATA_WIDTH-1:0]  cm1_data;
  logic [CM_CHUNK_COUNT-1:0]       cm1_chunk_en;

  logic                            eblock_commit_valid;
  logic [DICE_EBLOCK_ID_WIDTH-1:0] eblock_commit_id;
  logic [2**DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_pending;

  // Data-cache backing-memory side (flattened backend <-> dcache_mem_if).
  logic                              mem_req_valid;
  logic                              mem_req_rw;
  logic [DICE_CACHE_LINE_SIZE-1:0]   mem_req_byteen;
  logic [DCACHE_MEM_ADDR_WIDTH-1:0]  mem_req_addr;
  logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_req_data;
  logic [DCACHE_MEM_TAG_WIDTH-1:0]   mem_req_tag;
  logic                              mem_req_ready;
  logic                              mem_rsp_valid;
  logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_rsp_data;
  logic [DCACHE_MEM_TAG_WIDTH-1:0]   mem_rsp_tag;
  logic                              mem_rsp_ready;

  // ---------------------------------------------------------------------------
  // Frontend (CTA schedule + FDR)
  // ---------------------------------------------------------------------------
  dice_frontend #(
      .CM_CHUNK_COUNT(CM_CHUNK_COUNT)
  ) u_dice_frontend (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .cta_dispatch_if_inst(cta_dispatch_if_inst),
      .cta_complete_if_inst(cta_complete_if_inst),
      .metacache_mem_if(metacache_mem_if),
      .bitstream_cache_mem_if(bitstream_cache_mem_if),
      .fdr_valid_o(fdr_valid),
      .fdr_data_o(fdr_data),
      .fdr_ready_i(fdr_ready),
      .cm0_data_o(cm0_data),
      .cm0_chunk_en_o(cm0_chunk_en),
      .cm1_data_o(cm1_data),
      .cm1_chunk_en_o(cm1_chunk_en),
      .eblock_commit_valid_i(eblock_commit_valid),
      .eblock_commit_id_i(eblock_commit_id),
      .hw_cta_pending_i(hw_cta_pending)
  );

  // ---------------------------------------------------------------------------
  // Backend (dispatch / RF+fabric / commit / memory edge)
  // ---------------------------------------------------------------------------
  dice_backend #(
      .CM_CHUNK_COUNT(CM_CHUNK_COUNT)
  ) u_dice_backend (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .fdr_valid_i(fdr_valid),
      .fdr_data_i(fdr_data),
      .fdr_ready_o(fdr_ready),
      .cm0_data_i(cm0_data),
      .cm0_chunk_en_i(cm0_chunk_en),
      .cm1_data_i(cm1_data),
      .cm1_chunk_en_i(cm1_chunk_en),
      .eblock_commit_valid_o(eblock_commit_valid),
      .eblock_commit_id_o(eblock_commit_id),
      .hw_cta_pending_o(hw_cta_pending),
      .mem_req_valid_o(mem_req_valid),
      .mem_req_rw_o(mem_req_rw),
      .mem_req_byteen_o(mem_req_byteen),
      .mem_req_addr_o(mem_req_addr),
      .mem_req_data_o(mem_req_data),
      .mem_req_tag_o(mem_req_tag),
      .mem_req_ready_i(mem_req_ready),
      .mem_rsp_valid_i(mem_rsp_valid),
      .mem_rsp_data_i(mem_rsp_data),
      .mem_rsp_tag_i(mem_rsp_tag),
      .mem_rsp_ready_o(mem_rsp_ready)
  );

  // ---------------------------------------------------------------------------
  // Data-cache mem-side -> VX_mem_bus_if (dcache_mem_if) master.
  // req_data is {rw, addr, data, byteen, flags, tag}; map the fields we have.
  // TODO(width): dcache_mem_if must be DATA_SIZE = DICE_CACHE_LINE_SIZE and
  // TAG_WIDTH = DCACHE_MEM_TAG_WIDTH for these field widths to line up exactly.
  // ---------------------------------------------------------------------------
  assign dcache_mem_if.req_valid        = mem_req_valid;
  assign dcache_mem_if.req_data.rw      = mem_req_rw;
  assign dcache_mem_if.req_data.addr    = mem_req_addr;
  assign dcache_mem_if.req_data.data    = mem_req_data;
  assign dcache_mem_if.req_data.byteen  = mem_req_byteen;
  assign dcache_mem_if.req_data.flags   = '0;
  assign dcache_mem_if.req_data.tag.uuid = mem_req_tag;
  assign mem_req_ready = dcache_mem_if.req_ready;

  assign mem_rsp_valid = dcache_mem_if.rsp_valid;
  assign mem_rsp_data  = dcache_mem_if.rsp_data.data;
  assign mem_rsp_tag   = dcache_mem_if.rsp_data.tag.uuid;
  assign dcache_mem_if.rsp_ready = mem_rsp_ready;

endmodule

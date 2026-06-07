`include "VX_define.vh"

module fdr_top_syn_wrap
  import dice_pkg::*;
  import dice_frontend_pkg::*;
  import VX_gpu_pkg::*;
#(
  parameter int TAG_WIDTH      = DICE_ADDR_WIDTH,
  parameter int BITSTREAM_SIZE = 2056
) (
  input  logic clk_i,
  input  logic rst_i,

  // ---- Schedule interface (cta_sched_if) ----
  input  logic             schedule_valid_i,
  input  schedule_eblock_t schedule_data_i,
  output logic             schedule_ready_o,

  // ---- FDR interface (fdr_if) ----
  output logic fdr_valid_o,
  output fdr_t fdr_data_o,
  input  logic fdr_ready_i,

  // ---- SIMT stack status (simt_stack_status_if) ----
  input  simt_stack_status_entry_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] simt_status_i,

  // ---- Branch prediction (scalar ports) ----
  output branch_predict_interface_t bh_branch_predict_info_o,
  output logic                      bh_branch_predict_info_we_o,
  input  dice_cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_data_i,

  // ---- SIMT stack update (scalar ports) ----
  output logic                            simt_update_valid_o,
  input  logic                            simt_update_ready_i,
  output simt_stack_update_t              simt_update_stack_data_o,
  output logic [DICE_HW_CTA_ID_WIDTH-1:0] simt_update_hw_cta_id_o,
  output cta_size_e                       simt_update_hw_cta_size_o,

  // ---- Eblock flush (scalar ports) ----
  output logic                       eblock_flush_valid_o,
  output logic [EBLOCK_ID_WIDTH-1:0] eblock_flush_id_o,

  // ---- Metacache memory bus (VX_mem_bus_if, flattened) ----
  output logic                                          metacache_req_valid_o,
  output logic                                          metacache_req_rw_o,
  output logic [`MEM_ADDR_WIDTH-`CLOG2(256)-1:0]        metacache_req_addr_o,
  output logic [256*8-1:0]                              metacache_req_data_o,
  output logic [256-1:0]                                metacache_req_byteen_o,
  output logic [MEM_FLAGS_WIDTH-1:0]                    metacache_req_flags_o,
  output logic [TAG_WIDTH-1:0]                          metacache_req_tag_o,
  input  logic                                          metacache_req_ready_i,
  input  logic                                          metacache_rsp_valid_i,
  input  logic [256*8-1:0]                              metacache_rsp_data_i,
  input  logic [TAG_WIDTH-1:0]                          metacache_rsp_tag_i,
  output logic                                          metacache_rsp_ready_o,

  // ---- Bitstream cache memory bus (VX_mem_bus_if, flattened) ----
  output logic                                          bitstream_req_valid_o,
  output logic                                          bitstream_req_rw_o,
  output logic [`MEM_ADDR_WIDTH-`CLOG2(256)-1:0]        bitstream_req_addr_o,
  output logic [256*8-1:0]                              bitstream_req_data_o,
  output logic [256-1:0]                                bitstream_req_byteen_o,
  output logic [MEM_FLAGS_WIDTH-1:0]                    bitstream_req_flags_o,
  output logic [TAG_WIDTH-1:0]                          bitstream_req_tag_o,
  input  logic                                          bitstream_req_ready_i,
  input  logic                                          bitstream_rsp_valid_i,
  input  logic [256*8-1:0]                              bitstream_rsp_data_i,
  input  logic [TAG_WIDTH-1:0]                          bitstream_rsp_tag_i,
  output logic                                          bitstream_rsp_ready_o,

  // ---- CGRA configuration memory (cgra_cm_if, flattened) ----
  output logic [VX_MEM_DATA_WIDTH-1:0]                                                     cm0_data_o,
  output logic [((DICE_BITSTREAM_SIZE + VX_MEM_DATA_WIDTH - 1) / VX_MEM_DATA_WIDTH)-1:0]   cm0_chunk_en_o,
  output logic [VX_MEM_DATA_WIDTH-1:0]                                                     cm1_data_o,
  output logic [((DICE_BITSTREAM_SIZE + VX_MEM_DATA_WIDTH - 1) / VX_MEM_DATA_WIDTH)-1:0]   cm1_chunk_en_o
);

  // ==========================================================================
  // Internal SV interface instances
  // ==========================================================================

  cta_sched_if         schedule_if_inst ();
  fdr_if               fdr_if_inst ();
  simt_stack_status_if simt_status_if_inst ();
  cgra_cm_if           cm0_if_inst ();
  cgra_cm_if           cm1_if_inst ();

  VX_mem_bus_if #(
    .DATA_SIZE (256),
    .TAG_WIDTH (TAG_WIDTH)
  ) metacache_mem_if ();

  VX_mem_bus_if #(
    .DATA_SIZE (256),
    .TAG_WIDTH (TAG_WIDTH)
  ) bitstream_cache_mem_if ();

  // ==========================================================================
  // Wire wrapper inputs → interface instances (DUT inputs)
  // ==========================================================================

  // -- Schedule --
  assign schedule_if_inst.valid = schedule_valid_i;
  assign schedule_if_inst.data  = schedule_data_i;
  assign schedule_ready_o       = schedule_if_inst.ready;

  // -- FDR --
  assign fdr_if_inst.ready = fdr_ready_i;
  assign fdr_valid_o       = fdr_if_inst.valid;
  assign fdr_data_o        = fdr_if_inst.data;

  // -- SIMT status --
  assign simt_status_if_inst.status = simt_status_i;

  // -- Metacache memory bus: request outputs --
  assign metacache_req_valid_o  = metacache_mem_if.req_valid;
  assign metacache_req_rw_o     = metacache_mem_if.req_data.rw;
  assign metacache_req_addr_o   = metacache_mem_if.req_data.addr;
  assign metacache_req_data_o   = metacache_mem_if.req_data.data;
  assign metacache_req_byteen_o = metacache_mem_if.req_data.byteen;
  assign metacache_req_flags_o  = metacache_mem_if.req_data.flags;
  assign metacache_req_tag_o    = metacache_mem_if.req_data.tag.uuid;
  // -- Metacache memory bus: request input --
  assign metacache_mem_if.req_ready = metacache_req_ready_i;
  // -- Metacache memory bus: response inputs --
  assign metacache_mem_if.rsp_valid     = metacache_rsp_valid_i;
  assign metacache_mem_if.rsp_data.data = metacache_rsp_data_i;
  assign metacache_mem_if.rsp_data.tag  = metacache_rsp_tag_i;
  // -- Metacache memory bus: response output --
  assign metacache_rsp_ready_o = metacache_mem_if.rsp_ready;

  // -- Bitstream cache memory bus: request outputs --
  assign bitstream_req_valid_o  = bitstream_cache_mem_if.req_valid;
  assign bitstream_req_rw_o     = bitstream_cache_mem_if.req_data.rw;
  assign bitstream_req_addr_o   = bitstream_cache_mem_if.req_data.addr;
  assign bitstream_req_data_o   = bitstream_cache_mem_if.req_data.data;
  assign bitstream_req_byteen_o = bitstream_cache_mem_if.req_data.byteen;
  assign bitstream_req_flags_o  = bitstream_cache_mem_if.req_data.flags;
  assign bitstream_req_tag_o    = bitstream_cache_mem_if.req_data.tag.uuid;
  // -- Bitstream cache memory bus: request input --
  assign bitstream_cache_mem_if.req_ready = bitstream_req_ready_i;
  // -- Bitstream cache memory bus: response inputs --
  assign bitstream_cache_mem_if.rsp_valid     = bitstream_rsp_valid_i;
  assign bitstream_cache_mem_if.rsp_data.data = bitstream_rsp_data_i;
  assign bitstream_cache_mem_if.rsp_data.tag  = bitstream_rsp_tag_i;
  // -- Bitstream cache memory bus: response output --
  assign bitstream_rsp_ready_o = bitstream_cache_mem_if.rsp_ready;

  // -- CGRA CM outputs --
  assign cm0_data_o     = cm0_if_inst.data;
  assign cm0_chunk_en_o = cm0_if_inst.chunk_en;
  assign cm1_data_o     = cm1_if_inst.data;
  assign cm1_chunk_en_o = cm1_if_inst.chunk_en;

  // ==========================================================================
  // DUT — single fdr_top instance, every port connected
  // ==========================================================================

  fdr_top #(
    .TAG_WIDTH     (TAG_WIDTH),
    .BITSTREAM_SIZE(BITSTREAM_SIZE)
  ) u_fdr_top (
    .clk_i                    (clk_i),
    .rst_i                    (rst_i),

    // Memory buses
    .metacache_mem_if         (metacache_mem_if),
    .bitstream_cache_mem_if   (bitstream_cache_mem_if),

    // Schedule / FDR handshake
    .schedule_if              (schedule_if_inst),
    .fdr_if                   (fdr_if_inst),

    // SIMT stack status
    .simt_status_if           (simt_status_if_inst),

    // Branch prediction (scalar)
    .bh_branch_predict_info_o (bh_branch_predict_info_o),
    .bh_branch_predict_info_we_o(bh_branch_predict_info_we_o),
    .cta_status_data_i        (cta_status_data_i),

    // SIMT stack update (scalar)
    .simt_update_valid_o      (simt_update_valid_o),
    .simt_update_ready_i      (simt_update_ready_i),
    .simt_update_stack_data_o (simt_update_stack_data_o),
    .simt_update_hw_cta_id_o  (simt_update_hw_cta_id_o),
    .simt_update_hw_cta_size_o(simt_update_hw_cta_size_o),

    // CGRA CM
    .cm0_if                   (cm0_if_inst),
    .cm1_if                   (cm1_if_inst),

    // Eblock flush
    .eblock_flush_valid_o     (eblock_flush_valid_o),
    .eblock_flush_id_o        (eblock_flush_id_o)
  );

endmodule

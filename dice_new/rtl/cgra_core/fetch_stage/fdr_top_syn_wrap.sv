`include "VX_define.vh"

module fdr_top_syn_wrap
  import dice_pkg::*;
  import dice_frontend_pkg::*;
#(
  parameter int TAG_WIDTH      = DICE_ADDR_WIDTH,
  parameter int BITSTREAM_SIZE = 2056
) (
  input  logic clk_i,
  input  logic rst_i,

  // ----------------------------
  // Make key handshakes / inputs "unknown" to synthesis (not constants)
  // ----------------------------
  input  logic schedule_valid_i,
  input  logic fdr_ready_i,

  // Drive schedule_if.data without assuming its type:
  // Treat it as a packed blob whose width is $bits(schedule_if.data).
  input  schedule_eblock_t schedule_data_i,

  // SIMT status blob (same idea)
  input  simt_stack_status_entry_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] simt_status_i,

  // Memory response channels as packed blobs (same idea)
  input  logic metacache_rsp_valid_i,
  input  logic [3000:0] metacache_rsp_data_i,
  input  logic bitstream_rsp_valid_i,
  input  logic [3000:0] bitstream_rsp_data_i,

  // Ready from “memory” (so req_fire can happen if you want it to)
  input  logic metacache_req_ready_i,
  input  logic bitstream_req_ready_i,

  // ----------------------------
  // Export some DUT-observable outputs so logic can't be deleted
  // ----------------------------
  output logic fdr_valid_o,
  output fdr_t fdr_data_o,

  output logic eblock_flush_valid_o,
  output logic [EBLOCK_ID_WIDTH-1:0] eblock_flush_id_o,

  // Export memory requests (keeps those cones alive too)
  output logic metacache_req_valid_o,
  output logic [3000:0] metacache_req_data_o,
  output logic bitstream_req_valid_o,
  output logic [3000:0] bitstream_req_data_o
);

  // --------------------------------------------------------------------------
  // Instantiate the interfaces with explicit parameters (fixes your TAG_WIDTH)
  // --------------------------------------------------------------------------
  VX_mem_bus_if #(
    .DATA_SIZE(256),
    .TAG_WIDTH(TAG_WIDTH)
  ) metacache_mem_if();

  VX_mem_bus_if #(
    .DATA_SIZE(256),
    .TAG_WIDTH(TAG_WIDTH)
  ) bitstream_cache_mem_if();

  // Other SV interfaces used as ports
  cta_sched_if         schedule_if();
  fdr_if               fdr_if();
  simt_stack_status_if simt_status_if();
  cgra_cm_if           cm0_if();
  cgra_cm_if           cm1_if();

  // --------------------------------------------------------------------------
  // Drive DUT inputs from wrapper *ports* (not constants)
  // --------------------------------------------------------------------------
  assign schedule_if.valid = schedule_valid_i;
  assign schedule_if.data  = schedule_data_i;     // assumes schedule_if.data is packed

  assign fdr_if.ready      = fdr_ready_i;

  assign simt_status_if.status = simt_status_i;   // assumes status is packed

  // Memory bus “environment”
  assign metacache_mem_if.req_ready = metacache_req_ready_i;
  assign metacache_mem_if.rsp_valid = metacache_rsp_valid_i;
  assign metacache_mem_if.rsp_data  = metacache_rsp_data_i[$bits(metacache_mem_if.rsp_data)-1:0];

  assign bitstream_cache_mem_if.req_ready = bitstream_req_ready_i;
  assign bitstream_cache_mem_if.rsp_valid = bitstream_rsp_valid_i;
  assign bitstream_cache_mem_if.rsp_data  = bitstream_rsp_data_i[$bits(bitstream_cache_mem_if.rsp_data)-1:0];

  // --------------------------------------------------------------------------
  // DUT
  // --------------------------------------------------------------------------
  fdr_top #(
    .TAG_WIDTH(TAG_WIDTH),
    .BITSTREAM_SIZE(BITSTREAM_SIZE)
  ) dut (
    .clk_i(clk_i),
    .rst_i(rst_i),

    .metacache_mem_if(metacache_mem_if),
    .bitstream_cache_mem_if(bitstream_cache_mem_if),

    .schedule_if(schedule_if),
    .fdr_if(fdr_if),
    .simt_status_if(simt_status_if),

    .cm0_if(cm0_if),
    .cm1_if(cm1_if),

    .bh_branch_predict_info_o(),
    .bh_branch_predict_info_we_o(),
    .cta_status_data_i('0),

    .simt_update_valid_o(),
    .simt_update_ready_i(1'b1),
    .simt_update_stack_data_o(),
    .simt_update_hw_cta_id_o(),
    .simt_update_hw_cta_size_o(),

    .eblock_flush_valid_o(eblock_flush_valid_o),
    .eblock_flush_id_o(eblock_flush_id_o)
  );

  // --------------------------------------------------------------------------
  // Export “keep-alive” outputs
  // --------------------------------------------------------------------------
  assign fdr_valid_o = fdr_if.valid;
  assign fdr_data_o  = fdr_if.data;  // assumes fdr_if.data is packed

  assign metacache_req_valid_o  = metacache_mem_if.req_valid;
  assign metacache_req_data_o   = metacache_mem_if.req_data;

  assign bitstream_req_valid_o  = bitstream_cache_mem_if.req_valid;
  assign bitstream_req_data_o   = bitstream_cache_mem_if.req_data;

endmodule
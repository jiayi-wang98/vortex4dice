// =============================================================================
// dice_ldst_retire — coalesced load-response retire (extracted from dice_core).
//
// Off the merged cache core-response tag (dice_tmcu_mem_edge): accept the whole
// coalesced line into the RF, release its returning threads
// (scoreboard_wb_tid_bitmap) and the one dest register the group shares
// (dispatch_wb_regs_bitmap), and pack the RF LDST writeback command
// (cache_wr_cmd). The RF expands the line per coalesced word in one cycle
// (DE_pkg assemble_ldst_wr); the thread release is one cycle too
// (DE_pkg gen_wb_tid_bitmap) — no serial per-thread response expander.
//
// The cache response is accepted (core_rsp_ready_o) when the RF LDST buffer can
// take the line (rf_ldst_ready_i); the scoreboard/reg release fires on that
// accept (ldst_wb_fire_o).
// =============================================================================
module dice_ldst_retire
  import dice_pkg::*;
  import dice_frontend_pkg::*;
  import DE_pkg::*;
(
    // ---- Merged coalesced-line response from the cache (dice_tmcu_mem_edge) ----
    input  logic                               core_rsp_valid_i,
    input  logic [DCACHE_OUTCMD_TAG_WIDTH-1:0] core_rsp_tag_i,
    input  logic [DICE_CACHE_LINE_SIZE*8-1:0]  core_rsp_data_i,

    // RF LDST buffer can accept a line this cycle (from dice_cgra_rf).
    input  logic                               rf_ldst_ready_i,

    // ---- Outputs ----
    // Cache response accepted when the RF buffer can take the line.
    output logic                               core_rsp_ready_o,
    // Whole coalesced line accepted by the RF this cycle.
    output logic                               ldst_wb_fire_o,
    // Returning threads of the line (scoreboard release) — one cycle, no expander.
    output logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] scoreboard_wb_tid_bitmap_o,
    // One-hot dest-register release (the whole coalesced group shares one reg).
    output logic [REG_NUM-1:0]                 dispatch_wb_regs_bitmap_o,
    // Packed RF LDST writeback (RF expands per coalesced word via assemble_ldst_wr).
    output cache_wr_cmd                        rf_ldst_wr_o
);

  // Unpack the cache response tag (MSB-first pack order; dice_pkg::dcache_outcmd_tag_t
  // mirrors VX_cache_4temporal's outcmd_tag_t).
  dcache_outcmd_tag_t core_rsp_tag_unpacked;
  assign core_rsp_tag_unpacked = core_rsp_tag_i;

  assign core_rsp_ready_o = rf_ldst_ready_i;
  assign ldst_wb_fire_o   = core_rsp_valid_i & core_rsp_ready_o;

  assign scoreboard_wb_tid_bitmap_o = ldst_wb_fire_o
      ? gen_wb_tid_bitmap(core_rsp_tag_unpacked.outcmd_base_tid,
                          core_rsp_tag_unpacked.outcmd_tid_bitmap,
                          core_rsp_tag_unpacked.outcmd_address_map)
      : '0;
  assign dispatch_wb_regs_bitmap_o = ldst_wb_fire_o
      ? (REG_NUM'(1'b1) << core_rsp_tag_unpacked.outcmd_ld_dest_reg)
      : '0;

  // Pack the cache_wr_cmd for the RF LDST writeback directly from the unpacked
  // response tag + the returned line (this is exactly what cache_wr_cmd holds).
  always_comb begin
    rf_ldst_wr_o.outcmd_base_tid    = core_rsp_tag_unpacked.outcmd_base_tid;
    rf_ldst_wr_o.outcmd_tid_bitmap  = core_rsp_tag_unpacked.outcmd_tid_bitmap;
    rf_ldst_wr_o.outcmd_ld_dest_reg = DICE_REG_ADDR_WIDTH'(core_rsp_tag_unpacked.outcmd_ld_dest_reg);
    rf_ldst_wr_o.outcmd_address_map = core_rsp_tag_unpacked.outcmd_address_map;
    rf_ldst_wr_o.core_rsp_data      = core_rsp_data_i;
    rf_ldst_wr_o.e_block_id         = EBLOCK_ID_W'(core_rsp_tag_unpacked.outcmd_block_id);
  end

endmodule

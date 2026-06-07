// =============================================================================
// dice_tmcu_mem_edge — the Vortex memory edge (extracted from dice_core).
//
//   4x temporal_coalescing_unit (one per CGRA mem port, independent coalescing)
//     -> VX_cache_4temporal: VX_cache_top NUM_REQS=4 request crossbar arbitrates
//        the 4 coalesced streams before the L1; responses merged round-robin.
//   The returned coalesced line is written to the RF and its threads released in
//   ONE cycle downstream (dice_ldst_retire + DE_pkg helpers) — no serial expander.
//
// The data cache lives INSIDE this module; its backing-memory side is exposed as
// flattened mem_req_*/mem_rsp_* ports which dice_core adapts to the VX_mem_bus_if
// (dcache_mem_if) master. Tag/addr widths come from dice_pkg DCACHE_* so this
// edge, dice_ldst_retire, and the backend wiring all agree.
// =============================================================================
module dice_tmcu_mem_edge
  import dice_pkg::*;
  import DE_pkg::*;
#(
    parameter int NUM_BANKS = 1   // L1 banks (1 = full arbitration before the bank)
)(
    input  logic clk_i,
    input  logic rst_i,

    // ---- CGRA memory ops (per port) from dice_cgra_rf ----
    input  logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_valid_i,
    input  logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_op_i,    // 0=ld 1=st
    input  logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_addr_i,
    input  logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_data_i,
    input  logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] cgra_mem_rsp_addr_i,
    input  logic [DICE_TID_WIDTH-1:0]                         cgra_tid_i,
    input  logic [DICE_EBLOCK_ID_WIDTH-1:0]                   cgra_e_block_id_i,
    output logic [NUM_MEM_PORTS-1:0]                          tmcu_incmd_ready_o,

    // ---- Merged coalesced-line response -> dice_ldst_retire ----
    output logic [DICE_CACHE_LINE_SIZE*8-1:0]  core_rsp_data_o,
    output logic                               core_rsp_valid_o,
    output logic [DCACHE_OUTCMD_TAG_WIDTH-1:0] core_rsp_tag_o,
    input  logic                               core_rsp_ready_i,

    // ---- Backing-memory side (flattened; dice_core adapts to dcache_mem_if) ----
    output logic                              mem_req_valid_o,
    output logic                              mem_req_rw_o,
    output logic [DICE_CACHE_LINE_SIZE-1:0]   mem_req_byteen_o,
    output logic [DCACHE_MEM_ADDR_WIDTH-1:0]  mem_req_addr_o,
    output logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_req_data_o,
    output logic [DCACHE_MEM_TAG_WIDTH-1:0]   mem_req_tag_o,
    input  logic                              mem_req_ready_i,
    input  logic                              mem_rsp_valid_i,
    input  logic [DICE_CACHE_LINE_SIZE*8-1:0] mem_rsp_data_i,
    input  logic [DCACHE_MEM_TAG_WIDTH-1:0]   mem_rsp_tag_i,
    output logic                              mem_rsp_ready_o
);

  // Per-port replicated/constant incmd fields. tid + block_id are shared by the
  // whole CGRA result; size/write_mask are placeholders until the instruction
  // metadata carries per-op size/byte-enable.
  logic [NUM_MEM_PORTS-1:0][DICE_TID_WIDTH-1:0]       incmd_tid_a;
  logic [NUM_MEM_PORTS-1:0][DICE_EBLOCK_ID_WIDTH-1:0] incmd_block_id_a;
  logic [NUM_MEM_PORTS-1:0][1:0]                      incmd_size_a;
  logic [NUM_MEM_PORTS-1:0][DICE_DATA_WIDTH/8-1:0]    incmd_write_mask_a;
  always_comb begin
    for (int p = 0; p < NUM_MEM_PORTS; p++) begin
      incmd_tid_a[p]        = cgra_tid_i;
      incmd_block_id_a[p]   = cgra_e_block_id_i;
      incmd_size_a[p]       = 2'b10;   // TODO: per-op size from instruction metadata
      incmd_write_mask_a[p] = '0;      // TODO: per-op byte-enable
    end
  end

  // FOUR temporal coalescing units (one per CGRA mem port) sharing ONE L1 cache;
  // VX_cache_top's NUM_REQS request crossbar arbitrates the 4 coalesced streams
  // before the bank. Responses are merged round-robin to one stream.
  VX_cache_4temporal #(
      .NUM_REQS (NUM_MEM_PORTS),
      .NUM_BANKS(NUM_BANKS),
      .MSHR_SIZE(DCACHE_MSHR_SIZE)
  ) u_dcache (
      .clk(clk_i),
      .rst(rst_i),

      // 4 incmd ports straight from the CGRA mem ports (no pre-cache serialize).
      .incmd_valid       (cgra_mem_port_valid_i),
      .incmd_block_id    (incmd_block_id_a),
      .incmd_tid         (incmd_tid_a),
      .incmd_write_enable(cgra_mem_port_op_i),       // 0=ld, 1=st
      .incmd_write_data  (cgra_mem_data_i),
      .incmd_write_mask  (incmd_write_mask_a),
      .incmd_address     (cgra_mem_addr_i),
      .incmd_size        (incmd_size_a),
      .incmd_ld_dest_reg (cgra_mem_rsp_addr_i),
      .incmd_ready       (tmcu_incmd_ready_o),

      // merged coalesced-line response out -> RF writeback + scoreboard release.
      .core_rsp_data (core_rsp_data_o),
      .core_rsp_valid(core_rsp_valid_o),
      .core_rsp_tag  (core_rsp_tag_o),
      .core_rsp_ready(core_rsp_ready_i),

      // mem-side -> flattened ports (dice_core adapts to dcache_mem_if).
      .mem_req_valid (mem_req_valid_o),
      .mem_req_rw    (mem_req_rw_o),
      .mem_req_byteen(mem_req_byteen_o),
      .mem_req_addr  (mem_req_addr_o),
      .mem_req_data  (mem_req_data_o),
      .mem_req_tag   (mem_req_tag_o),
      .mem_req_ready (mem_req_ready_i),

      .mem_rsp_valid (mem_rsp_valid_i),
      .mem_rsp_data  (mem_rsp_data_i),
      .mem_rsp_tag   (mem_rsp_tag_i),
      .mem_rsp_ready (mem_rsp_ready_o)
  );

endmodule

`include "VX_define.vh"

module fdr_top #(
    parameter int TAG_WIDTH = 48,
    parameter int BITSTREAM_SIZE = 2056
) (
    input logic clk_i,
    input logic rst_i,

    // Reuse the Vortex instruction cache bus
    VX_mem_bus_if.master metacache_mem_if,
    VX_mem_bus_if.master bitstream_cache_mem_if,

    // Scheduler/FDR interfaces
    cta_sched_if.slave schedule_if,
    fdr_if.master      fdr_if,

    input logic [dice_pkg::DICE_ADDR_WIDTH-1:0] simt_stack_pc_i,

    // CTA Status Table interface
    input dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_i,
    output logic                                    clear_prefetch_valid_o,
    output logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_prefetch_hw_cta_id_o,
    output logic                                    predict_miss_flush_o,

    // CGRA configuration memories
    output logic [VX_gpu_pkg::VX_MEM_DATA_WIDTH-1:0] cm0_data_o,
    output logic [((BITSTREAM_SIZE + VX_gpu_pkg::VX_MEM_DATA_WIDTH - 1) / VX_gpu_pkg::VX_MEM_DATA_WIDTH) - 1:0] cm0_chunk_en_o,

    output logic [VX_gpu_pkg::VX_MEM_DATA_WIDTH-1:0] cm1_data_o,
    output logic [((BITSTREAM_SIZE + VX_gpu_pkg::VX_MEM_DATA_WIDTH - 1) / VX_gpu_pkg::VX_MEM_DATA_WIDTH) - 1:0] cm1_chunk_en_o
);

  // Control & Meta
  dice_frontend_pkg::pgraph_meta_t meta_internal;
  logic                            meta_valid_internal;
  logic                            fire_eblock_internal;
  logic                            schedule_ready_internal;

  // Bitstream
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0]            bitstream_addr;
  logic [dice_frontend_pkg::BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length;
  logic                                            bitstream_addr_valid_internal;
  logic                                            done_streaming_internal;

  // Branching & Masks
  dice_frontend_pkg::thread_mask_t branch_mask_internal;
  dice_frontend_pkg::branch_meta_t branch_meta_internal;
  logic                            branch_mask_valid;
  logic                            branch_req_valid_internal;
  logic                            is_barrier_internal;

  // Valid checker outputs
  logic                            clear_prefetch_internal;
  logic                            predict_miss_internal;

  // Scheduler ready handshake
  assign schedule_if.ready = schedule_ready_internal;

  // -------------------------------------------------------------------------
  // Pass-through assignments (schedule_if → fdr_if)
  // -------------------------------------------------------------------------

  // IDs
  assign fdr_if.data.schedule_hw_cta_id = schedule_if.data.schedule_hw_cta_id;
  assign fdr_if.data.schedule_eblock_id = schedule_if.data.schedule_eblock_id;
  assign fdr_if.data.schedule_cta_id    = schedule_if.data.schedule_cta_id;
  assign fdr_if.data.schedule_kernel_id = schedule_if.data.schedule_kernel_id;

  // Geometry & resources
  assign fdr_if.data.schedule_grid_size    = schedule_if.data.schedule_grid_size;
  assign fdr_if.data.schedule_cta_size     = schedule_if.data.schedule_cta_size;
  assign fdr_if.data.schedule_hw_cta_size  = schedule_if.data.schedule_hw_cta_size;
  assign fdr_if.data.schedule_smem_per_cta = schedule_if.data.schedule_smem_per_cta;

  // Execution state (from branch handler)
  assign fdr_if.data.real_active_mask = branch_mask_internal;

  // -------------------------------------------------------------------------
  // Meta Fetch
  // -------------------------------------------------------------------------
  meta_fetch #(
      .TAG_WIDTH(TAG_WIDTH)
  ) u_meta_fetch (
      .clk_i              (clk_i),
      .rst_i              (rst_i),
      .schedule_valid_i   (schedule_if.valid),
      .fdr_next_pc_i      (schedule_if.data.schedule_next_pc),
      .schedule_eblock_id_i(schedule_if.data.schedule_eblock_id),
      .schedule_ready_o   (schedule_ready_internal),
      .meta_fetch_bus_if  (metacache_mem_if),
      .outgoing_meta_o    (meta_internal),
      .meta_valid_o       (meta_valid_internal),
      .fire_eblock_i      (fire_eblock_internal)
  );

  // -------------------------------------------------------------------------
  // Decoder
  // -------------------------------------------------------------------------
  decode u_decode (
      .metadata_i                (meta_internal),
      .meta_in_valid_i           (meta_valid_internal),
      .real_active_thread_mask_i (branch_mask_internal),
      .bitstream_addr_o          (bitstream_addr),
      .bitstream_addr_valid_o    (bitstream_addr_valid_internal),
      .bitstream_length_o        (bitstream_length),
      .branch_metadata_o         (branch_meta_internal),
      .branch_req_valid_o        (branch_req_valid_internal),
      .is_barrier_o              (is_barrier_internal),
      .meta_o                    (fdr_if.data.metadata)
  );

  // -------------------------------------------------------------------------
  // Bitstream fetch/load
  // -------------------------------------------------------------------------
  bitstream_fetch_load #(
      .TAG_WIDTH     (TAG_WIDTH),
      .BITSTREAM_SIZE(BITSTREAM_SIZE)
  ) u_bitstream_fetch_load (
      .clk_i          (clk_i),
      .rst_i          (rst_i),
      .meta_valid_i   (bitstream_addr_valid_internal),
      .bitstream_addr_i(bitstream_addr),
      .cm0_data_o     (cm0_data_o),
      .cm0_chunk_en_o (cm0_chunk_en_o),
      .cm1_data_o     (cm1_data_o),
      .cm1_chunk_en_o (cm1_chunk_en_o),
      .done_streaming_o(done_streaming_internal),
      .cache_bus_if   (bitstream_cache_mem_if),
      .cm_num_o       (fdr_if.data.loaded_buffer)
  );

  // -------------------------------------------------------------------------
  // Valid checker
  // -------------------------------------------------------------------------

  // CTA status lookup for current CTA
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] current_hw_cta_id;
  assign current_hw_cta_id = schedule_if.data.schedule_hw_cta_id;

  valid_check u_valid_check (
      // From Decoder
      .barrier_indicator_i(is_barrier_internal),
      .mask_valid_i       (branch_mask_valid),

      // From FDR Stage Buffer
      .eblock_pc_i     (schedule_if.data.schedule_next_pc),
      .prefetch_block_i(schedule_if.data.schedule_prefetch_block),
      .hw_cta_id_i     (current_hw_cta_id),

      // From SIMT Stack
      .simt_stack_pc_i (simt_stack_pc_i),

      // From Bitstream Loader
      .bitstream_loaded_i(done_streaming_internal),

      // From CTA Status Table
      .unresolved_div_i  (cta_status_i[current_hw_cta_id].unresolved_control_divergence),
      .barrier_complete_i(cta_status_i[current_hw_cta_id].is_barrier),
      .prefetch_cleared_i(cta_status_i[current_hw_cta_id].prefetch_cleared),

      // To FDR-DE stage buffer
      .fdr_valid_o  (fdr_if.valid),
      .ex_ready_i   (fdr_if.ready),

      // Feedback/Control
      .fire_eblock_o   (fire_eblock_internal),
      .clear_prefetch_o(clear_prefetch_internal),
      .predict_miss_o  (predict_miss_internal)
  );

  // Output assignments for clear_prefetch and predict_miss
  assign clear_prefetch_valid_o     = clear_prefetch_internal;
  assign clear_prefetch_hw_cta_id_o = current_hw_cta_id;
  assign predict_miss_flush_o       = predict_miss_internal;


  // -------------------------------------------------------------------------
  // BRANCH HANDLER   UNFINISHED
  // -------------------------------------------------------------------------

  branch_handler u_branch_handler (
      .clk_i                     (clk_i),
      .rst_i                     (rst_i),
      .branch_metadata_i         (branch_meta_internal),
      .branch_req_valid_i        (branch_req_valid_internal),
      .real_active_thread_mask_o (branch_mask_internal),
      .mask_valid_o              (branch_mask_valid)
  );

endmodule

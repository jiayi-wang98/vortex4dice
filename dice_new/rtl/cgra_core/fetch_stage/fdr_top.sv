`include "VX_define.vh"

module fdr_top #(
    parameter int TAG_WIDTH = 48,
    parameter int BITSTREAM_SIZE = 2056
) (
    input logic clk,
    input logic rst,

    // Reuse the Vortex instruction cache bus
    VX_mem_bus_if.master metacache_mem_if,
    VX_mem_bus_if.master bitstream_cache_mem_if,

    // Scheduler/FDR interfaces
    cta_sched_if.slave schedule_if,
    fdr_if.master      fdr_if,

    input logic [dice_pkg::DICE_ADDR_WIDTH-1:0] simt_stack_pc,

    // CTA Status Table interface
    input dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status,
    output logic clear_prefetch_valid,
    output logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_prefetch_hw_cta_id,
    output logic predict_miss_flush,

    // CGRA configuration memories
    output logic [VX_gpu_pkg::VX_MEM_DATA_WIDTH-1:0] cm0_data,
    output logic [((BITSTREAM_SIZE + VX_gpu_pkg::VX_MEM_DATA_WIDTH - 1) / VX_gpu_pkg::VX_MEM_DATA_WIDTH) - 1:0] cm0_chunk_en,

    output logic [VX_gpu_pkg::VX_MEM_DATA_WIDTH-1:0] cm1_data,
    output logic [((BITSTREAM_SIZE + VX_gpu_pkg::VX_MEM_DATA_WIDTH - 1) / VX_gpu_pkg::VX_MEM_DATA_WIDTH) - 1:0] cm1_chunk_en
);

  // Control & Meta
  dice_frontend_pkg::pgraph_meta_t              meta_internal;
  logic                                      meta_valid_internal;
  logic                                      fire_eblock_internal;
  logic                                      schedule_ready_internal;

  // Bitstream
  logic         [       dice_pkg::DICE_ADDR_WIDTH-1:0] bitstream_addr;
  logic         [dice_frontend_pkg::BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length;
  logic                                      bitstream_addr_valid_internal;
  logic                                      done_streaming_internal;

  // Branching & Masks
  dice_frontend_pkg::thread_mask_t                              branch_mask_internal;
  dice_frontend_pkg::branch_meta_t            branch_meta_internal;
  logic                                      branch_mask_valid;
  logic                                      branch_req_valid_internal;
  logic                                      is_barrier_internal;

  // Valid checker outputs
  logic                                      clear_prefetch_internal;
  logic                                      predict_miss_internal;

  // Scheduler ready handshake
  assign schedule_if.ready              = schedule_ready_internal;

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
  ) meta_fetch_inst (
      .clk               (clk),
      .rst               (rst),
      .schedule_valid    (schedule_if.valid),
      .fdr_next_pc       (schedule_if.data.schedule_next_pc),
      .schedule_eblock_id(schedule_if.data.schedule_eblock_id),
      .schedule_ready    (schedule_ready_internal),
      .meta_fetch_bus_if (metacache_mem_if),
      .outgoing_meta     (meta_internal),
      .meta_valid        (meta_valid_internal),
      .fire_eblock       (fire_eblock_internal)
  );

  // -------------------------------------------------------------------------
  // Decoder
  // -------------------------------------------------------------------------
  decode decode_inst (
      .metadata_in            (meta_internal),
      .meta_in_valid          (meta_valid_internal),
      .real_active_thread_mask(branch_mask_internal),           //may need more ports. Decode has to decide if it needs to get real mask from branch handler or not
      .bitstream_addr         (bitstream_addr),
      .bitstream_addr_valid   (bitstream_addr_valid_internal),
      .bitstream_length       (bitstream_length),
      .branch_metadata        (branch_meta_internal),
      .branch_req_valid       (branch_req_valid_internal),
      .is_barrier             (is_barrier_internal),
      .meta_out               (fdr_if.data.metadata)
  );

  // -------------------------------------------------------------------------
  // Bitstream fetch/load
  // -------------------------------------------------------------------------
  bitstream_fetch_load #(
      .TAG_WIDTH     (TAG_WIDTH),
      .BITSTREAM_SIZE(BITSTREAM_SIZE)
  ) bitstream_fetch_load_inst (
      .clk           (clk),
      .rst           (rst),
      .meta_valid    (bitstream_addr_valid_internal),
      .bitstream_addr(bitstream_addr),
      .cm0_data      (cm0_data),
      .cm0_chunk_en  (cm0_chunk_en),
      .cm1_data      (cm1_data),
      .cm1_chunk_en  (cm1_chunk_en),
      .done_streaming(done_streaming_internal),
      .cache_bus_if  (bitstream_cache_mem_if),
      .cm_num        (fdr_if.data.loaded_buffer)
  );

  // -------------------------------------------------------------------------
  // Valid checker
  // -------------------------------------------------------------------------

  // CTA status lookup for current CTA
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] current_hw_cta_id;
  assign current_hw_cta_id = schedule_if.data.schedule_hw_cta_id;

  valid_check valid_check_inst (
      // From Decoder
      .barrier_indicator(is_barrier_internal),
      .mask_valid(branch_mask_valid),

      // From FDR Stage Buffer
      .eblock_pc(schedule_if.data.schedule_next_pc),
      .prefetch_block(schedule_if.data.schedule_prefetch_block),
      .hw_cta_id(current_hw_cta_id),

      // From SIMT Stack
      .simt_stack_pc(simt_stack_pc),

      // From Bitstream Loader
      .bitstream_loaded(done_streaming_internal),

      // From CTA Status Table
      .unresolved_div(cta_status[current_hw_cta_id].unresolved_control_divergence),
      .barrier_complete(cta_status[current_hw_cta_id].is_barrier),
      .prefetch_cleared(cta_status[current_hw_cta_id].prefetch_cleared),

      // To FDR-DE stage buffer
      .fdr_valid(fdr_if.valid),
      .ex_ready(fdr_if.ready),

      // Feedback/Control
      .fire_eblock(fire_eblock_internal),
      .clear_prefetch(clear_prefetch_internal),
      .predict_miss(predict_miss_internal)
  );

  // Output assignments for clear_prefetch and predict_miss
  assign clear_prefetch_valid = clear_prefetch_internal;
  assign clear_prefetch_hw_cta_id = current_hw_cta_id;
  assign predict_miss_flush = predict_miss_internal;


  // -------------------------------------------------------------------------
  // BRANCH HANDLER   UNFINISHED
  // -------------------------------------------------------------------------

  branch_handler branch_handler_inst (  //UNFINISHED
      .clk(clk),
      .rst_n(!rst),
      .branch_metadata(branch_meta_internal),
      .branch_req_valid(branch_req_valid_internal),
      .real_active_thread_mask(branch_mask_internal),
      .mask_valid(branch_mask_valid)
  );

endmodule

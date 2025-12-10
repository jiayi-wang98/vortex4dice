`include "VX_define.vh"

import frontend_pkg::*;
import dice_pkg::*;
import VX_gpu_pkg::*;

module fdr_top #(
    parameter int TAG_WIDTH = 48,
    parameter int BITSTREAM_SIZE = 2056
) (
    input  logic clk,
    input  logic rst,

    // Reuse the Vortex instruction cache bus
    VX_mem_bus_if.master metacache_mem_if,
    VX_mem_bus_if.master bitstream_cache_mem_if,

    // Scheduler/FDR interfaces
    cta_sched_if.slave   schedule_if,
    fdr_if.master        fdr_if,

    input  logic [DICE_ADDR_WIDTH-1:0] simt_stack_pc,
 
    // CGRA configuration memories
    // Use VX_MEM_DATA_WIDTH directly
    output logic [VX_MEM_DATA_WIDTH-1:0] cm0_data,
    output logic [((BITSTREAM_SIZE + VX_MEM_DATA_WIDTH - 1) / VX_MEM_DATA_WIDTH) - 1:0] cm0_chunk_en,
    
    output logic [VX_MEM_DATA_WIDTH-1:0] cm1_data,
    output logic [((BITSTREAM_SIZE + VX_MEM_DATA_WIDTH - 1) / VX_MEM_DATA_WIDTH) - 1:0] cm1_chunk_en
);

    // -------------------------------------------------------------------------
    // Local wires
    // -------------------------------------------------------------------------
    // Control & Meta
    pgraph_meta_t                       meta_internal;
    logic                               meta_valid_internal;
    logic                               fire_eblock_internal;
    logic                               schedule_ready_internal;

    // Bitstream
    logic [BITSTREAM_ADDR_WIDTH-1:0]    bitstream_addr;
    logic [BITSTREAM_LENGTH_WIDTH-1:0]  bitstream_length;
    logic                               bitstream_addr_valid_internal;
    logic                               done_streaming_internal;

    // Branching & Masks
    // USE PACKAGE TYPE
    thread_mask_t                       branch_mask_internal; 
    logic [31:0]                        branch_meta_internal;
    logic                               branch_mask_valid;
    logic                               branch_req_valid_internal;
    logic                               mask_valid_internal;

    // Scheduler ready handshake
    assign schedule_if.ready = schedule_ready_internal;

    //need to finish branch handler
    assign branch_mask_internal = schedule_if.data.active_mask;
    assign branch_mask_valid    = schedule_if.valid;



    //PASSTHROUGH STUFF
    assign fdr_if.data.schedule_hw_cta_id     = schedule_if.data.schedule_hw_cta_id;
    assign fdr_if.data.schedule_eblock_id     = schedule_if.data.schedule_eblock_id;
    assign fdr_if.data.schedule_cta_predicted = schedule_if.data.schedule_cta_predicted;
    assign fdr_if.data.kernel_info            = schedule_if.data.kernel_info;

    // -------------------------------------------------------------------------
    // Meta Fetch
    // -------------------------------------------------------------------------
    meta_fetch #(
        .TAG_WIDTH          (TAG_WIDTH)
    ) meta_fetch_inst (
        .clk                (clk),
        .rst                (rst),
        .schedule_valid     (schedule_if.valid),
        .fdr_next_pc        (schedule_if.data.schedule_next_pc),
        .schedule_eblock_id (schedule_if.data.schedule_eblock_id),
        .schedule_ready     (schedule_ready_internal),
        .meta_fetch_bus_if  (metacache_mem_if),
        .outgoing_meta      (meta_internal),
        .meta_valid         (meta_valid_internal),
        .fire_eblock        (fire_eblock_internal)
    );

    // -------------------------------------------------------------------------
    // Decoder
    // -------------------------------------------------------------------------
    decode decode_inst (
        .metadata_in            (meta_internal),
        .meta_in_valid          (meta_valid_internal),
        .bitstream_addr         (bitstream_addr),
        .bitstream_addr_valid   (bitstream_addr_valid_internal),
        .bitstream_length       (bitstream_length),
        .branch_metadata        (branch_meta_internal),
        .branch_req_valid       (branch_req_valid_internal),
        .real_active_thread_mask(branch_mask_internal),
        .mask_valid             (branch_mask_valid),

        .decode_valid           (mask_valid_internal),
        .metadata_out           (fdr_if.data.metadata),
        .mask_out               (fdr_if.data.real_active_mask)
    );

    // -------------------------------------------------------------------------
    // Bitstream fetch/load
    // -------------------------------------------------------------------------
    bitstream_fetch_load #(
        .TAG_WIDTH          (TAG_WIDTH),
        .BITSTREAM_SIZE     (BITSTREAM_SIZE)
    ) bitstream_fetch_load_inst (
        .clk                (clk),
        .rst                (rst),
        .meta_valid         (bitstream_addr_valid_internal),
        .bitstream_addr     (bitstream_addr),
        .cm0_data           (cm0_data),
        .cm0_chunk_en       (cm0_chunk_en),
        .cm1_data           (cm1_data),
        .cm1_chunk_en       (cm1_chunk_en),
        .done_streaming     (done_streaming_internal),
        .cache_bus_if       (bitstream_cache_mem_if),
        .cm_num             (fdr_if.data.loaded_buffer)
    );

    // -------------------------------------------------------------------------
    // Valid checker
    // -------------------------------------------------------------------------

    valid_check valid_check_inst (
        .barrier_indicator (meta_internal.barrier),
        .mask_valid        (mask_valid_internal),
        .eblock_pc         (schedule_if.data.schedule_next_pc),
        .prefetch_block    (schedule_if.data.schedule_cta_predicted),
        .simt_stack_pc     (simt_stack_pc),
        .bitstream_loaded  (done_streaming_internal),
        .unresolved_div    (1'b0),
        .barrier           (1'b1),
        .fdr_valid         (fdr_if.valid),
        .ex_ready          (fdr_if.ready),
        .fire_eblock       (fire_eblock_internal)
    );


    // -------------------------------------------------------------------------
    // FINISH BRANCH HANDLER
    // -------------------------------------------------------------------------

endmodule
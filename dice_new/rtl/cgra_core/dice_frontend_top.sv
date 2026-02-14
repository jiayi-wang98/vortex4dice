`timescale 1ns / 1ps
`include "VX_define.vh"

module dice_frontend_top
  import dice_pkg::*;
  import dice_frontend_pkg::*;
#(
    parameter int TAG_WIDTH      = 48,
    parameter int BITSTREAM_SIZE = 2056
) (
    input logic clk_i,
    input logic rst_i,

    // CTA Dispatch Interface (Slave - receives work)
    cta_dispatch_if.slave cta_dispatch_if,

    // CTA Completion Interface (Master - reports completion)
    cta_complete_if.master cta_complete_if,

    // Memory Interfaces (Master)
    VX_mem_bus_if.master metacache_mem_if,
    VX_mem_bus_if.master bitstream_cache_mem_if,

    // Configuration Interfaces
    cgra_cm_if.master cm0_if,
    cgra_cm_if.master cm1_if,

    // FDR Output Interface (to Backend)
    fdr_if.master fdr_if,

    // Backend Feedback Interfaces (E-block commit, BRT update)
    input logic                       eblock_commit_valid_i,
    input logic [EBLOCK_ID_WIDTH-1:0] eblock_commit_id_i,
    input block_retire_status_t       brt_info_i,
    input logic                       brt_info_write_enable_i
);

    // =========================================================================
    // Internal Interfaces & Signals
    // =========================================================================
    
    // Scheduler -> FDR
    cta_sched_if schedule_if();

    // FDR -> Scheduler: status table/branch prediction wires
    branch_predict_interface_t bh_branch_predict_info;
    logic                      bh_branch_predict_info_we;
    dice_cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_data;

    // FDR -> Scheduler: SIMT Stack Update wires
    logic                            simt_update_valid;
    logic                            simt_update_ready;
    simt_stack_update_t              simt_update_stack_data;
    logic [DICE_HW_CTA_ID_WIDTH-1:0] simt_update_hw_cta_id;
    cta_size_e                       simt_update_hw_cta_size;

    // Scheduler -> FDR: SIMT Stack Status
    simt_stack_status_if simt_status_if();

    // FDR -> Scheduler: Eblock flush on predict-miss
    logic                       eblock_flush_valid_internal;
    logic [EBLOCK_ID_WIDTH-1:0] eblock_flush_id_internal;

    // =========================================================================
    // CTA Schedule Stage Instantiation
    // =========================================================================
    cta_schedule_stage u_cta_schedule_stage (
        .clk_i                   (clk_i),
        .rst_i                   (rst_i),
        .cta_dispatch_if         (cta_dispatch_if),
        .cta_complete_if         (cta_complete_if),
        .schedule_if             (schedule_if),
        .eblock_commit_valid_i   (eblock_commit_valid_i),
        .eblock_commit_id_i      (eblock_commit_id_i),
        .eblock_flush_valid_i    (eblock_flush_valid_internal),
        .eblock_flush_id_i       (eblock_flush_id_internal),
        .bh_branch_predict_info_i(bh_branch_predict_info),
        .bh_branch_predict_info_we_i(bh_branch_predict_info_we),
        .cta_status_data_o       (cta_status_data),
        .brt_info_i              (brt_info_i),
        .brt_info_write_enable_i (brt_info_write_enable_i),
        .simt_update_valid_i     (simt_update_valid),
        .simt_update_ready_o     (simt_update_ready),
        .simt_update_stack_data_i(simt_update_stack_data),
        .simt_update_hw_cta_id_i (simt_update_hw_cta_id),
        .simt_update_hw_cta_size_i(simt_update_hw_cta_size),
        .simt_status_if          (simt_status_if)        // Master
    );

    // =========================================================================
    // FDR Stage Instantiation
    // =========================================================================
    fdr_top #(
        .TAG_WIDTH     (TAG_WIDTH),
        .BITSTREAM_SIZE(BITSTREAM_SIZE)
    ) u_fdr_top (
        .clk_i                 (clk_i),
        .rst_i                 (rst_i),
        .metacache_mem_if      (metacache_mem_if),
        .bitstream_cache_mem_if(bitstream_cache_mem_if),
        .schedule_if           (schedule_if),       // Slave
        .fdr_if                (fdr_if),            // Master (Port)
        .simt_status_if        (simt_status_if),    // Slave
        .bh_branch_predict_info_o(bh_branch_predict_info),
        .bh_branch_predict_info_we_o(bh_branch_predict_info_we),
        .cta_status_data_i     (cta_status_data),
        .simt_update_valid_o   (simt_update_valid),
        .simt_update_ready_i   (simt_update_ready),
        .simt_update_stack_data_o(simt_update_stack_data),
        .simt_update_hw_cta_id_o(simt_update_hw_cta_id),
        .simt_update_hw_cta_size_o(simt_update_hw_cta_size),
        .cm0_if                (cm0_if),
        .cm1_if                (cm1_if),
        .eblock_flush_valid_o  (eblock_flush_valid_internal),
        .eblock_flush_id_o     (eblock_flush_id_internal)
    );

endmodule

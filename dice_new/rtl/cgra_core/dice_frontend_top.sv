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

    // Predicate Register File Interface
    prf_if.master prf_if,

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

    // FDR <-> Scheduler: Status Table Access (via Branch Handler IF)
    // FDR is Master (requests info/update), Scheduler is Slave (holds table)
    branch_handler_if bh_if();

    // FDR -> Scheduler: SIMT Stack Update
    dice_bh_simt_if simt_stack_update_if();

    // Scheduler -> FDR: SIMT Stack Status
    simt_stack_status_if simt_status_if();

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
        .status_table_bh_if      (bh_if), // Slave
        .brt_info_i              (brt_info_i),
        .brt_info_write_enable_i (brt_info_write_enable_i),
        .simt_stack_update       (simt_stack_update_if), // Slave
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
        .simt_stack_update_if  (simt_stack_update_if), // Master
        .prf_if                (prf_if),
        .bh_if                 (bh_if),             // Master
        .cm0_if                (cm0_if),
        .cm1_if                (cm1_if)
    );

endmodule

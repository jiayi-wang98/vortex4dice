// Verilator filelist for FDR (fetch_stage) and CS (cta_schedule) stage linting
// Generated for lint-only checking

--sv
-Wall
+define+NO_SRAM

// =========================================================
// Include directories for `include headers
// =========================================================
// Vortex RTL headers (VX_define.vh, VX_platform.vh, VX_config.vh, VX_types.vh)
-Ihw/rtl
-Ihw/dpi
// DICE headers (dice_config.vh, dice_define.vh)
-Idice_new/rtl

// =========================================================
// Packages (compiled first; ordered by dependency)
// =========================================================
// VX_gpu_pkg depends on VX_define.vh (no package imports)
hw/rtl/VX_gpu_pkg.sv
// dice_pkg depends on dice_define.vh, no package imports
dice_new/rtl/dice_pkg.sv
// dice_frontend_pkg imports dice_pkg::*
dice_new/rtl/dice_frontend_pkg.sv

// =========================================================
// Interfaces (must be compiled after packages they depend on)
// =========================================================
hw/rtl/mem/VX_mem_bus_if.sv
dice_new/rtl/dice_ram/dice_ram_1w1r.sv
dice_new/rtl/dice_ram/dice_ram_1rw.sv
dice_new/rtl/interfaces/cta_dispatch_if.sv
dice_new/rtl/interfaces/cta_complete_if.sv
dice_new/rtl/interfaces/cta_sched_if.sv
dice_new/rtl/interfaces/simt_stack_status_if.sv
dice_new/rtl/interfaces/cgra_cm_if.sv
dice_new/rtl/interfaces/fdr_if.sv

// =========================================================
// FDR Stage (fetch_stage) Source Files
// =========================================================
dice_new/rtl/cgra_core/fetch_stage/decode.sv
dice_new/rtl/cgra_core/fetch_stage/valid_check.sv
dice_new/rtl/cgra_core/fetch_stage/rising_edge_detector.sv
dice_new/rtl/cgra_core/fetch_stage/branch_handler_no_branches.sv
dice_new/rtl/cgra_core/fetch_stage/meta_fetch.sv
dice_new/rtl/cgra_core/fetch_stage/bitstream_fetch_load.sv
dice_new/rtl/cgra_core/fetch_stage/fdr_top.sv

// =========================================================
// CS Stage (cta_schedule) Source Files
// =========================================================
dice_new/rtl/cgra_core/cta_schedule/cta_status_table.sv
dice_new/rtl/cgra_core/cta_schedule/simt_stack.sv
dice_new/rtl/cgra_core/cta_schedule/simt_stack_controller.sv
dice_new/rtl/cgra_core/cta_schedule/cta_controller.sv
dice_new/rtl/cgra_core/cta_schedule/active_cta_table.sv
dice_new/rtl/cgra_core/cta_schedule/cta_scheduler.sv
dice_new/rtl/cgra_core/cta_schedule/cta_schedule_stage.sv

+incdir+$DICE_HOME/hw/rtl
+incdir+$DICE_HOME/dice_new/rtl
+incdir+$DICE_HOME/dice_new/rtl/dice_ram

// Base Definitions & Packages (Must be first)
$DICE_HOME/hw/rtl/VX_define.vh
$DICE_HOME/hw/rtl/VX_gpu_pkg.sv
$DICE_HOME/dice_new/rtl/dice_config.vh
$DICE_HOME/dice_new/rtl/dice_define.vh
$DICE_HOME/dice_new/rtl/dice_pkg.sv
$DICE_HOME/dice_new/rtl/dice_frontend_pkg.sv

// Interfaces
$DICE_HOME/hw/rtl/mem/VX_mem_bus_if.sv
$DICE_HOME/dice_new/rtl/interfaces/cta_dispatch_if.sv
$DICE_HOME/dice_new/rtl/interfaces/cta_complete_if.sv
$DICE_HOME/dice_new/rtl/interfaces/cta_sched_if.sv
$DICE_HOME/dice_new/rtl/interfaces/simt_stack_status_if.sv
$DICE_HOME/dice_new/rtl/interfaces/cgra_cm_if.sv
$DICE_HOME/dice_new/rtl/interfaces/fdr_if.sv

// Memory/RAM Dependencies
$DICE_HOME/dice_new/rtl/dice_ram/dice_ram_1w1r.sv
$DICE_HOME/dice_new/rtl/dice_ram/dice_ram_1rw.sv

// CS Stage Modules
$DICE_HOME/dice_new/rtl/cgra_core/cta_schedule/active_cta_table.sv
$DICE_HOME/dice_new/rtl/cgra_core/cta_schedule/cta_controller.sv
$DICE_HOME/dice_new/rtl/cgra_core/cta_schedule/cta_scheduler.sv
$DICE_HOME/dice_new/rtl/cgra_core/cta_schedule/cta_status_table.sv
$DICE_HOME/dice_new/rtl/cgra_core/cta_schedule/simt_stack.sv
$DICE_HOME/dice_new/rtl/cgra_core/cta_schedule/simt_stack_controller.sv
$DICE_HOME/dice_new/rtl/cgra_core/cta_schedule/cta_schedule_stage.sv

// FDR Stage Modules
$DICE_HOME/dice_new/rtl/cgra_core/fetch_stage/bitstream_fetch_load.sv
$DICE_HOME/dice_new/rtl/cgra_core/fetch_stage/rising_edge_detector.sv
$DICE_HOME/dice_new/rtl/cgra_core/fetch_stage/branch_handler_no_branches.sv
$DICE_HOME/dice_new/rtl/cgra_core/fetch_stage/decode.sv
$DICE_HOME/dice_new/rtl/cgra_core/fetch_stage/meta_fetch.sv
$DICE_HOME/dice_new/rtl/cgra_core/fetch_stage/valid_check.sv
$DICE_HOME/dice_new/rtl/cgra_core/fetch_stage/fdr_top.sv

// Top Level
$DICE_HOME/dice_new/rtl/cgra_core/dice_frontend_top.sv

// Testbench
frontend_top_tb.sv

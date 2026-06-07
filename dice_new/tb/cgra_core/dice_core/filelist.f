-sv
-y ${DICE_HOME}/../hw/rtl/libs
+libext+.sv
+define+NO_SRAM

+incdir+${DICE_HOME}/rtl
+incdir+${DICE_HOME}/rtl/interfaces
+incdir+${DICE_HOME}/../hw/rtl
+incdir+${DICE_HOME}/../hw/rtl/mem
+incdir+${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile

// ==== BaseJump STL (for cgra_bitstream_buf_serial + credit converter) ====
// TODO(deps): dice_ready_to_credit_flow_converter `include "bsg_defines.v" (.v),
// but the file is bsg_defines.sv. Reconcile the include extension if it errors.
+incdir+${DICE_HOME}/../../dora/dora.py/external/basejump_stl/bsg_misc
-y ${DICE_HOME}/../../dora/dora.py/external/basejump_stl/bsg_misc

// ==== BUILT DORA CGRA fabric (dice_top + submodules) ====
-y ${DICE_HOME}/../../dora/examples/devices/dice-isca/dice/build/rtl
-y ${DICE_HOME}/../../dora/examples/devices/dice-isca/dice/build/rtl/cvfpu

// ==== Vortex base RTL (configs, packages, interfaces) ====
${DICE_HOME}/../hw/rtl/VX_config.vh
${DICE_HOME}/../hw/rtl/VX_define.vh
${DICE_HOME}/../hw/rtl/VX_gpu_pkg.sv
${DICE_HOME}/../hw/rtl/mem/VX_mem_bus_if.sv
${DICE_HOME}/../hw/rtl/mem/VX_local_mem.sv

// ==== DICE configs and packages ====
${DICE_HOME}/rtl/dice_config.vh
${DICE_HOME}/rtl/dice_define.vh
${DICE_HOME}/rtl/dice_pkg.sv
${DICE_HOME}/rtl/dice_frontend_pkg.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/DE_pkg.sv

// ==== DICE interfaces ====
${DICE_HOME}/rtl/interfaces/cta_sched_if.sv
${DICE_HOME}/rtl/interfaces/fdr_if.sv
${DICE_HOME}/rtl/interfaces/simt_stack_status_if.sv
${DICE_HOME}/rtl/interfaces/cgra_cm_if.sv
${DICE_HOME}/rtl/interfaces/cta_dispatch_if.sv
${DICE_HOME}/rtl/interfaces/cta_complete_if.sv
${DICE_HOME}/rtl/interfaces/branch_handler_if.sv
${DICE_HOME}/rtl/interfaces/dice_bh_simt_if.sv
${DICE_HOME}/rtl/interfaces/prf_if.sv

// ==== DICE RAM primitives ====
${DICE_HOME}/rtl/dice_ram/dice_ram_1w1r.sv
${DICE_HOME}/rtl/dice_ram/dice_ram_1rw.sv

// ==== CTA Schedule Stage ====
${DICE_HOME}/rtl/cgra_core/cta_schedule/simt_stack.sv
${DICE_HOME}/rtl/cgra_core/cta_schedule/simt_stack_controller.sv
${DICE_HOME}/rtl/cgra_core/cta_schedule/active_cta_table.sv
${DICE_HOME}/rtl/cgra_core/cta_schedule/cta_status_table.sv
${DICE_HOME}/rtl/cgra_core/cta_schedule/cta_controller.sv
${DICE_HOME}/rtl/cgra_core/cta_schedule/cta_scheduler.sv
${DICE_HOME}/rtl/cgra_core/cta_schedule/cta_schedule_stage.sv

// ==== Fetch Stage (FDR) ====
${DICE_HOME}/rtl/cgra_core/fetch_stage/rising_edge_detector.sv
${DICE_HOME}/rtl/cgra_core/fetch_stage/valid_check.sv
${DICE_HOME}/rtl/cgra_core/fetch_stage/meta_fetch.sv
${DICE_HOME}/rtl/cgra_core/fetch_stage/bitstream_fetch_load.sv
${DICE_HOME}/rtl/cgra_core/fetch_stage/decode.sv
${DICE_HOME}/rtl/cgra_core/fetch_stage/branch_handler_no_branches.sv
${DICE_HOME}/rtl/cgra_core/fetch_stage/fdr_top.sv

// ==== Dispatcher and sub-modules ====
${DICE_HOME}/rtl/cgra_core/dispatcher/sync_fifo.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/sync_fifo_read_unreg.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/priority_encoder_8bit.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/priority_encoder_64bit.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/active_mask_mapper.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/register_to_bank_mapper.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/reverse_mapper.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/thread_filter.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/thread_lane_reroute.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/next_active_thread_logic.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/next_thread_logic_top.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/scoreboard_refactor.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/constant_scoreboard.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_ctrl.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_df.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_fsm.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_refactored.sv

// ==== Register File ====
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/addr_swizzle.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/fifo_ctrl_credit.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/reg_wr_single_entry.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/reg_wr_buffer.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/dice_register_file.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/dice_rd_ctrl_bank.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/dice_read_org.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/dice_wr_ctrl_bank.sv
// dice_special_reg removed from the flattened build: the CGRA fabric (dice_top)
// now takes threadIdx/blockIdx/blockDim/gridDim on dedicated inputs.
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/dice_rf_ctrl.sv

// ==== NEW: predicate register file (dice_pred_rf) ====
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/dice_pred_rf_ctrl_new.sv

// ==== Backend glue (ported from Mini_Dice) ====
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/regfile/dice_shift_reg.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/dice_ready_to_credit_flow_converter.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/cgra_bitstream_buf_serial.sv

// ==== Commit / block-retire table (unified: vector hw_cta_pending) ====
${DICE_HOME}/rtl/cgra_core/commit_stage/block_commit_table.sv
${DICE_HOME}/rtl/cgra_core/commit_stage/dice_brt.sv

// ==== Load/Store: TMCU memory chain ====
// 4x temporal_coalescing_unit -> VX_cache_4temporal (VX_cache_top NUM_REQS=4
// request crossbar + round-robin response merge). The coalesced line is written
// to the RF + its threads released in one cycle (DE_pkg gen_wb_tid_bitmap) — no
// serial response expander.
${DICE_HOME}/rtl/cgra_core/ldst_unit/memory_cmd_coalesce_buffer.sv
${DICE_HOME}/rtl/cgra_core/ldst_unit/temporal_coalescing_unit.sv
${DICE_HOME}/rtl/cgra_core/ldst_unit/VX_cache_4temporal.sv
// VX_cache_4temporal instantiates VX_cache_top (EXTERNAL Vortex module). Add the
// Vortex cache RTL dir to the search path so VX_cache_top + submodules elaborate.
-y ${DICE_HOME}/../hw/rtl/cache

// ==== Modularized backend (dice_core split into FE/BE wrappers + leaf modules) ====
// dice_core = dice_frontend + dice_backend (Mini_Dice-style 2-child top).
// Leaf modules extracted from the former flat dice_core:
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/dice_eblock_tracker.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/dice_cgra_prog.sv
${DICE_HOME}/rtl/cgra_core/cgra_subsystem/dice_cgra_rf.sv
${DICE_HOME}/rtl/cgra_core/dispatcher/dice_mem_dispatch_credit.sv
${DICE_HOME}/rtl/cgra_core/ldst_unit/dice_tmcu_mem_edge.sv
${DICE_HOME}/rtl/cgra_core/ldst_unit/dice_ldst_retire.sv
// FE/BE wrappers:
${DICE_HOME}/rtl/cgra_core/dice_frontend.sv
${DICE_HOME}/rtl/cgra_core/dice_backend.sv

// ==== DUT ====
${DICE_HOME}/rtl/cgra_core/dice_core.sv

// ==== Testbench ====

${DICE_HOME}/tb/cgra_core/dice_core/tb_dice_core.sv

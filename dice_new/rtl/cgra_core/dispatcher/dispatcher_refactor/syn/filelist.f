+incdir+$DICE_HOME/rtl

// Package imports
$DICE_HOME/rtl/dice_pkg.sv
$DICE_HOME/rtl/dice_frontend_pkg.sv

// Test integrated fsm with other modules
$DICE_HOME/rtl/cgra_core/dispatcher/scoreboard_refactor.sv
$DICE_HOME/rtl/cgra_core/dispatcher/next_thread_logic_top.sv
$DICE_HOME/rtl/cgra_core/dispatcher/next_active_thread_logic.sv
$DICE_HOME/rtl/cgra_core/dispatcher/active_mask_mapper.sv
$DICE_HOME/rtl/cgra_core/dispatcher/priority_encoder_8bit.sv
$DICE_HOME/rtl/cgra_core/dispatcher/priority_encoder_64bit.sv
$DICE_HOME/rtl/cgra_core/dispatcher/reverse_mapper.sv
$DICE_HOME/rtl/cgra_core/dispatcher/thread_filter.sv
$DICE_HOME/rtl/cgra_core/dispatcher/thread_lane_reroute.sv
$DICE_HOME/rtl/cgra_core/dispatcher/sync_fifo.sv
$DICE_HOME/rtl/cgra_core/dispatcher/sync_fifo_read_unreg.sv
$DICE_HOME/rtl/cgra_core/dispatcher/constant_scoreboard.sv
$DICE_HOME/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_fsm.sv
$DICE_HOME/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_ctrl.sv
$DICE_HOME/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_df.sv
$DICE_HOME/rtl/cgra_core/dispatcher/dispatcher_refactor/dispatcher_refactored.sv
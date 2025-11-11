verdiSetActWin -dock widgetDock_<Message>
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiWindowResize -win $_Verdi_1 "0" "42" "1800" "967"
simSetSimulator "-vcssv" -exec \
           "/data/amanoj3/vortex4dice/dice_new/tb/cgra_core/dispatcher/regfile/simv" \
           -args
debImport "-dbdir" \
          "/data/amanoj3/vortex4dice/dice_new/tb/cgra_core/dispatcher/regfile/simv.daidir"
debLoadSimResult \
           /data/amanoj3/vortex4dice/dice_new/tb/cgra_core/dispatcher/regfile/addr_swizzle_tb.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "bank_sel" -line 12 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {12 38 15 1 5 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "bank_sel" -line 12 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {12 22 15 1 4 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "bank_sel" -line 12 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/addr_swizzle_tb/bank_sel\[4:0\]"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "expected_bank_sel" -line 16 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvAddSignal -win $_nWave2 "/addr_swizzle_tb/expected_bank_sel\[4:0\]"
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 1)}
verdiSetActWin -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "bank_sel" -line 21 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_cmd" -line 20 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_cmd" -line 20 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rs" -line 22 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_cmd" -line 20 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "bank_sel" -line 21 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -inst "dut" -line 19 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_cmd" -line 20 -pos 2 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvAddSignal -win $_nWave2 "addr_swizzle_tb/rd_cmd"
debExit

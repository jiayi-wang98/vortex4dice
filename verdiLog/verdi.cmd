verdiWindowResize -win $_Verdi_1 "830" "301" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiWindowResize -win $_Verdi_1 "830" "301" "900" "700"
simSetSimulator "-vcssv" -exec \
           "/data/thatton9/vortex4dice/dice_new/tb/cgra_core/ldst_unit/temporal_coalescing_unit/cache_testing/simv" \
           -args
debImport "-dbdir" \
          "/data/thatton9/vortex4dice/dice_new/tb/cgra_core/ldst_unit/temporal_coalescing_unit/cache_testing/simv.daidir"
debLoadSimResult \
           /data/thatton9/vortex4dice/dice_new/tb/cgra_core/ldst_unit/temporal_coalescing_unit/cache_testing/tb_vx_cache_with_temporal.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {118 138 5 1 1 1} -backward
srcDeselectAll -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
srcSetScope "tb_vx_cache_with_temporal.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {22 50 2 1 1 1}
wvAddSignal -win $_nWave2 "tb_vx_cache_with_temporal/dut/EBLOCK_ID_WIDTH"
wvAddSignal -win $_nWave2 "tb_vx_cache_with_temporal/dut/TID_WIDTH"
wvAddSignal -win $_nWave2 "tb_vx_cache_with_temporal/dut/DATA_WIDTH"
wvAddSignal -win $_nWave2 "tb_vx_cache_with_temporal/dut/ADDR_WIDTH"
wvAddSignal -win $_nWave2 "tb_vx_cache_with_temporal/dut/MAX_REG_WIDTH"
wvAddSignal -win $_nWave2 "tb_vx_cache_with_temporal/dut/OUTCMD_TAG_WIDTH"
wvAddSignal -win $_nWave2 "tb_vx_cache_with_temporal/dut/CACHE_LINE_SIZE"
wvAddSignal -win $_nWave2 "/tb_vx_cache_with_temporal/dut/incmd_valid" \
           "/tb_vx_cache_with_temporal/dut/incmd_block_id\[3:0\]" \
           "/tb_vx_cache_with_temporal/dut/incmd_tid\[9:0\]" \
           "/tb_vx_cache_with_temporal/dut/incmd_write_enable" \
           "/tb_vx_cache_with_temporal/dut/incmd_write_data\[63:0\]" \
           "/tb_vx_cache_with_temporal/dut/incmd_write_mask\[7:0\]" \
           "/tb_vx_cache_with_temporal/dut/incmd_address\[63:0\]" \
           "/tb_vx_cache_with_temporal/dut/incmd_size\[1:0\]" \
           "/tb_vx_cache_with_temporal/dut/incmd_ld_dest_reg\[6:0\]" \
           "/tb_vx_cache_with_temporal/dut/outcmd_ready" \
           "/tb_vx_cache_with_temporal/dut/core_rsp_data\[63:0\]" \
           "/tb_vx_cache_with_temporal/dut/core_rsp_valid" \
           "/tb_vx_cache_with_temporal/dut/core_rsp_tag\[68:0\]" \
           "/tb_vx_cache_with_temporal/dut/core_rsp_ready" \
           "/tb_vx_cache_with_temporal/dut/mem_req_valid" \
           "/tb_vx_cache_with_temporal/dut/mem_req_rw" \
           "/tb_vx_cache_with_temporal/dut/mem_req_byteen\[31:0\]" \
           "/tb_vx_cache_with_temporal/dut/mem_req_addr\[26:0\]" \
           "/tb_vx_cache_with_temporal/dut/mem_req_data\[255:0\]" \
           "/tb_vx_cache_with_temporal/dut/mem_req_tag\[47:0\]" \
           "/tb_vx_cache_with_temporal/dut/mem_req_ready" \
           "/tb_vx_cache_with_temporal/dut/mem_rsp_valid" \
           "/tb_vx_cache_with_temporal/dut/mem_rsp_data\[63:0\]" \
           "/tb_vx_cache_with_temporal/dut/mem_rsp_tag\[68:0\]" \
           "/tb_vx_cache_with_temporal/dut/mem_rsp_ready"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 25)}
wvSetPosition -win $_nWave2 {("G1" 25)}
wvSetCursor -win $_nWave2 4861.272275 -snap {("G1" 13)}
verdiSetActWin -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 2199.596230 -snap {("G1" 9)}
wvZoomAll -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_vx_cache_with_temporal.dut.cache_inst" -win $_nTrace1
srcSetScope "tb_vx_cache_with_temporal.dut.cache_inst" -delim "." -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal.dut.cache_inst" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_vx_cache_with_temporal" -win $_nTrace1
srcSetScope "tb_vx_cache_with_temporal" -delim "." -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 139 -pos 3 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "idx" -line 140 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvAddSignal -win $_nWave2 "/tb_vx_cache_with_temporal/i\[31:0\]" \
           "/tb_vx_cache_with_temporal/idx\[31:0\]"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 13792.097747 -snap {("G1" 1)}
verdiSetActWin -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "idx" -line 140 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 13576.876456 -snap {("G1" 16)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvScrollDown -win $_nWave2 1
wvSetPosition -win $_nWave2 {("G1" 19)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 19)}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 13585.172489 -snap {("G1" 16)}
wvSetCursor -win $_nWave2 13542.998350 -snap {("G1" 16)}
wvSetCursor -win $_nWave2 13534.119584 -snap {("G1" 15)}
wvSelectSignal -win $_nWave2 {( "G1" 16 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 13558.941349 -snap {("G1" 16)}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 102 -pos 2 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {102 106 6 3 1 9}
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 102 -pos 2 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 21)}
wvSetPosition -win $_nWave2 {("G1" 22)}
wvSetPosition -win $_nWave2 {("G1" 23)}
wvSetPosition -win $_nWave2 {("G1" 24)}
wvSetPosition -win $_nWave2 {("G1" 25)}
wvSetPosition -win $_nWave2 {("G1" 24)}
wvSetPosition -win $_nWave2 {("G1" 23)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 23)}
wvSetPosition -win $_nWave2 {("G1" 24)}
wvSetPosition -win $_nWave2 {("G1" 25)}
wvSetPosition -win $_nWave2 {("G1" 26)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvAddSignal -win $_nWave2 "/tb_vx_cache_with_temporal/clk"
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomIn -win $_nWave2
verdiSetActWin -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 13474.637873 -snap {("G1" 13)}
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
wvSetCursor -win $_nWave2 13524.580933 -snap {("G1" 15)}
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 19)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 19)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 17)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 17)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSelectSignal -win $_nWave2 {( "G1" 17 )} 
wvSelectSignal -win $_nWave2 {( "G1" 15 )} 
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 13612.746671 -snap {("G1" 15)}
wvSetCursor -win $_nWave2 13505.136026 -snap {("G1" 15)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 13871.721233 -snap {("G1" 15)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 13508.043021 -snap {("G1" 1)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetRadix -win $_nWave2 -format UDec
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 13585.177302 -snap {("G1" 15)}
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
srcSetScope "tb_vx_cache_with_temporal.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
verdiSetActWin -win $_nWave2
wvShowOneTraceSignals -win $_nWave2 -signal \
           "/tb_vx_cache_with_temporal/dut/outcmd_ready" -driver
wvShowOneTraceSignals -win $_nWave2 -signal \
           "/tb_vx_cache_with_temporal/dut/outcmd_ready" -driver
wvSelectSignal -win $_nWave2 \
           {( "G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver" \
           1 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 \
           {("G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver" 0)}
wvSetPosition -win $_nWave2 \
           {("G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver" 0)}
wvSelectSignal -win $_nWave2 {( "G1" 11 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 \
           {("G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver" 0)}
wvSetPosition -win $_nWave2 \
           {("G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver" 0)}
wvSelectGroup -win $_nWave2 \
           {G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver}
wvSelectGroup -win $_nWave2 \
           {G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver}
wvSelectGroup -win $_nWave2 \
           {G1//tb_vx_cache_with_temporal/dut/outcmd_ready@13(100ps)#ActiveDriver}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvAddSignal -win $_nWave2 "/tb_vx_cache_with_temporal/outcmd_ready"
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 11)}
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
srcSetScope "tb_vx_cache_with_temporal.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSelectSignal -win $_nWave2 {( "G1" 14 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "outcmd_valid" -line 131 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {131 131 7 7 6 10} -backward
srcDeselectAll -win $_nTrace1
srcSelect -signal "outcmd_valid" -line 131 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 18)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvAddSignal -win $_nWave2 "/tb_vx_cache_with_temporal/dut/outcmd_valid"
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 13637.062592 -snap {("G1" 24)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 13586.842071 -snap {("G1" 16)}
wvScrollUp -win $_nWave2 1
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 15)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetCursor -win $_nWave2 13741.144746 -snap {("G1" 15)}
wvSetCursor -win $_nWave2 13768.613429 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 13792.197652 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 13819.388873 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 13845.470249 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 13875.991007 -snap {("G2" 1)}
wvDisplayGridCount -win $_nWave2 -off
wvCloseGetStreamsDialog -win $_nWave2
wvAttrOrderConfigDlg -win $_nWave2 -close
wvCloseDetailsViewDlg -win $_nWave2
wvCloseDetailsViewDlg -win $_nWave2 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave2
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 1920.517705 -snap {("G1" 23)}
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 13523.071133 -snap {("G1" 16)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "outcmd_valid" -line 108 -pos 2 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 13646.009440 -snap {("G1" 24)}
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
srcSetScope "tb_vx_cache_with_temporal.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_vx_cache_with_temporal" -win $_nTrace1
srcSetScope "tb_vx_cache_with_temporal" -delim "." -win $_nTrace1
srcHBSelect "tb_vx_cache_with_temporal" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "outcmd_ready" -line 178 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetCursor -win $_nWave2 32234.115653 -snap {("G1" 12)}
verdiSetActWin -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvCloseGetStreamsDialog -win $_nWave2
wvAttrOrderConfigDlg -win $_nWave2 -close
wvCloseDetailsViewDlg -win $_nWave2
wvCloseDetailsViewDlg -win $_nWave2 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave2
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvCloseGetStreamsDialog -win $_nWave2
wvAttrOrderConfigDlg -win $_nWave2 -close
wvCloseDetailsViewDlg -win $_nWave2
wvCloseDetailsViewDlg -win $_nWave2 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave2
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 13)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetPosition -win $_nWave2 {("G1" 14)}
wvAddSignal -win $_nWave2 "/tb_vx_cache_with_temporal/outcmd_ready"
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSetPosition -win $_nWave2 {("G1" 15)}
wvSetCursor -win $_nWave2 27654.650125 -snap {("G1" 13)}
verdiSetActWin -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomAll -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 13630.681779 -snap {("G1" 21)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 15729.089369 -snap {("G1" 21)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0

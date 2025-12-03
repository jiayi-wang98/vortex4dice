verdiSetActWin -dock widgetDock_<Message>
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
simSetSimulator "-vcssv" -exec \
           "/data/amanoj3/vortex4dice/dice_new/tb/cgra_core/dispatcher/regfile/simv" \
           -args
debImport "-dbdir" \
          "/data/amanoj3/vortex4dice/dice_new/tb/cgra_core/dispatcher/regfile/simv.daidir"
debLoadSimResult \
           /data/amanoj3/vortex4dice/dice_new/tb/cgra_core/dispatcher/regfile/reg_wr_buffer_tb.fsdb
wvCreateWindow
verdiFindBar -show -win nWave_2
verdiSetActWin -win $_nWave2
srcHBSelect "reg_wr_buffer_tb.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "reg_wr_buffer_tb.dut" -win $_nTrace1
srcSetScope "reg_wr_buffer_tb.dut" -delim "." -win $_nTrace1
srcHBSelect "reg_wr_buffer_tb.dut" -win $_nTrace1
verdiSetActWin -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/DE_pkg"
wvGetSignalSetScope -win $_nWave2 "/_vcs_unit__3329755842"
wvGetSignalSetScope -win $_nWave2 "/dice_pkg"
wvGetSignalSetScope -win $_nWave2 "/reg_wr_buffer_tb"
wvGetSignalSetScope -win $_nWave2 "/reg_wr_buffer_tb/dut"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/reg_wr_buffer_tb/dut/clk_i} -height 16 \
{/reg_wr_buffer_tb/dut/reset_i} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvGetSignalClose -win $_nWave2
wvSetCursor -win $_nWave2 1.974530 -snap {("G2" 0)}
wvSelectGroup -win $_nWave2 {G2}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/DE_pkg"
wvGetSignalSetScope -win $_nWave2 "/reg_wr_buffer_tb"
wvGetSignalSetScope -win $_nWave2 "/reg_wr_buffer_tb/dut"
wvGetSignalClose -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G2}
verdiDockWidgetMaximize -dock windowDock_nWave_2
verdiHideBanners -win $_Verdi_1 -off
wvResizeWindow -win $_nWave2 0 174 1800 658
verdiWindowBeWindow -win $_nWave2
wvResizeWindow -win $_nWave2 -92 500 1800 972
wvSetCursor -win $_nWave2 6.713401 -snap {("G2" 0)}
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/DE_pkg"
wvGetSignalSetScope -win $_nWave2 "/reg_wr_buffer_tb"
wvGetSignalSetScope -win $_nWave2 "/reg_wr_buffer_tb/dut"
wvGetSignalSetScope -win $_nWave2 "/reg_wr_buffer_tb/dut"
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/reg_wr_buffer_tb/dut/clk_i} -height 16 \
{/reg_wr_buffer_tb/dut/reset_i} -height 16 \
{/reg_wr_buffer_tb/dut/enq_li} -height 16 \
{/reg_wr_buffer_tb/dut/full} -height 16 \
{/reg_wr_buffer_tb/dut/valid_i} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 4 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvGetSignalClose -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 3)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvShowOneTraceSignals -win $_nWave2 -signal "/reg_wr_buffer_tb/dut/full" \
           -valuechange
wvResizeWindow -win $_nWave2 0 27 1800 972
wvResizeWindow -win $_nWave2 0 27 1800 972
wvSelectSignal -win $_nWave2 \
           {( "G2//reg_wr_buffer_tb/dut/full@0(1s)#ValueChange" \
           3 )} 
wvShowOneTraceSignals -win $_nWave2 -signal \
           "/reg_wr_buffer_tb/dut/fifo_track/equal_ptrs" -valuechange
wvSelectSignal -win $_nWave2 \
           {( "G2//reg_wr_buffer_tb/dut/full@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/equal_ptrs@0(1s)#ValueChange" \
           3 )} 
wvShowOneTraceSignals -win $_nWave2 -signal \
           "/reg_wr_buffer_tb/dut/fifo_track/wptr_r\[2:0\]" -valuechange
wvSelectSignal -win $_nWave2 \
           {( "G2//reg_wr_buffer_tb/dut/full@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/equal_ptrs@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/wptr_r@0(1s)#ValueChange" \
           2 )} 
wvSelectSignal -win $_nWave2 \
           {( "G2//reg_wr_buffer_tb/dut/full@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/equal_ptrs@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/wptr_r@0(1s)#ValueChange" \
           1 )} 
wvSelectSignal -win $_nWave2 \
           {( "G2//reg_wr_buffer_tb/dut/full@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/equal_ptrs@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/wptr_r@0(1s)#ValueChange" \
           3 )} 
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 \
           {( "G2//reg_wr_buffer_tb/dut/full@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/equal_ptrs@0(1s)#ValueChange//reg_wr_buffer_tb/dut/fifo_track/wptr_r@0(1s)#ValueChange" \
           1 )} 
wvShowOneTraceSignals -win $_nWave2 -signal \
           "/reg_wr_buffer_tb/dut/fifo_track/wptr_r\[2:0\]" -valuechange
wvSelectSignal -win $_nWave2 \
           {( "G2//reg_wr_buffer_tb/dut/full@0(1s)#ValueChange" \
           2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvDisplayGridCount -win $_nWave2 -off
wvCloseGetStreamsDialog -win $_nWave2
wvAttrOrderConfigDlg -win $_nWave2 -close
wvCloseDetailsViewDlg -win $_nWave2
wvCloseDetailsViewDlg -win $_nWave2 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave2
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
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
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 34.945442 -snap \
           {("/reg_wr_buffer_tb/dut/full@0(1s)#ValueChange" 2)}
wvCloseGetStreamsDialog -win $_nWave2
wvAttrOrderConfigDlg -win $_nWave2 -close
wvCloseDetailsViewDlg -win $_nWave2
wvCloseDetailsViewDlg -win $_nWave2 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave2
wvGetSignalClose -win $_nWave2
wvCloseWindow -win $_nWave2
verdiSetActWin -win $_OneSearch
wvCreateWindow
verdiFindBar -show -win nWave_3
verdiSetActWin -win $_nWave3
wvGetSignalOpen -win $_nWave3
wvGetSignalSetScope -win $_nWave3 "/DE_pkg"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut/fifo_track"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut"
wvGetSignalOpen -win $_nWave3
wvSetPosition -win $_nWave3 {("G4" 3)}
wvSetPosition -win $_nWave3 {("G4" 3)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"G1" \
{/reg_wr_buffer_tb/dut/clk_i} -height 16 \
{/reg_wr_buffer_tb/dut/reset_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G2" \
{/reg_wr_buffer_tb/dut/enq_li} -height 16 \
{/reg_wr_buffer_tb/dut/deq_li} -height 16 \
{/reg_wr_buffer_tb/dut/valid_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G3" \
{/reg_wr_buffer_tb/dut/wr_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G4" \
{/reg_wr_buffer_tb/dut/wb_data_o\[31:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_tid_o\[8:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_valid_o} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G5" \
}
wvSelectSignal -win $_nWave3 {( "G4" 3 )} 
wvSetPosition -win $_nWave3 {("G4" 3)}
wvGetSignalClose -win $_nWave3
wvResizeWindow -win $_nWave3 0 27 1800 972
verdiWindowBeWindow -win $_nWave3
wvResizeWindow -win $_nWave3 0 27 1350 719
wvResizeWindow -win $_nWave3 0 27 1800 972
wvZoomAll -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G3" 1 )} 
wvSelectSignal -win $_nWave3 {( "G3" 1 )} 
wvSetPackedMode -win $_nWave3 -unpacked on
wvSetCursor -win $_nWave3 17.607350 -snap {("G5" 0)}
wvGetSignalOpen -win $_nWave3
wvGetSignalSetScope -win $_nWave3 "/DE_pkg"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut"
wvSetPosition -win $_nWave3 {("G5" 4)}
wvSetPosition -win $_nWave3 {("G5" 4)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"G1" \
{/reg_wr_buffer_tb/dut/clk_i} -height 16 \
{/reg_wr_buffer_tb/dut/reset_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G2" \
{/reg_wr_buffer_tb/dut/enq_li} -height 16 \
{/reg_wr_buffer_tb/dut/deq_li} -height 16 \
{/reg_wr_buffer_tb/dut/valid_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G3" \
{/reg_wr_buffer_tb/dut/wr_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G4" \
{/reg_wr_buffer_tb/dut/wb_data_o\[31:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_tid_o\[8:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_valid_o} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G5" \
{/reg_wr_buffer_tb/dut/empty_o} -height 16 \
{/reg_wr_buffer_tb/dut/fw_req_i} -height 16 \
{/reg_wr_buffer_tb/dut/wb_tid_o\[8:0\]} -height 16 \
{/BLANK} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G6" \
}
wvSelectSignal -win $_nWave3 {( "G5" 2 3 4 )} 
wvSetPosition -win $_nWave3 {("G5" 4)}
wvGetSignalClose -win $_nWave3
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("G5" 1)}
wvSelectSignal -win $_nWave3 {( "G5" 1 )} 
wvZoom -win $_nWave3 16.703846 21.087912
wvZoomAll -win $_nWave3
wvGetSignalOpen -win $_nWave3
wvGetSignalSetScope -win $_nWave3 "/DE_pkg"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut"
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut/fifo_track"
wvSetPosition -win $_nWave3 {("G6" 9)}
wvSetPosition -win $_nWave3 {("G6" 9)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"G1" \
{/reg_wr_buffer_tb/dut/clk_i} -height 16 \
{/reg_wr_buffer_tb/dut/reset_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G2" \
{/reg_wr_buffer_tb/dut/enq_li} -height 16 \
{/reg_wr_buffer_tb/dut/deq_li} -height 16 \
{/reg_wr_buffer_tb/dut/valid_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G3" \
{/reg_wr_buffer_tb/dut/wr_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G4" \
{/reg_wr_buffer_tb/dut/wb_data_o\[31:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_tid_o\[8:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_valid_o} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G5" \
{/reg_wr_buffer_tb/dut/empty_o} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G6" \
{/reg_wr_buffer_tb/dut/fifo_track/count_r\[3:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/fifo_track/deq_i} -height 16 \
{/reg_wr_buffer_tb/dut/fifo_track/empty_o} -height 16 \
{/reg_wr_buffer_tb/dut/fifo_track/full_o} -height 16 \
{/reg_wr_buffer_tb/dut/fifo_track/reset_i} -height 16 \
{/reg_wr_buffer_tb/dut/fifo_track/rptr_r\[2:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/fifo_track/wptr_r\[2:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/fifo_track/wptr_r_o\[2:0\]} -height 16 \
{/LOGIC_LOW} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G7" \
}
wvSelectSignal -win $_nWave3 {( "G6" 2 3 4 5 6 7 8 9 )} 
wvSetPosition -win $_nWave3 {("G6" 9)}
wvGetSignalClose -win $_nWave3
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("G6" 1)}
wvDisplayGridCount -win $_nWave3 -off
wvCloseGetStreamsDialog -win $_nWave3
wvAttrOrderConfigDlg -win $_nWave3 -close
wvCloseDetailsViewDlg -win $_nWave3
wvCloseDetailsViewDlg -win $_nWave3 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave3
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomAll -win $_nWave3
wvSetCursor -win $_nWave3 34.007965 -snap {("G1" 0)}
wvZoomAll -win $_nWave3
wvZoom -win $_nWave3 33.788559 36.915098
wvDisplayGridCount -win $_nWave3 -off
wvCloseGetStreamsDialog -win $_nWave3
wvAttrOrderConfigDlg -win $_nWave3 -close
wvCloseDetailsViewDlg -win $_nWave3
wvCloseDetailsViewDlg -win $_nWave3 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave3
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvZoomAll -win $_nWave3
wvDisplayGridCount -win $_nWave3 -off
wvCloseGetStreamsDialog -win $_nWave3
wvAttrOrderConfigDlg -win $_nWave3 -close
wvCloseDetailsViewDlg -win $_nWave3
wvCloseDetailsViewDlg -win $_nWave3 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave3
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvDisplayGridCount -win $_nWave3 -off
wvCloseGetStreamsDialog -win $_nWave3
wvAttrOrderConfigDlg -win $_nWave3 -close
wvCloseDetailsViewDlg -win $_nWave3
wvCloseDetailsViewDlg -win $_nWave3 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave3
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvZoomAll -win $_nWave3
wvDisplayGridCount -win $_nWave3 -off
wvCloseGetStreamsDialog -win $_nWave3
wvAttrOrderConfigDlg -win $_nWave3 -close
wvCloseDetailsViewDlg -win $_nWave3
wvCloseDetailsViewDlg -win $_nWave3 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave3
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvZoomAll -win $_nWave3
wvGetSignalOpen -win $_nWave3
wvGetSignalSetScope -win $_nWave3 "/reg_wr_buffer_tb/dut"
wvSetPosition -win $_nWave3 {("G6" 2)}
wvSetPosition -win $_nWave3 {("G6" 2)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"G1" \
{/reg_wr_buffer_tb/dut/clk_i} -height 16 \
{/reg_wr_buffer_tb/dut/reset_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G2" \
{/reg_wr_buffer_tb/dut/enq_li} -height 16 \
{/reg_wr_buffer_tb/dut/deq_li} -height 16 \
{/reg_wr_buffer_tb/dut/valid_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G3" \
{/reg_wr_buffer_tb/dut/wr_i} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G4" \
{/reg_wr_buffer_tb/dut/wb_data_o\[31:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_tid_o\[8:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/wb_valid_o} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G5" \
{/reg_wr_buffer_tb/dut/empty_o} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G6" \
{/reg_wr_buffer_tb/dut/fifo_track/count_r\[3:0\]} -height 16 \
{/reg_wr_buffer_tb/dut/full} -height 16 \
}
wvAddSignal -win $_nWave3 -group {"G7" \
}
wvSelectSignal -win $_nWave3 {( "G6" 2 )} 
wvSetPosition -win $_nWave3 {("G6" 2)}
wvGetSignalClose -win $_nWave3
wvSetPosition -win $_nWave3 {("G7" 0)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("G7" 1)}
wvSetPosition -win $_nWave3 {("G7" 1)}
wvScrollDown -win $_nWave3 0
wvSelectSignal -win $_nWave3 {( "G2" 1 )} 
wvShowOneTraceSignals -win $_nWave3 -signal "/reg_wr_buffer_tb/dut/enq_li" \
           -valuechange
wvDisplayGridCount -win $_nWave3 -off
wvCloseGetStreamsDialog -win $_nWave3
wvAttrOrderConfigDlg -win $_nWave3 -close
wvCloseDetailsViewDlg -win $_nWave3
wvCloseDetailsViewDlg -win $_nWave3 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave3
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
wvSelectGroup -win $_nWave3 {G2//reg_wr_buffer_tb/dut/enq_li@35(1s)#ValueChange}
wvSelectSignal -win $_nWave3 \
           {( "G2//reg_wr_buffer_tb/dut/enq_li@35(1s)#ValueChange" \
           1 )} 
wvSelectSignal -win $_nWave3 \
           {( "G2//reg_wr_buffer_tb/dut/enq_li@35(1s)#ValueChange" \
           2 )} 
wvSelectSignal -win $_nWave3 \
           {( "G2//reg_wr_buffer_tb/dut/enq_li@35(1s)#ValueChange" \
           3 )} 
wvCloseGetStreamsDialog -win $_nWave3
wvAttrOrderConfigDlg -win $_nWave3 -close
wvCloseDetailsViewDlg -win $_nWave3
wvCloseDetailsViewDlg -win $_nWave3 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave3
wvGetSignalClose -win $_nWave3
wvCloseWindow -win $_nWave3
verdiSetActWin -win $_OneSearch
debExit

verdiSetActWin -dock widgetDock_<Message>
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_<Inst._Tree>
simSetSimulator "-vcssv" -exec \
           "/data/jwang710/vortex4dice/dice_new/tb/cgra_core/cgra_subsys/simv" \
           -args
debImport "-dbdir" \
          "/data/jwang710/vortex4dice/dice_new/tb/cgra_core/cgra_subsys/simv.daidir"
debLoadSimResult \
           /data/jwang710/vortex4dice/dice_new/tb/cgra_core/cgra_subsys/tb_dice_cgra.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 21 -pos 1 -win $_nTrace1
srcAction -pos 20 3 2 -win $_nTrace1 -name "clk" -ctrlKey off
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvAddSignal -win $_nWave2 "/tb_dice_cgra/clk"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rst_n" -line 387 -pos 1 -win $_nTrace1
srcSelect -signal "clr" -line 388 -pos 1 -win $_nTrace1
srcSelect -signal "disp_clr" -line 389 -pos 1 -win $_nTrace1
srcSelect -signal "disp_enable" -line 390 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/rst_n" "/tb_dice_cgra/clr" \
           "/tb_dice_cgra/disp_clr" "/tb_dice_cgra/disp_enable"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_done" -line 398 -pos 1 -win $_nTrace1
srcSelect -signal "disp_done" -line 398 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/cgra_done" "/tb_dice_cgra/disp_done"
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G2" 2)}
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.gen_rf_io\[0\]" -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -delim \
           "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 10 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {10 37 14 1 3 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 10 -pos 1 -win $_nTrace1
srcAction -pos 9 13 4 -win $_nTrace1 -name "rd_en" -ctrlKey off
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 30 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectGroup -win $_nWave2 {G3}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 26 -pos 2 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 26 -pos 2 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[0\]/u_dice_register_file/clk"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 30 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[0\]/u_dice_register_file/rd_en\[0:0\]"
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 0)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 13 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {13 26 6 1 4 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 13 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {13 41 6 1 5 1}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 13 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[0\]/u_dice_register_file/gen_bank\[0\]/bank_ram/rd_en"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file" \
           -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -delim \
           "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "conv_rd_addr\[i*RF_ADDR_WIDTH +: RF_ADDR_WIDTH\]" -line 134 \
          -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 133 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 15 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/rd_en\[31:0\]"
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvZoom -win $_nWave2 3121712.519154 3159557.339871
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 3122682.899173 3143060.879559
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 2989740.836653 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 916038.737358 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 928653.677597 -snap {("G3" 2)}
srcDeselectAll -win $_nTrace1
srcAction -pos 125 1 14 -win $_nTrace1 -name "dice_register_file" -ctrlKey off
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcAction -pos 125 1 14 -win $_nTrace1 -name "dice_register_file" -ctrlKey off
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "mem" -line 18 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvAddSignal -win $_nWave2 \
           "tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[0\]/u_dice_register_file/gen_bank\[0\]/bank_ram/mem\[0:511\]"
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 13 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem" -win $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem" -win $_nTrace1
srcHBSelect "tb_dice_cgra" -win $_nTrace1
srcSetScope "tb_dice_cgra" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra" -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_cfg\[tile_idx * TILE_BITS + \(TILE_BITS - 1 - b\)\]" \
          -line 319 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/cgra_cfg\[2495:0\]"
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rf_rd_en\[i\]" -line 157 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/rf_rd_en\[31:0\]"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal \
          "gprf_cfg\[i*GPRF_CFG_BITS_PER_PORT +: GPRF_CFG_BITS_PER_PORT\]" \
          -line 167 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/gprf_cfg\[1567:0\]"
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal \
          "gprf_cfg\[i*GPRF_CFG_BITS_PER_PORT +: GPRF_CFG_BITS_PER_PORT\]" \
          -line 167 -pos 1 -win $_nTrace1
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 75689.641434 -snap {("G1" 4)}
wvZoom -win $_nWave2 6792.660129 62104.321177
wvZoom -win $_nWave2 6945.220640 8267.411741
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvZoomAll -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "gprf_cfg" -line 278 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "predrf_cfg" -line 227 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/predrf_cfg\[255:0\]"
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G5" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "prf_rd_en\[i\]" -line 155 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {155 179 3 1 8 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "prf_rd_en\[i\]" -line 155 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/prf_rd_en\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 21348.744054 -snap {("G6" 1)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvSetRadix -win $_nWave2 -format Bin
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetCursor -win $_nWave2 1627356.535418 -snap {("G3" 0)}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal \
          "gprf_cfg\[i*GPRF_CFG_BITS_PER_PORT +: GPRF_CFG_BITS_PER_PORT\]" \
          -line 167 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal \
          "gprf_cfg\[i*GPRF_CFG_BITS_PER_PORT +: GPRF_CFG_BITS_PER_PORT\]" \
          -line 167 -pos 1 -partailSelPos 12 -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
debLoadSimResult \
           /data/jwang710/vortex4dice/dice_new/tb/cgra_core/cgra_subsys/tb_dice_cgra.fsdb
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
verdiSetActWin -win $_nWave2
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
debReload
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 )} {( "G2" 1 2 )} {( "G3" 1 \
           2 )} {( "G4" 1 )} {( "G5" 1 )} {( "G6" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvSelectSignal -win $_nWave2 {( "G3" 1 2 )} {( "G4" 1 )} {( "G5" 1 )} {( "G6" \
           1 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSelectGroup -win $_nWave2 {G7}
wvSelectGroup -win $_nWave2 {G4} {G5} {G6} {G7}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSelectGroup -win $_nWave2 {G3}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl" -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -delim \
           "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl" -win $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl" -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -delim \
           "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 133 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {133 141 6 1 5 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 133 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 133 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pipe_rf_rd_data\[i*DATA_WIDTH +: DATA_WIDTH\]" -line 135 -pos \
          1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "conv_rd_addr\[i*RF_ADDR_WIDTH +: RF_ADDR_WIDTH\]" -line 134 \
          -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/conv_rd_addr\[8:0\]"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetCursor -win $_nWave2 61200.047529 -snap {("G4" 0)}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "pipe_rf_rd_data\[i*DATA_WIDTH +: DATA_WIDTH\]" -line 135 -pos \
          1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/pipe_rf_rd_data\[31:0\]"
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetCursor -win $_nWave2 183600.142586 -snap {("G4" 0)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 122400.095057 -snap {("G3" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rst_n" -line 132 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 133 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/rd_en\[0\]"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetCursor -win $_nWave2 814662.927757 -snap {("G3" 3)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 178583.745247 -snap {("G3" 3)}
wvSetCursor -win $_nWave2 190623.098859 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 119390.256654 -snap {("G3" 3)}
wvSelectSignal -win $_nWave2 {( "G3" 3 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSetRadix -win $_nWave2 -format UDec
wvZoom -win $_nWave2 196642.775665 504649.572243
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvSearchNext -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 258118.296530 750619.873817
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_addr_override_enable\[i*RF_ADDR_WIDTH +: RF_ADDR_WIDTH\]" \
          -line 112 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {112 123 6 1 10 7}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_addr_override_enable\[i*RF_ADDR_WIDTH +: RF_ADDR_WIDTH\]" \
          -line 112 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_addr_override_address\[i*RF_ADDR_WIDTH +: RF_ADDR_WIDTH\]" \
          -line 113 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_addr_override_enable\[i*RF_ADDR_WIDTH +: RF_ADDR_WIDTH\]" \
          -line 112 -pos 1 -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[8\]" -delim \
           "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 133 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/rd_en\[8\]"
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "conv_rd_addr\[i*RF_ADDR_WIDTH +: RF_ADDR_WIDTH\]" -line 134 \
          -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/conv_rd_addr\[80:72\]"
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 2)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSetRadix -win $_nWave2 -format UDec
srcDeselectAll -win $_nTrace1
srcSelect -signal "pipe_rf_rd_data\[i*DATA_WIDTH +: DATA_WIDTH\]" -line 135 -pos \
          1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/pipe_rf_rd_data\[287:256\]"
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 17 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/rd_data\[1023:0\]"
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G5" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data\[i*DATA_WIDTH +: DATA_WIDTH\]" -line 102 -pos 1 -win \
          $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_data\[i*DATA_WIDTH +: DATA_WIDTH\]" -line 103 -pos 1 -win \
          $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data\[i*DATA_WIDTH +: DATA_WIDTH\]" -line 102 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/rd_data\[287:256\]"
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst.alu_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst.alu_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst.alu_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "in0" -line 27 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/alu_inst/in0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "in1" -line 28 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/alu_inst/in1\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
verdiSetActWin -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 1)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "in2" -line 29 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/alu_inst/in2\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvScrollDown -win $_nWave2 2
wvZoom -win $_nWave2 203215.161859 299540.391486
verdiSetActWin -win $_nWave2
wvZoom -win $_nWave2 223786.519517 227479.597078
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvGoToGroup -win $_nWave2 "G2"
wvGoToGroup -win $_nWave2 "G3"
wvScrollUp -win $_nWave2 4
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 1)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 193519.136518 324728.705861
srcDeselectAll -win $_nTrace1
srcSelect -signal "opcode" -line 31 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "out0" -line 32 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/alu_inst/out0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
verdiSetActWin -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "opcode" -line 31 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/alu_inst/opcode\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 5)}
verdiSetActWin -win $_nWave2
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSetRadix -win $_nWave2 -format Hex
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tile_cfg" -line 46 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/tile_cfg\[155:0\]"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "tile_cfg\[154:123\]" -line 209 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSetCursor -win $_nWave2 66216.550732 -snap {("G6" 3)}
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
debReload
wvZoom -win $_nWave2 190780.116823 452478.496967
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 45161.885895 -snap {("G6" 4)}
wvZoom -win $_nWave2 41147.496038 47169.080824
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 5 )} 
wvSetCursor -win $_nWave2 73262.614897 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 318140.396197 -snap {("G6" 5)}
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSetCursor -win $_nWave2 82294.992076 -snap {("G6" 4)}
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSetRadix -win $_nWave2 -format Bin
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 3 4 5 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 3 4 5 6 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 253910.158479 -snap {("G6" 6)}
wvZoom -win $_nWave2 259931.743265 639291.584786
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 490582.615977 567055.788467
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 212912.946801 466159.129426
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 234383.154759 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 243373.193572 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 251721.086755 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 245941.776089 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 251721.086755 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 253647.523643 -snap {("G6" 1)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 218405.794054 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 203543.861323 -snap {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSetCursor -win $_nWave2 224867.503937 -snap {("G6" 2)}
wvSetCursor -win $_nWave2 232621.555797 -snap {("G6" 1)}
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_in" -line 8 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_in\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvScrollDown -win $_nWave2 2
wvSetCursor -win $_nWave2 236498.581727 -snap {("G6" 5)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 242960.291610 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 236498.581727 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 241021.778645 -snap {("G6" 5)}
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_in_t0" -line 46 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/W_in_t0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvScrollDown -win $_nWave2 2
wvSetCursor -win $_nWave2 222928.990972 -snap {("G6" 8)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 237790.923704 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 224867.503937 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 222282.819984 -snap {("G6" 8)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_out_t3" -line 61 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/L_out_t3\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_mux_t3" -line 348 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/L_mux_t3\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_mux_t3" -line 348 -pos 1 -win $_nTrace1
srcAction -pos 347 15 5 -win $_nTrace1 -name "L_mux_t3" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_en_L_t3" -line 305 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_in_t0" -line 305 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_sel_t3" -line 305 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_in_t0" -line 305 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_sel_t3" -line 305 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/L_sel_t3\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_sel_t3" -line 305 -pos 1 -win $_nTrace1
srcAction -pos 304 21 4 -win $_nTrace1 -name "L_sel_t3" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t1" -line 283 -pos 1 -win $_nTrace1
wvScrollDown -win $_nWave2 3
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G6" 7)}
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/E_in_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvScrollDown -win $_nWave2 2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\]" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t1" -line 43 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/u_data_router/E_in_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvScrollDown -win $_nWave2 1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[2\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[2\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[2\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[2\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t1" -line 43 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[2\]/tile_inst/u_data_router/E_in_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvScrollDown -win $_nWave2 2
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[3\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[3\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[3\].tile_inst.pe_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[3\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[3\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[3\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t0" -line 42 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t1" -line 43 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[3\]/tile_inst/u_data_router/E_in_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvScrollDown -win $_nWave2 2
wvSetCursor -win $_nWave2 113726.093945 -snap {("G7" 1)}
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 114372.264934 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 116310.777899 -snap {("G3" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetCursor -win $_nWave2 196435.980451 -snap {("G1" 4)}
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 233267.726785 -snap {("G6" 13)}
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_out_p0" -line 213 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/L_out_p0"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 14)}
verdiSetActWin -win $_nWave2
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 15)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_out_p1" -line 214 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/L_out_p1"
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvScrollDown -win $_nWave2 3
wvSetCursor -win $_nWave2 216467.281089 -snap {("G6" 15)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 228744.529867 -snap {("G6" 15)}
wvSetCursor -win $_nWave2 233913.897774 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 245544.975564 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 239729.436669 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 233267.726785 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 224867.503937 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 233267.726785 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 242960.291610 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 235206.239750 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 226806.016902 -snap {("G6" 1)}
wvSetCursor -win $_nWave2 185451.073649 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 201605.348358 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 226806.016902 -snap {("G6" 15)}
wvSetCursor -win $_nWave2 237144.752715 -snap {("G6" 15)}
wvSetCursor -win $_nWave2 226806.016902 -snap {("G6" 15)}
wvSetCursor -win $_nWave2 242314.120622 -snap {("G6" 15)}
wvSetCursor -win $_nWave2 220344.307019 -snap {("G6" 15)}
wvSetCursor -win $_nWave2 204190.032311 -snap {("G6" 16)}
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
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_output_mode" -line 74 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 59 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_in_enable" -line 60 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_in_enable"
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvScrollDown -win $_nWave2 2
wvSetCursor -win $_nWave2 227452.187891 -snap {("G6" 16)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 234560.068762 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 240375.607657 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 222282.819984 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 239729.436669 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 224867.503937 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 241021.778645 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 224221.332949 -snap {("G6" 16)}
wvSetCursor -win $_nWave2 226806.016902 -snap {("G6" 15)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 235206.239750 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 225513.674926 -snap {("G6" 3)}
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_in2" -line 6 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_in2" -line 6 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_in2" -line 6 -pos 1 -win $_nTrace1
srcAction -pos 5 11 4 -win $_nTrace1 -name "pe_in2" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_mux_t2" -line 347 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/L_mux_t2\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSelectSignal -win $_nWave2 {( "G6" 15 )} 
wvSetCursor -win $_nWave2 233267.726785 -snap {("G6" 1)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 222928.990972 -snap {("G6" 3)}
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 236498.581727 -snap {("G6" 11)}
wvSetCursor -win $_nWave2 226806.016902 -snap {("G6" 15)}
wvSelectSignal -win $_nWave2 {( "G6" 15 )} 
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" \
           -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pipe_rd_data" -line 35 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 16 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 17)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/rd_data\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 16 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 15)}
verdiSetActWin -win $_nWave2
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" \
           -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 12 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 17)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_data\[0:0\]"
wvSetPosition -win $_nWave2 {("G6" 17)}
wvSetPosition -win $_nWave2 {("G6" 18)}
wvSetCursor -win $_nWave2 204836.203299 -snap {("G6" 18)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 18 )} 
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "sel_L_t0" -line 43 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 17)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 18)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_pred_router/sel_L_t0\[3:0\]"
wvSetPosition -win $_nWave2 {("G6" 18)}
wvSetPosition -win $_nWave2 {("G6" 19)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_sel_t0" -line 196 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 17)}
wvSetPosition -win $_nWave2 {("G6" 18)}
wvSetPosition -win $_nWave2 {("G6" 19)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_pred_router/L_sel_t0\[0:0\]"
wvSetPosition -win $_nWave2 {("G6" 19)}
wvSetPosition -win $_nWave2 {("G6" 20)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "N_in_t0" -line 196 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 18)}
wvSetPosition -win $_nWave2 {("G6" 19)}
wvSetPosition -win $_nWave2 {("G6" 20)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 20)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_pred_router/N_in_t0\[0:0\]"
wvSetPosition -win $_nWave2 {("G6" 20)}
wvSetPosition -win $_nWave2 {("G6" 21)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "N_in_t0" -line 15 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 16)}
wvSetPosition -win $_nWave2 {("G6" 18)}
wvSetPosition -win $_nWave2 {("G6" 19)}
wvSetPosition -win $_nWave2 {("G6" 20)}
wvSetPosition -win $_nWave2 {("G6" 21)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 21)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_pred_router/N_in_t0\[0:0\]"
wvSetPosition -win $_nWave2 {("G6" 21)}
wvSetPosition -win $_nWave2 {("G6" 22)}
wvSetCursor -win $_nWave2 233913.897774 -snap {("G6" 20)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 235206.239750 -snap {("G6" 13)}
wvSetCursor -win $_nWave2 224221.332949 -snap {("G6" 15)}
wvSelectSignal -win $_nWave2 {( "G6" 22 )} 
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcActiveTrace \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router.N_in_t0\[0:0\]" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p0" -line 284 -pos 1 -win $_nTrace1
srcActiveTrace "tb_dice_cgra.u_cgra_subsystem.u_cgra.CGRA_N_in_p0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_in_p\[i+CGRA_IO_PER_EDGE\]" -line 120 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G6" 21)}
wvSetPosition -win $_nWave2 {("G6" 22)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/CGRA_in_p\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSetRadix -win $_nWave2 -format Bin
wvZoom -win $_nWave2 197728.322428 347639.991719
wvZoom -win $_nWave2 220103.198441 248977.443202
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvExpandBus -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G7" 25 )} 
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcDeselectAll -win $_nTrace1
srcSelect -signal "N_in_p\[i\]" -line 120 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAction -pos 119 1 2 -win $_nTrace1 -name "N_in_p\[i\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "N_in_p\[i\]" -line 120 -pos 1 -win $_nTrace1
srcAction -pos 119 1 3 -win $_nTrace1 -name "N_in_p\[i\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_in_p\[i\]" -line 172 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "prf_rd_data\[i\]" -line 172 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 16)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 28)}
wvSetPosition -win $_nWave2 {("G7" 29)}
wvSetPosition -win $_nWave2 {("G7" 31)}
wvSetPosition -win $_nWave2 {("G7" 32)}
wvSetPosition -win $_nWave2 {("G7" 33)}
wvSetPosition -win $_nWave2 {("G7" 34)}
wvSetPosition -win $_nWave2 {("G7" 33)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/prf_rd_data\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 33)}
wvSetPosition -win $_nWave2 {("G7" 34)}
wvSelectSignal -win $_nWave2 {( "G7" 34 )} 
wvExpandBus -win $_nWave2
verdiSetActWin -win $_nWave2
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
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "prf_rd_data\[i\]" -line 172 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl" -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" \
           -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 16 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 48)}
wvSetPosition -win $_nWave2 {("G7" 54)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 61)}
wvSetPosition -win $_nWave2 {("G7" 63)}
wvSetPosition -win $_nWave2 {("G7" 65)}
wvSetPosition -win $_nWave2 {("G7" 66)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/rd_data\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 66)}
wvSetPosition -win $_nWave2 {("G7" 67)}
wvScrollDown -win $_nWave2 2
wvSelectSignal -win $_nWave2 {( "G7" 67 )} 
wvExpandBus -win $_nWave2
verdiSetActWin -win $_nWave2
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
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G7" 68 69 70 71 72 73 74 75 76 77 78 79 80 81 \
           82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 )} 
wvSelectSignal -win $_nWave2 {( "G7" 91 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_addr" -line 11 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 12 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 81)}
wvSetPosition -win $_nWave2 {("G7" 80)}
wvSetPosition -win $_nWave2 {("G7" 79)}
wvSetPosition -win $_nWave2 {("G7" 81)}
wvSetPosition -win $_nWave2 {("G7" 85)}
wvSetPosition -win $_nWave2 {("G7" 87)}
wvSetPosition -win $_nWave2 {("G7" 89)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 90)}
wvSetPosition -win $_nWave2 {("G7" 91)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_data\[0:0\]"
wvSetPosition -win $_nWave2 {("G7" 91)}
wvSetPosition -win $_nWave2 {("G7" 92)}
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G7" 91 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G7" 91 )} 
wvSelectSignal -win $_nWave2 {( "G7" 92 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "latency_in" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "latency_out" -line 12 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "latency_in" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rf_rdata" -line 15 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 81)}
wvSetPosition -win $_nWave2 {("G7" 85)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 92)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_cgra_port_io/rf_rdata\[0:0\]"
wvSetPosition -win $_nWave2 {("G7" 92)}
wvSetPosition -win $_nWave2 {("G7" 93)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_out" -line 19 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_in" -line 18 -pos 1 -win $_nTrace1
srcAction -pos 17 15 5 -win $_nTrace1 -name "cgra_in" -ctrlKey off
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io.gen_port\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io.gen_port\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io.gen_port\[0\]" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_in" -line 18 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_out" -line 19 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 81)}
wvSetPosition -win $_nWave2 {("G7" 86)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 93)}
wvSetPosition -win $_nWave2 {("G7" 94)}
wvSetPosition -win $_nWave2 {("G7" 95)}
wvSetPosition -win $_nWave2 {("G7" 94)}
wvSetPosition -win $_nWave2 {("G7" 93)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_cgra_port_io/cgra_out\[0:0\]"
wvSetPosition -win $_nWave2 {("G7" 93)}
wvSetPosition -win $_nWave2 {("G7" 94)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 6 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 88)}
wvSetPosition -win $_nWave2 {("G7" 90)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 94)}
wvSetPosition -win $_nWave2 {("G7" 95)}
wvSetPosition -win $_nWave2 {("G7" 94)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_cgra_port_io/clk"
wvSetPosition -win $_nWave2 {("G7" 94)}
wvSetPosition -win $_nWave2 {("G7" 95)}
srcDeselectAll -win $_nTrace1
debReload
debReload
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
wvSetCursor -win $_nWave2 142400.216243 -snap {("G7" 99)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 117041.273624 -snap {("G7" 99)}
wvSelectSignal -win $_nWave2 {( "G7" 96 )} 
wvSelectSignal -win $_nWave2 {( "G7" 97 )} 
wvSelectSignal -win $_nWave2 {( "G7" 98 )} 
wvSelectSignal -win $_nWave2 {( "G7" 100 )} 
wvSelectSignal -win $_nWave2 {( "G7" 102 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 103 )} 
srcHBSelect "tb_dice_cgra" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra" -win $_nTrace1
srcSetScope "tb_dice_cgra" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "disp_tid_valid" -line 87 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 96)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 101)}
wvSetPosition -win $_nWave2 {("G7" 102)}
wvSetPosition -win $_nWave2 {("G7" 103)}
wvSetPosition -win $_nWave2 {("G7" 104)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/disp_tid_valid"
wvSetPosition -win $_nWave2 {("G7" 104)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G7" 104)}
wvSetPosition -win $_nWave2 {("G7" 103)}
verdiSetActWin -win $_nWave2
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G7" 103)}
wvSetPosition -win $_nWave2 {("G7" 104)}
wvSetCursor -win $_nWave2 196369.247970 -snap {("G7" 104)}
debReload
wvSelectSignal -win $_nWave2 {( "G7" 103 )} 
wvSelectSignal -win $_nWave2 {( "G7" 102 )} 
wvSelectSignal -win $_nWave2 {( "G7" 103 )} 
wvSelectSignal -win $_nWave2 {( "G7" 102 )} 
srcHBSelect "tb_dice_cgra.gen_rf_io\[8\]" -win $_nTrace1
srcSetScope "tb_dice_cgra.gen_rf_io\[8\]" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.gen_rf_io\[8\]" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" \
           -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 30 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {30 37 6 1 4 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 30 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {30 37 6 1 4 1}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 30 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 85)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G7" 101)}
wvSetPosition -win $_nWave2 {("G7" 103)}
wvSetPosition -win $_nWave2 {("G7" 104)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G7" 104)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_en\[0:0\]"
wvSetPosition -win $_nWave2 {("G7" 104)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 211324.521822 -snap {("G7" 104)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 225629.566376 -snap {("G7" 102)}
wvSetCursor -win $_nWave2 197019.477268 -snap {("G7" 104)}
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
debReload
wvSetCursor -win $_nWave2 210674.292524 -snap {("G7" 96)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 214575.668311 -snap {("G7" 86)}
wvSetCursor -win $_nWave2 223678.878482 -snap {("G7" 85)}
wvSetCursor -win $_nWave2 239284.381632 -snap {("G7" 85)}
wvSetCursor -win $_nWave2 221728.190588 -snap {("G7" 85)}
wvSetCursor -win $_nWave2 242535.528122 -snap {("G7" 85)}
wvSetCursor -win $_nWave2 229530.942163 -snap {("G7" 85)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
debReload
debReload
debReload
wvSelectSignal -win $_nWave2 {( "G7" 96 )} 
wvSetCursor -win $_nWave2 200920.853055 -snap {("G7" 96)}
wvSetCursor -win $_nWave2 214575.668311 -snap {("G7" 95)}
wvSetCursor -win $_nWave2 224979.337078 -snap {("G7" 95)}
wvSetCursor -win $_nWave2 235383.005845 -snap {("G7" 95)}
wvSetCursor -win $_nWave2 204171.999545 -snap {("G7" 95)}
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 106 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 106 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 106 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 106 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 106 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 106 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 104 )} 
wvSelectSignal -win $_nWave2 {( "G7" 105 )} 
wvSelectSignal -win $_nWave2 {( "G7" 106 )} 
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[10\]" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_addr" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_data" -line 12 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 97)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G7" 103)}
wvSetPosition -win $_nWave2 {("G7" 104)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G7" 106)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_data\[0:0\]"
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 272446.075826 -snap {("G8" 1)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 221077.961291 -snap {("G9" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 10 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 93)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_en\[0:0\]"
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetCursor -win $_nWave2 208723.604630 -snap {("G8" 1)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 513681.145352 -snap {("G8" 1)}
wvSetCursor -win $_nWave2 196369.247970 -snap {("G8" 2)}
wvSetCursor -win $_nWave2 204822.228843 -snap {("G8" 1)}
wvSetCursor -win $_nWave2 193768.330778 -snap {("G8" 2)}
wvScrollDown -win $_nWave2 1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" \
           -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\]" -win \
           $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_in" -line 18 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 91)}
wvSetPosition -win $_nWave2 {("G7" 105)}
wvSetPosition -win $_nWave2 {("G7" 106)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_cgra_port_io/cgra_in\[0:0\]"
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 28
wvScrollDown -win $_nWave2 28
wvScrollUp -win $_nWave2 108
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
verdiSetActWin -win $_nWave2
wvScrollDown -win $_nWave2 13
wvScrollDown -win $_nWave2 94
wvSelectSignal -win $_nWave2 {( "G7" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
           84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 \
           105 106 )} {( "G8" 1 2 3 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 0)}
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 21 )} 
wvSelectSignal -win $_nWave2 {( "G6" 22 )} 
wvScrollUp -win $_nWave2 15
wvScrollUp -win $_nWave2 5
wvScrollUp -win $_nWave2 2
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G3" 1 2 3 )} {( "G4" 1 2 3 )} {( "G5" 1 )} {( \
           "G6" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSelectGroup -win $_nWave2 {G4}
wvSelectGroup -win $_nWave2 {G4} {G5} {G6} {G7} {G8} {G9}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 0)}
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_in" -line 18 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_cgra" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p0" -line 21 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p0"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p2" -line 23 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p2"
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
verdiSetActWin -win $_nWave2
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p4" -line 25 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p4"
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G3" 3)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p6" -line 27 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p6"
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G3" 4)}
wvSelectGroup -win $_nWave2 {G4}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p0" -line 21 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {21 22 6 6 9 9}
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p1" -line 22 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G3" 4)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G3" 4)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p1"
wvSetPosition -win $_nWave2 {("G3" 4)}
wvSetPosition -win $_nWave2 {("G3" 5)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file.gen_bank\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en" -line 10 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "rd_addr" -line 11 -pos 1 -win $_nTrace1
srcSelect -signal "rd_data" -line 12 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_en\[0:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_addr\[8:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_data\[0:0\]"
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 211324.521822 -snap {("G5" 0)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSetCursor -win $_nWave2 203521.770247 -snap {("G4" 2)}
wvSetCursor -win $_nWave2 194418.560076 -snap {("G4" 2)}
wvSetCursor -win $_nWave2 202871.540949 -snap {("G4" 2)}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetCursor -win $_nWave2 195068.789374 -snap {("G1" 4)}
wvSelectSignal -win $_nWave2 {( "G4" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvScrollDown -win $_nWave2 0
srcHBSelect "tb_dice_cgra.u_dispatcher" -win $_nTrace1
srcSetScope "tb_dice_cgra.u_dispatcher" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_dispatcher" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "dispatch_tid" -line 10 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 2)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_dispatcher/dispatch_tid\[8:0\]"
wvSetPosition -win $_nWave2 {("G4" 2)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
verdiSetActWin -win $_nWave2
debReload
wvSetCursor -win $_nWave2 202871.540949 -snap {("G4" 1)}
debReload
wvScrollDown -win $_nWave2 0
srcHBSelect "tb_dice_cgra.u_dispatcher" -win $_nTrace1
srcSetScope "tb_dice_cgra.u_dispatcher" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_dispatcher" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "tid_valid" -line 17 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_dispatcher/tid_valid"
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dispatch_tid" -line 10 -pos 1 -win $_nTrace1
srcSelect -signal "done" -line 9 -pos 1 -win $_nTrace1
srcSelect -signal "max_tid" -line 8 -pos 1 -win $_nTrace1
srcSelect -signal "enable" -line 6 -pos 1 -win $_nTrace1
srcSelect -signal "clk" -line 4 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 1)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_dispatcher/dispatch_tid\[8:0\]" \
           "/tb_dice_cgra/u_dispatcher/done" \
           "/tb_dice_cgra/u_dispatcher/max_tid\[8:0\]" \
           "/tb_dice_cgra/u_dispatcher/enable" \
           "/tb_dice_cgra/u_dispatcher/clk"
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G5" 6)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 176212.139735 -snap {("G5" 4)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G5" 4 )} 
wvSelectSignal -win $_nWave2 {( "G5" 3 )} 
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G5" 5 )} 
wvSelectSignal -win $_nWave2 {( "G5" 3 )} 
wvZoom -win $_nWave2 0.000000 160582731.876333
wvZoom -win $_nWave2 0.000000 9358766.179004
wvZoom -win $_nWave2 2288141.837653 3538637.958231
wvZoom -win $_nWave2 2707640.180874 2910279.211074
wvZoomAll -win $_nWave2
debReload
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G5" 3 )} 
wvZoom -win $_nWave2 130941.080313 519249.111585
wvZoom -win $_nWave2 184481.775456 265344.784101
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2648170.469083 2975523.169865
wvSelectSignal -win $_nWave2 {( "G4" 1 )} 
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 146744.314144 618583.724236
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G5" 6 )} 
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst.alu_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_in0" -line 4 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "pe_in1" -line 5 -pos 1 -win $_nTrace1
srcSelect -signal "pe_in2" -line 6 -pos 1 -win $_nTrace1
srcSelect -signal "dff_in" -line 8 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G3" 5)}
wvSetPosition -win $_nWave2 {("G4" 3)}
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSetPosition -win $_nWave2 {("G5" 5)}
wvSetPosition -win $_nWave2 {("G5" 6)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/pe_in0\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/pe_in1\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/pe_in2\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_in\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSetPosition -win $_nWave2 {("G5" 1)}
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G5" 3)}
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSetPosition -win $_nWave2 {("G5" 5)}
wvSetPosition -win $_nWave2 {("G5" 6)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvZoom -win $_nWave2 216832.755302 299664.549397
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 97961.695363 606608.959747
wvSetCursor -win $_nWave2 250881.235401 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 253411.818806 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 264980.200086 -snap {("G5" 5)}
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 189638.805970 489900.248756
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSetCursor -win $_nWave2 256434.706178 -snap {("G6" 4)}
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 18 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "dff_output_mode" -line 19 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_input_mode" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_output_mode"
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 256221.300746 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 263903.896297 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 256648.111610 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 265184.328889 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 256007.895314 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 263263.680001 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 256648.111610 -snap {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 244910.812851 -snap {("G6" 5)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t0" -line 42 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/E_in_t0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetCursor -win $_nWave2 243630.380259 -snap {("G6" 5)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 231466.270637 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 243630.380259 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 231679.676069 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 243203.569395 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 234453.946684 -snap {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_sel_t0" -line 245 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/L_sel_t0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "sel_L_t0" -line 234 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t0" -line 237 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G5" 3)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/E_in_t0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "sel_L_t0" -line 234 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/sel_L_t0\[3:0\]"
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_sel_t0" -line 242 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/L_sel_t0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvScrollDown -win $_nWave2 3
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 8 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSelectSignal -win $_nWave2 {( "G6" 8 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_in_t1" -line 242 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/W_in_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t1" -line 238 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/E_in_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 8 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 8 )} 
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "N_in_t1" -line 41 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "E_in_t1" -line 43 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/u_data_router/E_in_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 7 )} 
wvSetCursor -win $_nWave2 245551.029147 -snap {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvSetCursor -win $_nWave2 254940.868154 -snap {("G6" 9)}
wvSetCursor -win $_nWave2 264757.518025 -snap {("G6" 9)}
wvSetCursor -win $_nWave2 255581.084450 -snap {("G6" 9)}
wvSelectSignal -win $_nWave2 {( "G6" 8 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -delim "." -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst.alu_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "N_in_t1" -line 16 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "N_in_t0" -line 15 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 0)}
wvSetPosition -win $_nWave2 {("G6" 3)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_pred_router/N_in_t0\[0:0\]"
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
debReload
wvSetCursor -win $_nWave2 234857.629866 -snap {("G6" 4)}
verdiSetActWin -win $_nWave2
debReload
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
debReload
wvScrollUp -win $_nWave2 1
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G4" 4 )} 
wvSelectSignal -win $_nWave2 {( "G4" 3 )} 
wvSelectSignal -win $_nWave2 {( "G4" 4 )} 
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSelectSignal -win $_nWave2 {( "G4" 4 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 4 )} 
wvShowOneTraceSignals -win $_nWave2 -signal \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_data\[0:0\]" \
           -driver
wvSelectSignal -win $_nWave2 \
           {( "G4//tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks[8]/u_dice_register_file/rd_data@225000(1ps)#ActiveDriver" \
           3 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvScrollUp -win $_nWave2 2
wvSelectSignal -win $_nWave2 \
           {( "G4//tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks[8]/u_dice_register_file/rd_data@225000(1ps)#ActiveDriver" \
           2 )} 
wvSelectSignal -win $_nWave2 \
           {( "G4//tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks[8]/u_dice_register_file/rd_data@225000(1ps)#ActiveDriver" \
           3 )} 
wvSelectSignal -win $_nWave2 \
           {( "G4//tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks[8]/u_dice_register_file/rd_data@225000(1ps)#ActiveDriver" \
           2 )} 
wvSelectSignal -win $_nWave2 \
           {( "G4//tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks[8]/u_dice_register_file/rd_data@225000(1ps)#ActiveDriver" \
           1 )} 
wvSelectGroup -win $_nWave2 \
           {G4//tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks[8]/u_dice_register_file/rd_data@225000(1ps)#ActiveDriver}
wvSelectSignal -win $_nWave2 {( "G4" 4 )} 
wvSelectGroup -win $_nWave2 \
           {G4//tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks[8]/u_dice_register_file/rd_data@225000(1ps)#ActiveDriver}
debReload
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 254086.195167 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 265285.249684 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 254931.406829 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 264228.735107 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 252395.771844 -snap {("G6" 8)}
wvSetCursor -win $_nWave2 64661.845888 -snap {("G6" 9)}
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 153517.128643 634386.958067
wvSetCursor -win $_nWave2 255364.469914 -snap {("G6" 10)}
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
wvScrollUp -win $_nWave2 4
wvSelectSignal -win $_nWave2 {( "G4" 4 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G4" 1 2 3 4 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSelectGroup -win $_nWave2 {G4}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvScrollDown -win $_nWave2 0
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_dice_register_file" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 30 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "rd_addr\[\(i+1\)*ADDR_WIDTH-1:i*ADDR_WIDTH\]" -line 31 -pos 1 \
          -win $_nTrace1
srcSelect -signal "rd_data\[\(i+1\)*WIDTH-1:i*WIDTH\]" -line 32 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_en\[0:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_addr\[8:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_dice_register_file/rd_data\[0:0\]"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetCursor -win $_nWave2 182909.314378 -snap {("G8" 0)}
wvScrollDown -win $_nWave2 1
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 206149.647286 -snap {("G7" 1)}
wvSetCursor -win $_nWave2 206491.416888 -snap {("G8" 0)}
wvSetCursor -win $_nWave2 214693.887325 -snap {("G7" 2)}
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_pred_rf_ctrl.gen_rf_banks\[8\].u_cgra_port_io" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "latency_in" -line 11 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_cgra_port_io/latency_in\[2:0\]"
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rf_rdata\[\(i+1\)*WIDTH-1:i*WIDTH\]" -line 36 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G5" 3)}
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_cgra_port_io/rf_rdata\[0:0\]"
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G7" 5)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_in\[\(i+1\)*WIDTH-1:i*WIDTH\]" -line 37 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 5)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_pred_rf_ctrl/gen_rf_banks\[8\]/u_cgra_port_io/cgra_in\[0:0\]"
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetCursor -win $_nWave2 220845.740154 -snap {("G7" 5)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 233149.445811 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 245111.381866 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 253313.852304 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 264592.249156 -snap {("G7" 2)}
debReload
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
debReload
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 249285.011632 -snap {("G6" 5)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSetCursor -win $_nWave2 256391.462313 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 265189.925061 -snap {("G6" 4)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\]" -win \
           $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\]" -delim "." \
           -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\]" -win \
           $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "opcode" -line 14 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "out_sel" -line 15 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_out_p0" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_out_t1" -line 10 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_out_t0" -line 9 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/pe_out_t0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 5)}
wvSetCursor -win $_nWave2 248269.804392 -snap {("G6" 5)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 264851.522648 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 272296.375742 -snap {("G6" 5)}
wvSetCursor -win $_nWave2 273988.387809 -snap {("G6" 4)}
wvSelectSignal -win $_nWave2 {( "G6" 4 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 5 )} 
wvSetRadix -win $_nWave2 -format UDec
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSetCursor -win $_nWave2 565014.463323 -snap {("G6" 10)}
wvSetCursor -win $_nWave2 213752.758226 -snap {("G6" 12)}
wvSetCursor -win $_nWave2 533881.441291 -snap {("G6" 12)}
wvSetCursor -win $_nWave2 545387.123346 -snap {("G6" 12)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 59 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_in_enable" -line 60 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_in_enable"
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetCursor -win $_nWave2 254699.450246 -snap {("G6" 10)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 261129.096100 -snap {("G6" 11)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 59 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSetCursor -win $_nWave2 253684.243006 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 260790.693687 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 254361.047833 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 267220.339541 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 255037.852659 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 263497.912994 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 256053.059899 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 262821.108167 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 262821.108167 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 252669.035766 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 264174.717821 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 256053.059899 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 263497.912994 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 256053.059899 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 263497.912994 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 252669.035766 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 263836.315407 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 256391.462313 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 263159.510581 -snap {("G6" 4)}
debReload
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSetCursor -win $_nWave2 249961.816459 -snap {("G6" 6)}
wvSetCursor -win $_nWave2 257406.669553 -snap {("G6" 11)}
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff0" -line 61 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_in" -line 61 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff0" -line 61 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_in" -line 61 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff1" -line 63 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "out0" -line 63 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff1" -line 63 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "out0" -line 63 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
verdiSetActWin -win $_nWave2
debReload
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 2 )} 
wvSelectSignal -win $_nWave2 {( "G6" 3 )} 
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 247254.597151 -snap {("G6" 10)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSetCursor -win $_nWave2 253684.243006 -snap {("G6" 6)}
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
debReload
wvSetCursor -win $_nWave2 263497.912994 -snap {("G6" 5)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 238794.536817 -snap {("G6" 4)}
wvSetCursor -win $_nWave2 252669.035766 -snap {("G6" 2)}
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 2 3 4 5 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 11)}
wvScrollUp -win $_nWave2 3
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSetCursor -win $_nWave2 215444.770293 -snap {("G6" 10)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSetCursor -win $_nWave2 257068.267140 -snap {("G6" 4)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 255714.657486 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 254361.047833 -snap {("G6" 3)}
wvSetCursor -win $_nWave2 210368.734092 -snap {("G6" 10)}
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 3 )} 
wvSelectSignal -win $_nWave2 {( "G5" 4 )} 
wvSelectSignal -win $_nWave2 {( "G5" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 1 )} 
wvSetCursor -win $_nWave2 204954.295478 -snap {("G6" 1)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetCursor -win $_nWave2 254361.047833 -snap {("G6" 11)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSetCursor -win $_nWave2 247254.597151 -snap {("G6" 11)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 250300.218872 -snap {("G6" 11)}
wvSetCursor -win $_nWave2 244547.377844 -snap {("G6" 11)}
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst.alu_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 18 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_latch_enable" -line 19 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G3" 5)}
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_latch_enable"
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetCursor -win $_nWave2 254361.047833 -snap {("G6" 11)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 242855.365777 -snap {("G6" 11)}
wvSetCursor -win $_nWave2 251992.230939 -snap {("G6" 11)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_in3" -line 7 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_in2" -line 6 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff1" -line 61 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff0" -line 61 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff1" -line 61 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff1\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 14 )} 
wvSelectSignal -win $_nWave2 {( "G6" 6 )} 
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 46 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_latch_enable" -line 47 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 {( "G6" 10 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSetCursor -win $_nWave2 246239.389911 -snap {("G6" 11)}
wvSetCursor -win $_nWave2 251992.230939 -snap {("G6" 11)}
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
verdiSetActWin -win $_nWave2
debReload
wvSetCursor -win $_nWave2 214767.965466 -snap {("G6" 9)}
wvSetCursor -win $_nWave2 224581.635454 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 235072.110269 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 245562.585084 -snap {("G5" 5)}
wvSetCursor -win $_nWave2 257406.669553 -snap {("G5" 5)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSetCursor -win $_nWave2 264851.522648 -snap {("G6" 5)}
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 58697.725657 596007.675906
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 195524.303147 496448.425958
wvSelectSignal -win $_nWave2 {( "G6" 4 )} 
wvSetCursor -win $_nWave2 264606.386777 -snap {("G6" 4)}
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 5 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 13 )} 
wvSetRadix -win $_nWave2 -format UDec
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 164805.152807 1243940.262971
wvZoom -win $_nWave2 216959.514919 726998.497335
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff1" -line 61 -pos 1 -win $_nTrace1
srcSelect -signal "dff0" -line 61 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 2)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/pe_inst/dff1\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/pe_inst/dff0\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 2)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G7" 1 2 )} 
wvSetRadix -win $_nWave2 -format UDec
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 124168.265814 817252.949538
wvZoom -win $_nWave2 210372.828466 352733.506217
wvZoomAll -win $_nWave2
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_en_W_t0" -line 16 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_en_W_t1" -line 18 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/overload_en_W_t1"
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvScrollDown -win $_nWave2 3
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
wvSetCursor -win $_nWave2 173835.572139 -snap {("G7" 3)}
wvSetCursor -win $_nWave2 259624.555792 -snap {("G7" 3)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_ctrl_W_t1" -line 19 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/overload_ctrl_W_t1"
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 230275.692964 -snap {("G8" 0)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 257366.950959 -snap {("G7" 4)}
wvZoom -win $_nWave2 512476.297086 871435.465529
wvSetCursor -win $_nWave2 565031.797228 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 576767.491434 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 565797.168589 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 572430.387053 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 562990.806931 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 576002.120073 -snap {("G7" 4)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_in_t1" -line 49 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_in_t0" -line 48 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/L_in_t0\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G7" 5)}
wvScrollDown -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
verdiSetActWin -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 413141.684435 830798.578536
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 2 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectGroup -win $_nWave2 {G7}
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "out0" -line 32 -pos 2 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 1)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 8)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 11)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/out0\[31:0\]"
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G6" 12)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSetRadix -win $_nWave2 -format UDec
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 650190.191898 -snap {("G7" 0)}
wvZoom -win $_nWave2 27091.257996 372504.797441
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 161045.687190 1054652.853915
wvZoom -win $_nWave2 195977.026330 571965.258527
wvSelectSignal -win $_nWave2 {( "G6" 9 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 156060.502916 402978.147941
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 826919.647020 1179308.155343
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_out" -line 63 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 9)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 14)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_out\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
wvSelectSignal -win $_nWave2 {( "G7" 3 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 3 4 )} 
wvSetRadix -win $_nWave2 -format UDec
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 189638.805970 1115256.787491
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvZoom -win $_nWave2 180608.386638 1187500.142146
wvZoom -win $_nWave2 543432.921139 684412.079515
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_out_t1" -line 31 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_pred_router/W_out_t1\[0:0\]"
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetCursor -win $_nWave2 549888.856551 -snap {("G8" 0)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 609206.313381 -snap {("G7" 4)}
wvZoom -win $_nWave2 511412.668338 713412.656459
wvZoomAll -win $_nWave2
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_out_t0" -line 56 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_out_t1" -line 57 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 12)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/W_out_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
verdiSetActWin -win $_nWave2
wvSelectGroup -win $_nWave2 {G8}
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvZoom -win $_nWave2 519249.111585 783388.877043
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSetRadix -win $_nWave2 -format UDec
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 839828.997868 1119771.997157
wvSetCursor -win $_nWave2 894345.260700 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 895539.047478 -snap {("G7" 5)}
wvSetCursor -win $_nWave2 890167.006980 -snap {("G7" 5)}
wvSetCursor -win $_nWave2 885192.895407 -snap {("G7" 5)}
wvSetCursor -win $_nWave2 893350.438386 -snap {("G7" 5)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 3 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
wvSelectSignal -win $_nWave2 {( "G7" 1 )} 
wvSelectSignal -win $_nWave2 {( "G7" 2 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_cgra" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
wvScrollDown -win $_nWave2 2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_in_p1" -line 124 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 6)}
wvSetPosition -win $_nWave2 {("G6" 4)}
wvSetPosition -win $_nWave2 {("G6" 13)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_in_p1" -line 124 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G7" 5)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p1"
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_in_p2" -line 125 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_in_p3" -line 126 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G6" 7)}
wvSetPosition -win $_nWave2 {("G6" 10)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G7" 5)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p3"
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_in_p5" -line 128 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_in_p7" -line 130 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p5" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p7"
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_out_p1" -line 132 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_p3" -line 134 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_p5" -line 136 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_p7" -line 138 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p1" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p3" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p5" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p7"
wvSetPosition -win $_nWave2 {("G8" 4)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSelectSignal -win $_nWave2 {( "G8" 8 )} 
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSelectSignal -win $_nWave2 {( "G8" 8 )} 
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSelectSignal -win $_nWave2 {( "G8" 8 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSetCursor -win $_nWave2 874698.745140 -snap {("G8" 5)}
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 886321.994231 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 875092.753584 -snap {("G7" 2)}
debReload
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomAll -win $_nWave2
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 7 )} 
wvSetCursor -win $_nWave2 241563.717129 -snap {("G7" 5)}
wvSelectSignal -win $_nWave2 {( "G7" 4 )} 
wvZoom -win $_nWave2 155774.733475 833056.183369
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 537309.950249 772100.852878
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 550855.579247 830798.578536
wvSetCursor -win $_nWave2 603979.090839 -snap {("G7" 5)}
wvSetCursor -win $_nWave2 567170.665204 -snap {("G7" 5)}
wvSetCursor -win $_nWave2 602586.339599 -snap {("G7" 5)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 886585.646647 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 881810.499538 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 926378.539226 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 888177.362351 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 923195.107820 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 881810.499538 -snap {("G7" 2)}
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 11 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 14 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 14 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 891360.793757 -snap {("G7" 4)}
wvSetCursor -win $_nWave2 931153.686335 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 886585.646647 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 921603.392116 -snap {("G7" 2)}
wvSetCursor -win $_nWave2 888177.362351 -snap {("G7" 2)}
wvScrollDown -win $_nWave2 9
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_out_t1" -line 116 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_t3" -line 118 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_t5" -line 120 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_t7" -line 122 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G7" 5)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_t1\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_t3\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_t5\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_t7\[31:0\]"
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvScrollDown -win $_nWave2 4
wvSetCursor -win $_nWave2 609627.114302 -snap {("G8" 3)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 1 2 3 4 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 878627.068132 -snap {("G8" 5)}
wvSetCursor -win $_nWave2 900911.087976 -snap {("G8" 4)}
wvSelectSignal -win $_nWave2 {( "G7" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_in_p0" -line 21 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_N_in_p2" -line 23 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_N_in_p4" -line 25 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_N_in_p6" -line 27 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 15)}
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G8" 6)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p0" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p2" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p4" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_in_p6"
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G9" 4)}
wvSetPosition -win $_nWave2 {("G9" 4)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 262633.091018 -snap {("G9" 3)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 257857.943908 -snap {("G9" 3)}
wvSetCursor -win $_nWave2 240349.071174 -snap {("G9" 3)}
wvSetCursor -win $_nWave2 278550.248049 -snap {("G9" 4)}
wvSetCursor -win $_nWave2 305609.415002 -snap {("G10" 0)}
wvSetCursor -win $_nWave2 248307.649689 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 249899.365393 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 257857.943908 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 319934.856331 -snap {("G9" 0)}
wvSetCursor -win $_nWave2 542775.054770 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 880218.783835 -snap {("G9" 1)}
wvZoom -win $_nWave2 795857.851569 1203337.071572
wvSetCursor -win $_nWave2 897510.450162 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 884767.674270 -snap {("G9" 1)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_out_p2" -line 31 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_N_out_p0" -line 29 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_N_out_p2" -line 31 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_N_out_p4" -line 33 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_N_out_p6" -line 35 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G8" 5)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G9" 4)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G9" 4)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G9" 4)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_out_p0" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_out_p2" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_out_p4" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_N_out_p6"
wvSetPosition -win $_nWave2 {("G9" 4)}
wvSetPosition -win $_nWave2 {("G9" 8)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 847987.389309 -snap {("G9" 5)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 847987.389309 -snap {("G9" 5)}
wvSetCursor -win $_nWave2 897800.058705 -snap {("G9" 4)}
wvSetCursor -win $_nWave2 884767.674270 -snap {("G9" 4)}
wvSetCursor -win $_nWave2 893455.930560 -snap {("G9" 4)}
wvSetCursor -win $_nWave2 884478.065727 -snap {("G9" 4)}
wvSetCursor -win $_nWave2 892587.104931 -snap {("G9" 4)}
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 {( "G9" 5 )} 
verdiSetActWin -win $_nWave2
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G9" 7)}
wvSelectSignal -win $_nWave2 {( "G9" 5 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G9" 6)}
wvSelectSignal -win $_nWave2 {( "G9" 5 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G9" 5)}
wvSelectSignal -win $_nWave2 {( "G9" 5 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G9" 4)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_S_out_p0" -line 97 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_S_out_p2" -line 99 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "CGRA_S_out_p4" -line 101 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_S_out_p6" -line 103 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G9" 4)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_S_out_p0" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_S_out_p2" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_S_out_p4" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_S_out_p6"
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G10" 4)}
wvSetPosition -win $_nWave2 {("G10" 4)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 916045.396914 -snap {("G9" 3)}
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoom -win $_nWave2 808222.530206 1142348.045487
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 18 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G6" 13)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[1\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_input_mode"
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 18 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/pe_inst/dff_input_mode"
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 906774.121423 -snap {("G8" 2)}
wvSetCursor -win $_nWave2 895375.383161 -snap {("G8" 3)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 894188.014592 -snap {("G8" 4)}
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.u_pred_router" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[1\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_ctrl_W_t1" -line 19 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_en_L_t0" -line 20 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_en_W_t1" -line 18 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_ctrl_W_t1" -line 19 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[1\]/col_tile_gen\[0\]/tile_inst/u_data_router/overload_ctrl_W_t1"
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 3)}
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_ctrl_W_t1" -line 19 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/overload_ctrl_W_t1"
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.pe_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_out_p1" -line 139 -pos 1 -win $_nTrace1
srcAction -pos 138 4 6 -win $_nTrace1 -name "W_out_p1" -ctrlKey off
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_reg_t1" -line 284 -pos 1 -win $_nTrace1
srcAction -pos 283 11 1 -win $_nTrace1 -name "W_reg_t1" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_mux_t1" -line 270 -pos 1 -win $_nTrace1
srcAction -pos 269 5 5 -win $_nTrace1 -name "W_mux_t1" -ctrlKey off
srcDeselectAll -win $_nTrace1
debReload
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 155774.733475 -snap {("G8" 5)}
wvZoom -win $_nWave2 796934.506041 1182984.932480
wvSetCursor -win $_nWave2 912173.439307 -snap {("G8" 5)}
wvSetCursor -win $_nWave2 903393.330105 -snap {("G8" 5)}
wvSetCursor -win $_nWave2 913270.952957 -snap {("G8" 6)}
wvSetCursor -win $_nWave2 924246.089458 -snap {("G8" 6)}
wvSetCursor -win $_nWave2 928636.144059 -snap {("G8" 7)}
wvSetCursor -win $_nWave2 933026.198659 -snap {("G8" 7)}
wvSetCursor -win $_nWave2 935769.982785 -snap {("G8" 8)}
wvSetCursor -win $_nWave2 943178.199923 -snap {("G8" 8)}
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvZoomAll -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoom -win $_nWave2 803707.320540 1155893.674485
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
wvScrollDown -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G8" 16 )} 
wvSelectSignal -win $_nWave2 {( "G8" 9 10 11 12 13 14 15 16 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSelectSignal -win $_nWave2 {( "G9" 1 )} 
wvScrollDown -win $_nWave2 2
wvSelectSignal -win $_nWave2 {( "G9" 1 2 3 4 )} {( "G10" 1 2 3 4 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 3)}
wvScrollUp -win $_nWave2 2
wvSelectSignal -win $_nWave2 {( "G8" 6 )} 
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_out_t1" -line 57 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 4)}
wvSetPosition -win $_nWave2 {("G8" 5)}
wvSetPosition -win $_nWave2 {("G8" 6)}
wvSetPosition -win $_nWave2 {("G8" 7)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/u_data_router/W_out_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 9)}
wvScrollDown -win $_nWave2 3
srcDeselectAll -win $_nTrace1
debReload
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
verdiSetActWin -win $_nWave2
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "W_out_t1" -line 57 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 5)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 9)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/u_data_router/W_out_t1\[31:0\]"
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSetPosition -win $_nWave2 {("G8" 10)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_ctrl_W_t1" -line 19 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/u_data_router/overload_ctrl_W_t1"
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G8" 11)}
wvScrollDown -win $_nWave2 2
wvSetCursor -win $_nWave2 905323.369180 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 895409.608337 -snap {("G8" 11)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 836918.419364 -snap {("G11" 0)}
wvSetCursor -win $_nWave2 827996.034605 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 839644.703596 -snap {("G10" 0)}
wvSetCursor -win $_nWave2 905323.369180 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 891691.948021 -snap {("G9" 0)}
wvSetCursor -win $_nWave2 896896.672464 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 904084.149075 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 894170.388232 -snap {("G8" 11)}
wvScrollDown -win $_nWave2 0
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff1" -line 61 -pos 1 -win $_nTrace1
srcSelect -signal "dff0" -line 61 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G8" 5)}
wvSetPosition -win $_nWave2 {("G8" 6)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 11)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/pe_inst/dff1\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/pe_inst/dff0\[31:0\]"
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G8" 12)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
wvSelectSignal -win $_nWave2 {( "G8" 4 )} 
wvSelectSignal -win $_nWave2 {( "G8" 13 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 13 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 12)}
wvSelectSignal -win $_nWave2 {( "G8" 12 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_pred_router" \
           -delim "." -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_pred_router" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.u_data_router" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "overload_ctrl_W_t1" -line 19 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G7" 4)}
wvSetPosition -win $_nWave2 {("G8" 1)}
wvSetPosition -win $_nWave2 {("G8" 2)}
wvSetPosition -win $_nWave2 {("G8" 7)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 12)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/u_data_router/overload_ctrl_W_t1"
wvSetPosition -win $_nWave2 {("G8" 12)}
wvSetPosition -win $_nWave2 {("G8" 13)}
wvSetCursor -win $_nWave2 893922.544211 -snap {("G8" 13)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 901853.552885 -snap {("G8" 13)}
wvSetCursor -win $_nWave2 898631.580611 -snap {("G8" 13)}
wvSetCursor -win $_nWave2 903340.617011 -snap {("G8" 13)}
wvSetCursor -win $_nWave2 896896.672464 -snap {("G8" 13)}
wvSetCursor -win $_nWave2 905075.525159 -snap {("G8" 13)}
wvSetCursor -win $_nWave2 890204.883895 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 895409.608337 -snap {("G8" 11)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 904827.681138 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 905323.369180 -snap {("G8" 3)}
wvSetCursor -win $_nWave2 895657.452358 -snap {("G8" 11)}
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvSetCursor -win $_nWave2 913502.221875 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 894418.232253 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 914989.286002 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 894913.920295 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 913502.221875 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 895409.608337 -snap {("G8" 11)}
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[1\].tile_inst.pe_inst" \
           -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_in" -line 8 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_out_t1" -line 10 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pe_out_p0" -line 11 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_input_mode" -line 18 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff_latch_enable" -line 19 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 1)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 5)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 5)}
wvSetPosition -win $_nWave2 {("G8" 7)}
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G8" 11)}
wvSetPosition -win $_nWave2 {("G8" 12)}
wvSetPosition -win $_nWave2 {("G8" 13)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[1\]/tile_inst/pe_inst/dff_latch_enable"
wvSetPosition -win $_nWave2 {("G8" 13)}
wvSetPosition -win $_nWave2 {("G8" 14)}
wvScrollDown -win $_nWave2 3
wvSetCursor -win $_nWave2 885991.535536 -snap {("G8" 14)}
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
debReload
wvZoomAll -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G8" 5 )} 
wvZoom -win $_nWave2 801449.715707 1230394.633973
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 905408.647568 -snap {("G8" 4)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 915164.324458 -snap {("G8" 7)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 926139.460960 -snap {("G8" 8)}
wvSetCursor -win $_nWave2 938638.921975 -snap {("G8" 9)}
wvSetCursor -win $_nWave2 924310.271543 -snap {("G8" 8)}
wvSetCursor -win $_nWave2 914859.459556 -snap {("G8" 7)}
wvSetCursor -win $_nWave2 905103.782665 -snap {("G8" 6)}
wvSetCursor -win $_nWave2 896872.430289 -snap {("G8" 5)}
wvZoomAll -win $_nWave2
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSelectSignal -win $_nWave2 {( "G8" 1 )} 
wvSelectSignal -win $_nWave2 {( "G8" 2 )} 
wvSelectSignal -win $_nWave2 {( "G8" 3 )} 
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoom -win $_nWave2 279942.999289 936906.005686
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 151259.523810 428944.918266
wvZoomAll -win $_nWave2
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvZoomAll -win $_nWave2
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
wvScrollUp -win $_nWave2 1
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSelectSignal -win $_nWave2 {( "G6" 13 )} 
wvSelectSignal -win $_nWave2 {( "G6" 12 )} 
wvSetCursor -win $_nWave2 2828778.855721 -snap {("G6" 13)}
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
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 8
wvScrollUp -win $_nWave2 3
wvSelectSignal -win $_nWave2 {( "G5" 3 )} 
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvZoom -win $_nWave2 2695580.170576 2934886.282871
wvSelectSignal -win $_nWave2 {( "G5" 1 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 2775518.957198 -snap {("G5" 1)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoomAll -win $_nWave2
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G6" 14 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 12 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 12 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 12 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 13 )} 
wvSelectGroup -win $_nWave2 {G9}
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSetScope "tb_dice_cgra.u_cgra_subsystem.u_cgra" -delim "." -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_cgra" -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 9 10 11 12 13 14 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 8)}
wvScrollDown -win $_nWave2 0
wvSelectGroup -win $_nWave2 {G10}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSelectGroup -win $_nWave2 {G11}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSelectGroup -win $_nWave2 {G9}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_out_p0" -line 131 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_out_p1" -line 132 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_p3" -line 134 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_p5" -line 136 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_out_p7" -line 138 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G6" 11)}
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G7" 2)}
wvSetPosition -win $_nWave2 {("G7" 3)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 5)}
wvSetPosition -win $_nWave2 {("G8" 7)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 7)}
wvSetPosition -win $_nWave2 {("G8" 6)}
wvSetPosition -win $_nWave2 {("G8" 7)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p1" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p3" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p5" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_out_p7"
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 12)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 266397.370291 -snap {("G8" 10)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 557628.393746 -snap {("G8" 10)}
wvSetCursor -win $_nWave2 925617.981521 -snap {("G8" 10)}
wvZoom -win $_nWave2 758555.223881 1359078.109453
wvSetCursor -win $_nWave2 884891.239609 -snap {("G8" 9)}
wvSetCursor -win $_nWave2 898122.376391 -snap {("G8" 9)}
wvSetCursor -win $_nWave2 925011.460819 -snap {("G8" 2)}
wvSetCursor -win $_nWave2 916902.054404 -snap {("G8" 12)}
wvSetCursor -win $_nWave2 913914.378357 -snap {("G8" 11)}
wvSetCursor -win $_nWave2 903244.106758 -snap {("G8" 10)}
wvSetCursor -win $_nWave2 893000.646024 -snap {("G8" 10)}
wvSetCursor -win $_nWave2 887025.293928 -snap {("G8" 9)}
debReload
wvSetCursor -win $_nWave2 895056.907231 -snap {("G8" 9)}
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSetCursor -win $_nWave2 984649.343361 -snap {("G8" 8)}
wvSetCursor -win $_nWave2 894634.301400 -snap {("G8" 9)}
wvSetCursor -win $_nWave2 886182.184784 -snap {("G8" 9)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_in_p1" -line 124 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "CGRA_W_in_p3" -line 126 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_in_p5" -line 128 -pos 1 -win $_nTrace1
srcSelect -signal "CGRA_W_in_p7" -line 130 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G7" 0)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 11)}
wvSetPosition -win $_nWave2 {("G8" 12)}
wvAddSignal -win $_nWave2 "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p1" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p3" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p5" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/CGRA_W_in_p7"
wvSetPosition -win $_nWave2 {("G8" 12)}
wvSetPosition -win $_nWave2 {("G8" 16)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 903509.023847 -snap {("G8" 16)}
verdiSetActWin -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSelectSignal -win $_nWave2 {( "G8" 13 )} 
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 565097.583864 -snap {("G8" 8)}
wvSetCursor -win $_nWave2 256086.518368 -snap {("G8" 12)}
wvSetCursor -win $_nWave2 539488.932028 -snap {("G8" 13)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "CGRA_W_out_p7" -line 138 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSetCursor -win $_nWave2 824926.581729 -snap {("G8" 2)}
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 571363.083247 -snap {("G8" 9)}
wvSetCursor -win $_nWave2 566291.813277 -snap {("G8" 9)}
wvSetCursor -win $_nWave2 285681.541623 -snap {("G8" 13)}
wvSetCursor -win $_nWave2 285681.541623 -snap {("G8" 14)}
wvSetCursor -win $_nWave2 290752.811593 -snap {("G8" 15)}
wvSetCursor -win $_nWave2 312728.314795 -snap {("G8" 16)}
debReload
wvSelectSignal -win $_nWave2 {( "G8" 12 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "cgra_cfg" -line 141 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[0\].col_tile_gen\[0\].tile_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "L_out_p2" -line 131 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave2 {("G8" 0)}
wvSetPosition -win $_nWave2 {("G8" 3)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G8" 9)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[0\]/col_tile_gen\[0\]/tile_inst/L_out_p2"
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
verdiSetActWin -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 9 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSetCursor -win $_nWave2 838449.968314 -snap {("G7" 5)}
debReload
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvZoom -win $_nWave2 829997.851698 1081870.926857
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSetCursor -win $_nWave2 896644.070037 -snap {("G8" 10)}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 14 )} 
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSetCursor -win $_nWave2 916496.135074 -snap {("G8" 12)}
wvSetCursor -win $_nWave2 925890.415851 -snap {("G8" 12)}
wvSetCursor -win $_nWave2 926244.917012 -snap {("G8" 13)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\]" -win \
           $_nTrace1
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[0\]" -win \
           $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_cgra_port_io" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_cgra_port_io" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_cgra_port_io" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_special_reg_extra" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_wr_address_converter" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_special_reg_extra" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_rd_address_converter" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file.gen_bank\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file.gen_bank\[0\].bank_ram" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[1\].u_dice_register_file" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_en\[i\]" -line 27 -pos 1 -win $_nTrace1
srcSelect -signal "wr_addr\[\(i+1\)*ADDR_WIDTH-1:i*ADDR_WIDTH\]" -line 28 -pos 1 \
          -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "wr_data\[\(i+1\)*WIDTH-1:i*WIDTH\]" -line 29 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G8" 6)}
wvSetPosition -win $_nWave2 {("G8" 8)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G8" 17)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[1\]/u_dice_register_file/wr_en\[0:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[1\]/u_dice_register_file/wr_addr\[8:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[1\]/u_dice_register_file/wr_data\[31:0\]"
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G9" 3)}
wvSetPosition -win $_nWave2 {("G9" 3)}
wvScrollDown -win $_nWave2 1
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G9" 1 2 3 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 869347.480611 -snap {("G9" 3)}
wvSelectSignal -win $_nWave2 {( "G9" 2 )} 
wvSelectSignal -win $_nWave2 {( "G9" 3 )} 
wvSelectSignal -win $_nWave2 {( "G9" 1 )} 
wvSelectSignal -win $_nWave2 {( "G9" 2 )} 
wvSelectSignal -win $_nWave2 {( "G9" 3 )} 
wvSetCursor -win $_nWave2 934221.193143 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 923586.158302 -snap {("G8" 17)}
wvSetCursor -win $_nWave2 921990.903076 -snap {("G9" 2)}
wvSetCursor -win $_nWave2 896998.571198 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 927840.172238 -snap {("G9" 3)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[7\].u_dice_register_file" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[7\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[7\].u_dice_register_file.gen_bank\[0\]" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[7\].u_dice_register_file.gen_bank\[0\]" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "rd_en\[i\]" -line 30 -pos 1 -win $_nTrace1
srcSelect -signal "rd_addr\[\(i+1\)*ADDR_WIDTH-1:i*ADDR_WIDTH\]" -line 31 -pos 1 \
          -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "rd_data\[\(i+1\)*WIDTH-1:i*WIDTH\]" -line 32 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G8" 6)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G9" 2)}
wvSetPosition -win $_nWave2 {("G9" 3)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[7\]/u_dice_register_file/rd_en\[0:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[7\]/u_dice_register_file/rd_addr\[8:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[7\]/u_dice_register_file/rd_data\[31:0\]"
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G10" 3)}
wvSetPosition -win $_nWave2 {("G10" 3)}
wvScrollDown -win $_nWave2 1
wvSelectGroup -win $_nWave2 {G11}
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G10" 3 )} 
wvSelectSignal -win $_nWave2 {( "G10" 2 3 )} 
wvSelectSignal -win $_nWave2 {( "G10" 1 2 3 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G10" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_en\[i\]" -line 27 -pos 1 -win $_nTrace1
srcSelect -signal "wr_addr\[\(i+1\)*ADDR_WIDTH-1:i*ADDR_WIDTH\]" -line 28 -pos 1 \
          -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "wr_data\[\(i+1\)*WIDTH-1:i*WIDTH\]" -line 29 -pos 1 -win \
          $_nTrace1
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G11" 0)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[7\]/u_dice_register_file/wr_en\[0:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[7\]/u_dice_register_file/wr_addr\[8:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_gprf_ctrl/gen_rf_banks\[7\]/u_dice_register_file/wr_data\[31:0\]"
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G10" 3)}
wvScrollDown -win $_nWave2 1
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G10" 1 2 3 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 941665.717532 -snap {("G11" 0)}
wvSetCursor -win $_nWave2 936879.951853 -snap {("G10" 0)}
wvSetCursor -win $_nWave2 948223.989018 -snap {("G8" 16)}
wvSetCursor -win $_nWave2 932980.439078 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 924295.160625 -snap {("G10" 0)}
wvSetCursor -win $_nWave2 928726.425142 -snap {("G10" 2)}
wvSetCursor -win $_nWave2 934221.193143 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 924826.912367 -snap {("G10" 0)}
wvSetCursor -win $_nWave2 935107.446047 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 894694.313649 -snap {("G9" 1)}
debReload
wvSelectSignal -win $_nWave2 {( "G9" 1 )} 
wvSelectSignal -win $_nWave2 {( "G9" 2 )} 
wvSelectSignal -win $_nWave2 {( "G9" 3 )} 
wvSetCursor -win $_nWave2 916496.135074 -snap {("G8" 15)}
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 620841.329069 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 903041.933191 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 602780.490405 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 632129.353234 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 609553.304904 -snap {("G9" 1)}
wvZoom -win $_nWave2 458293.781095 1262001.101635
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvSetCursor -win $_nWave2 924907.813076 -snap {("G9" 1)}
verdiSetActWin -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 862107.142857 1348489.978678
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 2861681.023454 -snap {("G9" 3)}
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
wvSelectSignal -win $_nWave2 {( "G9" 1 )} 
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
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
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 12 )} 
wvSelectSignal -win $_nWave2 {( "G8" 13 )} 
wvSelectSignal -win $_nWave2 {( "G8" 14 )} 
wvSelectSignal -win $_nWave2 {( "G8" 15 )} 
wvSelectSignal -win $_nWave2 {( "G8" 16 )} 
wvSelectSignal -win $_nWave2 {( "G8" 17 )} 
wvSelectSignal -win $_nWave2 {( "G9" 1 )} 
wvSetCursor -win $_nWave2 599614.818763 -snap {("G9" 1)}
wvSelectSignal -win $_nWave2 {( "G8" 10 )} 
wvSelectSignal -win $_nWave2 {( "G8" 11 )} 
wvSelectSignal -win $_nWave2 {( "G8" 12 )} 
wvSelectSignal -win $_nWave2 {( "G8" 13 )} 
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 2506544.349680 -snap {("G6" 15)}
wvScrollDown -win $_nWave2 1
wvSetCursor -win $_nWave2 2815358.848614 -snap {("G6" 13)}
wvSetCursor -win $_nWave2 3131893.710021 -snap {("G6" 14)}
wvSetCursor -win $_nWave2 3191083.155650 -snap {("G6" 14)}
wvSetCursor -win $_nWave2 3113879.530917 -snap {("G7" 0)}
wvSetCursor -win $_nWave2 3111306.076759 -snap {("G6" 12)}
wvSetCursor -win $_nWave2 3152481.343284 -snap {("G6" 12)}
wvZoom -win $_nWave2 2913150.106610 3407253.304904
wvZoomAll -win $_nWave2
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvSetCursor -win $_nWave2 2869401.385928 -snap {("G8" 9)}
wvSetCursor -win $_nWave2 2678965.778252 -snap {("G8" 10)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvScrollDown -win $_nWave2 1
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
srcHBSelect "tb_dice_cgra.u_cgra_subsystem.u_gprf_ctrl.gen_rf_banks\[7\]" -win \
           $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[3\].col_tile_gen\[3\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[3\].col_tile_gen\[3\].tile_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[3\].col_tile_gen\[3\].tile_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[3\].col_tile_gen\[3\].tile_inst" \
           -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[3\].col_tile_gen\[3\].tile_inst.pe_inst" \
           -win $_nTrace1
srcSetScope \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[3\].col_tile_gen\[3\].tile_inst.pe_inst" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "tb_dice_cgra.u_cgra_subsystem.u_cgra.row_tile_gen\[3\].col_tile_gen\[3\].tile_inst.pe_inst" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "dff0" -line 64 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "dff1" -line 64 -pos 1 -win $_nTrace1
srcSelect -signal "dff0" -line 64 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G8" 9)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G8" 15)}
wvSetPosition -win $_nWave2 {("G8" 17)}
wvSetPosition -win $_nWave2 {("G8" 10)}
wvSetPosition -win $_nWave2 {("G9" 1)}
wvSetPosition -win $_nWave2 {("G9" 2)}
wvSetPosition -win $_nWave2 {("G9" 3)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G10" 1)}
wvSetPosition -win $_nWave2 {("G10" 2)}
wvSetPosition -win $_nWave2 {("G11" 0)}
wvSetPosition -win $_nWave2 {("G10" 3)}
wvSetPosition -win $_nWave2 {("G11" 0)}
wvSetPosition -win $_nWave2 {("G10" 3)}
wvSetPosition -win $_nWave2 {("G11" 0)}
wvSetPosition -win $_nWave2 {("G10" 3)}
wvSetPosition -win $_nWave2 {("G10" 2)}
wvSetPosition -win $_nWave2 {("G10" 1)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G9" 3)}
wvSetPosition -win $_nWave2 {("G9" 2)}
wvSetPosition -win $_nWave2 {("G9" 1)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G8" 17)}
wvSetPosition -win $_nWave2 {("G9" 0)}
wvSetPosition -win $_nWave2 {("G9" 1)}
wvSetPosition -win $_nWave2 {("G9" 2)}
wvSetPosition -win $_nWave2 {("G10" 0)}
wvSetPosition -win $_nWave2 {("G10" 1)}
wvSetPosition -win $_nWave2 {("G10" 2)}
wvSetPosition -win $_nWave2 {("G10" 3)}
wvSetPosition -win $_nWave2 {("G11" 0)}
wvAddSignal -win $_nWave2 \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[3\]/col_tile_gen\[3\]/tile_inst/pe_inst/dff1\[31:0\]" \
           "/tb_dice_cgra/u_cgra_subsystem/u_cgra/row_tile_gen\[3\]/col_tile_gen\[3\]/tile_inst/pe_inst/dff0\[31:0\]"
wvSetPosition -win $_nWave2 {("G11" 0)}
wvSetPosition -win $_nWave2 {("G11" 2)}
wvSetPosition -win $_nWave2 {("G11" 2)}
wvScrollDown -win $_nWave2 1
wvZoomAll -win $_nWave2
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 2889989.019190 -snap {("G11" 2)}
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
wvSetCursor -win $_nWave2 2835946.481876 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 2859107.569296 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 2902856.289979 -snap {("G9" 1)}
wvSetCursor -win $_nWave2 2874548.294243 -snap {("G10" 0)}
wvSetCursor -win $_nWave2 2851387.206823 -snap {("G9" 3)}
wvSetCursor -win $_nWave2 2879695.202559 -snap {("G9" 3)}
wvZoom -win $_nWave2 2789624.307036 3026382.089552
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2738155.223881 3332623.134328
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvZoom -win $_nWave2 2672743.396556 2988778.931037
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 2506544.349680 3046969.722814
wvSetCursor -win $_nWave2 2875662.177386 -snap {("G11" 2)}
wvSelectSignal -win $_nWave2 {( "G11" 1 2 )} 
wvSetRadix -win $_nWave2 -format Bin
wvSelectSignal -win $_nWave2 {( "G11" 1 2 )} 
wvSetRadix -win $_nWave2 -format UDec
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
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
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvZoom -win $_nWave2 818358.422175 1206950.000000
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
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
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoom -win $_nWave2 2779330.490405 3000647.547974
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2504669.587411 2737469.335245
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2845099.922285 2922534.379987
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 2648709.089663 3411276.144329
wvZoom -win $_nWave2 2825394.846466 2985279.196946
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1

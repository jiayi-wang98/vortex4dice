    vcs -full64 -sverilog -debug_all +incdir+$HW_HOME/rtl/cache +incdir+$HW_HOME/rtl/libs +incdir+$HW_HOME/rtl \
-y $HW_HOME/rtl/libs -y $HW_HOME/rtl/cache +libext+.sv+.v \
-top VX_cache_with_temporal -f filelist2.f -l compile.log -timescale=1ns/10ps
    ./simv
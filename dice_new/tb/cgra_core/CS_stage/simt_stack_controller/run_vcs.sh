#!/bin/bash
vcs -full64 -timescale=1ns/1ps -sverilog -f filelist.f \
    -debug_access+all -kdb -lca +vpi \
    +define+FSDB +define+NO_SRAM \
    -o simv

./simv

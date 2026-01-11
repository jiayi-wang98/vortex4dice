#!/bin/bash
vcs -full64 -sverilog -dd -debug_access+all -kdb -lca -f filelist.f \
    +vcs+initreg+random \
    +define+NO_SRAM \
    -timescale=1ns/1ps \
    -o simv

if [ $? -eq 0 ]; then
    ./simv -gui=verdi &
fi

#!/bin/bash
# run_vcs.sh - Launch VCS simulation for Frontend Top

# Ensure DICE_HOME is set
if [ -z "$DICE_HOME" ]; then
    echo "Error: DICE_HOME environment variable is not set."
    echo "Please set it to the root of your repository (e.g. export DICE_HOME=~/projects/vortex4dice)"
    exit 1
fi

echo "Compiling with VCS..."

# VCS Compilation
# -full64: 64-bit mode
# -sverilog: Enable SystemVerilog
# -dd: Enable design debug
# -debug_access+all: Enable full debug access (required for Verdi/DVE)
# -kdb: Generate Knowledge Database (required for Verdi)
# -lca: Enable Limited Customer Access features (often needed for advanced SV/Verdi features)
# -f filelist.f: Read source files from filelist
# +vcs+initreg+random: Initialize registers randomly (catches reset bugs)
# +define+NO_SRAM: Macro definition matching Verilator flow
# -timescale=1ns/1ps: Set default timescale
# -o simv: Output executable name
vcs -full64 -sverilog -dd -debug_access+all -kdb -lca -f filelist.f \
    +vcs+initreg+random \
    +define+NO_SRAM \
    -timescale=1ns/1ps \
    -o simv

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Compilation successful. Launching Simulation with Verdi..."
    ./simv -gui=verdi &
else
    echo "Compilation failed."
    exit 1
fi

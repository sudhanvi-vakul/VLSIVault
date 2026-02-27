#!/usr/bin/env bash
set -e

SEED=${1:-123}

mkdir -p ../results

echo "Running ALU test with seed=$SEED"

iverilog -g2012 -o ../results/sim.out \
    ../rtl/param_alu.sv \
    ../tb/tb_top.sv

vvp ../results/sim.out +seed=$SEED | tee ../results/transcript.log

echo "Simulation complete."
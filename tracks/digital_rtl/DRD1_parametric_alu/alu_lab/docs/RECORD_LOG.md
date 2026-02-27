ALU Project Development Record Log
Section 0 — Environment Setup

Date: 02-24-2026

Tool Versions

Command executed:

iverilog -V
vvp -V
gtkwave --version

Result:

Icarus Verilog version: 12.0

VVP version: 

GTKWave version: 3.3.116

Status: ✅ Tools installed and accessible from PATH.

Section 1 — Smoke Test

Created: tb/smoke.sv

Compile:

iverilog -g2012 -o results/smoke.out tb/smoke.sv

Run:

vvp results/smoke.out | tee results/00_smoke.log

Result:

Compilation: SUCCESS

Simulation: SUCCESS

Waveform generated: results/00_smoke.vcd

Section 2 — ALU Specification

Created: docs/alu_spec.md

Defined:

Opcode table

Flag rules

Borrow convention

Timing contract

Shift rules

Status: ✅ Spec complete.

Section 3 — RTL Implementation

Created: rtl/param_alu.sv

Key points:

Parameterized width W

Used W+1 extended arithmetic

Implemented carry-out-as-not-borrow for SUB

Verified no truncation

Compile:

iverilog -g2012 -o results/sim.out rtl/param_alu.sv tb/tb_top.sv

Result: SUCCESS

Section 4 — Reference Model

Created inside: tb/tb_top.sv

Verified:

Arithmetic rules match spec

Flags computed independently

No DUT internal signals used

Status: ✅ Reference model matches specification.

Section 5 — Self-Checking Testbench

Features:

Directed tests

500 random tests

Pass/fail counters

Scoreboard summary

Run command:

./sim/run.sh 123

Result:

ALU TEST SUMMARY: PASS=505 FAIL=0

Status: ✅ All tests passing.

Section 6 — Multi-Width Validation

Tested:

W = 8 → PASS

W = 16 → PASS

W = 32 → PASS

Commands used:

iverilog -g2012 -Ptb_top.W=16 ...
iverilog -g2012 -Ptb_top.W=32 ...

Status: ✅ Parameterization verified.

Section 7 — Debug Exercise

Injected bug:

Changed XOR to OR.

Result:

Directed test failed.

Failure printed in transcript.

Fixed RTL.

Re-ran:

PASS=505 FAIL=0

Status: ✅ Scoreboard correctly detects bugs.

Final Summary

Total tests executed: 505
Failures: 0
Seed used: 123
Width tested: 8 / 16 / 32

Project Status: COMPLETE
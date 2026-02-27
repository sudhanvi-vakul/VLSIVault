DRD1 – Parametric ALU (Design + Verification)

1. Overview

This project implements a parameterized Arithmetic Logic Unit (ALU) in SystemVerilog with configurable data width.

The design supports multiple arithmetic and logical operations and is verified using a self-checking testbench with randomized stimulus.

This project demonstrates:

	Parameterized RTL design
	Clean combinational logic modeling
	Self-checking verification
	Functional validation with waveform analysis

2. Project Objective

Design a reusable ALU module with parameterizable width
Support common arithmetic and logical operations
Build a self-checking testbench
Validate correctness using randomized testing
Generate waveform and simulation evidence

3. Features

Parameterized width (default: 16-bit or configurable)

Arithmetic operations:

Addition
Subtraction

Logical operations:

AND
OR
XOR
NOT

Clean case-based operation decoding

Deterministic output behavior

4. Tools Used

SystemVerilog / Verilog – RTL implementation
Verilator / ModelSim / XSIM – Simulation
GTKWave – Waveform visualization
Random stimulus generation – Functional coverage confidence

5. Directory Structure
DRD1 - Parametric ALU/
│
├── rtl/
│   └── alu.v
│
├── tb/
│   └── alu_tb.sv
│
├── build/
│   ├── sim.out
│   └── waves.vcd
│
└── notes/
    └── RECORD_LOG.md

6. ALU Architecture

The ALU consists of:
Two N-bit inputs: a, b
3-bit operation selector: op
N-bit output: result
Operation selection is implemented using a combinational case statement.

Example:
op = 000 → ADD
op = 001 → SUB
op = 010 → AND
op = 011 → OR
op = 100 → XOR
...
This design is purely combinational.

7. Verification Strategy

The testbench performs:
Directed tests (known values)
Randomized input generation
Automatic expected-value comparison
Error counting and reporting
Self-checking logic compares DUT output with a reference model inside the testbench.

If mismatch:
Error is printed
Counter increments
Simulation continues
This ensures automated validation without manual waveform inspection.

8. Simulation Flow

Compile
Example:

verilator --cc alu.v --exe alu_tb.cpp
make -C obj_dir -f Valu.mk

Or using ModelSim:

vlog rtl/alu.v tb/alu_tb.sv
vsim alu_tb
Run Simulation

Produces:

waves.vcd

Console output with pass/fail summary

View Waveforms

gtkwave waves.vcd

Waveform signals to observe:

a
b
op
result

Verify:
Result updates immediately with input change
Correct arithmetic/logical behavior

9. Example Waveform Interpretation

When:
a = 10
b = 5
op = ADD

Result should be:
15

For:
a = 6
b = 3
op = AND

Result:
2

Waveforms confirm combinational response without clock dependency.

10. Results

All directed tests passed
Randomized test set completed successfully
No mismatches reported
Functional correctness validated

11. Key Learnings

Writing parameterized RTL improves reusability
Self-checking testbenches are critical for automation
Random testing increases confidence
Clean combinational modeling avoids latch inference
Waveform debugging validates functional assumptions

12. Industry Relevance

This project demonstrates core RTL skills required for:
Digital Design Engineer
ASIC/FPGA RTL Engineer
Design Verification Engineer

It proves:
Strong understanding of combinational logic
Parameter usage
Functional verification methodology
Structured project organization

13. Possible Extensions
Add overflow flag
Add carry/borrow flag
Add shift operations
Add signed/unsigned mode
Add pipeline stage
Add coverage metrics
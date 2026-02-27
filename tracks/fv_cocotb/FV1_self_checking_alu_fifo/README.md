FV1 -Self-Checking Randomized Verification (ALU + FIFO)

Overview
This project implements a structured, self-checking, randomized verification environment for digital RTL modules (ALU and FIFO) using Verilator and GTKWave.
The objective is to demonstrate:
-->Deterministic seeded regression
-->Golden reference modeling
-->Automated scoreboard comparison
-->Waveform-driven debug methodology
-->Structured evidence-based verification
This project focuses on professional verification architecture and methodology design.

Project Objectives
-->Design a reproducible randomized verification flow
-->Build a golden reference model for automated checking
-->Implement deterministic seed-based regression
-->Establish a structured waveform-debug workflow
-->Produce documented verification evidence

DUTs Verified - ALU (Parameterized N-bit)
Supported operations include:
-->ADD
-->SUB
-->AND
-->OR
-->XOR
-->SLT
-->Logical shifts

FIFO (Parameterized Depth)
-->Synchronous operation
-->Full / Empty detection
-->Overflow / Underflow protection
-->Controlled write and read behavior

Verification Architecture
    Random Stimulus Generator
                ↓
               DUT
                ↓
     Golden Reference Model
                ↓
     Scoreboard Comparator
                ↓
Pass/Fail Summary + Wave Dump

Key characteristics:
-->Randomized input generation
-->Deterministic seed control
-->Automatic mismatch detection
-->Failure vector reporting
-->Waveform generation for debug

Quick Run

bash scripts/run.sh
Expected Output:
SEED = 12345
TOTAL TESTS = 1000
PASS = 1000
FAIL = 0
Generated Artifacts:
logs/run_seed12345.log
waves/alu_seed12345.vcd

Manual Verilator Flow (Example)
verilator -Wall --cc rtl/alu.v \
  --exe tb/tb_alu.cpp \
  --trace \
  --Mdir build

make -C build -f Valu.mk -j
./build/Valu +seed=12345 +tests=1000

Waveform Debug Flow
Open waveform:
gtkwave waves/alu_seed12345.vcd
Inspect:
-->Input signals (a, b, op)
-->Output (y)
-->Expected reference output
-->Failure indicator (if applicable)
Use seed and test index from the log file to locate mismatches.

Reproducibility
All random stimulus is seed-controlled:
./build/Valu +seed=98765 +tests=2000
Using the same seed guarantees identical stimulus, enabling deterministic debugging and regression analysis.

Evidence Package
Project completion includes:
-->Passing regression log
-->Waveform screenshots
-->Forced failure validation (to verify scoreboard correctness)
-->Completed verification record log

Role & Contribution
This project was developed under the VLSIVault initiative.
My Role
Project Manager – defined scope, milestones, and deliverables
Technical Lead – designed verification architecture and methodology
Authored specification, verification strategy, and documentation
Reviewed RTL and testbench implementation
Guided execution and debugging workflow
RTL implementation and simulation execution were carried out by a team member under my technical supervision.
This project demonstrates verification methodology ownership, architectural design thinking, and technical leadership in digital system validation.

Skills Demonstrated
Verification architecture design
Scoreboard methodology
Deterministic regression planning
Debug workflow standardization
Technical documentation leadership
Engineering project management

Next Steps
This project forms the foundation for:
UVM-based agent development
Protocol verification environments
Coverage-driven verification
SoC subsystem validation

VLSIVault Initiative
VLSIVault is a structured digital design and verification portfolio initiative focused on building industry-grade semiconductor engineering competencies through methodical project execution and documentation.
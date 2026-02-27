FV – UVM ALU Agent (XSIM)

Transaction-Level Verification of a Parametric ALU using UVM on Vivado XSIM

1. Overview

This project implements a UVM-based verification environment for a parameterized ALU design and runs using Vivado XSIM (free simulator).

The objective is to demonstrate:
UVM testbench architecture
Transaction-based stimulus generation
Driver/Monitor separation
Scoreboard-based checking
Clean verification structure without paid simulators
This project proves practical UVM skills using only free tooling.

2. Verification Architecture

The testbench follows standard UVM layering:

Test
 └── Environment
      └── Agent
           ├── Sequencer
           ├── Driver
           └── Monitor
      └── Scoreboard

###Components

ALU Interface

Encapsulates DUT signals:
a
b
op
result

Provides a clean virtual interface connection to driver and monitor.

Sequence Item (Transaction)

Defines:
    Operands (a, b)
    Operation (op)
    Expected result (optional reference model field)

Randomizable fields allow constrained random testing.

Sequencer
Generates ALU transactions
Controls randomization
Feeds transactions to driver

Driver
Converts transactions into pin-level stimulus
Drives DUT through interface
Obeys timing protocol (if clocked)

Monitor
Observes DUT signals
Reconstructs transactions
Sends observed data to scoreboard

Scoreboard
Computes expected ALU result
Compares against DUT output
Reports mismatches

Tracks pass/fail statistics

3. DUT (Design Under Test)

Parametric ALU supporting:

ADD

SUB

AND

OR

XOR

(Extendable operations)

Combinational logic modeled using case-based decode.

4. Tools Used

SystemVerilog

UVM Library

Vivado ML Standard

XSIM Simulator

GTKWave (optional)

No paid simulators used.

5. Project Structure (Typical)
FV-UVM ALU Agent XSim/
│
├── rtl/
│   └── alu.sv
│
├── tb/
│   ├── alu_if.sv
│   ├── alu_seq_item.sv
│   ├── alu_sequencer.sv
│   ├── alu_driver.sv
│   ├── alu_monitor.sv
│   ├── alu_scoreboard.sv
│   ├── alu_agent.sv
│   ├── alu_env.sv
│   └── alu_test.sv
│
├── sim/
│   └── run_xsim.tcl
│
└── README.md

6. Simulation Flow (Vivado XSIM)
Step 1: Open Vivado

Create a simulation project and add:
RTL files
UVM TB files
UVM library path

Step 2: Run Simulation

Run behavioral simulation in XSIM.

Observe:
UVM build phase
UVM connect phase
UVM run phase
Random transactions generated
Scoreboard comparisons

7. Verification Strategy

Directed Testing
Basic operations validated first.

Constrained Random Testing
Random operands
Random operation selection
Multiple transactions per run

Self-Checking

Scoreboard computes:
    expected = reference_model(a, b, op)
Compares against DUT result.

Mismatch triggers:
    UVM error report
    Test failure increment

8. Example UVM Log Behavior

During simulation:
Sequence prints transaction
Driver logs drive action
Monitor logs observed result
Scoreboard logs PASS/FAIL

Clean separation of concerns ensures debuggability.

9. What This Project Demonstrates

UVM class hierarchy understanding
Transaction-level modeling
Separation of driver/monitor
Virtual interface usage
Scoreboard-based validation
Free-tool UVM execution (XSIM)
This directly aligns with:
    ASIC Design Verification roles
    SoC-level verification
    IP verification environments

10. Key Learnings

Proper UVM component phasing
Debugging build/connect/run issues
Avoiding race conditions between driver and monitor
Structuring reusable agents
Writing scalable verification environments

11. Industry Relevance

This project proves practical knowledge of:
UVM architecture
Agent construction
Scoreboard methodology
Transaction-driven verification

Relevant for:
ASIC DV Engineer
Verification IP Developer
SoC Verification Engineer

12. Possible Extensions

Add functional coverage
Add error injection
Add reset testing
Add protocol timing checks
Convert ALU agent into reusable VIP
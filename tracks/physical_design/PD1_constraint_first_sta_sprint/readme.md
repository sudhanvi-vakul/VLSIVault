Constraint-First STA Sprint

Clock Constraints → Synthesis → Static Timing Analysis → Violation Interpretation

1. Overview

This project demonstrates a constraint-driven RTL flow, where timing intent is defined first using SDC constraints, followed by synthesis and detailed Static Timing Analysis (STA).

Instead of just writing RTL and simulating, this project focuses on:
Writing proper clock constraints
Running synthesis
Performing setup and hold analysis
Comparing slack under different clock targets
Reading and interpreting STA reports professionally
This reflects real-world front-end ASIC timing workflows.

2. Project Objective

Implement a small RTL design
Define two clock constraint scenarios:
	Base clock constraint
	Tight clock constraint
Synthesize the design
Run OpenSTA
Compare setup and hold slack
Document worst timing paths

The goal is to understand how clock frequency affects timing closure.

3. Tools Used

SystemVerilog – RTL design
Yosys – Synthesis
OpenSTA – Static Timing Analysis
GTKWave – Waveform viewing
SDC – Timing constraint definition
This mirrors commercial flows like:
Synopsys Design Compiler + PrimeTime
Cadence Genus + Tempus

4. Directory Structure
sta_sprint/
│
├── rtl/
│   └── top.sv
│
├── tb/
│   └── top_tb.sv
│
├── constraints/
│   ├── top_base.sdc
│   └── top_tight.sdc
│
├── scripts/
│   ├── run_yosys.ys
│   └── run_sta.tcl
│
├── build/
│   ├── top_synth.v
│   ├── waves.vcd
│   ├── sim.out
│   └── lint.out
│
├── reports/
│   ├── yosys_stat.log
│   ├── sta_base.log
│   └── sta_tight.log
│
└── notes/
    ├── base_worst_setup.md
    ├── base_worst_hold.md
    ├── tight_worst_setup.md
    ├── tight_worst_hold.md
    └── recording_template.md

5. Constraint Strategy

Two timing modes were defined:
Base Constraint (top_base.sdc)
	Realistic clock frequency
	Expected to pass setup timing
	Used as reference timing target
Tight Constraint (top_tight.sdc)
	Higher clock frequency
	Reduces available timing margin
	Demonstrates slack reduction and potential setup violations

This models frequency scaling scenarios in real ASIC flows.

6. Flow Execution

Step 1 – Run Synthesis
yosys -s scripts/run_yosys.ys

Outputs:
Synthesized netlist
Synthesis statistics report

Step 2 – Run Static Timing Analysis
sta scripts/run_sta.tcl

Generates:
sta_base.log
sta_tight.log

These contain setup and hold reports.

Step 3 – View Functional Waveforms
gtkwave build/waves.vcd

Used to confirm functional correctness before timing analysis.

7. Setup Timing Analysis

Setup Slack Formula:
Slack = Required Arrival Time – Data Arrival Time

Key observations:
Tightening the clock reduces available setup margin.
Worst Negative Slack (WNS) indicates frequency limits.
Critical path delay determines maximum achievable frequency.

8. Hold Timing Analysis

Hold Slack Formula:
Slack = Data Arrival Time – Required Hold Time

Key observations:

Hold timing is largely independent of clock period.
Violations are related to minimum path delays.
Tightening the clock may not affect hold slack.

9. Results Summary
Scenario	Setup Slack	Hold Slack	Observation
Base Constraint	Positive	Positive	Design meets timing
Tight Constraint	Reduced / Negative	Stable	Setup stress introduced

This demonstrates:
Frequency vs slack tradeoff
Critical path sensitivity
Constraint-driven timing exploration

10. Key Learnings

Writing correct SDC constraints is essential.
Timing closure is constraint-driven.
Setup violations are frequency dependent.
Hold violations are minimum delay related.
STA requires interpretation, not just tool execution.

11. Industry Relevance

This project demonstrates skills expected from:
ASIC Implementation Engineers
Physical Design Engineers
STA Engineers
Front-End Timing Engineers
It shows practical experience in:
Constraint creation
Slack interpretation
Timing report analysis
Setup vs hold reasoning

12. Possible Extensions

Add input/output delays
Add multi-cycle path constraints
Introduce clock uncertainty
Add multiple clock domains
Perform frequency sweep analysis


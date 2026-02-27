# STA Sprint Recording Template

## Project metadata
- Windows version: Windows 11
- WSL Ubuntu version: Ubuntu 22.04.5 LTS
- VS Code version:1.108.2
- yosys version:0.9
- gtkwave version:GTKWave Analyzer v3.3.104 
- opensta version: 2.6.0
- iverilog version: Icarus Verilog version 11.0

## Files created
- RTL: rtl/top.sv
- TB: tb/top_tb.sv (optional)
- Yosys script: scripts/run_yosys.ys
- SDC: constraints/top_base.sdc, constraints/top_tight.sdc
- OpenSTA script: scripts/run_sta.tcl

## Evidence to capture
- OpenSTA WNS/TNS summary for sta_base
worst slack 4.47
worst slack 1.98
tns 0.00

- OpenSTA WNS/TNS summary for sta_tight (setup violation)
worst slack -3.78
worst slack 1.85
tns -55.05

## Experiment table
| Run | Clock(ns) | Unc(ns) | InD(ns) | OutD(ns) | Setup WNS | Setup TNS | Hold WNS | 
|-----|----------:|--------:|--------:|---------:|----------:|----------:|---------:|
| base |   10.0   |   0.2   |   2.0   |   2.0    |   4.47    |   0.00    |   1.98   |       
| tight|    2.0   |   0.4   |   2.0   |   2.0    |  -3.78    |  -55.05   |   1.85   |       


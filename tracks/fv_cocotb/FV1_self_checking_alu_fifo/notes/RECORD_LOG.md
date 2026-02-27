# Self-Checking + Randomized TB — Record Log

## Environment
- Windows version: Windows 11
- WSL Ubuntu version: Ubuntu 24.04.3 LTS
- VS Code version:1.108.2
- verilator version:5.020
- gtkwave version:GTKWave Analyzer v3.3.116 
- python version: Python 3.12.3

## Evidence index
List your screenshots and key report files here.

Screenshots
●	01_vscode_wsl_badge.png
●	02_project_tree.png
●	03_alu_opcodes.png
●	04_gen_vectors_seed.png
●	05_vectors_csv_head.png
●	06_tb_self_check.png
●	07_verilator_pass_or_fail.png
●	08_waveform_signals.png

Files
●	rtl/alu.v
●	py/gen_vectors.py
●	vectors/alu_vectors.csv
●	tb/tb_alu_file.sv
●	reports/gen_vectors.log, reports/vectors_head.txt
●	reports/verilator_run.log


## Test Runs
| Run ID | DUT | Num tests | Seed | Ops included | Result | Fail count | Notes |
|-------:|-----|----------:|-----:|--------------|--------|-----------:|------|
  001     ALU      200         7        All 7       PASS         0           
## Bug diary (if any)
| Bug ID | Symptom | How found | Fix | Proof (screenshot/report) |
|------:|---------|----------|-----|---------------------------|
              
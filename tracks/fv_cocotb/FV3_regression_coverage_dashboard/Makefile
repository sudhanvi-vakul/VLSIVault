# cocotb Makefile (Verilator) — Project 2

TOPLEVEL_LANG ?= verilog
SIM ?= verilator

# DUT selection
TOPLEVEL ?= alu
VERILOG_SOURCES ?= $(PWD)/rtl/$(TOPLEVEL).v

# cocotb python module (test file without .py)
MODULE ?= tb.tests.test_alu_smoke

# Wave dumps (Verilator VCD)
WAVES ?= 1
export WAVES

SEED ?= 0
export SEED

VERILATOR_TRACE ?= 1
SIM_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim

TOP=cpu_pipe_top
TB=../tb/sim_main.cpp

RTL=../rtl/cpu_pipe_top.sv ../rtl/hazard_unit.sv \
    ../rtl/pc.v ../rtl/rom.v ../rtl/regfile.v ../rtl/alu.v ../rtl/control_decode.v ../rtl/dmem.v

BUILD_DIR=obj_dir

build:
	verilator -Wall --sv --cc $(RTL) --exe $(TB) --trace --top-module $(TOP) -o sim.out
	make -C $(BUILD_DIR) -f V$(TOP).mk -j

# IMPORTANT:
# rom.v reads "program.hex" from *current working directory*
# So we copy ROM into OUT/program.hex and run from inside OUT.
run:
	@mkdir -p $(OUT)
	@cp $(ROM) $(OUT)/program.hex
	@echo "./$(BUILD_DIR)/sim.out +max_cycles=$(MAX_CYCLES) +waves=$(WAVES)" > $(OUT)/command.txt
	@cd $(OUT) && ../../sim/$(BUILD_DIR)/sim.out +max_cycles=$(MAX_CYCLES) +waves=$(WAVES) > transcript.log

wave:
	gtkwave $(OUT)/waves.vcd

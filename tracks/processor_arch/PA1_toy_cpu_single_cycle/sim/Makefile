TOP      := top
OUTBIN   := sim
OBJDIR   := obj_dir

VERILATOR := verilator

RTL_SRCS := \
  ../rtl/top.v \
  ../rtl/cpu_top_wrap.v \
  ../rtl/cpu_top.v \
  ../rtl/control_decode.v \
  ../rtl/dmem.v \
  ../rtl/pc.v \
  ../rtl/rom.v \
  ../rtl/regfile.v \
  ../rtl/alu.v

TB_CPP := ../tb/sim_main.cpp

all:
	$(VERILATOR) --cc --top-module $(TOP) $(RTL_SRCS) \
	  --exe $(TB_CPP) \
	  --build \
	  -Wno-PINMISSING -Wno-WIDTHEXPAND -Wno-WIDTH \
	  -CFLAGS "-DTOP_HAS_RST_N" \
	  -o $(OUTBIN)

clean:
	rm -rf $(OBJDIR) $(OUTBIN)

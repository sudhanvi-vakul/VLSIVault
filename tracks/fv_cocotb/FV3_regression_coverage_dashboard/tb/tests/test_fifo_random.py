import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge
import random

@cocotb.test()
async def fifo_full_empty_test(dut):
    # 1. Start Clock (100MHz / 10ns period)
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # 2. Reset Sequence
    dut.rst_n.value = 0
    dut.wr_en.value = 0
    dut.rd_en.value = 0
    dut.din.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # 3. FILL PHASE (Push 16 items)
    for i in range(16):
        dut.wr_en.value = 1
        dut.din.value = i + 0xA0  # Hex values for easy tracking
        await RisingEdge(dut.clk)
    
    dut.wr_en.value = 0
    await FallingEdge(dut.clk)
    assert dut.full.value == 1, "FIFO should be FULL"

    # 4. OVERFLOW ATTEMPT (Push 17th item)
    dut.wr_en.value = 1
    dut.din.value = 0xFF
    await RisingEdge(dut.clk)
    dut.wr_en.value = 0
    await RisingEdge(dut.clk)

    # 5. DRAIN PHASE (Pop 16 items)
    for i in range(16):
        dut.rd_en.value = 1
        await RisingEdge(dut.clk)
        # Note: dout updates 1 cycle after rd_en due to registered output
    
    dut.rd_en.value = 0
    await FallingEdge(dut.clk)
    assert dut.empty.value == 1, "FIFO should be EMPTY"
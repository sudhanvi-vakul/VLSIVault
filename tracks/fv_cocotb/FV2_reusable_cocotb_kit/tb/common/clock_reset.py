import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

async def start_clock(dut, period_ns):
    from cocotb.clock import Clock
    cocotb.start_soon(Clock(dut.clk, period_ns, unit='ns').start())

async def apply_reset(dut, cycles):
    dut.rst_n.value = 0
    for _ in range(cycles):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

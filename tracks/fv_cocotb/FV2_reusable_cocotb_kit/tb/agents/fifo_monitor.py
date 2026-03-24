import cocotb
from cocotb.triggers import RisingEdge

class FifoMonitor:
    def __init__(self, dut):
        self.dut = dut
        self.observed = []

    async def run(self):
        while True:
            await RisingEdge(self.dut.clk)

            obs = {
                "push": int(self.dut.wr_en.value),
                "pop":  int(self.dut.rd_en.value),
                "din":  int(self.dut.din.value),
                "dout": int(self.dut.dout.value),
                "full": int(self.dut.full.value),
                "empty":int(self.dut.empty.value),
            }

            self.observed.append(obs)
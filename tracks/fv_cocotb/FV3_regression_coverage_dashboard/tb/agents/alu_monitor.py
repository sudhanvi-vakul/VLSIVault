import cocotb
from cocotb.triggers import RisingEdge

class AluMonitor:
    def __init__(self, dut, cfg):
        self.dut = dut
        self.cfg = cfg
        self.observed = []

    async def run(self):
        while True:
            await RisingEdge(self.dut.clk)
            # Capture a simple observation each cycle (you can improve later).
            obs = {
                'a': int(self.dut.a.value),
                'b': int(self.dut.b.value),
                'op': int(self.dut.op.value),
                'y': int(self.dut.y.value),
            }
            self.observed.append(obs)

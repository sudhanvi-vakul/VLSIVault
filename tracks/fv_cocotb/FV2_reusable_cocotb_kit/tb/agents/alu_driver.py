import cocotb
from cocotb.triggers import RisingEdge

class AluDriver:
    def __init__(self, dut, cfg):
        self.dut = dut
        self.cfg = cfg
        self.tid = 0

    async def send(self, txn):
        """Drive inputs for 1 cycle; sample output next cycle."""
        self.tid += 1
        txn.tid = self.tid

        self.dut.a.value  = txn.a
        self.dut.b.value  = txn.b
        self.dut.op.value = txn.op

        await RisingEdge(self.dut.clk)   
        await RisingEdge(self.dut.clk)   
        return int(self.dut.y.value)

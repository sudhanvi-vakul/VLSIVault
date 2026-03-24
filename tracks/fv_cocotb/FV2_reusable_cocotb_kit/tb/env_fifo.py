from tb.common.fifo_txn import FifoTxn
from tb.scoreboard_fifo import ScoreboardFifo
from cocotb.triggers import RisingEdge


class EnvFifo:
    def __init__(self, dut):
        self.dut = dut
        self.scb = ScoreboardFifo()

    async def reset(self):
        self.dut.rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.clk)

    async def write(self, val):
        self.dut.din.value = val
        self.dut.wr_en.value = 1

        txn = FifoTxn(data=val, wr_en=True)
        self.scb.check_fifo(txn, None)

        await RisingEdge(self.dut.clk)

        self.dut.wr_en.value = 0

    async def read(self):
        # Assert read enable
        self.dut.rd_en.value = 1
        await RisingEdge(self.dut.clk)

        # Deassert read enable
        self.dut.rd_en.value = 0
        await RisingEdge(self.dut.clk)

        dout = int(self.dut.dout.value)

        txn = FifoTxn(data=dout, rd_en=True)
        self.scb.check_fifo(txn, dout)

        return dout
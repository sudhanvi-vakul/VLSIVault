class FifoDriver:
    def __init__(self, dut, cfg):
        self.dut = dut
        self.cfg = cfg

    async def send(self, txn):
        await RisingEdge(self.dut.clk)

        self.dut.wr_en.value = txn.wr_en
        self.dut.rd_en.value = txn.rd_en
        self.dut.din.value   = txn.data

        await RisingEdge(self.dut.clk)

        self.dut.wr_en.value = 0
        self.dut.rd_en.value = 0
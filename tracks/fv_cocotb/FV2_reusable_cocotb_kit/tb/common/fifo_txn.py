# tb/common/fifo_txn.py
class FifoTxn:
    def __init__(self, data, wr_en=False, rd_en=False):
        self.data = data
        self.wr_en = wr_en  
        self.rd_en = rd_en  
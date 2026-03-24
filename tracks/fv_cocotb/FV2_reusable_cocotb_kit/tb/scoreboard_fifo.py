# tb/scoreboard_fifo.py

class ScoreboardFifo:
    def __init__(self):
        # Internal model of the FIFO
        self.model = []

    def check_fifo(self, txn, dut_dout):
        """Check the DUT output against the model."""

        # Write operation
        if txn.wr_en:
            self.model.append(txn.data)

        # Read operation
        if txn.rd_en:
            if not self.model:
                raise AssertionError("FIFO Underflow detected")

            expected = self.model.pop(0)

            if expected != int(dut_dout):
                raise AssertionError(
                    f"FIFO Mismatch! Expected {expected}, Got {int(dut_dout)}"
                )
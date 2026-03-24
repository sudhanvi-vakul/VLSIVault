class Scoreboard:
    def __init__(self, model_fn):
        self.model_fn = model_fn
        self.pass_cnt = 0
        self.fail_cnt = 0

    def check_alu(self, txn, got_y, nbits=16):
        exp = self.model_fn(txn.a, txn.b, txn.op, nbits=nbits)
        if got_y != exp:
            self.fail_cnt += 1
            raise AssertionError(
                f"ALU MISMATCH tid={txn.tid} op={txn.op} a=0x{txn.a:X} b=0x{txn.b:X} exp=0x{exp:X} got=0x{got_y:X}"
            )
        self.pass_cnt += 1

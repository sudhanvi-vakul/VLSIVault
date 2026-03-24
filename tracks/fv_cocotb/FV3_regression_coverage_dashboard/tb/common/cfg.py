from dataclasses import dataclass

@dataclass
class Cfg:
    clk_period_ns: int = 10
    reset_cycles: int = 5
    seed: int = 1
    txns: int = 200
    timeout_cycles: int = 2000
    waves: bool = False

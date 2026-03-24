import cocotb
import random
from cocotb.clock import Clock
from tb.common.clock_reset import start_clock, apply_reset
from tb.agents.alu_driver import AluDriver
from tb.scoreboard import Scoreboard
from tb.models.alu_model import alu_ref

class Env:
    def __init__(self, dut, cfg):
        self.dut = dut
        self.cfg = cfg
        self.rng = random.Random(cfg.seed)
        self.driver = AluDriver(dut, cfg)
        self.scb = Scoreboard(alu_ref)

    async def setup(self):
       
        if hasattr(self.dut, "clk"):
            cocotb.start_soon(Clock(self.dut.clk, self.cfg.clk_period_ns, unit='ns').start())
       
        if hasattr(self.dut, "rst_n"):
            await apply_reset(self.dut, self.cfg.reset_cycles)
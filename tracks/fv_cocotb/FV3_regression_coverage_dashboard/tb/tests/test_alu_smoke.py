import cocotb
from tb.common.cfg import Cfg
from tb.common.txns import AluTxn
from tb.env import Env
from cocotb.triggers import Timer

@cocotb.test()
async def alu_smoke(dut):
    cfg = Cfg(seed=1, txns=40)
    env = Env(dut, cfg)
    await env.setup()

    for i in range(cfg.txns):
        txn = AluTxn(a=i, b=i+1, op=i % 7)
        got = await env.driver.send(txn)
        env.scb.check_alu(txn, got)

    await Timer(200, units='ns')
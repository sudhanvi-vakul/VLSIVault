import cocotb
from tb.common.cfg import Cfg
from tb.common.txns import AluTxn
from tb.env import Env

@cocotb.test()
async def alu_random(dut):
    cfg = Cfg(seed=int(getattr(dut, 'SEED', 1)), txns=200)
    dut._log.info(f"RUNCFG seed={cfg.seed} txns={cfg.txns} dut={dut._name}")
    env = Env(dut, cfg)
    await env.setup()

    for i in range(cfg.txns):
        a  = env.rng.randrange(0, 1<<16)
        b  = env.rng.randrange(0, 1<<16)
        op = env.rng.randrange(0, 7)
        txn = AluTxn(a=a, b=b, op=op, tid=i)
        got = await env.driver.send(txn)
        env.scb.check_alu(txn, got)


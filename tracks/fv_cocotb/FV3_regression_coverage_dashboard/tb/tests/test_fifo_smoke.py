# tb/tests/test_fifo_smoke.py
import cocotb
from cocotb.triggers import RisingEdge
from tb.env_fifo import EnvFifo

@cocotb.test()
async def fifo_smoke(dut):
    env = EnvFifo(dut)
    
    # Reset DUT
    await env.reset()

    # Simple smoke test: write 4 values and read them back
    test_data = [10, 20, 30, 40]

    # Write phase
    for val in test_data:
        await env.write(val)

    # Read phase
    read_values = []
    for _ in test_data:
        dout = await env.read()
        read_values.append(dout)

    dut._log.info(f"Read values: {read_values}")
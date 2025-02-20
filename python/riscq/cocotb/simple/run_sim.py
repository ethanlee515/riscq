import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb.types import LogicArray
from cocotb.runner import Verilator

async def reset(dut):
    dut.reset.value = 1
    await Timer(10, units="ns")
    dut.reset.value = 0

@cocotb.test()
async def simple_test(dut):
    """test start"""

    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())  # run the clock "in the background"
    await reset(dut)

    # await RisingEdge(dut.clk)
    for i in range(200):
        await RisingEdge(dut.clk)
        dut._log.info(f"{dut.counter.value}")
    assert(True, "")

def run_test():
    hdl_toplevel_lang = "verilog"
    sim = "verilator"
    sources = ["/workspaces/ctrlq/MyTimer.v"]
    # runner = get_runner(sim)
    runner = Verilator()
    runner.build(
        sources = sources,
        hdl_toplevel = "MyTimer",
        # build_args=["--timing"],
        clean=True,
        always=True
    )
    runner.test(hdl_toplevel = "MyTimer", test_module = "run_sim")

if __name__ == "__main__":
    run_test()

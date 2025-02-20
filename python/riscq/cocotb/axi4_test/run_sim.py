import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb.types import LogicArray
from cocotb.runner import Verilator, Icarus
from cocotb_bus.drivers.amba import AXI4Master
# import riscq
from riscq.assembler import *

async def reset(dut):
    dut.reset.value = 1
    await Timer(10, units="ns")
    dut.reset.value = 0

@cocotb.test()
async def simple_test(dut):
    """test start"""

    add = ADD(7, 7, 7)
    beq = BEQ(1, 2, 3)
    insts = assemble([add,beq])
    print(insts)

    axim = AXI4Master(dut, "AXI", dut.clk)
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())  # run the clock "in the background"
    await reset(dut)
    ADDRESS = 0
    DATA = [0x7, 0x7]
    await axim.write(ADDRESS, DATA)
    read_data = await axim.read(ADDRESS + 4)
    dut._log.info(f"{read_data}")

    assert(True, "")

def run_test():
    sources = ["/workspaces/ctrlq/AxiToTileLinkMem.v"]
    runner = Icarus()
    # runner = Verilator()
    runner.build(
        sources = sources,
        hdl_toplevel = "AxiToTileLinkMem",
        # build_args=["-Wno-WIDTH"],
        clean=True,
        always=True
    )
    runner.test(hdl_toplevel = "AxiToTileLinkMem", test_module = "run_sim")

if __name__ == "__main__":
    run_test()

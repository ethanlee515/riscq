import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb.types import LogicArray
from cocotb.runner import Verilator, Icarus
from cocotb_bus.drivers.amba import AXI4Master
from riscq.assembler import *
from riscq.sim_utils import *
import math

def to_sint(d, width):
    if d >= 1 << (width - 1):
        return d - (1 << width)
    else:
        return d


async def reset(dut):
    dut.reset.value = 1
    await Timer(10, units="ns")
    dut.reset.value = 0

@cocotb.test()
async def pulse_test(dut):
    """test start"""

    set_time = SETTIME(10)
    # freq = 1 << (16 - 5)
    # freq = int(0.01 * freq)
    freq = int((1 << 16) / 32.0)
    amp = (1 << 16) - 1
    id = 1
    set_carrier = CARRIER(freq = freq, phase = 0, id = id)
    send_pulse = PULSE(start = 50, addr = 0, duration = 8, phase = 0, freq = freq, amp = amp, id = id)

    insts = assemble([set_time, set_carrier, send_pulse])

    axim = AXI4Master(dut, "AXI", dut.clk)
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())  # run the clock "in the background"
    await reset(dut)
    await Timer(100, units="ns")

    inst_addr_shift = 0x80000000
    await load_insts(axim, insts, inst_addr_shift)

    await Timer(100, units="ns")
    def pulse_addr_shift(id: int):
        return id * (1 << 24)
    env = [50 for i in range(512)]
    for id in range(2):
        await load_pulse(axim, env, pulse_addr_shift(id))

    await Timer(500, units="ns")
    await reset(dut)

    def to_sint(d, width):
        if d >= 1 << (width - 1):
            return d - (1 << width)
        else:
            return d
    for i in range(60):
        dac_data = get_dac(dut, id)
        dut._log.info(f"{[to_sint(d.integer, 16) for d in dac_data]}")
        dut._log.info(f"{dut.globalTime.value.integer}")
        await Timer(2, units="ns")

    assert(True, "")

async def adc_input(dut, freq, phase, batchSize = 16):
    while(True):
        for id in range(2):
            adcs = get_adc(dut, id)
            time = int(dut.globalTime.value)
            time = time - 8
            adc_r = [math.cos((time * batchSize + i) * freq * math.pi + phase) for i in range(len(adcs))]
            adc_r = [int(r * (1 << 14)) % (1 << 16) for r in adc_r]
            adc_i = [-math.sin((time * batchSize + i) * freq * math.pi + phase) for i in range(len(adcs))]
            adc_i = [int(i * (1 << 14)) % (1 << 16) for i in adc_i]
            print("adc_r:", [to_sint(r, 16) for r in adc_r])
            for i in range(len(adcs)):
                # adc_r = math.cos((time * batchSize + i) * freq * math.pi + phase)
                # print(f'adc{i}: {adc_r}')
                # print(f'adc time: {time}')
                # adc_r = int(adc_r * (1 << 15)) % (1 << 16)
                # adc_i = -math.sin((time * batchSize + i) * freq * math.pi + phase)
                # adc_i = int(adc_i * (1 << 15)) % (1 << 16)
                adcs[i][0].value = adc_r[i]
                adcs[i][1].value = adc_i[i]
        await Timer(2, units='ns')

# @cocotb.test()
async def readout_test(dut):
    """test start"""

    freq = 1 / 100.0
    id = 0

    set_time = SETTIME(10)
    set_carrier = CARRIER(freq = int((1 << 15) * freq), phase = 0, id = id)
    wait55 = WAIT(55)
    readout = READOUT(id, 4)
    wait60 = WAIT(60)
    write_r = WRITER(7, id)
    write_i = WRITER(8, id)
    sub78 = SUB(9, 7, 8)
    beq00 = BEQ(0, 0, 0)

    insts = assemble([set_time, set_carrier, wait55, readout, wait60, write_r, write_i, sub78, beq00])

    axim = AXI4Master(dut, "AXI", dut.clk)
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())  # run the clock "in the background"
    await reset(dut)
    dut._log.info("here")
    await Timer(100, units="ns")

    inst_addr_shift = 0x80000000
    await load_insts(axim, insts, inst_addr_shift)

    cocotb.start_soon(adc_input(dut, freq, 0))

    await Timer(500, units="ns")
    await reset(dut)

    for i in range(100):
        readout_r, readout_i = get_readout(dut, id)
        try: 
            dut._log.info(f"time:{dut.globalTime.value.integer}, pc:{dut.pc.value.integer:x}, readout_r:{to_sint(readout_r.value.integer, 32)}, readout_i:{to_sint(readout_i.value.integer, 32)}")
            carrier = [to_sint(dut._id(f"carrier_0_{i}_r", extended = False).value.integer, 16) for i in range(16)]
            print("carrier:",carrier)
        except:
            dut._log.info(f"time:{dut.globalTime.value.integer}, pc:{dut.pc.value.integer:x}, readout_r:{readout_r}, readout_i:{readout_i}")
        await Timer(2, units="ns")
    # read_data = await axim.read(inst_addr_shift)

    assert(True, "")


def run_test():
    sources = ["/Users/user/vivado-on-silicon-mac/riscq/riscq-vivado/rtl/QubicSoc.v"]

    # runner = Icarus()
    # runner.build(
    #     sources = sources,
    #     hdl_toplevel = "QubicSoc",
    #     always=True
    # )

    runner = Verilator()
    runner.build(
        sources = sources,
        hdl_toplevel = "QubicSoc",
        build_args=["-Wno-WIDTH"],
        # clean=True,
        always=True
    )

    runner.test(hdl_toplevel = "QubicSoc", test_module = "run_sim")

if __name__ == "__main__":
    run_test()

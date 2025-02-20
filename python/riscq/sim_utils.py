async def load_insts(axim, insts, addr):
    cur_addr = addr
    for inst in insts:
        slices = [inst[i:i+32] for i in range(0, 128, 32)]
        slices = slices[::-1]
        for slice in slices:
            await axim.write(cur_addr, int(slice, 2))
            cur_addr += 4

def get_dac(dut, id, batchSize = 16):
    res = [dut._id(f"dac_{id}_{i}_r", extended = False).value for i in range(batchSize)]
    return res

def get_adc(dut, id, batchSize = 16):
    res = [(dut._id(f"adc_{id}_{i}_r", extended = False), \
            dut._id(f"adc_{id}_{i}_i", extended = False))  for i in range(batchSize)]
    return res

def get_readout(dut, id):
    return (dut._id(f"readouts_{id}_r", extended = False), dut._id(f"readouts_{id}_i", extended = False))

async def load_pulse(axim, env, addr):
    batchSize = 2
    dataWidth = 16
    batches = [env[i: i + batchSize] for i in range(0, len(env), batchSize)]
    cur_addr = addr
    for batch in batches:
        load_data: int = (batch[1] << dataWidth) + batch[0]
        # print(f'{cur_addr}, {load_data}')
        await axim.write(cur_addr, load_data)
        cur_addr += 4



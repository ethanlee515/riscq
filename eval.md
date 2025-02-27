## Examples

- src/main/scala/riscq/scratch/Bench.scala
- src/main/scala/riscq/soc/Minimal.scala

## start vivado
In our gui, open a terminal by `ctrl + alt + t`, click the title bar of the terminal if you cannot input anything, then run
```bash
vivado -mode tcl
```

###
Vivado can be fully controlled by tcl scripts. You can input tcl script in the tcl console. Below are some useful tcl commands
- `start_g`: start gui
- `stop_g`: stop gui
- `close_p`: close current project
- `exit`: exit vivado

## Elements of circuit

### Register

- Run `mill q.runMain riscq.scratch.ManyRegs`
- In vivado gui, open the project in `./build`
- Check `schematic` under `RTL ANALYSIS`, `SYNTHESIS` and `IMPLEMENTATION` on the left hand side
- In most case, implementation is the most important one, which shows the design after circuit simplification and placement on the FPGA chip.

- Usually, registers are implemented by [FDRE](https://docs.amd.com/r/en-US/ug974-vivado-ultrascale-libraries/FDRE), which is just a Flip-Flop (FF)


### Gates

- Run `mill q.runMain riscq.scratch.ManyOrs`
- Check `schematic`
- Usually, gates are implemented by LookUp Tables(LUTs), which are gates defined by truth tables.


### Timing

- Run `mill q.runMain riscq.scratch.LongCombPath`
- Check `WNS` in the `Timing section` of Project Summary
  - A negative `WNS` indicates that the critical path in the circuit is too long to fit in a clock cycle
  - Click `Implemented Timing Report`
  - Click the number after `WNS`
  - You can see several paths
  - Right click the path, select schematic
  - For some components in schematic, you can find `Go To Source` in the right click menu, which shows the corresponding code in verilog.
- Vivado stops optimization as soon as `WNS` becomes positive. So a positive `WNS` gives little information. To find out the max frequency (FMax) of the current design, change the target frequency and redo the bench.

### Memory

- Run `mill q.runMain riscq.scratch.BramInfer`
- In verilog, a memory is just an array of registers.
- Although memories can be implemented by FFs and LUTs, FPGA provides some more efficient implementation of memory. Block Ram is the most common one.
- Usually, Vivado automatically infers which register array can be implemented by bram, as long as we use `Mem` in spinalhdl. Sometimes, we need to give some hint to vivado by  `mem.addAttribute("ram_style", "block")`
- A BRam can store 1024x18 bits, and has two read/write ports.
- BRam has better timing performance if we add a buffer register to its output data. The output buffer will be absorb into the BRam component in schematic. We can see the buffer as `DOA_REG`, `DOB_REG` in the BRam properties.
- [BRam doc](https://docs.amd.com/v/u/en-US/ug573-ultrascale-memory-resources) (usually we don't need to read that)

### DSP

- Run `mill q.runMain riscq.scratch.DspInfer`
- DSPs are efficient implementation of `(a * b) + c` on FPGA
- `https://docs.amd.com/v/u/en-US/ug579-ultrascale-dsp`
- To help Vivado infer DSP from verilog, use `+^` and `-^`, add buffers between different steps


## Generate QubicSoc
In vivado-scripts, run
```bash
./gen-rtl.sh
./gen-bit.sh some-name
```

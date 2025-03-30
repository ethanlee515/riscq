## Code refactor
- Testing facilities
  - src/main/scala/riscq/tester/QubicSocTestBench.scala
  - src/main/scala/riscq/test/WhiteBoxerPlugin.scala
  - ✅ We have written a minimal risc-v processor without the pulse generation logic as the starting point for testing.
  - More tests are required
- Pulse generation logic
  - src/main/scala/riscq/pulse/PulseGenerator.scala
  - src/main/scala/riscq/pulse/CarrierGenerator.scala
  - I've added a lot of buffers to improve the timing, and the code became a little messy. Need some cleaning or rewrite for readability
- QubicSoc
  - ☑️ We have made it more readable. More improvement is possible.

## Add more risc-v instructions
There are some reference implementations in VexiiRiscv. We can try to reproduce a simple version.
- [multiplication](https://github.com/SpinalHDL/VexiiRiscv/blob/dev/src/main/scala/vexiiriscv/execute/MulPlugin.scala)
- [division](https://github.com/SpinalHDL/VexiiRiscv/blob/dev/src/main/scala/vexiiriscv/execute/DivPlugin.scala)
- You can try to implement one of them to get familiar with the framework

## Vivado evaluation environment
- ✅ We have a script to benchmark the area and timing of a new module in a couple of lines.
- There are some examples in `src/main/scala/riscq/scratch/Bench.scala`

## Pulse generation using original risc-v instructions without customize instructions
- It is a good baseline for comparison with different architectures.
- It may save resources because we only need to store 32-bit instrucions along the pipeline instead of 128-bit ones.

- ✅ We have implemented some facilities that can use one line of code to map a hardware registers to the memory address space of the RISC-V processor.
  - ✅ We have mapped the parameters of the pulse generation (duration, frequency, phase, amplitude, envelope address) to some memory address, so that we can setup the pulse generator using original load/store instructions in RISC-V, without adding customized instructions.
  - ☑️ Readout modules will be implemented in this way soon, so that we can get the readout result by loading some memory address.
  - By doing this, we can implement feedback control by read the measurement result from `READOUT_ADDRESS` and send the result to some `PULSE_SELECTION_ADDRESS` to decide the feedback control in mid-circuit control without branching. This can save considerable cycles in a pipelined processor without the help of branch prediction.
  ```c
    int readout_result = *(READOUT_ADDRESS)
    *(PULSE_SELECTION_ADDRESS) = readout_result
  ```
  - Base on this, we can also implement some warm up process for pulse generation, so that some intermediate results of pulse generation are precomputed before the pulse generation process start. In this way, we can get lower latency in pulse generation.


## Customize risc-v toolchain
Write C to program an experiment
- add custom instruction
  - [VexiiRiscv custom instruction](https://spinalhdl.github.io/VexiiRiscv-RTD/master/VexiiRiscv/Execute/custom.html)
  - [code example](https://github.com/SpinalHDL/NaxSoftware/blob/849679c70b238ceee021bdfd18eb2e9809e7bdd0/baremetal/simdAdd/src/crt.S)
  - [c macro](https://github.com/SpinalHDL/NaxSoftware/blob/849679c70b238ceee021bdfd18eb2e9809e7bdd0/baremetal/driver/custom_asm.h)
- force every instruction to align to 128 bits.
- Need someone to experiment with the toolchain
- After that, we can try to write some experiments using C and run them on real machines.
  - Rabi oscillation
  - Ramsey experiment for calibration of x gate
  - Suying's calibration protocol
- ✅ We have figured out how to modify the RISC-V toolchain to implement customize instruction with C macro.
- ✅ We can now write control process using C programming language and compile with the LLVM clang compiler.
- ☑️ We need some customized process for the linking process in the compilation. Still require some script to automate the whole compilation.

## Pulse compression
- A very important topic for scaling
  - Pulse generation takes most resources in current implementations (QubiC, QICK)
- [reference](https://ieeexplore.ieee.org/document/9923861)
- Figure out the algorithm. Build a simple implementation

## Documentation
- Maybe it is time to write some documentation
- [QICK reference](https://github.com/meeg/qick_demos_sho/tree/main/tprocv2)

##

measurement

histogram

raw data


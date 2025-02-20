## Code refactor
- Testing facilities
  - src/main/scala/riscq/tester/QubicSocTestBench.scala
  - src/main/scala/riscq/test/WhiteBoxerPlugin.scala
  - Current implementation is quite arbitrary. Some tests are broken. Need some refactoring to ensure the correctness of further development
  - I will write a minimal risc-v processor without the pulse generation logic as the starting point for testing.
- Pulse generation logic
  - src/main/scala/riscq/pulse/PulseGenerator.scala
  - src/main/scala/riscq/pulse/CarrierGenerator.scala
  - I've added a lot of buffers to improve the timing, and the code became a little messy. Need some cleaning or rewrite for readability
- QubicSoc
  - It is too long (~300 lines for a single class)
  - I will try to make it more readable

## Add more risc-v instructions
There are some reference implementations in VexiiRiscv. We can try to reproduce a simple version.
- [multiplication](https://github.com/SpinalHDL/VexiiRiscv/blob/dev/src/main/scala/vexiiriscv/execute/MulPlugin.scala)
- [division](https://github.com/SpinalHDL/VexiiRiscv/blob/dev/src/main/scala/vexiiriscv/execute/DivPlugin.scala)
- bit shift: [implementation1](https://github.com/SpinalHDL/VexiiRiscv/blob/dev/src/main/scala/vexiiriscv/execute/BarrelShifterPlugin.scala), [implementation2](https://github.com/SpinalHDL/VexiiRiscv/blob/dev/src/main/scala/vexiiriscv/execute/IterativeShiftPlugin.scala)
- You can try to implement one of them to get familiar with the framework

## Vivado evaluation environment
So that we know if our implementation can pass the timing test at 500MHz
- There are some examples in `src/main/scala/riscq/scratch/Bench.scala`
- I will give a brief tutorial later.

## Pulse generation using original risc-v instructions without customize instructions
- It is a good baseline for comparison with different architectures.
- It may save resources because we only need to store 32-bit instrucions along the pipeline instead of 128-bit ones.

Method: 
- Map the paremeters of pulse generaters (frequency, phase, amplitude, envelope address, duration) to some memory address using memorymap. Change parameters by write to specific memory address.
- Readout by reading specific memory address
  - need new implementation `PulseGeneratorPlugin`, `CarrierPlugin`, `ReadoutPlugin`
  - add memory map in `LsuCachelessBramConnectArea`
  - Starting point: [Bus slave factory](https://spinalhdl.github.io/SpinalDoc-RTD/master/SpinalHDL/Libraries/bus_slave_factory.html), `ext/SpinalHDL/lib/src/main/scala/spinal/lib/bus/bram/BRAMSlaveFactory.scala`
- Implement timing instruction by [timer interrupt](https://danielmangum.com/posts/risc-v-bytes-timer-interrupts/) or stuck the pipeline using memory load/store instructions (`sw`, `lw`...)
- Start with reading the interface of `PulseGeneratorWithCarrierTop`, `CarrierGenerator`

## Customize risc-v toolchain
Write C to program an experiment
- add custom instruction
  - [VexiiRiscv custom instruction](https://spinalhdl.github.io/VexiiRiscv-RTD/master/VexiiRiscv/Execute/custom.html)
  - [code example](https://github.com/SpinalHDL/NaxSoftware/blob/849679c70b238ceee021bdfd18eb2e9809e7bdd0/baremetal/simdAdd/src/crt.S)
  - [c macro](https://github.com/SpinalHDL/NaxSoftware/blob/849679c70b238ceee021bdfd18eb2e9809e7bdd0/baremetal/driver/custom_asm.h)
- force every instruction to align to 128 bits.
  - pad 32-bit instructions to 128 bits by adding nop instruction
  - answers from chatgpt for: how to force riscv toolchain to align all instructions to 128 bits?
  > Approach 3: Custom Linker Script
  > 
  > A better way is to modify the linker script to ensure 128-bit alignment of all code sections:
  ```
  SECTIONS {
      .text ALIGN(16) : {
          *(.text)
      }
      .rodata ALIGN(16) : {
          *(.rodata)
      }
      .data ALIGN(16) : {
          *(.data)
      }
  }
  ```
  > This ensures that the .text (code) section is always aligned on 128-bit boundaries.

  > Approach 4: Using -mno-relax and -falign-functions
  > 
  > The RISC-V toolchain sometimes optimizes and relaxes instructions, which can break strict alignment. You can disable this:
  > riscv64-unknown-elf-gcc -mno-relax -falign-functions=16 -falign-labels=16 -falign-loops=16 -falign-jumps=16 -T custom_linker.ld -o output.elf input.c
  >   -	-mno-relax: Prevents instruction relaxation.
  >   -	-falign-functions=16: Aligns functions to 16-byte boundaries.
  >   -	-falign-labels=16: Aligns labels.
  >   -	-falign-loops=16: Aligns loop entry points.
  >   -	-falign-jumps=16: Aligns jump targets.
- Need someone to experiment with the toolchain
- After that, we can try to write some experiments using C and run them on real machines.
  - Rabi oscillation
  - Ramsey experiment for calibration of x gate
  - Suying's calibration protocol

## Pulse compression
- A very important topic for scaling
  - Pulse generation takes most resources in current implementations (QubiC, QICK)
- [reference](https://ieeexplore.ieee.org/document/9923861)
- Figure out the algorithm. Build a simple implementation

## Documentation
- Maybe it is time to write some documentation
- [QICK reference](https://github.com/meeg/qick_demos_sho/tree/main/tprocv2)
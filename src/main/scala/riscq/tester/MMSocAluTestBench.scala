package riscq.tester.mmsoc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MemoryMapSoc
import riscq.tester.RvAssembler

object TestAlu extends App {
  val simConfig = SimConfig.addSimulatorFlag("-Wno-MULTIDRIVEN")
  simConfig.compile(MemoryMapSoc(withWhitebox = true)).doSim { dut =>
    val driver = new MMSocDriver(dut)
    val asm = new RvAssembler(32)
    driver.init()
    driver.rstUp()
    val insts = List(
      asm.addi(1, 0, 3),
      asm.add(2, 1, 2),
      asm.beq(0, 0, -2)
    )
    driver.loadInsts(insts)
    dut.riscq_rst #= true
    for(_ <- 0 until 10) {
      driver.tick()
    }
    dut.riscq_rst #= false
    for(_ <- 0 until 20) {
      driver.logRf()
      driver.tick()
    }
  }
}

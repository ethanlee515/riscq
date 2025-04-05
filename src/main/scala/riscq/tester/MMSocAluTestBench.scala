package riscq.tester.mmsoc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MemoryMapSoc
import riscq.tester.RvAssembler

object TestAlu extends App {
  val simConfig = SimConfig.addSimulatorFlag("-Wno-MULTIDRIVEN")
  simConfig.compile(MemoryMapSoc(withWhitebox = true)).doSim { dut =>
    val driver = new MMSocDriver(dut, "testAlu.elf")
    driver.init()
    driver.rstUp()
    driver.tick(50)
    driver.loadInsts()
    driver.rstDown()
    println("starting simulation...")
    for(_ <- 0 until 25) {
      driver.logRf()
      driver.tick()
    }
  }
}

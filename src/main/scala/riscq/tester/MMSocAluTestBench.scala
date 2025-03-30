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
    driver.loadInsts()
    driver.init()
    driver.rstUp()

    dut.riscq_rst #= true
    for(_ <- 0 until 15) {
      driver.tick()
    }

    driver.rstDown()
    dut.riscq_rst #= false
    for(_ <- 0 until 40) {
      driver.logRf()
      driver.tick()
    }
  }
}

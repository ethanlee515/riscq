package riscq.tester.mmsoc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MemoryMapSoc

class MMSocDriver(dut: MemoryMapSoc) {
  val cd = dut.clockDomain

  def init() = {
    cd.forkStimulus(10)
  }

  def rstUp() = {
    cd.assertReset()
  }

  def rstDown() = {
    cd.deassertReset()
  }
}

object TestMMSocAlu extends App {
  SimConfig.compile(MemoryMapSoc(withWhitebox = true)).doSim { dut =>
    val driver = new MMSocDriver(dut)
    driver.init()
    driver.rstUp()
  }
}

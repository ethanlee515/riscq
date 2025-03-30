package riscq.tester.mmsoc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MemoryMapSoc
import riscq.test.WhiteboxerPlugin

class MMSocDriver(dut: MemoryMapSoc) {
  val cd = dut.clockDomain
  val wb = dut.core.host[WhiteboxerPlugin].logic

  def init() = {
    cd.forkStimulus(10)
  }

  def rstUp() = {
    cd.assertReset()
  }

  def tick() = {
    cd.waitRisingEdge(1)
  }

  def loadInsts(insts: Seq[String]) = {
    var addr : Long = 0
    for (inst <- insts) {
      val instInt = BigInt(inst, 2)
      dut.mem.mem.setBigInt(addr, instInt)
      addr += 1
    }
  }

  def logRf() = {
    val n = wb.rf.mem.wordCount
    val res = List.tabulate(n)(wb.rf.mem.getBigInt(_).toString())
    println(s"rf: ${res}")
  }
}

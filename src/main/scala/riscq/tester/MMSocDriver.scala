package riscq.tester.mmsoc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MemoryMapSoc
import riscq.test.WhiteboxerPlugin
import spinal.lib.misc.Elf
import java.io.File

class MMSocDriver(dut: MemoryMapSoc) {
  val cd = dut.clockDomain
  val wb = dut.core.host[WhiteboxerPlugin].logic

  def loadInsts() = {
    val elfFile = new File("src/main/asm/testAlu.elf")
    val elf = new Elf(elfFile, addressWidth = 32)
    elf.load(dut.mem.mem, -0x80000000)
  }

  def init() = {
    cd.forkStimulus(10)
  }

  def rstUp() = {
    cd.assertReset()
  }

  def tick() = {
    cd.waitRisingEdge(1)
  }

  def logRf() = {
    val n = wb.rf.mem.wordCount
    val res = List.tabulate(n)(wb.rf.mem.getBigInt(_).toString())
    println(s"rf: ${res}")
  }
}

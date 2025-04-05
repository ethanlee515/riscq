package riscq.tester.mmsoc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MemoryMapSoc
import riscq.test.WhiteboxerPlugin
import spinal.lib.misc.Elf
import java.io.File
import spinal.lib.bus.amba4.axi.sim.Axi4Master
import spinal.lib.bus.tilelink.sim._
import spinal.lib.bus.tilelink._
import riscq._

class MMSocDriver(dut: MemoryMapSoc, elfFileName : String) extends Driver(dut) {
  def loadInsts() = {
    val elfFile = new File("src/main/asm/" + elfFileName)
    val elf = new Elf(elfFile, addressWidth = 32)
    elf.load(dut.mem.mem, -0x80000000)
  }
}

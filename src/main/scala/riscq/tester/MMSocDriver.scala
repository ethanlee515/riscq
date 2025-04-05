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

class MMSocDriver(dut: MemoryMapSoc, elfFileName : String) {
  implicit val idAllocator = new IdAllocator(DebugId.width)
  implicit val idCallback = new IdCallback
  val cd = dut.clockDomain
  val cd100m = dut.cd100m
  val wb = dut.core.host[WhiteboxerPlugin].logic

  var axi4Driver: Axi4Master = null
  var tlDriver: MasterAgent = null

  def loadInsts() = {
    val elfFile = new File("src/main/asm/" + elfFileName)
    val elf = new Elf(elfFile, addressWidth = 32)
    elf.load(dut.mem.mem, -0x80000000)
  }

  def init() = {
    axi4Driver = Axi4Master(dut.axi, cd100m)
    axi4Driver.reset()
    tlDriver = new MasterAgent(dut.tlBus.node.bus, cd100m)
    cd.forkStimulus(10)
    cd100m.forkStimulus(50)

    cd.assertReset()
    cd100m.assertReset()
    cd100m.waitRisingEdge(10)
    cd.deassertReset()
    cd100m.deassertReset()
  }

  def rstUp() = {
    cd.assertReset()
    cd100m.assertReset()
  }

  def rstDown() = {
    cd.deassertReset()
    cd100m.deassertReset()
  }

  def tick() = {
    cd.waitRisingEdge(1)
  }

  def logRf() = {
    val n = wb.rf.mem.wordCount
    val res = List.tabulate(n)(wb.rf.mem.getBigInt(_).toString())
    println(s"rf: ${res}")
  }

  def logPcs() = {
    for (data <- wb.pcs.data) {
      println(
        s"pc ${data.pc.toBigInt.toString(16)}, v: ${data.valid.toBoolean}, r: ${data.ready.toBoolean}, f: ${data.forgetOne.toBoolean}, ${data.ctrlName}"
      )
    }
  }
}

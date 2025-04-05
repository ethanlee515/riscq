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

class MMSocDriver(dut: MemoryMapSoc, elfPath : String) {
  implicit val idAllocator = new IdAllocator(DebugId.width)
  implicit val idCallback = new IdCallback

  val cd = dut.clockDomain
  val cd100m = dut.cd100m
  val wb = dut.core.host[test.WhiteboxerPlugin].logic
  var axi4Driver: Axi4Master = null
  var tlDriver: MasterAgent = null

  def init() = {
    axi4Driver = Axi4Master(dut.axi, cd100m)
    axi4Driver.reset()
    tlDriver = new MasterAgent(dut.tlBus.node.bus, cd100m)
    cd.forkStimulus(10)
    cd100m.forkStimulus(50)

    rstUp()
    cd100m.waitRisingEdge(10)
    rstDown()
  }

  def rstUp() = {
    cd.assertReset()
    cd100m.assertReset()
    dut.riscq_rst #= true
  }

  def rstDown() = {
    cd.deassertReset()
    cd100m.deassertReset()
    dut.riscq_rst #= false
  }

  def loadInsts() = {
    val elfFile = new File(elfPath)
    val elf = new Elf(elfFile, addressWidth = 32)
    elf.load(dut.mem.mem, -0x80000000)
  }

  def tick(t: Int = 1) = {
    cd.waitRisingEdge(t)
  }

  def logRf() = {
    val n = wb.rf.mem.wordCount
    val res = (0 until n).map { x => wb.rf.mem.getBigInt(x).toString() }.toList
    println(s"rf: ${res}")
  }
}

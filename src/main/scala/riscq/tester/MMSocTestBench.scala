package riscq.tester.mmsoc

import spinal.core.sim._
import spinal.core._
import spinal.lib.bus.tilelink.sim._
import spinal.lib.bus.tilelink._
import riscq._
import riscq.soc.QubicSoc
import spinal.lib.bus.amba4.axi.sim.Axi4Master
import riscq.tester.RvAssembler
import riscq.tester.QubicAssembler
import riscq.tester.ByteHelper
import riscq.soc.QubicPlugins

class Driver(dut: QubicSoc) {
  implicit val idAllocator = new IdAllocator(DebugId.width)
  implicit val idCallback = new IdCallback
  val cd = dut.clockDomain
  val cd100m = dut.cd100m

  val wb = dut.core.host[test.WhiteboxerPlugin].logic
  val puop = QubicPlugins.puop

  var axi4Driver: Axi4Master = null
  var tlDriver: MasterAgent = null

  def init() = {
    axi4Driver = Axi4Master(dut.axi, cd100m)
    axi4Driver.reset()
    tlDriver = new MasterAgent(dut.tlBus.node.bus, cd100m)
    cd.forkStimulus(10)
    cd100m.forkStimulus(50)

    cd.assertReset()
    cd100m.assertReset()
    cd100m.waitRisingEdge(0)
    cd.deassertReset()
    cd100m.deassertReset()
  }

  def rstUp() = {
    cd.assertReset()
  }

  def rstDown() = {
    cd.deassertReset()
  }

  def loadIMem(addr: Long, insts: Seq[String]) = {
    var writeAddr = addr
    for (inst <- insts) {
      val instInt = BigInt(inst, 2)
      dut.iMem.mem.setBigInt(writeAddr, instInt)
      writeAddr += 1
    }
  }

  def getDMem(addr: Long): BigInt = {
    return dut.dMem.mem.getBigInt(addr)
  }

  def tick(t: Int = 1) = {
    cd.waitRisingEdge(t)
  }

  def logRf() = {
    val n = wb.rf.mem.wordCount
    val res = (0 until n).map { x => wb.rf.mem.getBigInt(x).toString() }.toList
    println(s"rf: ${res}")
  }

  def logPc() = {
    val pc = wb.pc.output.toBigInt.toString(16)
    val valid = wb.pc.valid.toBoolean
    println(s"pc: ${pc}, v: ${valid}")
  }

  def logPcs() = {
    for (data <- wb.pcs.data) {
      println(
        s"pc ${data.pc.toBigInt.toString(16)}, v: ${data.valid.toBoolean}, r: ${data.ready.toBoolean}, f: ${data.forgetOne.toBoolean}, ${data.ctrlName}"
      )
    }
  }

  def logExInsts() = {
    for (data <- wb.exInsts.data) {
      println(s"pc ${data.pc.toBigInt.toString(16)}, ${data.inst.toBigInt
          .toString(2)}, v: ${data.valid.toBoolean}, r: ${data.ready.toBoolean}, ${data.ctrlName}")
    }
  }

  def logSrc() = {
    val src1 = wb.src.src1.toBigInt
    val src1k = wb.src.src1k.toBigInt
    val src2 = wb.src.src2.toBigInt
    val src2k = wb.src.src2k.toBigInt
    println(s"src1: $src1, src1k: $src1k, src2: $src2, src2k: $src2k")
  }

  def logDac(n: Int) = {
    val dac = dut.pgs(n).io.data
    val pulse = dac.payload.map { _.r.toDouble * (1 << 14) }.toList
    println(s"${pulse}")
  }

  def logCarrier(n: Int) = {
    val carrier = dut.cgs(n).io.carrier
    val data = carrier.payload.map { _.r.toDouble * (1 << 14) }.toList
    println(s"${data}")
  }

  def logTime() = {
    val time = wb.timer.time.toBigInt
    println(s"time: $time")
  }
}

object QubicTestConfig {
  val simConfig = SimConfig.addSimulatorFlag("-Wno-MULTIDRIVEN") // .withFstWave.withTimeSpec(1 ns, 1 ps)
}

// println(s"${dut.cd100mLogic.iMemTlFiber.up.bus.a.valid.toBoolean}")
object TestQubicPulse extends App {
  import QubicTestConfig._
  simConfig
    .compile{
      val dut = QubicSoc(
        qubitNum = 8,
        withVivado = false,
        withCocotb = false,
        withWhitebox = true,
        withTest = true
      )
      dut.pgs.map{_.io.simPublic()}
      dut.cgs.map{_.io.simPublic()}
      dut
    }
    .doSim { dut =>
      val driver = new Driver(dut)
      import driver._
      val rvAsm = new RvAssembler(128)
      import rvAsm._
      val qbAsm = new QubicAssembler()
      import qbAsm._

      init()

      val batchSize = 16
      val dataWidth = 16
      for (i <- 0 until 100) {
        val dt = if (i == 0) BigInt(10) else BigInt(1000)
        val batch = List.fill(batchSize)(dt)
        val batchData = riscq.pulse.PGTestPulse.concat(batch, dataWidth)
        val dataStr = batch.map { x => ByteHelper.intToBinStr(x, dataWidth) }.reduce { _ ++ _ }
        tlDriver.putFullData(0, dut.pulseOffset + i * batchSize * dataWidth / 8, ByteHelper.fromBinStr(dataStr).reverse)
      }
      cd100m.waitRisingEdge()

      val startTime = 50
      val insts = List(
        setTime(0), // 0
        carrier(1 << (16 - 5), 0), // 1
        pulse(
          puop,
          start = startTime,
          addr = 0,
          duration = 4,
          phase = (1 << (puop.phaseWidth - 7)),
          freq = 0,
          amp = (1 << (puop.ampWidth - 1)) - 1
        ), // 2
        beq(0, 0, 0) // 3
      )
      loadIMem(0, insts)

      dut.riscq_rst #= true
      tick()
      dut.riscq_rst #= false

      tick(startTime+8)
      for (i <- 0 until 6) {
        logTime()
        logPcs()
        logDac(0)
        logCarrier(0)
        println("")
        tick()
      }
    }
}



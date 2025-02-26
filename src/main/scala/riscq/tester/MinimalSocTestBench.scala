package riscq.tester.minimal

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MinimalSoc
import riscq.tester.ByteHelper
import riscq.test
import riscq.tester.RvAssembler


class Driver(dut: MinimalSoc) {
  // implicit val idAllocator = new IdAllocator(DebugId.width)
  // implicit val idCallback = new IdCallback

  val cd = dut.clockDomain
  val wb = dut.riscq.host[test.WhiteboxerPlugin].logic

  def init() = {
    cd.forkStimulus(10)
  }

  def rstUp() = {
    cd.assertReset()
  }

  def rstDown() = {
    cd.deassertReset()
  }

  def loadIMem(addr: Long, insts: Seq[String]) = {
    var writeAddr = addr
    for(inst <- insts) {
      val instInt = BigInt(inst, 2)
      dut.iMem.setBigInt(writeAddr, instInt)
      writeAddr += 1
    }
  }

  def getDMem(addr: Long): BigInt = {
    return dut.dMem.getBigInt(addr)
  }

  def tick(t: Int = 1) = {
    cd.waitRisingEdge(t)
  }

  def logRf() = {
    val n = wb.rf.mem.wordCount
    val res = (0 until n).map{x => wb.rf.mem.getBigInt(x).toString()}.toList
    println(s"rf: ${res}")
  }

  def logPc() = {
    val pc = wb.pc.output.toBigInt.toString(16)
    val valid = wb.pc.valid.toBoolean
    println(s"pc: ${pc}, v: ${valid}")
 }

  def logPcs() = {
    for(data <- wb.pcs.data) {
      println(s"pc ${data.pc.toBigInt.toString(16)}, v: ${data.valid.toBoolean}, r: ${data.ready.toBoolean}, f: ${data.forgetOne.toBoolean}, ${data.ctrlName}")
    }
  }
  
  def logExInsts() = {
    for(data <- wb.exInsts.data) {
      println(s"pc ${data.pc.toBigInt.toString(16)}, ${data.inst.toBigInt.toString(2)}, v: ${data.valid.toBoolean}, r: ${data.ready.toBoolean}, ${data.ctrlName}")
    }
  }

  def logSrc() = {
    val src1 = wb.src.src1.toBigInt
    val src1k = wb.src.src1k.toBigInt
    val src2 = wb.src.src2.toBigInt
    val src2k = wb.src.src2k.toBigInt
    println(s"src1: $src1, src1k: $src1k, src2: $src2, src2k: $src2k")
  }
}

object TestAlu extends App {
  SimConfig.compile(MinimalSoc(whiteboxer = true)).doSim{dut =>
    val driver = new Driver(dut)
    import driver._
    init()
    rstUp()

    val asm = new RvAssembler(dut.wordWidth)
    import asm._

    val insts = List(
      addi(rd = 1, rs1 = 0, imm = 123), //0
      addi(rd = 2, rs1 = 0, imm = -2), //4
      add(rd = 1, rs1 = 1, rs2 = 2), //8
      beq(rs1 = 0, rs2 = 0, imm = -4), //c
      sw(rs2 = 1, imm = 0, rs1 = 0), //10
      addi(rd = 1, rs1 = 0, imm = 123), //14
    )

    loadIMem(0, insts)

    tick()
    rstDown()

    tick(100)
    for(i <- 0 until 14) {
      // logPc()
      logPcs()
      // println(s"skid: pc: ${wb.skid.pc.toBigInt.toString(16)}, v: ${wb.skid.valid.toBoolean}")
      // logExInsts()
      logRf()
      logSrc()
      println("")
      tick()
    }
  }
}
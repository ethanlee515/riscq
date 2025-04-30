package riscq.tester.branchprediction

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MinimalSoc
import riscq.tester.ByteHelper
import riscq.test
import riscq.tester.RvAssembler

class Driver(dut: MinimalSoc) {
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
    for (inst <- insts) {
      val instInt = BigInt(inst, 2)
      dut.iMem.setBigInt(writeAddr, instInt)
      writeAddr += 1
    }
  }

  def tick(t: Int = 1) = {
    cd.waitRisingEdge(t)
  }

  def getRf(i: Int): BigInt = {
    return wb.rf.mem.getBigInt(i)
  }
}

object CountIterationCycles extends App {
  SimConfig.compile(MinimalSoc(whiteboxer = true)).doSim { dut =>
    val driver = new Driver(dut)
    import driver._
    val asm = new RvAssembler(dut.wordWidth)
    import asm._

    val insts = List(
      addi(3, 0, 3), // i = 3
      addi(4, 0, 50), // s = 50
      // do {
      add(4, 4, 3), // s = s + i
      addi(3, 3, -1), // i = i - 1
      bne(3, 0, -8), // } while (i != 0)
      addi(5, 0, 1), // done flag
      beq(0, 0, 0)
    )

    init()
    rstUp()
    loadIMem(0, insts)
    tick()
    rstDown()

    var ticks = 0
    val fuel = 500
    val x4_values = List(50, 53, 55, 56)
    for (x4_value <- x4_values) {
      var reached = false
      while (!reached && ticks < fuel) {
        val x4 = getRf(4)
        if (x4 == x4_value) {
          reached = true
          println(f"reached x4 = ${x4_value} at PC = ${ticks}")
        } else {
          tick()
          ticks += 1
        }
      }
    }

    var done = false
    while(ticks < fuel && !done) {
      val x5 = getRf(5)
      if(x5 != 0) {
        done = true
        println(f"done at PC = ${ticks}")
      } else {
        tick()
        ticks += 1
      }
    }
  }
}

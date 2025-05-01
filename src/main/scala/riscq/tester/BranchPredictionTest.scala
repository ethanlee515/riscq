package riscq.tester.branchprediction

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import riscq.soc.MinimalSoc
import riscq.soc.BranchPredictSoc
import riscq.tester.ByteHelper
import riscq.test
import riscq.tester.RvAssembler
import riscq.execute.BtbBranchPlugin
import riscq.fetch.BtbFetchPlugin
import riscq.fetch.BtbParams

class Driver(dut: BranchPredictSoc) {
  val cd = dut.clockDomain
  val wb = dut.riscq.host[test.RegReaderPlugin].logic
  val btb = dut.riscq.host[BtbFetchPlugin].logic.branch_targets

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

/* MinimalSoc test outputs:
 * reached x4 = 50 at time = 9
 * reached x4 = 53 at time = 11
 * reached x4 = 55 at time = 19
 * reached x4 = 56 at time = 27
 * done at PC = 31
*/

object CountIterationCycles extends App {
  SimConfig.compile(BranchPredictSoc(whiteboxer = true)).doSim { dut =>
    val driver = new Driver(dut)
    import driver._
    val asm = new RvAssembler(dut.wordWidth)
    import asm._

    val insts = List(
      addi(3, 0, 5), // i = 5
      addi(4, 0, 3), // s = 3
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
    for(i <- 0 until BtbParams.num_entries) {
      btb.setBigInt(i, 0)
    }
    tick()
    rstDown()

    var ticks = 0
    val fuel = 500
    val x4_values = List(3, 8, 12, 15, 17, 18)
    for (x4_value <- x4_values) {
      var reached = false
      while (!reached && ticks < fuel) {
        val x4 = getRf(4)
        if (x4 == x4_value) {
          reached = true
          println(f"reached x4 = ${x4_value} at time = ${ticks}")
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
        println(f"done at time = ${ticks}")
      } else {
        tick()
        ticks += 1
      }
    }

    if(ticks >= fuel) {
      println("out of fuel")
    }

    for(i <- 0 until 10) {
      println(f"btb($i) = ${btb.getBigInt(i)}")
    }
  }
}

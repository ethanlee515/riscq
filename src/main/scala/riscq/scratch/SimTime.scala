package riscq.scratch

import spinal.core._
import spinal.core.sim._
import spinal.lib._

case class MyCounter() extends Component {
  val counter = Reg(UInt(10 bits)) init 512

  val wd = 14
  val bs = 8
  val width = wd * bs
  val depth = 1024
  val mem = Mem(Bits(width bits), wordCount = depth)

  val io = new Bundle {
    val wr = new Bundle {
      val addr = in UInt(log2Up(depth) bits)
      val data = in Bits(width bits)
      val en = in Bool()
    }
    val rst = Bool()
    val dac = new Bundle {
      val data = out(Vec.fill(bs)(UInt(wd bits)))
    }
  }

  
  counter := counter + 1
  // when(rst) {
  //   counter := 0
  // }

  // when

}

object Test extends App {
  SimConfig.compile(MyCounter()).doSim{ dut =>
    dut.clockDomain.forkStimulus(10)
    for(i <- 0 to 16) {
      println(dut.counter.toInt)
      // sleep(1)
      dut.clockDomain.waitActiveEdge(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitActiveEdge(10)
      // sleep(1)
    }
  }
}

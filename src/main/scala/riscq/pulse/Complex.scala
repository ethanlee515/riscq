package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.misc.pipeline._

case class Complex(width: Int) extends Bundle {
  val r = AFix.S(1 exp, width bits)
  val i = AFix.S(1 exp, width bits)

  def assignTruncated(that: Complex) = {
    r := that.r.truncated
    i := that.i.truncated
  }
  def assignSaturated(that: Complex) = {
    r := that.r.saturated
    i := that.i.saturated
  }
}

case class ComplexMul(width: Int) extends Component {
  // addAttribute("DONT_TOUCH", "TRUE")
  val delay = 6
  val io = new Bundle {
    val c0 = in port Complex(width)
    val c1 = in port Complex(width)
    val c = out port Complex(width)
  }
  val inType = HardType(SInt(width bits))
  val addType = HardType(SInt(width + 1 bits))
  val mulType = HardType(SInt(width + width + 1 bits))

  val stages = Array.fill(7)(Node())
  class StageArea(at: Int) extends NodeMirror(stages(at))
  val links = (stages, stages.tail).zipped.map{ case (s0, s1) => StageLink(s0, s1)}
  val XR, YR, XI, YI = Payload(inType())
  val ADDCOMMON, ADDR, ADDI = Payload(addType()) 
  val COMMON, MULTR, MULTI = Payload(mulType())
  val COMMONR, COMMONI = Payload(mulType())
  val COSOUT, SINOUT = Payload(mulType())

  val stage0 = new StageArea(0) {
    XR := io.c0.r.asSInt
    YR := io.c1.r.asSInt
    XI := io.c0.i.asSInt
    YI := io.c1.i.asSInt
  }

  val stage1 = new StageArea(1) {
    ADDCOMMON := XR -^ XI
  }
  val stage2 = new StageArea(2) {
    COMMON := ADDCOMMON * YI // (XR*YI - XI*YI)
  }
  val stage3 = new StageArea(3) {
    ADDR := YR -^ YI
    ADDI := YR +^ YI
  }
  val stage4 = new StageArea(4) {
    COMMONR := COMMON
    COMMONI := COMMON
    MULTR := ADDR * XR // (YR*XR - YI*XR)
    MULTI := ADDI * XI // (YR*XI + YI*XI)
  }
  val stage5 = new StageArea(5) {
    COSOUT := MULTR + COMMONR // (XR*YR - XI*YI)
    SINOUT := MULTI + COMMONI // (XR*YI + YR*XI)
  }
  val stage6 = new StageArea(6) {
    io.c.r.assignFromBits((COSOUT.asBits)(width - 2, width bits))
    io.c.i.assignFromBits((SINOUT.asBits)(width - 2, width bits))
  }

  Builder(links)
}

object TestCosSinAdd extends App {
  SimConfig.compile {
    val dut = ComplexMul(16)
    dut
  }.doSim {dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    dut.io.c0.r #= 0.707
    dut.io.c0.i #= 0.707
    dut.io.c1.r #= 0
    dut.io.c1.i #= 1

    for(i <- 0 to 10) {
      sleep(1)
      println(s"${i}, ${dut.io.c.r.toDouble}, ${dut.io.c.i.toDouble},")
      cd.waitSampling()
    }
  }
}

object ComplexBatch {
  def apply(batchSize: Int, dataWidth: Int) = Vec.fill(batchSize)(Complex(dataWidth))
}


object GenComplexMul extends App {
  SpinalVerilog(ComplexMul(16))
}
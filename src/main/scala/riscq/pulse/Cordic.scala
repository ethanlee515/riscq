package riscq.pulse

import spinal.core._
import spinal.lib
import spinal.lib._
import spinal.lib.misc.pipeline._
import scala.math.max
import scala.math.Pi
import scala.math
import scala.math.pow
import scala.math.sqrt
import spinal.lib.eda.bench.Rtl

object CordicConstant {
  def gain(nStage: Int): Double = ((0 until nStage).map(x => pow(2.0, -x)).map(x => sqrt(1 + x * x)).reduce(_ * _))
  def atan(nStage: Int): Seq[Double] = (0 until nStage).map(x => math.atan(pow(2.0, -x)) / Pi).toSeq
}

case class CordicParam(
  xyWidth: Int,
  zWidth: Int,
  correctGain: Boolean = true,
) {
  // 1 exp to allow 1.0
  val xyInType = HardType(AFix.S(1 exp, xyWidth bits))
  val xyOutType = HardType(AFix.S(1 exp, xyWidth bits))
  val zIoType = HardType(AFix.S(0 exp, zWidth bits))
  // val iterWidth = max(xyWidth, zWidth) + log2Up(max(xyWidth, zWidth)) + 2
  val iterWidth = max(xyWidth, zWidth) + 2
  val xyIterType = HardType(AFix.S(1 exp, iterWidth bits))
  val zIterType = HardType(AFix.S(0 exp, iterWidth bits))
  val nStage = max(xyWidth, zWidth)
  val latency = nStage + 1
}

case class CordicInData(p: CordicParam) extends Bundle {
  val x = p.xyInType()
  val y = p.xyInType()
  val z = p.zIoType()
}

case class CordicOutData(p: CordicParam) extends Bundle {
  val x = p.xyOutType()
  val y = p.xyOutType()
  val z = p.zIoType()
}

// input: x = c cos(a), y = c sin(a), z = b, -1 <= x < 1, -1 <= y < 1, -1 <= z < 1
// output: x = c cos(a + pi * b), y = c cos (a + pi * b), z = 0
case class Cordic(p: CordicParam) extends Component {

  val io = new Bundle {
    val cmd = slave Flow(CordicInData(p))
    val rsp = master Flow(CordicOutData(p))
  }
  
  // val stages = (for(i <- 0 until p.nStage) yield new Node()).toSeq
  // val links = (for((up, down) <- (stages, stages.tail).zipped) yield new StageLink(up, down)).toSeq
  case class IterData() extends Bundle {
    val x = p.xyIterType()
    val y = p.xyIterType()
    val z = p.zIterType()
  }
  val data = List.fill(p.nStage+1)(Reg(Flow(IterData())))
  data.foreach(_.valid.init(False))
  val head = data.head
  head.valid := io.cmd.valid
  val half = p.zIoType()
  half := 0.5
  val zabs = io.cmd.z.isNegative().mux(-io.cmd.z, io.cmd.z) // AFix negation bug
  val xpos = zabs < half
  val ypos = io.cmd.z.isPositive()
  // xpos ypos 0 < z < 0.5 -> compute directly
  // xneg ypos 0.5 < z < 1 -> compute cos(a + 0.5pi + pi((z - 0.5))) 
  // xpos yneg -0.5 < z < 0 -> compute directly
  // xneg yneg -1 < z < -0.5 -> compute cos(a - 0.5pi + pi((z + 0.5))) 
  when(io.cmd.fire) {
    head.x := xpos.mux(io.cmd.x, ypos.mux(-io.cmd.y, io.cmd.y)).truncated
    head.y := xpos.mux(io.cmd.y, ypos.mux(io.cmd.x, -io.cmd.x)).truncated
    head.z := xpos.mux(io.cmd.z, ypos.mux(io.cmd.z-half, io.cmd.z+half)).truncated
  }

  val alpha = CordicConstant.atan(p.nStage).map{ x =>
    val a = p.zIterType()
    a := x
    a
  }
  for(i <- 0 until p.nStage) {
    val zpos = data(i).z.isPositive()
    data(i+1).valid := data(i).valid
    val shiftX = p.xyIterType()
    shiftX := (data(i).x >> i).rounded
    val shiftY = p.xyIterType()
    shiftY := (data(i).y >> i).rounded
    data(i+1).x := zpos.mux(data(i).x - shiftY, data(i).x + (shiftY)).truncated
    data(i+1).y := zpos.mux(data(i).y + shiftX, data(i).y - shiftX).truncated
    data(i+1).z := zpos.mux(data(i).z - alpha(i), data(i).z + alpha(i)).truncated
  }
  val last = data.last
  io.rsp.valid := last.valid
  io.rsp.z := last.z.truncated
  
  if(p.correctGain) {
    var gain = CordicConstant.gain(p.nStage)
    val gainCor = p.xyIterType()
    gainCor := 1 / gain
    val xCor = gainCor * last.x
    val yCor = gainCor * last.y
    io.rsp.x := xCor.truncated
    io.rsp.y := yCor.truncated
  } else {
    io.rsp.x := last.x.truncated
    io.rsp.y := last.y.truncated
  }
}

object CordicBench extends App {
    val p = CordicParam(xyWidth = 16, zWidth = 16, correctGain = true)
    // SpinalVerilog{
      // val cordic = Cordic(p)
      // Rtl.ffIo(cordic)
      // Rtl.xorOutputs(cordic)
    //   cordic
    // }
    SpinalVerilog{Cordic(p)}
}

object AdderTest extends App {
  val width = 8
  SpinalVerilog{ new Component {
      val a = in(UInt(width bits))
      val b = in(UInt(width bits))
      val c = out(UInt()) 
      c := a + b
    }
  }
}


object CordicGenTest extends App {
  SpinalVerilog {
    Cordic(CordicParam(xyWidth = 16, zWidth = 16, correctGain = true))
  }
}
object CordicTest extends App {
    import scala.math._
    import spinal.core.sim._

    def test(xyWidth: Int, zWidth: Int, correctGain: Boolean) = {
      val p = CordicParam(xyWidth = xyWidth, zWidth = zWidth, correctGain = correctGain)
      SimConfig.compile{
        val dut = Cordic(p)
        dut.head.simPublic()
        dut
      }.doSim { dut =>
        val clock = dut.clockDomain
        clock.forkStimulus(10) // clock.waitSampling() = sleep(10)
        clock.waitRisingEdge(10)
        dut.io.cmd.x #= 1.0
        dut.io.cmd.y #= 0
        dut.io.cmd.z #= 0
        dut.io.cmd.valid #= false
        clock.assertReset()
        clock.waitRisingEdge(10)
        clock.deassertReset()
        clock.waitRisingEdge(10)

        val inputs = -1.0 until 1.0 by 0.1
        val inputThread = fork {
          for(input <- inputs) {
            dut.io.cmd.z #= input
            dut.io.cmd.valid #= true
            clock.waitSampling()
            sleep(1)
          }
        }

        val outputThread = fork {
          clock.waitSampling(p.nStage+1)
          for(input <- inputs) {
            sleep(1) // wait a little to let the reg update
            var outputX = cos(input * Pi)
            var outputY = sin(input * Pi)
            if(correctGain == false) {
              val gain = CordicConstant.gain(p.nStage)
              outputX *= gain
              outputY *= gain
            }
            println(s"x: $outputX, ${dut.io.rsp.x.toBigDecimal}, y: $outputY, ${dut.io.rsp.y.toBigDecimal}, ${dut.io.rsp.valid.toBoolean}")
            val delta = 1e-3
            clock.waitSampling()
          }
        }

        inputThread.join()
        outputThread.join()
      }
    }


    val xyWidth = 16
    val zWidth = 10

    // with gaincor
    println("correctGain = true")
    test(xyWidth, zWidth, true)

    // without gaincor
    println("correctGain = false")
    test(xyWidth, zWidth, false)
}

object AFixMuxBug extends App {
  case class AFMuxBug() extends Component {
    val input = in(AFix.S(3 exp, 10 bits))
    val inputbits = out(Bits(input.bitWidth+1 bits))
    inputbits := (-input.asBits.asSInt.resize(inputbits.getBitsWidth)).asBits
    val output0 = out(cloneOf(input))
    val output = out(AFix(512, -512, -6 exp))
    val outputbits = out(Bits(output.bitWidth bits))
    outputbits := output.asBits
    output0 := (-input).truncated
    output := -input
    println(s"${input}")
    println(s"${output0}")
    println(s"${output}")
  }

  import spinal.core.sim._
  SimConfig.compile {
    val dut = AFMuxBug()
    dut
  }.doSim { dut =>
    dut.input #= -1
    sleep(10)
    println(s"input: ${dut.input.toBigDecimal}")
    print(s"inputbits: ")
    dut.inputbits.toBooleans.reverse.map(x => print(s"${(x == true).toInt}"))
    println("")
    print(s"outputbits: ")
    dut.outputbits.toBooleans.reverse.map(x => print(s"${(x == true).toInt}"))
    println("")
    println(s"output0: ${dut.output0.toBigDecimal}")
    println(s"output: ${dut.output.toBigDecimal}")
  }
}
package riscq.pulse

import spinal.core._
import spinal.lib
import spinal.lib._
import spinal.lib.misc.pipeline._
import scala.math.Pi
import scala.math
import scala.math.pow
import scala.math.sqrt
import spinal.lib.eda.bench.Rtl

object CordicConstant {
  def gain(nStage: Int): Double = ((0 until nStage).map(x => pow(2.0, -x)).map(x => sqrt(1 + x * x)).reduce(_ * _))
  def atan(nStage: Int): Seq[Double] = (0 until nStage).map(x => math.atan(pow(2.0, -x)) / Pi).toSeq
}

// input: x = c cos(a), y = c sin(a), z = b, -1 <= x < 1, -1 <= y < 1, -1 <= z < 1
// output: x = c cos(a + pi * b), y = c cos (a + pi * b), z = 0
case class Cordic(xyWidth: Int, zWidth: Int, correctGain: Boolean = true, bufIn: Boolean = true) extends Component {
  val nStage = zWidth
  val latency = nStage + bufIn.toInt + correctGain.toInt * 5

  val ioXyType = HardType(AFix.S(0 exp, xyWidth bit))
  val ioZType = HardType(AFix.S(0 exp, zWidth bit))
  val ioType = HardType(new Bundle {
      val x = ioXyType()
      val y = ioXyType()
      val z = ioZType()
  })
  val io = new Bundle {
    val cmd = slave Flow(ioType())
    val rsp = master Flow(ioType())
  }


  // val stages = (for(i <- 0 until p.nStage) yield new Node()).toSeq
  // val links = (for((up, down) <- (stages, stages.tail).zipped) yield new StageLink(up, down)).toSeq
  val iterWidth = xyWidth + 1
  val iterType = HardType(SInt(iterWidth bit))
  val zType = HardType(SInt(zWidth bit))
  case class IterData() extends Bundle {
    val x = iterType()
    val y = iterType()
    val z = zType()
  }

  val stage = List.fill(nStage)(Reg(Flow(IterData())))
  val inData = Flow(ioType())
  if(bufIn) {
    inData.assignAllByName(RegNext(io.cmd))
  } else {
    inData.assignAllByName(io.cmd)
  }

  val zSInt = inData.z.asSInt
  val shiftPi = zSInt(zSInt.getBitsWidth - 1) ^ zSInt(zSInt.getBitsWidth - 2)

  // xpos ypos 0 < z < 0.5 -> compute directly
  // xneg ypos 0.5 < z < 1 -> compute cos(a + 0.5pi + pi((z - 0.5))) 
  // xpos yneg -0.5 < z < 0 -> compute directly
  // xneg yneg -1 < z < -0.5 -> compute cos(a - 0.5pi + pi((z + 0.5))) 
  val head = stage.head
  head.valid := inData.valid

  head.x := shiftPi.mux(-inData.x.asSInt.resize(iterWidth), inData.x.asSInt)
  head.y := shiftPi.mux(-inData.y.asSInt.resize(iterWidth), inData.y.asSInt)
  head.z := shiftPi.mux(((~zSInt.msb) ## zSInt(zSInt.getBitsWidth - 2 downto 0)).asSInt, zSInt)

  val alpha = CordicConstant.atan(nStage).map{ x =>
    val a = zType()
    a := math.round(x * (1 << (zWidth - 1))).toInt
    a
  }

  for(i <- 0 until nStage - 1) {
    val zNeg = stage(i).z.sign
    stage(i+1).valid := stage(i).valid
    val shiftX = stage(i).x >> i
    val shiftY = stage(i).y >> i
    stage(i+1).x := zNeg.mux(stage(i).x + (shiftY), stage(i).x - shiftY)
    stage(i+1).y := zNeg.mux(stage(i).y - shiftX, stage(i).y + shiftX)
    stage(i+1).z := zNeg.mux(stage(i).z + alpha(i), stage(i).z - alpha(i))
  }
  val last = stage.last
  
  if(correctGain) {
    // var gain = CordicConstant.gain(nStage)
    // val gainCor = iterType()
    // gainCor := math.round((1 / gain) * (1 << (iterWidth - 1))).toInt
    // val xCor = gainCor * last.x
    // val yCor = gainCor * last.y
    // io.rsp.x := xCor(xCor)
    // io.rsp.y := yCor
    def correctXy(data: SInt): SInt = {
      val cor = Vec.fill(5)(Reg(SInt(xyWidth + 1 bit)))
      cor(0) := (data |>> 1) + (data |>> 3)
      cor(1) := (data |>> 6) + (data |>> 9)
      cor(2) := (data |>> 12) - (data |>> 14)
      cor(3) := cor(2)
      cor(4) := cor(0) - cor(1)
      val res = cor(4) - cor(3)
      return res
    }
    val corX = RegNext(correctXy(last.x).sat(1))
    val corY = RegNext(correctXy(last.y).sat(1))
    // val corX = correctXy(last.x)(0, xyWidth bit)
    // val corY = correctXy(last.y)(0, xyWidth bit)
    val outReg = Reg(Flow(ioType()))
    outReg.x := corX
    outReg.y := corY
    outReg.z := Delay(last.z, 3)
    outReg.valid := Delay(last.valid, 3)
    io.rsp.x := outReg.x
    io.rsp.y := outReg.y
    io.rsp.z := outReg.z
    io.rsp.valid := outReg.valid
  } else {
    io.rsp.x := last.x.resized
    io.rsp.y := last.y.resized
    io.rsp.z := last.z
    io.rsp.valid := last.valid
  }
}

object CordicTest extends App {
    import scala.math._
    import spinal.core.sim._

    def test(xyWidth: Int, zWidth: Int, correctGain: Boolean) = {
      // def doubleToSInt(w: Int, d: Double): Int = {
      //   return math.round(d * (1 << w - 1)).toInt
      // }
      SimConfig.compile{
        val dut = Cordic(xyWidth, zWidth, correctGain)
        dut.head.simPublic()
        dut.last.simPublic
        dut
      }.doSim { dut =>
        val clock = dut.clockDomain
        clock.forkStimulus(10) // clock.waitSampling() = sleep(10)
        clock.waitRisingEdge(10)
        dut.io.cmd.x #= dut.io.cmd.x.maxValue
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
          clock.waitSampling(dut.nStage)
          if(correctGain) clock.waitSampling(4)
          for(input <- inputs) {
            sleep(1) // wait a little to let the reg update
            var expectX = cos(input * Pi)
            var expectY = sin(input * Pi)
            if(correctGain == false) {
              val gain = CordicConstant.gain(dut.nStage)
              expectX *= gain
              expectY *= gain
            }            
            val outputX = dut.io.rsp.x.toBigDecimal
            val outputY = dut.io.rsp.y.toBigDecimal
            println(s"x: $expectX, ${outputX}, y: $expectY, ${outputY}, ${dut.io.rsp.valid.toBoolean}, diff: ${(expectX - outputX) * 1000}")
// , input: $input, testY: ${dut.testY.toBigInt.toString(2)}, corYL: ${dut.corY.toBigInt.toString(2)}, last: ${dut.last.y.toInt.toDouble / (1 << (xyWidth - 1))}, ${dut.last.y.toBigInt.toString(2)}, ${dut.last.y.getBitsWidth}
            val delta = 1e-3
            clock.waitSampling()
          }
        }

        inputThread.join()
        outputThread.join()
      }
    }


    val xyWidth = 16
    val zWidth = 16

    // with gaincor
    println("correctGain = true")
    test(xyWidth, zWidth, true)

    // without gaincor
    // println("correctGain = false")
    // test(xyWidth, zWidth, false)
}

object CordicLatencyTest extends App {
    import scala.math._
    import spinal.core.sim._

    val xyWidth = 16
    val zWidth = 16
    val correctGain = true

    def doubleToSInt(w: Int, d: Double): Int = {
      return math.round(d * (1 << w - 1)).toInt
    }
    SimConfig.compile{
      val dut = Cordic(xyWidth, zWidth, correctGain)
      dut.head.simPublic()
      dut.last.simPublic
      dut
    }.doSim { dut =>
      val clock = dut.clockDomain
      clock.forkStimulus(10) // clock.waitSampling() = sleep(10)
      clock.waitRisingEdge(10)
      dut.io.cmd.x #= dut.io.cmd.x.maxValue
      dut.io.cmd.y #= 0
      dut.io.cmd.z #= 0
      dut.io.cmd.valid #= false
      clock.assertReset()
      clock.waitRisingEdge(10)
      clock.deassertReset()
      clock.waitRisingEdge(10)

      dut.io.cmd.z #= 0.5
      dut.io.cmd.valid #= true
      for(i <- 0 until 25) {
        println(s"latency: $i, ${dut.io.rsp.valid.toBoolean}, ${dut.io.rsp.x.toBigDecimal}")
        clock.waitRisingEdge()
      }
    }
}
package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.fsm._
// import riscq.pulse.PGTest.batchSize

import scala.math

case class ReadoutResult(width: Int) extends Bundle {
  val r = SInt(width bits)
  val i = SInt(width bits)
}

case class ReadoutAccumulator(batchSize: Int, inWidth: Int, outWidth: Int, timeWidth: Int) extends Component {
  val io = new Bundle {
    // val en = in Bool()
    // val valid = out Bool()
    val adc = in port CarrierBundle(batchSize, inWidth)
    val carrier = in port CarrierBundle(batchSize, inWidth)
    // val accR = out port SInt(outWidth bits)
    // val accI = out port SInt(outWidth bits)
    val cmd = slave port Flow(UInt(timeWidth bits))
    val rsp = master port Flow(ReadoutResult(outWidth))
    val demodData = master port Flow(Vec.fill(batchSize)(Complex(inWidth)))
  }

  val compMulDelay = 3
  val timer = Reg(UInt(timeWidth bits)) init 0
  // val accBufferR = (for(i <- 0 until batchSize) yield List.fill(batchSize - i)(Reg(SInt(outWidth bits)))).toList
  // val accBufferI = (for(i <- 0 until batchSize) yield List.fill(batchSize - i)(Reg(SInt(outWidth bits)))).toList
  val result = Reg(ReadoutResult(outWidth))
  when(io.cmd.fire){
    timer := io.cmd.payload
    result.r := S(0)
    result.i := S(0)
  }

  val timerGtZero = timer > 0
  when(timerGtZero) {
    timer := timer - 1
  }

  val accBuffer = (for(i <- 0 until batchSize) yield List.fill(batchSize - i)(Reg(ReadoutResult(outWidth)))).toList
  // val accValid = List.fill(batchSize + compMulDelay - 1)(Reg(Bool()) init False)
  // accValid(0) := timer > 0
  // (accValid, accValid.tail).zipped.foreach{(i, o) => o := i}

  val busy = Reg(Bool()) init False
  busy := timerGtZero
  busy.addAttribute("MAX_FANOUT", 16)

  io.rsp.valid := !busy
  when(busy){
    result.r := result.r + accBuffer.last(0).r
    result.i := result.i + accBuffer.last(0).i
  }

  io.rsp.payload := result
  // io.rsp.valid := timer === 0
  // when(timer =/= 0){
  //   timer := timer - 1
  //   result.r := result.r + accBuffer.last(0).r
  //   result.i := result.i + accBuffer.last(0).i
  // }

  val compMul = List.fill(batchSize)(ComplexMul(inWidth))
  for(i <- 0 until batchSize){
    compMul(i).io.c0 := io.adc(i)
    compMul(i).io.c1 := io.carrier(i)
    accBuffer(0)(i).r := compMul(i).io.c.r.asSInt.resized
    accBuffer(0)(i).i := compMul(i).io.c.i.asSInt.resized
  }
  for(i <- 1 until batchSize){
    accBuffer(i)(0).r := accBuffer(i - 1)(0).r + accBuffer(i - 1)(1).r
    accBuffer(i)(0).i := accBuffer(i - 1)(0).i + accBuffer(i - 1)(1).i
    for(j <- 1 until batchSize - i){
      accBuffer(i)(j).r := accBuffer(i - 1)(j + 1).r
      accBuffer(i)(j).i := accBuffer(i - 1)(j + 1).i
    }
  }

  for((cm, dm) <- (compMul zip io.demodData.payload)) {
    dm := cm.io.c
  }
  io.demodData.valid := busy
}

object ReadoutAccumulatorTest extends App {
  val batchSize = 4
  SimConfig.compile{
    val dut = ReadoutAccumulator(batchSize, 16, 32, 32)
    dut.compMul.map{_.io.c.simPublic}
    dut.accBuffer.map{_.map{_.simPublic}}
    dut.timer.simPublic
    dut.result.simPublic
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    
    val input = fork {
      var time = 0
      val freq = 1 / 16.0
      val phaseAdc = 0
      while(true) {
        for(i <- 0 until batchSize) {
          val cr = math.cos((time + i) * freq)
          val ci = math.sin((time + i) * freq)
          val ar = math.cos((time + i) * freq + phaseAdc)
          val ai = -math.sin((time + i) * freq + phaseAdc)
          dut.io.carrier(i).r #= cr
          dut.io.carrier(i).i #= ci
          dut.io.adc(i).r #= ar
          dut.io.adc(i).i #= ai
        }
        time += batchSize
        cd.waitSampling()
      }
    }

    dut.io.cmd.valid #= false
    cd.waitSampling(100)
    dut.io.cmd.valid #= true
    dut.io.cmd.payload #= 4
    cd.waitSampling()
    dut.io.cmd.valid #= false
    for(i <- 0 until 30){
      println(s"${dut.io.rsp.valid.toBoolean}, ${dut.io.rsp.r.toBigInt}, ${dut.io.rsp.i.toBigInt}")
      println(s"compMul: ${dut.compMul.map(_.io.c.r.toDouble)}")
      println(s"accR: ${dut.accBuffer.last.map(_.r.toBigInt)}")
      println(s"timer: ${dut.timer.toBigInt}")
      // println(s"result: ${dut.io.rsp.payload.r.toBigInt},${dut.io.rsp.payload.i.toBigInt}")
      println(s"result: ${dut.result.r.toBigInt},${dut.result.i.toBigInt}")
      println("")
      cd.waitSampling()
    }
    simSuccess()
    
  }
}
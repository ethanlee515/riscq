package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.fsm._
import spinal.lib.misc.pipeline._
// import riscq.pulse.PGTest.batchSize

import scala.math
import spinal.lib.eda.bench.Rtl
import riscq.misc.XilinxRfsocTarget
import spinal.lib.eda.bench.Bench

case class AddTree(batchSize: Int, inWidth: Int, outWidth: Int) extends Component {
  val input = in port Vec.fill(batchSize)(SInt(inWidth bit))
  val sum = out port SInt(outWidth bit)

  val log2BatchSize = log2Up(batchSize)
  val bufferSize = (1 << (log2BatchSize + 1)) - 1
  val buffer = List.fill(bufferSize)(Reg(SInt(outWidth bit)))
  val firstInputIdx = bufferSize / 2
  for(i <- 0 until batchSize) {
    buffer(firstInputIdx + i) := input(i).resized
  }
  for(i <- 0 until firstInputIdx) {
    if(i * 2 + 2 < firstInputIdx + batchSize) {
      buffer(i) := buffer(i * 2 + 1) + buffer(i * 2 + 2)
    } else if (i * 2 + 1 < firstInputIdx + batchSize) {
      buffer(i) := buffer(i * 2 + 1)
    } else {
      buffer(i) := 0
    }
  }

  sum := buffer(0)
}

object TestAddTree extends App {
  val batchSize = 5
  SimConfig.compile{
    val dut = AddTree(batchSize = batchSize, inWidth = 16, outWidth = 27)
    dut
  }.doSim{dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)

    for(i <- 0 until batchSize){
      dut.input(i) #= 1
    }

    for(i <- 0 until 10){
      println(s"${dut.sum.toBigInt}")
      cd.waitRisingEdge()
    }
  }
}

case class ReadoutComparator(refWidth: Int, readoutWidth: Int) extends Component {
  val io = new Bundle {
    val refR = in port SInt(refWidth bit)
    val refI = in port SInt(refWidth bit)
    val readoutR = in port SInt(readoutWidth bit)
    val readoutI = in port SInt(readoutWidth bit)
    val res = out port Bool() // = 1 iff refR * readoutR + refI * readoutI < 0
  }

  val input, mult, add, output = Node()
  val REFR, REFI = Payload(SInt(refWidth bit))
  val READOUTR, READOUTI = Payload(SInt(readoutWidth bit))
  val MULTR, MULTI, SUM = Payload(SInt(refWidth + readoutWidth bit))

  val inLogic = new input.Area {
    REFR := io.refR
    REFI := io.refI
    READOUTR := io.readoutR
    READOUTI := io.readoutI
  }

  val multLogic = new mult.Area {
    MULTR := REFR * READOUTR
    MULTI := REFI * READOUTI
  }

  val addLogic = new add.Area {
    SUM := MULTR + MULTI
  }

  val outputLogic = new output.Area {
    io.res := SUM.sign
  }

  val connectors = List(StageLink(input, mult), StageLink(mult, add), StageLink(add, output))
  Builder(connectors)
}


object BenchReadoutComparator extends App {
  val rtl = Rtl(SpinalVerilog(
    ReadoutComparator(16, 27)
  ))
  Bench(List(rtl), XilinxRfsocTarget(), "./bench/")
}

case class ReadoutDecoder(batchSize: Int, inWidth: Int, accWidth: Int, durWidth: Int, timeWidth: Int) extends Component {
  val io = new Bundle {
    val time = in port UInt(timeWidth bit)
    val startTime = in port UInt(timeWidth bit)
    val adc = in port ComplexBatch(batchSize, inWidth)
    val carrier = in port ComplexBatch(batchSize, inWidth)
    val dur = slave port Flow(UInt(durWidth bits))
    val refR = slave port Flow(SInt(inWidth bit))
    val refI = slave port Flow(SInt(inWidth bit))
    val res = master port Flow(Bool())
    val demodData = master port Flow(Vec.fill(batchSize)(Complex(inWidth)))
  }
  val resValid = Reg(Bool()) init False
  io.res.valid := resValid

  val timer = Reg(UInt(durWidth bit))

  val shiftedTime = RegNext(io.time + 4)
  val dur = Reg(io.dur)
  dur.valid init False
  val startTime = Reg(io.startTime)
  val start = RegNext(shiftedTime >= startTime)
  when(io.dur.fire) {
    dur := io.dur
    startTime := io.startTime
    resValid := False
  }
  val fire = start && dur.valid
  when(fire){
    dur.valid := False
    timer := dur.payload
  }

  val compMul = List.fill(batchSize)(ComplexMul(inWidth))
  (io.demodData.payload zip compMul).foreach{case (dataOut, dataIn) => 
    dataOut := dataIn.io.c
  }
  io.demodData.valid := False

  val addTreeR = AddTree(batchSize, inWidth, accWidth)
  val addTreeI = AddTree(batchSize, inWidth, accWidth)
  for(i <- 0 until batchSize){
    compMul(i).io.c0 := io.adc(i)
    compMul(i).io.c1 := io.carrier(i)
    addTreeR.input(i) := compMul(i).io.c.r.asSInt.resized
    addTreeI.input(i) := compMul(i).io.c.i.asSInt.resized
  }
  val sumR = Reg(SInt(accWidth bit))
  val sumI = Reg(SInt(accWidth bit))
  when(fire){
    sumR := S(0)
    sumI := S(0)
  }

  val refR = RegNextWhen(io.refR.payload, io.refR.valid)
  val refI = RegNextWhen(io.refI.payload, io.refI.valid)
  val cmp = ReadoutComparator(refWidth = inWidth, readoutWidth = accWidth)
  cmp.io.readoutI := sumI
  cmp.io.readoutR := sumR
  cmp.io.refI := refI
  cmp.io.refR := refR
  io.res.payload := cmp.io.res

  val fsm = new StateMachine {
    val idle = makeInstantEntry()
    idle.whenIsActive {
      when(fire) {
        goto(waitSampling)
      }
    }
    val waitSampling = new State {
      whenIsActive {
        timer := timer - 1
        sumR := sumR + addTreeR.sum
        sumI := sumI + addTreeI.sum
        io.demodData.valid := True
        when(timer === 0) {
          goto(waitCmp)
        }
      }
    }
    val waitCmp = new StateDelay(cyclesCount = 3) {
      whenCompleted{
        resValid := True
        exit()
      }
    }
  }
}

object BenchReadoutDecoder extends App {
  val rtl = Rtl(SpinalVerilog(
    ReadoutDecoder(batchSize = 4, inWidth = 16, accWidth = 27, durWidth = 12, timeWidth = 32)
  ))
  Bench(List(rtl), XilinxRfsocTarget(FMax = 1000 MHz), "./bench/")
}

object ReadoutDecoderTest extends App {
  val batchSize = 4
  SimConfig.compile{
    val dut = ReadoutDecoder(
      batchSize = batchSize,
      inWidth = 16,
      accWidth = 27,
      durWidth = 12,
      timeWidth = 32,
    )
    dut.fsm.stateReg.simPublic()
    dut.dur.simPublic()
    dut.fire.simPublic()
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    
    dut.io.refR.valid #= false
    dut.io.refI.valid #= false
    dut.io.dur.valid #= false
    cd.assertReset()
    cd.waitRisingEdge(10)
    cd.deassertReset()

    var time = 0
    val input = fork {
      val freq = 1 / 16.0
      val phaseAdc = 0
      while(true) {
        for(i <- 0 until batchSize) {
          val cr = math.cos((time * batchSize + i) * freq)
          val ci = math.sin((time * batchSize + i) * freq)
          val ar = math.cos((time * batchSize + i) * freq + phaseAdc)
          val ai = -math.sin((time * batchSize + i) * freq + phaseAdc)

          dut.io.carrier(i).r #= cr / 2
          dut.io.carrier(i).i #= ci / 2
          dut.io.adc(i).r #= ar / 2
          dut.io.adc(i).i #= ai / 2
        }
        dut.io.time #= time
        time += 1
        cd.waitRisingEdge()
      }
    }


    dut.io.refR.payload #= -7
    dut.io.refI.payload #= -7
    dut.io.refR.valid #= true
    dut.io.refI.valid #= true

    cd.waitRisingEdge(10)

    time = 0
    dut.io.dur.valid #= true
    dut.io.dur.payload #= 4
    dut.io.startTime #= 10

    cd.waitRisingEdge()
    dut.io.dur.valid #= false
    for(i <- 0 until 20){
      println(s"$time res: ${dut.io.res.payload.toBoolean}, valid: ${dut.io.res.valid.toBoolean}, state: ${dut.fsm.stateReg.toBigInt}")
      // println(s"rsp valid: ${dut.acc.io.rsp.valid.toBoolean}")
      println("")
      cd.waitRisingEdge()
    }
    simSuccess()
  }
}
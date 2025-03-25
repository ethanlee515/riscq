package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.fsm._
import scala.math

// output carrier batch: amp * exp(i * (time * freq * k + phase)), k = 0, ..., batchSize - 1
case class CarrierGeneratorWithAmp(
  batchSize: Int,
  dataWidth: Int,
  timeWidth: Int
) extends Component {
  val cosSin = Cordic(xyWidth = dataWidth, zWidth = dataWidth)
  val ampLatency = cosSin.latency + 7
  val phaseLatency = cosSin.latency + 8

  val io = new Bundle {
    val amp = slave port Flow(AFix.S(0 exp, dataWidth bit))
    val phase = slave port Flow(AFix.S(0 exp, dataWidth bit))
    val freq = slave port Flow(AFix.S(0 exp, dataWidth bit))
    val freqPhases = slave port Flow(ComplexBatch(batchSize, dataWidth))
    val time = in port UInt(timeWidth bit)
    val carrier = out port ComplexBatch(batchSize, dataWidth)
  }

  val phase = RegNextWhen(io.phase.payload, io.phase.valid)
  val amp = RegNextWhen(io.amp.payload, io.amp.valid)
  val freq = RegNextWhen(io.freq.payload, io.freq.valid)
  val freqPhases = RegNextWhen(io.freqPhases.payload, io.freqPhases.valid)
  val gPhase = Reg(phase) // time * batchSize * freq + phase
  assert(batchSize == 16 || batchSize == 4)
  val batchSizeLog2 = log2Up(batchSize)
  val batchTime = Reg(AFix.S(dataWidth - 1 exp, dataWidth bits))
  batchTime.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  batchTime := (io.time << batchSizeLog2)(0, dataWidth bits).asSInt
  val timePhase = RegNext(freq * batchTime)
  val gPhaseRaw = timePhase + phase
  gPhase := gPhaseRaw.truncated

  cosSin.io.cmd.x := amp
  cosSin.io.cmd.y := cosSin.io.cmd.y.getZero
  cosSin.io.cmd.z := gPhase

  val compMul = List.fill(batchSize)(ComplexMul(dataWidth))
  val cosSinBuffer = Reg(compMul(0).io.c0)
  cosSinBuffer.r := cosSin.io.rsp.x
  cosSinBuffer.i := cosSin.io.rsp.y
  cosSinBuffer.addAttribute("MAX_FANOUT", 16)

  // val outBuffer = Reg(io.carrier)
  val outBuffer = cloneOf(io.carrier)
  for(i <- 0 until batchSize) {
    compMul(i).io.c0 := cosSinBuffer
    compMul(i).io.c1 := freqPhases(i)
    outBuffer(i) := compMul(i).io.c
  }

  io.carrier := outBuffer
}

case class DemodCarrierGenerator(
  batchSize: Int,
  dataWidth: Int,
  timeWidth: Int
) extends Component {
  val io = new Bundle {
    val time = in port UInt(timeWidth bit)
    val phase = slave port Flow(AFix.S(0 exp, dataWidth bit))
    val freq = slave port Flow(AFix.S(0 exp, dataWidth bit))
    val carrier = out port ComplexBatch(batchSize, dataWidth)
  }

  val freqGen = FreqPhaseBatchGenerator(batchSize, dataWidth)
  val carrierGen = CarrierGeneratorWithAmp(batchSize, dataWidth, timeWidth)

  freqGen.io.freq.payload := io.freq.payload
  freqGen.io.freq.valid := io.freq.valid
  carrierGen.io.freqPhases << freqGen.io.phases
  carrierGen.io.freq.assignAllByName(io.freq)
  carrierGen.io.phase << io.phase
  carrierGen.io.amp.valid := True
  carrierGen.io.amp.payload := carrierGen.io.amp.payload.maxValue

  carrierGen.io.time := io.time

  io.carrier := carrierGen.io.carrier
}

object TestCarrierGenerator extends App {
  val batchSize = 16
  val dataWidth = 16
  val timeWidth = 16
  SimConfig.compile{
    val dut = DemodCarrierGenerator(batchSize, dataWidth, timeWidth)
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    dut.io.phase.valid #= false
    dut.io.freq.valid #= false
    cd.waitSampling()
    cd.assertReset()
    cd.waitRisingEdge(10)
    cd.deassertReset()
    cd.waitRisingEdge(10)

    val timer = fork {
      var time = 0
      while(true) {
        dut.io.time #= time
        time += 1
        cd.waitRisingEdge()
      }
    }

    val freq = 1 / 64.0
    dut.io.phase.valid #= true
    dut.io.phase.payload #= 0.5
    dut.io.freq.valid #= true
    dut.io.freq.payload #= freq
    cd.waitRisingEdge()
    dut.io.phase.valid #= false
    dut.io.freq.valid #= false

    for(i <- 0 until 60) {
      println(s"${dut.io.time.toBigInt}")
      println(s"carrier: ${dut.io.carrier.map{_.r.toDouble}.toList} \n")
      cd.waitRisingEdge()
    }
    // cd.waitSampling(100)
    // for(i <- 0 until 100) {
    //   println(s"${dut.io.rsp.payload.map{_.r.toDouble}}")
    //   cd.waitSampling()
    // }
    simSuccess()
  }
}

object TestCarrierGeneratorWithAmp extends App {
  val batchSize = 16
  val dataWidth = 16
  val timeWidth = 16
  SpinalVerilog(CarrierGeneratorWithAmp(batchSize, dataWidth, timeWidth))
  SimConfig.compile{
    val dut = CarrierGeneratorWithAmp(batchSize, dataWidth, timeWidth)
    dut.gPhaseRaw.simPublic()
    dut.gPhase.simPublic()
    dut.freqPhases.simPublic()
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    dut.io.amp.valid #= false
    dut.io.phase.valid #= false
    dut.io.freq.valid #= false
    dut.io.freqPhases.valid #= false
    cd.waitSampling()
    cd.assertReset()
    cd.waitRisingEdge(10)
    cd.deassertReset()
    cd.waitRisingEdge(10)

    val timer = fork {
      var time = 0
      while(true) {
        dut.io.time #= time
        time += 1
        cd.waitRisingEdge()
      }
    }

    val freq = 1 / 64.0
    dut.io.amp.valid #= true
    dut.io.amp.payload #= dut.io.amp.payload.maxValue
    dut.io.phase.valid #= true
    dut.io.phase.payload #= 0
    dut.io.freq.valid #= true
    dut.io.freq.payload #= freq
    dut.io.freqPhases.valid #= true
    for(i <- 0 until batchSize) {
      dut.io.freqPhases.payload(i).r #= math.min(math.cos(i * freq * math.Pi), dut.io.freqPhases.payload(i).r.maxValue.toDouble)
      dut.io.freqPhases.payload(i).i #= math.min(math.sin(i * freq * math.Pi), dut.io.freqPhases.payload(i).r.maxValue.toDouble)
    }
    cd.waitRisingEdge()
    dut.io.amp.valid #= false
    dut.io.phase.valid #= false
    dut.io.freq.valid #= false
    dut.io.freqPhases.valid #= false

    for(i <- 0 until 60) {
      println(s"${dut.io.time.toBigInt}")
      println(s"cossinRaw: ${dut.gPhaseRaw.toDouble}")
      println(s"cossin: ${dut.gPhase.toDouble}")
      println(s"${dut.freqPhases.map(_.r.toDouble)}")
      println(s"carrier: ${dut.io.carrier.map{_.r.toDouble}.toList} \n")
      cd.waitSampling()
    }
    simSuccess()
  }
}

object TestCarrierGeneratorWithAmpLatency extends App {
  val batchSize = 16
  val dataWidth = 16
  val timeWidth = 16
  SpinalVerilog(CarrierGeneratorWithAmp(batchSize, dataWidth, timeWidth))
  SimConfig.compile{
    val dut = CarrierGeneratorWithAmp(batchSize, dataWidth, timeWidth)
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    dut.io.amp.valid #= false
    dut.io.phase.valid #= false
    dut.io.freq.valid #= false
    dut.io.freqPhases.valid #= false
    cd.waitSampling()
    cd.assertReset()
    cd.waitRisingEdge(10)
    cd.deassertReset()
    cd.waitRisingEdge(10)

    val timer = fork {
      var time = 0
      while(true) {
        dut.io.time #= time
        time += 1
        cd.waitRisingEdge()
      }
    }

    val freq = 1.0 / 8
    dut.io.amp.valid #= true
    dut.io.amp.payload #= dut.io.amp.payload.maxValue
    dut.io.phase.valid #= true
    dut.io.phase.payload #= 0
    dut.io.freq.valid #= true
    dut.io.freq.payload #= freq
    dut.io.freqPhases.valid #= true
    for(i <- 0 until batchSize) {
      dut.io.freqPhases.payload(i).r #= math.min(math.cos(i * freq * math.Pi), dut.io.freqPhases.payload(i).r.maxValue.toDouble)
      dut.io.freqPhases.payload(i).i #= math.min(math.sin(i * freq * math.Pi), dut.io.freqPhases.payload(i).r.maxValue.toDouble)
    }
    cd.waitRisingEdge()
    dut.io.amp.valid #= false
    dut.io.phase.valid #= false
    dut.io.freq.valid #= false
    dut.io.freqPhases.valid #= false
    cd.waitRisingEdge(100)
    dut.io.amp.valid #= true
    dut.io.amp.payload #= 0
    // dut.io.phase.valid #= true
    // dut.io.phase.payload #= 0.5

    for(i <- 0 until 40) {
      sleep(3)
      println(s"time: $i")
      println(s"carrier: ${dut.io.carrier.map{_.r.toDouble}.toList} \n")
      cd.waitSampling()
    }
    simSuccess()
  }
}
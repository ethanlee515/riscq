package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.fsm._
import scala.math
import riscq.tester.ByteHelper

case class PulseGenerator(
  batchSize: Int,
  dataWidth: Int,
  addrWidth: Int,
  timeWidth: Int,
  queueDepth: Int = 2,
  durWidth: Int = 16,
  memLatency: Int = 2,
  timeInOffset: Int = 0, // real_time - io.time
) extends Component {
  val batchWidth = batchSize * dataWidth

  val io = new Bundle {
    val time = in port UInt(timeWidth bits) // the real time

    val startTime = in port UInt(timeWidth bit) // to control timed queue

    val amp = slave port Flow(AFix.S(0 exp, dataWidth bit)) // to carrier generator
    val freq = slave port Flow(AFix.S(0 exp, dataWidth bit)) // to carrier generator
    val phase = slave port Flow(AFix.S(0 exp, dataWidth bit)) // to carrier generator
    val addr = slave port Flow(UInt(addrWidth bit)) // to pulse mem
    val dur = slave port Flow(UInt(durWidth bit)) // pulse duration
    val memPort = master port MemReadPort(Bits(batchWidth bits), addressWidth = addrWidth)// to pulse mem

    val pulse = master port Flow(ComplexBatch(batchSize, dataWidth)) // to dac
  }

  val startTime = io.startTime

  val phaseGen = FreqPhaseBatchGenerator(batchSize, dataWidth)
  val cg = CarrierGeneratorWithAmp(batchSize, dataWidth, timeWidth)
  val pmReader = PulseMemReader(batchSize, dataWidth, addrWidth, memLatency)
  val envMult = EnvelopeMultiplier(batchSize, dataWidth)

  pmReader.io.memPort <> io.memPort

  envMult.io.carrier := cg.io.carrier
  envMult.io.env := pmReader.io.env


  // !!!!!!!!!!!!!!!!! flow to stream
  // freq has to be set in advance
  phaseGen.io.freq.assignSomeByName(io.freq)
  cg.io.freqPhases << phaseGen.io.phases
  cg.io.freq << io.freq

  cg.io.time := io.time

  val timeQueueLatency = 1
  def shiftedTime(shift: Int): UInt = {
    RegNext(io.time + timeInOffset + timeQueueLatency + shift + 1)
    // RegNext(time) is 1 earlier than time
  }

  // addr
  // startTime = 100
  // addrLatency = 3 + 2 = 5
  // shiftedTime = RegNext(io.time + 5 + 2) = io.time + 6
  // pop time: io.time + 6 === startTime + 1 => io.time = 95
  val pulseBufLatency = 1

  val phaseLatency = cg.phaseLatency + envMult.latency + pulseBufLatency
  val phaseRefTime = shiftedTime(phaseLatency)
  val phaseQueue = TimedQueue(cg.io.phase.payload, queueDepth, timeWidth)
  phaseQueue.io.time := phaseRefTime
  phaseQueue.io.push.valid := io.phase.valid
  phaseQueue.io.push.payload.data := io.phase.payload
  phaseQueue.io.push.payload.startTime := startTime
  cg.io.phase << phaseQueue.io.pop

  val ampLatency = cg.ampLatency + envMult.latency + pulseBufLatency
  val ampRefTime = shiftedTime(ampLatency)
  val ampQueue = TimedQueue(cg.io.amp.payload, queueDepth, timeWidth)
  ampQueue.io.time := ampRefTime
  ampQueue.io.push.valid := io.amp.valid
  ampQueue.io.push.payload.data := io.amp.payload
  ampQueue.io.push.payload.startTime := startTime
  cg.io.amp << ampQueue.io.pop

  val addrLatency = pmReader.latency + envMult.latency + pulseBufLatency
  val addrRefTime = shiftedTime(addrLatency)
  val addrQueue = TimedQueue(pmReader.io.addr.payload, queueDepth, timeWidth)
  addrQueue.io.time := addrRefTime
  addrQueue.io.push.valid := io.addr.valid
  addrQueue.io.push.payload.data := io.addr.payload
  addrQueue.io.push.payload.startTime := startTime
  pmReader.io.addr << addrQueue.io.pop


  val durLatency = 3 // queue -> timer -> resValid -> pulseBuf
  val durRefTime = shiftedTime(durLatency)
  val durQueue = TimedQueue(io.dur.payload, queueDepth, timeWidth)
  durQueue.io.time := durRefTime
  durQueue.io.push.valid := io.dur.valid
  durQueue.io.push.payload.data := io.dur.payload
  durQueue.io.push.payload.startTime := startTime

  val timer = Reg(UInt(durWidth bits)) init 0 // for pulse duration
  val timerGtZero = timer > 0
  when(timerGtZero) {
    timer := timer - U(1)
  }
  when(durQueue.io.pop.fire) {
    timer := durQueue.io.pop.payload
  }

  val resValid = RegNext(timerGtZero)
  resValid.addAttribute("MAX_FANOUT", "16")
  io.pulse.valid := resValid

  val pulseBuf = Reg(io.pulse.payload)
  pulseBuf := resValid.mux(envMult.io.pulse, pulseBuf.getZero)
  io.pulse.payload := pulseBuf
}

object TestPulseGenerator extends App {
  val batchSize = 16
  val dataWidth = 16
  val addrWidth = 12
  val timeWidth = 32
  SimConfig.compile{
    val dut = PulseGenerator(
      batchSize,
      dataWidth,
      addrWidth,
      timeWidth,
      queueDepth = 3
    )
    dut.phaseGen.io.simPublic()
    dut.cg.io.simPublic()
    dut.cg.amp.simPublic()
    dut.envMult.io.simPublic()
    dut.pmReader.io.simPublic()
    dut.ampQueue.io.simPublic()
    dut.phaseQueue.io.simPublic()
    dut.addrQueue.io.simPublic()
    dut.durQueue.io.simPublic()
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    cd.assertReset()
    dut.io.amp.valid #= false
    dut.io.freq.valid #= false
    dut.io.phase.valid #= false
    dut.io.addr.valid #= false
    dut.io.dur.valid #= false

    cd.waitRisingEdge(100)
    cd.deassertReset()
    cd.waitRisingEdge(100)

    dut.io.time #= 0
    cd.waitRisingEdge()

    dut.io.amp.valid #= true
    dut.io.freq.valid #= true
    dut.io.phase.valid #= true
    dut.io.addr.valid #= true
    dut.io.dur.valid #= true


    // dut.io.amp.payload #= 0
    val freq = 1.0 / 8
    // val freq = 0
    dut.io.startTime #= 60
    dut.io.amp.payload #= dut.io.amp.payload.maxValue / 2
    dut.io.freq.payload #= freq
    dut.io.phase.payload #= 0
    dut.io.addr.payload #= 0
    dut.io.dur.payload #= 0
    cd.waitRisingEdge()

    dut.io.amp.valid #= false
    dut.io.freq.valid #= false
    dut.io.phase.valid #= false
    dut.io.addr.valid #= false
    dut.io.dur.valid #= false
    cd.waitRisingEdge()

    val memLogic = fork {
      var addr = 0
      var rsp1 = 0
      var rsp2 = 0
      while(true) {
        rsp2 = rsp1
        rsp1 = if (addr > 200) ((1 << 15) - 1) else (1 << 13)
        // addr = dut.io.memPort.cmd.payload.toInt
        sleep(1)
        addr = dut.pmReader.io.memPort.cmd.payload.toInt
        val rsp2Str = ByteHelper.intToBinStr(rsp2, 16)
        // val rsp2Str = ByteHelper.intToBinStr((1 << 15) - 1, 16)
        val rsp2Bytes = ByteHelper.fromBinStr(rsp2Str * 16).reverse
        dut.io.memPort.rsp #= rsp2Bytes

        // println(s"$time $addr, $rsp1, $rsp2")
        // println(s"dutio addr: ${dut.io.memPort.cmd.payload.toBigInt}")
        // println(s"pmReader addr: ${dut.pmReader.io.memPort.cmd.payload.toBigInt}")
        cd.waitRisingEdge()
      }
    }

    dut.io.amp.valid #= true
    dut.io.phase.valid #= true
    dut.io.addr.valid #= true
    dut.io.dur.valid #= true

    dut.io.startTime #= 100
    dut.io.amp.payload #= dut.io.amp.payload.maxValue
    dut.io.phase.payload #= 0.5
    dut.io.addr.payload #= 1000
    dut.io.dur.payload #= 3

    cd.waitRisingEdge()

    dut.io.amp.valid #= false
    dut.io.freq.valid #= false
    dut.io.phase.valid #= false
    dut.io.addr.valid #= false
    dut.io.dur.valid #= false

    dut.io.dur.payload #= 3
    dut.io.startTime #= 104
    dut.io.dur.valid #= true

    cd.waitRisingEdge()
    dut.io.dur.valid #= false

    println(s"${dut.io.time.toBigInt}")

    var time = 0
    val timeLogic = fork {
      while(true) {
        dut.io.time #= time
        cd.waitRisingEdge()
        time += 1
      }
    }

    val waitStart = 90
    cd.waitRisingEdge(waitStart)
    for(i <- 0 until 20) {
      sleep(3)
      println(s"time: $time v: ${dut.io.pulse.valid.toBoolean}")
      println(s"pulse: ${dut.io.pulse.payload.map{_.r.toDouble}}")
      // println(s"envMult: env: ${dut.envMult.io.env.map{_.toBigInt}}")
      println(s"envMult: carrier: ${dut.envMult.io.carrier.map{_.r.toDouble}}")
      println(s"envMult: pulse: ${dut.envMult.io.pulse.map{_.r.toDouble}}")
      // println(s"pm addr in: ${dut.pmReader.io.addr.payload.toBigInt} ${dut.pmReader.io.addr.valid.toBoolean}")
      // println(s"pm addr out: ${dut.pmReader.io.memPort.cmd.payload.toBigInt}")
      // println(s"pm env: ${dut.pmReader.io.env.map{_.toBigInt}}")
      // println(s"carrier: ${dut.cg.io.carrier.map{_.r.toDouble}}")
      // println(s"env: ${dut.pmReader.io.env.map{_.toBigInt.toString(2)}}")
      // println(s"env: ${dut.pmReader.io.memPort.rsp.toBigInt.toString(2)}")
      // println(s"amp: ${dut.cg.io.amp.payload.toDouble}, ${dut.cg.io.amp.valid.toBoolean}, ${dut.cg.amp.toDouble}")
      // println(s"ampQueue: ${dut.ampQueue.io.pop.payload.toDouble}, ${dut.ampQueue.io.pop.valid.toBoolean}")
      // println(s"phaseQueue: ${dut.phaseQueue.io.pop.payload.toDouble}, ${dut.phaseQueue.io.pop.valid.toBoolean}")
      // println(s"durQueue: ${dut.durQueue.io.pop.payload.toBigInt}, ${dut.durQueue.io.pop.valid.toBoolean}")
      // println(s"addrQueue: ${dut.addrQueue.io.pop.payload.toBigInt}, ${dut.addrQueue.io.pop.valid.toBoolean}")
      // println(s"phase gen: ${dut.phaseGen.io.phases.payload.map{_.r.toDouble}}")
      println("")
      cd.waitRisingEdge()
    }

    simSuccess()
  }
}
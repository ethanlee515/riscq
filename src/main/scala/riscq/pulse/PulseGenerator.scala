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

    // val ampRefTime = in port UInt(timeWidth bits) 
    // val freqRefTime = in port UInt(timeWidth bits) 
    // val phaseRefTime = in port UInt(timeWidth bits) 
    // val addrRefTime = in port UInt(timeWidth bits)
    // val durRefTime = in port UInt(timeWidth bits) 

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

  val pulseBufLatency = 1

  def shiftedTime(shift: Int): UInt = {
    RegNext(io.time + shift + 2)
    // RegNext(io.time + shift) is 1 later than io.time + shift
    // if we want things at startTime, we need to set time in tq to startTime - 1, or equivalently, timeRef = io.time + 1
  }

  // addr
  // startTime = 100
  // addrLatency = 3 + 2 = 5
  // shiftedTime = RegNext(io.time + 5 + 2) = io.time + 6
  // pop time: io.time + 6 === startTime + 1 => io.time = 95

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

    cd.waitRisingEdge(10)
    cd.deassertReset()
    cd.waitRisingEdge(10)

    dut.io.amp.valid #= true
    dut.io.freq.valid #= true
    dut.io.phase.valid #= true
    dut.io.addr.valid #= true
    dut.io.dur.valid #= true

    // dut.io.amp.payload #= 0
    val freq = 1.0 / 8
    // val freq = 0
    dut.io.amp.payload #= dut.io.amp.payload.maxValue / 2
    dut.io.freq.payload #= freq
    dut.io.phase.payload #= 0
    dut.io.addr.payload #= 0
    dut.io.dur.payload #= 0
    dut.io.startTime #= 50
    cd.waitRisingEdge()
    dut.io.amp.valid #= false
    dut.io.freq.valid #= false
    dut.io.phase.valid #= false
    dut.io.addr.valid #= false
    dut.io.dur.valid #= false
    cd.waitRisingEdge()

    var time = 0
    val timeLogic = fork {
      while(true) {
        dut.io.time #= time
        cd.waitRisingEdge()
        time += 1
      }
    }


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

    dut.io.amp.payload #= dut.io.amp.payload.maxValue
    dut.io.phase.payload #= 0.5
    dut.io.addr.payload #= 1000
    dut.io.dur.payload #= 3
    dut.io.startTime #= 100

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

    val waitStart = 90
    cd.waitRisingEdge(waitStart)
    for(i <- 0 until 20) {
      sleep(3)
      println(s"time: $time v: ${dut.io.pulse.valid.toBoolean}")
      // println(s"pulse: ${dut.envMult.io.pulse.map{_.r.toDouble}}")
      println(s"pulse: ${dut.io.pulse.payload.map{_.r.toDouble}}")
      // println(s"envMult: env: ${dut.envMult.io.env.map{_.toBigInt}}")
      // println(s"envMult: carrier: ${dut.envMult.io.carrier.map{_.r.toDouble}}")
      println(s"envMult: pulse: ${dut.envMult.io.pulse.map{_.r.toDouble}}")
      // println(s"pm addr in: ${dut.pmReader.io.addr.payload.toBigInt} ${dut.pmReader.io.addr.valid.toBoolean}")
      // println(s"pm addr out: ${dut.pmReader.io.memPort.cmd.payload.toBigInt}")
      // println(s"pm env: ${dut.pmReader.io.env.map{_.toBigInt}}")
      // println(s"carrier: ${dut.cg.io.carrier.map{_.r.toDouble}}")
      // println(s"env: ${dut.pmReader.io.env.map{_.toBigInt.toString(2)}}")
      // println(s"env: ${dut.pmReader.io.memPort.rsp.toBigInt.toString(2)}")
      // println(s"amp: ${dut.cg.io.amp.payload.toDouble}, ${dut.cg.io.amp.valid.toBoolean}, ${dut.cg.amp.toDouble}")
      // println(s"ampQueue: ${dut.ampQueue.io.pop.payload.toDouble}, ${dut.ampQueue.io.pop.valid.toBoolean}")
      // println(s"phase gen: ${dut.phaseGen.io.phases.payload.map{_.r.toDouble}}")
      println("")
      cd.waitRisingEdge()
    }

    simSuccess()
  }
}

// case class PulseGenerator(
//   batchSize: Int,
//   dataWidth: Int,
//   addrWidth: Int,
//   durWidth: Int,
//   timeWidth: Int,
// ) extends Component {
//   val batchWidth = batchSize * dataWidth

//   val io = new Bundle {
//     val time = in port UInt(timeWidth bits) // from controller, offseted by required delay
//     val event = slave port Stream(PulseEvent(dataWidth, addrWidth, durWidth, timeWidth)) // from controller
//     val pulse = master port Flow(PulseDataBundle(batchSize, dataWidth)) // to dac
//     val memPort = master port MemReadPort(Bits(batchWidth bits), addressWidth = addrWidth)// to pulse mem
//     val phase = master port Flow(SInt(dataWidth bits)) // to carrier generator
//     val carrier = in port ComplexBatch(batchSize, dataWidth) // from carrier generator
//   }

//   val pMult = PulseMultiplier(batchSize, dataWidth)
//   val pmReader = PulseMemReader(batchSize, dataWidth, addrWidth)

//   val time_buf = RegNext(io.time)
//   KeepAttribute(time_buf)
//   val phaseLatency = 20 // carrier generator latency for phase
//   val pq = PulseQueue(
//     dataWidth,
//     addrWidth,
//     durWidth,
//     timeWidth,
//     depth = 2,
//     delay = phaseLatency + pMult.latency + 4
//   )
//   pq.io.time := time_buf
//   pq.io.push << io.event
//   val event = RegNext(pq.io.pop)

//   val phaseFlow = Reg(io.phase)
//   phaseFlow.payload := event.cmd.phase
//   phaseFlow.valid := event.valid
//   io.phase := phaseFlow // phase is critical path, so no delay.

//   val ampDelay = phaseLatency - 3
//   val ampFlow = cloneOf(pMult.io.amp)
//   ampFlow.payload := event.cmd.amp
//   ampFlow.valid := event.valid
//   val amp = Delay(ampFlow, ampDelay)
//   pMult.io.amp := amp
//   pMult.io.carrier := io.carrier
//   pMult.io.env := pmReader.io.env
//   // output pmult.io.pulse depends on duration timer

//   val addrDelay = phaseLatency - pmReader.latency
//   val addrFlow = cloneOf(pmReader.io.addr)
//   addrFlow.payload := event.cmd.addr
//   addrFlow.valid := event.valid
//   var addr = Delay(addrFlow, addrDelay)
//   pmReader.io.addr := addr
//   pmReader.io.memPort <> io.memPort

//   val timer = Reg(UInt(durWidth bits)) init 0 // for pulse duration
//   val timerGtZero = timer > 0
//   when(timerGtZero) {
//     timer := timer - U(1)
//   }
//   when(event.fire) {
//     timer := event.cmd.duration
//   }

//   val resDelay = phaseLatency + pMult.latency
//   val resValid = Delay(timerGtZero, resDelay)
//   resValid.addAttribute("MAX_FANOUT", "16")
//   io.pulse.valid := resValid

//   val pulseBuf = Reg(io.pulse.payload)
//   pulseBuf := resValid.mux(pMult.io.pulse, pulseBuf.getZero)
//   io.pulse.payload := pulseBuf
// }

// object PulseGeneratorTopTest extends App {
//   val dataWidth = 16
//   val addrWidth = 10
//   val phaseWidth = 16
//   val batchSize = 16
//   val timeWidth = 32
//   val durWidth = 12
//   SimConfig.compile{
//     val dut = PulseGeneratorTop(
//       batchSize,
//       dataWidth,
//       addrWidth,
//       durWidth,
//       timeWidth
//     )
//     dut
//   }.doSimUntilVoid { dut =>
//     val cd = dut.clockDomain
//     cd.forkStimulus(10)

//     cd.assertReset()
//     cd.waitRisingEdge(10)
//     cd.deassertReset()

//     val mem = fork {
//       var addr = BigInt(0)
//       var out = BigInt(0)
//       var outReg = BigInt(0)
//       while(true) {
//         outReg = out

//         val batch = List.fill(batchSize)(addr * (1 << 11))
//         val batchData = riscq.pulse.PGTestPulse.concat(batch, dataWidth)
//         val dataStr = batch.map { x => ByteHelper.intToBinStr(x, dataWidth) }.reduce { _ ++ _ }
//         out = BigInt(dataStr, 2)

//         addr = dut.io.memPort.cmd.payload.toInt
//         dut.io.memPort.rsp #= outReg
//         cd.waitRisingEdge()
//       }
//     }

//     dut.io.cmd.valid #= true
//     dut.io.cmd.payload.amp #= 0
//     dut.io.cmd.payload.addr #= 10
//     dut.io.cmd.payload.duration #= 0
//     dut.io.carrier.payload.foreach{c => c.r #= 0.5; c.i #= 0.5}
//     cd.waitRisingEdge(20)

//     dut.io.cmd.payload.amp #= (1 << 15 - 1)
//     dut.io.cmd.payload.addr #= 3
//     dut.io.cmd.payload.duration #= 10
//     cd.waitRisingEdge()

//     dut.io.cmd.valid #= false

//     cd.waitRisingEdge(0)
//     for(i <- 0 until 30) {
//       println(s"time: ${i+1}")
//       println(s"v: ${dut.resValid.toBoolean}")
//       println(s"timer: ${dut.timer.toBigInt}")
//       println(s"ampAReg: ${dut.ampAReg(0).toDouble * (1 << 14)}")
//       println(s"envAReg: ${dut.envDataAReg(0).toBigInt}")
//       println(s"pulse: ${dut.io.data.payload.map{c => c.r.toDouble * (1 << 14)}}")
//       cd.waitRisingEdge()
//     }
//     simSuccess()
//   }
// }
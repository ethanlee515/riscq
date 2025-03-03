package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.fsm._
import scala.math

import scala.collection.mutable
import riscq.misc.GpioFiber
import spinal.lib.bus.tilelink.fabric.RamFiber
import riscq.execute.PulseOpParam

case class PulseGeneratorSpec(
    dataWidth: Int,
    batchSize: Int,
    bufferDepth: Int,
    clockWidth: Int,
    phaseWidth: Int = 0,
    freqWidth: Int = 0,
    ampWidth: Int = 0,
    correctGain: Boolean = false
) {
  val addrWidth = log2Up(bufferDepth)
  val batchWidth = dataWidth * batchSize
}

case class PulseCmd(spec: PulseGeneratorSpec) extends Bundle {
  val addr = UInt(log2Up(spec.bufferDepth) bits)
  val duration = UInt(spec.clockWidth bits)
  val phase = SInt(spec.phaseWidth bits)
  val freq = SInt(spec.freqWidth bits)
  val amp = SInt(spec.ampWidth bits)
}

case class PulseEvent(spec: PulseGeneratorSpec) extends Bundle {
  val cmd = PulseCmd(spec)
  val start = UInt(spec.clockWidth bits)
}

object PulseDataBundle {
  def apply(spec: PulseGeneratorSpec) = Vec.fill(spec.batchSize)(Complex(spec.dataWidth))
  def apply(batchSize: Int, dataWidth: Int) = Vec.fill(batchSize)(Complex(dataWidth))
}

// latency 25
case class PulseGeneratorWithCarrierInput(spec: PulseGeneratorSpec) extends Component {
  val delay = 25
  val io = new Bundle {
    val carrier = slave port Flow(Vec.fill(spec.batchSize)(Complex(spec.freqWidth)))
    val cmd = slave port Flow(PulseCmd(spec))
    val data = master port Flow(PulseDataBundle(spec))
    val memPort = master port MemReadPort(Bits(spec.batchWidth bits), addressWidth = spec.addrWidth)
  }
  // io.data.valid := False
  val addr = Reg(UInt(log2Up(spec.bufferDepth) bits))
  val addrIncr = Reg(Bool())
  when(addrIncr) {
    addr := addr + U(1)
  }

  io.memPort.cmd.payload := addr
  io.memPort.cmd.valid := True
  val envData = Reg(Vec.fill(spec.batchSize)(SInt(spec.dataWidth bits)))
  (envData, io.memPort.rsp.subdivideIn(spec.batchSize slices)).zipped
    .foreach((data, result) => data := result.asSInt)
  val envDataAReg = RegNext(envData)

  val cosSinParam = TableAndDspParam(spec.freqWidth)
  val cosSin = TableAndDsp(cosSinParam)
  cosSin.io.cmd.valid := False
  val cosSinRsp = cosSin.io.rsp

  val phase = Reg(io.cmd.phase)
  phase.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  cosSin.io.cmd.z := phase
  // cosSin.io.cmd.z := io.cmd.phase
  val phaseC = Reg(Complex(spec.freqWidth))
  val phaseCBuf = Vec.fill(spec.batchSize)(RegNext(phaseC))
  phaseCBuf.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")

  // c: carrier
  // p: phase
  // amp: amplification
  // env: envelope
  val amp = Reg(AFix.S(0 exp, spec.freqWidth bits))
  val ampAReg = Vec.fill(spec.batchSize)(Reg(AFix.S(0 exp, spec.freqWidth bits)))
  ampAReg.foreach { _ := amp }
  ampAReg.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  val carrierMulPhase = Vec.fill(spec.batchSize)(Reg(Complex(spec.freqWidth)))
  val carrierMul = List.fill(spec.batchSize)(ComplexMul(spec.freqWidth))
  for (i <- 0 until spec.batchSize) {
    carrierMul(i).io.c0 := io.carrier.payload(i)
    carrierMul(i).io.c1 := phaseCBuf(i)
    carrierMulPhase(i) := carrierMul(i).io.c
  }
  val eaMReg = Vec.fill(spec.batchSize)(Reg(SInt(spec.freqWidth + spec.freqWidth bits)))
  for (i <- 0 until spec.batchSize) {
    eaMReg(i) := (envDataAReg(i) * ampAReg(i).asSInt)
  }
  val eaPReg = Vec.fill(spec.batchSize)(Reg(SInt(spec.freqWidth + spec.freqWidth bits)))
  eaPReg := eaMReg
  val eaARegR = Vec.fill(spec.batchSize)(Reg(SInt(spec.freqWidth bits)))
  eaARegR.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  val eaARegI = Vec.fill(spec.batchSize)(Reg(SInt(spec.freqWidth bits)))
  eaARegI.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  (eaARegR, eaPReg).zipped.foreach { case (x, y) => x := y(spec.freqWidth - 1, spec.freqWidth bits) }
  (eaARegI, eaPReg).zipped.foreach { case (x, y) => x := y(spec.freqWidth - 1, spec.freqWidth bits) }

  // KeepAttribute(carrierMulPhase_buf_buf)
  val eacMReg = Reg(PulseDataBundle(spec))
  for (i <- 0 until spec.batchSize) {
    val real = RegNext(eaARegR(i) * carrierMulPhase(i).r.asSInt)
    val imag = RegNext(eaARegI(i) * carrierMulPhase(i).i.asSInt)
    eacMReg(i).r := real(real.getWidth - spec.freqWidth - 2, spec.freqWidth bits)
    eacMReg(i).i := imag(imag.getWidth - spec.freqWidth - 2, spec.freqWidth bits)
  }
  val eacPReg = RegNext(eacMReg)

  val valid = Reg(Bool()) init False
  valid := False
  valid.addAttribute("MAX_FANOUT", "16")
  io.data.valid := valid

  val ioDataBuf = RegNext(eacPReg)
  val ioDataBufBuf = Reg(ioDataBuf)
  ioDataBufBuf := valid.mux(ioDataBuf, ioDataBufBuf.getZero)

  (io.data.payload, ioDataBufBuf).zipped.foreach { (d, c) => d := c }
  val timer = Reg(UInt(spec.clockWidth bits)) init 0

  val fsm = new StateMachine {
    val idle = makeInstantEntry() // 0
    idle.whenIsActive {
      addrIncr := False
      when(io.cmd.fire) {
        amp := io.cmd.amp
        addr := io.cmd.addr
        phase := io.cmd.phase
        timer := io.cmd.duration - 1
        goto(waitCosSin)
      }
    }
    val waitCosSin = new StateDelay(cyclesCount = cosSin.delay + 1) { // 1
      whenCompleted {
        phaseC.assignTruncated(cosSin.io.rsp)
        goto(warmMul)
      }
    }
    val warmMul = new StateDelay(cyclesCount = 2) {
      whenCompleted {
        goto(waitMul)
        addrIncr := True
      }
    }
    val waitMul = new StateDelay(cyclesCount = 9) { // 2
      whenCompleted {
        goto(running)
      }
    }
    val running = new State {
      whenIsActive {
        // ioDataBufBuf := ioDataBuf
        // io.data.valid := True
        valid := True
        timer := timer - 1
        when(timer === 0) {
          exit()
        }
      }
    }
  }

  Component.current.afterElaboration {
    fsm.stateReg.addAttribute("MAX_FANOUT", "16")
  }
}

object PulseGeneratorState extends SpinalEnum {
  val sIdle, sLoadCarrier, sLoadData, sStart = newElement()
}

object PGTestPulse {
  import scala.math
  def sinPulse(n: Int, b: Int): Seq[Seq[Boolean]] = {
    val times = (0 until n).map(i => 2 * math.Pi * i / n)
    val sins = times
      .map(t => (1 << (b - 1)) * math.sin(t) + (1 << (b - 1)))
      .map(x => x.min((1 << b) - 1))
      .map(x => x.toLong)
      .toSeq
    val binStr = sins.map(i => i.toBinaryString.reverse.padTo(b, '0'))
    val bools = binStr.map(s => s.map(c => c == '1'))
    return bools
  }
  def cosPulse(n: Int, b: Int): Seq[Seq[Boolean]] = {
    val times = (0 until n).map(i => 2 * math.Pi * i / n)
    val coss = times
      .map(t => (1 << (b - 1)) * math.cos(t) + (1 << (b - 1)))
      .map(x => x.min((1 << b) - 1))
      .map(x => x.toLong)
      .toSeq
    val binStr = coss.map(i => i.toBinaryString.reverse.padTo(b, '0'))
    val bools = binStr.map(s => s.map(c => c == '1'))
    return bools
  }
  def constPulse(c: Int, n: Int, b: Int): Seq[Seq[Boolean]] = {
    val consts = (0 until n).map(_ => c).toSeq
    val binStr = consts.map(i => i.toBinaryString.reverse.padTo(b, '0'))
    val bools = binStr.map(s => s.map(c => c == '1'))
    return bools
  }
  def concat(a: Seq[BigInt], b: Int): BigInt = {
    a.zipWithIndex.map { case (x, i) => x << (i * b) }.sum
  }
}

object PGCTest extends App {
  val dataWidth = 16
  val addrWidth = 10
  val phaseWidth = 16
  val batchSize = 16
  val pgSpec = PulseGeneratorSpec(
    dataWidth = dataWidth,
    batchSize = batchSize,
    bufferDepth = 1 << addrWidth,
    clockWidth = 32,
    phaseWidth = phaseWidth,
    freqWidth = phaseWidth,
    ampWidth = 16,
  )
  val carrierSpec = CarrierGeneratorSpec(
    batchSize = batchSize,
    carrierWidth = dataWidth,
    freqWidth = dataWidth,
    clockWidth = 32
  )

  SimConfig
    .compile {
      val dut = PulseGeneratorWithCarrierInput(pgSpec)
      dut.addr.simPublic()
      dut.envData.simPublic()
      dut.phase.simPublic()
      dut.timer.simPublic()
      dut.fsm.stateReg.simPublic()
      dut.amp.simPublic()
      dut.phaseC.simPublic()
      dut.eacMReg.simPublic()
      dut.eaARegR.simPublic()
      dut.carrierMulPhase.simPublic()
      // dut.eaPReg.foreach{_.simPublic}
      // dut.carrierMulPhase.map(_.simPublic)
      // dut.mem.mem.simPublic
      // dut.mul.foreach(_.simPublic())
      dut
    }
    .doSimUntilVoid { dut =>
      val cd = dut.clockDomain
      dut.clockDomain.forkStimulus(10)
      dut.io.cmd.valid #= false
      // dut.memPort.write #= false
      // dut.memPort.enable #= true
      dut.clockDomain.waitRisingEdge(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitRisingEdge(10)
      dut.clockDomain.deassertReset()

      val carrier = fork {
        var time = 0
        val freq = 0.1
        while (true) {
          for (i <- 0 until batchSize) {
            dut.io.carrier.payload(i).r #= math.cos((time + i) * freq)
            dut.io.carrier.payload(i).i #= math.sin((time + i) * freq)
          }
          time += batchSize
          cd.waitSampling()
        }
      }

      // dut.memPort.write #= false
      // for (i <- 0 until 100) {
      //   val concat = List.fill(batchSize)(100.toBigInt)
      //   dut.mem.mem.setBigInt(i, PGTestPulse.concat(concat, dataWidth))
      // }
      val concat0 = List.fill(batchSize)(0.toBigInt)
      dut.io.memPort.rsp #= PGTestPulse.concat(concat0, dataWidth)
      dut.io.cmd.duration #= 1
      dut.io.cmd.phase #= 0
      dut.io.cmd.valid #= true
      dut.io.cmd.amp #= 0
      cd.waitRisingEdge()
      dut.io.cmd.valid #= false
      cd.waitRisingEdge(100)

      dut.io.cmd.valid #= true
      dut.io.cmd.addr #= 0
      dut.io.cmd.duration #= 4
      dut.io.cmd.amp #= dut.io.cmd.amp.maxValue
      // dut.io.cmd.freq #= 1 << (phaseWidth - 5)
      // dut.io.cmd.freq #= 0
      // dut.io.cmd.phase #= 0
      dut.io.cmd.phase #= dut.io.cmd.phase.maxValue / 2
      dut.clockDomain.waitRisingEdge()
      dut.io.cmd.valid #= false

      fork {
        val concat100 = List.fill(batchSize)(100.toBigInt)
        val env100 = PGTestPulse.concat(concat100, dataWidth)
        val concat10 = List.fill(batchSize)(10.toBigInt)
        val env10 = PGTestPulse.concat(concat10, dataWidth)
        var rsp = env100
        while (true) {
          dut.io.memPort.rsp #= rsp
          if (dut.io.memPort.cmd.payload.toBigInt == 0) {
            rsp = env10
          } else {
            rsp = env100
          }
          cd.waitRisingEdge()
        }
        // val concat100 = List.fill(batchSize)(dut.io.cmd.amp.maxValue / 2 - 1)
      }
      // dut.clockDomain.waitSampling(16)
      for (i <- 1 until 30) {
        sleep(2)
        print(s"cycle: $i ")
        print(s"dataValid:${dut.io.data.valid.toBoolean}, ")
        println("")
        // val data = (dut.carriers.map(_.io.out.x.toBigDecimal), dut.readData.map(_.toLong)).zipped.map{case (c, d) => c * d}
        // println(s"    carrier in z: ${dut.carriers.map(_.io.in.z.toBigDecimal)}, ")
        // println(s"    carrier out x: ${dut.carriers.map(_.io.out.x.toBigDecimal)}, ")
        // println(s"    mul: ${dut.mul.map(_.toBigDecimal)}, ")
        print(s"    state: ${dut.fsm.stateReg.toBigInt}, ")
        println(s"addr: ${dut.addr.toBigInt}, timer: ${dut.timer.toBigInt}")
        // println(s"    carrier: ${dut.io.carrier.payload.map(_.r.toDouble)}, ")
        // println(s"    phase: ${dut.phase.toBigInt}, ")
        // println(s"    phaseC: ${dut.phaseC.r.toDouble}, ")
        // println(s"    phaseCV: ${dut.cosSinRsp.valid.toBoolean}, ")
        // println(s"    phaseCD: ${dut.cosSinRsp.payload.r.toDouble}, ")
        // println(s"    carrierphase: ${dut.carrierMulPhase.map{_.r.toDouble}}, ")
        println(s"    eaARegR: ${dut.eaARegR.map { _.toBigInt }}, ")
        // println(s"    eacMReg: ${dut.eacMReg.map{_.r.toDouble}}, ")
        // println(s"    amp: ${dut.amp.toDouble}, ")
        // println(s"    cpa: ${dut.cpa.map(_.toDouble)}, ")
        // println(s"    cp: ${dut.carrierMulPhase.map(_.r.toDouble)}, ")
        // println(s"    phase: ${dut.phaseC.r.toDouble}, ${dut.phaseC.i.toDouble},")
        // val t = dut.io.data.payload.map(_.toBooleans).toList
        // println(s"    output: ${t(0).toList}, ")
        println(s"    output: ${(dut.io.data.payload.map(_.r.toDouble * (1 << 14)))}, ")
        // print(s"${dut.phases.map(_.toLong)}, ")
        // print(s"timer: ${dut.timer.toBigInt}. ")
        // for(j <- 0 until batchSize) {
        //   print(s"${dut.io.data.payload(j).toBigInt}, ")
        // }
        println("")
        dut.clockDomain.waitSampling()
      }
      simSuccess()
    }
}

case class PulseQueue(puop: PulseOpParam, spec: PulseGeneratorSpec, depth: Int, delay: Int) extends Component {
  val io = new Bundle {
    val time = in UInt (puop.startWidth bits)
    val push = slave Stream (PulseEvent(spec))
    val pop = master Flow (PulseEvent(spec))
  }

  val fifo = new StreamFifo(
    dataType = PulseEvent(spec),
    depth = depth,
    withAsyncRead = true,
    forFMax = true,
    useVec = true
  )

  val delayedTime = Reg(io.time)
  // delayedTime.addAttribute("MAX_FANOUT", 8)
  delayedTime := io.time + U(delay)
  val start = RegNext(delayedTime === fifo.io.pop.start)
  // val start = (io.time + U(delay)) === fifo.io.pop.start
  fifo.io.push << io.push
  fifo.io.pop.ready := start
  io.pop.payload := fifo.io.pop.payload
  io.pop.valid := fifo.io.pop.valid && start
}

case class PulseGeneratorPort(puop: PulseOpParam, spec: PulseGeneratorSpec) extends Bundle with IMasterSlave {
  val time = UInt(puop.startWidth bits)
  val event = Stream(PulseEvent(spec))
  val data = Flow(PulseDataBundle(spec))
  val carrier = Flow(CarrierBundle(spec.batchSize, spec.dataWidth))

  def asMaster(): Unit = {
    out(time)
    master(event, carrier)
    slave(data)
  }
}

case class PulseGeneratorWithCarrierTop(puop: PulseOpParam, spec: PulseGeneratorSpec) extends Component {
  val io = slave port PulseGeneratorPort(puop, spec)
  val time_buf = Reg(io.time)
  KeepAttribute(time_buf)
  time_buf := io.time

  val pg = PulseGeneratorWithCarrierInput(spec)
  val memPort = master port cloneOf(pg.io.memPort)
  pg.io.memPort <> memPort
  io.data << pg.io.data
  pg.io.carrier << io.carrier

  val cosSinDelay = 4
  val pq = PulseQueue(puop, spec, depth = 2, delay = pg.delay + 4)
  pq.io.time := time_buf
  pq.io.push << io.event
  val event = RegNext(pq.io.pop)

  pg.io.cmd.valid := event.valid
  pg.io.cmd.addr := event.cmd.addr
  pg.io.cmd.duration := event.cmd.duration
  pg.io.cmd.phase := event.cmd.phase
  pg.io.cmd.freq := event.cmd.freq // not used in this impl
  pg.io.cmd.amp := event.cmd.amp
}

object PGCTTest extends App {
  val n = 32
  val dataWidth = 16
  val addrWidth = 10
  val phaseWidth = 16
  val batchSize = 16
  val pgSpec = PulseGeneratorSpec(
    dataWidth = dataWidth,
    batchSize = batchSize,
    bufferDepth = 1 << addrWidth,
    clockWidth = 32,
    phaseWidth = phaseWidth,
    freqWidth = phaseWidth,
    ampWidth = 16,
  )
  val puop = PulseOpParam(
    addrWidth = 12,
    startWidth = 32,
    durationWidth = 12,
    phaseWidth = 16,
    freqWidth = 16,
    ampWidth = 16
  )

  SimConfig
    .compile {
      val dut = PulseGeneratorWithCarrierTop(puop, pgSpec)
      // dut.eaPReg.foreach{_.simPublic}
      // dut.carrierMulPhase.map(_.simPublic)
      // dut.mem.mem.simPublic
      // dut.mul.foreach(_.simPublic())
      dut
    }
    .doSimUntilVoid { dut =>
      val cd = dut.clockDomain
      dut.clockDomain.forkStimulus(10)
      dut.io.event.valid #= false
      // dut.memPort.write #= false
      // dut.memPort.enable #= true
      dut.clockDomain.waitRisingEdge(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitRisingEdge(10)
      dut.clockDomain.deassertReset()

      val carrier = fork {
        var time = 0
        val freq = 0.1
        while (true) {
          for (i <- 0 until batchSize) {
            dut.io.carrier.payload(i).r #= math.cos((time + i) * freq)
            dut.io.carrier.payload(i).i #= math.sin((time + i) * freq)
          }
          time += batchSize
          dut.io.time #= time / batchSize
          cd.waitSampling()
        }
      }

      val iters = n / batchSize
      // dut.memPort.write #= false
      // for (i <- 0 until 100) {
      //   val concat = List.fill(batchSize)(100.toBigInt)
      //   dut.mem.mem.setBigInt(i, PGTestPulse.concat(concat, dataWidth))
      // }
      val concat0 = List.fill(batchSize)(0.toBigInt)
      dut.memPort.rsp #= PGTestPulse.concat(concat0, dataWidth)

      dut.io.event.valid #= true
      dut.io.event.cmd.addr #= 0
      dut.io.event.cmd.duration #= iters
      dut.io.event.cmd.amp #= dut.io.event.cmd.amp.maxValue / 2 - 1
      dut.io.event.start #= 50
      // dut.io.cmd.freq #= 1 << (phaseWidth - 5)
      // dut.io.cmd.freq #= 0
      // dut.io.cmd.phase #= 0
      dut.io.event.cmd.phase #= dut.io.event.cmd.phase.maxValue / 4
      dut.clockDomain.waitRisingEdge()
      dut.io.event.valid #= false
      // val concat100 = List.fill(batchSize)(100.toBigInt)
      val concat100 = List.fill(batchSize)(dut.io.event.cmd.amp.maxValue / 2 - 1)
      dut.memPort.rsp #= PGTestPulse.concat(concat100, dataWidth)

      while (dut.io.time.toBigInt < 48) {
        println(s"amp: ${dut.io.event.cmd.amp.toBigInt}")
        cd.waitRisingEdge()
      }
      for (i <- 0 until 10) {
        sleep(2)
        print(s"cycle: ${dut.io.time.toBigInt} ")
        print(s"dataValid:${dut.io.data.valid.toBoolean}, ")
        println("")
        // val data = (dut.carriers.map(_.io.out.x.toBigDecimal), dut.readData.map(_.toLong)).zipped.map{case (c, d) => c * d}
        // println(s"    carrier in z: ${dut.carriers.map(_.io.in.z.toBigDecimal)}, ")
        // println(s"    carrier out x: ${dut.carriers.map(_.io.out.x.toBigDecimal)}, ")
        // println(s"    mul: ${dut.mul.map(_.toBigDecimal)}, ")
        println(s"    output: ${(dut.io.data.payload.map(_.r.toDouble))}, ")
        // print(s"${dut.phases.map(_.toLong)}, ")
        // print(s"timer: ${dut.timer.toBigInt}. ")
        // for(j <- 0 until batchSize) {
        //   print(s"${dut.io.data.payload(j).toBigInt}, ")
        // }
        println("")
        dut.clockDomain.waitSampling()
      }
      simSuccess()
    }
}

object GenPG extends App {
  val dataWidth = 16
  val batchSize = 16
  val depth = 1 << 12
  val pulseSpec = PulseGeneratorSpec(
    dataWidth = dataWidth,
    batchSize = batchSize,
    bufferDepth = depth,
    clockWidth = 32,
    phaseWidth = 16,
    freqWidth = 16,
    ampWidth = 16,
  )
  SpinalConfig(
    mode = Verilog,
    targetDirectory = "./pgtest/rtl"
  ).generate(
    PulseGeneratorWithCarrierInput(pulseSpec)
  )
}

object TestFsmDelay extends App {
  SimConfig.compile{
    val dut = new Component {
      val end = out UInt(2 bit)
      end := 0
      val fsm = new StateMachine {
        val start = new State with EntryPoint {
          whenIsActive{
            end := U(1)
            goto(wt)
          }
        }
        val wt = new StateDelay(cyclesCount = 3) {
          whenIsActive{
            end := U(2)
          }
          whenCompleted{
            end := U(3)
            exit()
          }
        }
      }
    }
    dut
  }.doSim{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)

    for(i <- 0 until 10) {
      println(s"${dut.end.toBigInt}")
      cd.waitRisingEdge()
    }
  }
}
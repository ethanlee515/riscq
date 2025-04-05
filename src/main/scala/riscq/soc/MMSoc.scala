package riscq.soc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.tilelink.fabric._
import spinal.lib.bus.amba4.axi.Axi4Config
import spinal.lib.bus.amba4.axi.Axi4
import spinal.lib.bus.amba4.axi.Axi4ToTilelinkFiber
import scala.collection.mutable.ArrayBuffer
import riscq._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.core.fiber.Fiber
import spinal.lib.bus.tilelink
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.eda.bench.Rtl
import riscq.memory.DualClockRam
import riscq.misc.TileLinkMemReadWriteFiber
import spinal.lib.eda.bench.Bench
import riscq.misc.XilinxRfsocTarget
import scala.collection.mutable.LinkedHashMap
import spinal.lib.bus.misc.SingleMapping
import riscq.pulse.GenPG.batchSize
import spinal.lib.misc.PathTracer

case class DspConnectionArea(
  qubitNum: Int,
  pgs: List[pulse.PulseGeneratorWithCarrierTop], 
  pms: List[DualClockRam],
  cgs: List[pulse.CarrierGenerator], 
  rds: List[pulse.ReadoutDecoder], 
  ) extends Area {
  
  (pgs zip cgs).foreach{case (pg, cg) => pg.io.carrier := cg.io.carrier}

  (pgs zip pms).foreach {
    case (x, y) => {
      y.fastPort.enable := True
      y.fastPort.write := False
      y.fastPort.mask.setAllTo(False)
      y.fastPort.wdata.setAllTo(False)
      y.fastPort.address := x.memPort.cmd.payload
      x.memPort.rsp := RegNext(y.fastPort.rdata)
    }
  }

  for((rd, id) <- rds.zipWithIndex) {
    rd.io.carrier := cgs(2 * qubitNum + id).io.carrier.payload
  }
}

object MemMapReg {
  val pgOffset = 0x10000
  val pgStep = 0x100
  val cgOffset = 0x20000
  val cgStep = 0x100
  val rdOffset = 0x30000
  val rdStep = 0x100

  def pgBase(i: Int) = pgOffset + pgStep * i
  def pgAddr(i: Int) = pgBase(i)
  def pgAmp(i: Int) = pgBase(i) + 4
  def pgDur(i: Int) = pgBase(i) + 8
  def pgPhase(i: Int) = pgBase(i) + 12
  def pgStart(i: Int) = pgBase(i) + 16

  def cgBase(i: Int) = cgOffset + cgStep * i
  def cgFreq(i: Int) = cgBase(i)
  def cgPhase(i: Int) = cgBase(i) + 4

  def rdBase(i: Int) = rdOffset + rdStep * i
  def rdDur(i: Int) = rdBase(i)
  def rdRefR(i: Int) = rdBase(i) + 4
  def rdRefI(i: Int) = rdBase(i) + 8
  def rdRes(i: Int) = rdBase(i) + 12

  def getCHeader(qubitNum: Int) = {
    var res = ""
    for(i <- 0 until qubitNum * 2) {
      val base = pgOffset + pgStep * i
      res += s"#define PG_${i}_ADDR 0x${pgAddr(i).toHexString} \n"
      res += s"#define PG_${i}_AMP 0x${pgAmp(i).toHexString} \n"
      res += s"#define PG_${i}_DUR 0x${pgDur(i).toHexString} \n"
      res += s"#define PG_${i}_PHASE 0x${pgPhase(i).toHexString} \n"
      res += s"#define PG_${i}_START 0x${pgStart(i).toHexString} \n"
    }

    for(i <- 0 until qubitNum * 3) {
      val base = pgOffset + pgStep * i
      res += s"#define CG_${i}_FREQ 0x${cgFreq(i).toHexString} \n"
      res += s"#define CG_${i}_PHASE 0x${cgPhase(i).toHexString} \n"
    }

    for(i <- 0 until qubitNum) {
      val base = pgOffset + pgStep * i
      res += s"#define RD_${i}_DUR 0x${rdDur(i).toHexString} \n"
      res += s"#define RD_${i}_REFR 0x${rdRefR(i).toHexString} \n"
      res += s"#define RD_${i}_REFI 0x${rdRefI(i).toHexString} \n"
      res += s"#define RD_${i}_RES 0x${rdRes(i).toHexString} \n"
    }
    res
  }
}

object GenMemMapRegHeader extends App {
  println(MemMapReg.getCHeader(8))
}



case class MemMapRegFiber(pgs: List[pulse.PulseGeneratorWithCarrierTop], cgs: List[pulse.CarrierGenerator], rds: List[pulse.ReadoutDecoder]) extends Area {
  val up = Node.up()
  val allowBurst = false

  import MemMapReg._

  val logic = Fiber build new Area {
    up.m2s.supported load tilelink.SlaveFactory.getSupported(
      addressWidth = 24,
      dataWidth = 32,
      allowBurst = allowBurst,
      proposed = up.m2s.proposed
    )
    up.s2m.none()

    val factory = new tilelink.SlaveFactory(up.bus, allowBurst)

    val timeAddr = 0xBFF8
    val time = Reg(UInt(32 bit)) init 0
    time := time + U(1)
    time.simPublic()

    factory.readAndWrite(time, timeAddr)

    val timeCmpAddr = 0x4000
    val timeCmp = Reg(UInt(32 bit)) init 0
    factory.readAndWrite(timeCmp, timeCmpAddr)
    val delay = 3
    val waitTimeCmp = RegNext(time + delay < timeCmp)
    factory.onReadPrimitive(SingleMapping(timeCmpAddr + 8), haltSensitive = false, null) {
      when(waitTimeCmp) {
        factory.readHalt()
        // factory.writeHalt()
      }
    }

    val pgFactory = factory
    for((pg, id) <- pgs.zipWithIndex) {
      val pgIo = Reg(pg.io.event.payload)
      val pgValid = Reg(Bool())
      pgValid := False
      pgFactory.write(pgIo.cmd.addr, pgAddr(id))
      pgFactory.write(pgIo.cmd.amp, pgAmp(id))
      pgFactory.write(pgIo.cmd.duration, pgDur(id))
      // pgFactory.write(pgIo.cmd.freq, pgOffset + pgStep*id + 12)
      pgFactory.write(pgIo.cmd.phase, pgPhase(id))
      pgFactory.write(pgIo.start, pgStart(id))
      pgIo.cmd.freq := 0
      pgFactory.onWrite(pgStart(id)) { pgValid := True}

      val pgStream = cloneOf(pg.io.event)
      pgStream.payload := pgIo
      pgStream.valid := pgValid
      val pgPipe = StreamPipe.FULL(pgStream)
      pg.io.event <> pgPipe
      // pg.io.event.payload := pgIo
      // pg.io.event.valid := pgValid

      pg.io.time := time
    }

    val cgFactory = factory
    val cgParams = for((cg, id) <- cgs.zipWithIndex) yield new Area {
      val cgIo = Reg(cg.io.cmd.payload).simPublic()
      val cgValid = Reg(Bool())
      cgValid := False
      cgFactory.write(cgIo.freq, cgFreq(id))
      cgFactory.write(cgIo.phase, cgPhase(id))
      cgFactory.onWrite(cgPhase(id)) { cgValid := True}

      val cgStream = cloneOf(cg.io.cmd)
      cgStream.payload := cgIo
      cgStream.valid := cgValid
      val cgPipe = StreamPipe.FULL(cgStream)
      cg.io.cmd <> cgPipe

      cg.io.time := time
    }

    for((rd, id) <- rds.zipWithIndex) {
      // rd.io.cmd.valid := False
      // rd.io.cmd.payload := 0
      // rd.io.refR.valid := False
      // rd.io.refR.payload := 0
      // rd.io.refI.valid := False
      // rd.io.refI.payload := 0

      val cmdFlow = Reg(rd.io.cmd)
      rd.io.cmd := cmdFlow
      factory.driveFlow(cmdFlow, rdDur(id))

      val refRFlow = Reg(rd.io.refR)
      rd.io.refR := refRFlow
      factory.driveFlow(refRFlow, rdRefR(id))

      val refIFlow = Reg(rd.io.refI)
      rd.io.refI := refIFlow
      factory.driveFlow(refIFlow, rdRefI(id))

      factory.read(rd.io.res.payload, rdRes(id))
      factory.onReadPrimitive(SingleMapping(rdRes(id)), haltSensitive = false, null) {
        when(!rd.io.res.valid) {
          factory.readHalt()
        }
      }
    }
    
  }
}

object MemoryMapPlugins {
  val puop = execute.PulseOpParam(
    addrWidth = 12,
    startWidth = 32,
    durationWidth = 12,
    phaseWidth = 16,
    freqWidth = 16,
    ampWidth = 16
  )
  // val qubitNum = 2
  def qubitDrivePgSpec = pulse.PulseGeneratorSpec(
    dataWidth = 16,
    batchSize = 16,
    bufferDepth = 4096,
    clockWidth = 12,
    phaseWidth = 16,
    freqWidth = 16,
    ampWidth = 16
  )
  def readoutDrivePgSpec = pulse.PulseGeneratorSpec(
    dataWidth = 16,
    batchSize = 16,
    bufferDepth = 4096,
    clockWidth = 12,
    phaseWidth = 16,
    freqWidth = 16,
    ampWidth = 16
  )

  def testAdcPgSpec = pulse.PulseGeneratorSpec(
    dataWidth = 16,
    batchSize = 4,
    bufferDepth = 4096,
    clockWidth = 12,
    phaseWidth = 16,
    freqWidth = 16,
    ampWidth = 16
  )

  def qubitDriveCgSpec = pulse.CarrierGeneratorSpec(
    batchSize = 16,
    carrierWidth = 16,
    freqWidth = 16,
    clockWidth = 32
  )
  def readoutDriveCgSpec = pulse.CarrierGeneratorSpec(
    batchSize = 16,
    carrierWidth = 16,
    freqWidth = 16,
    clockWidth = 32
  )
  def readoutDemodCgSpec = pulse.CarrierGeneratorSpec(
    batchSize = 4,
    carrierWidth = 16,
    freqWidth = 16,
    clockWidth = 32
  )
  def getPlugins(qubitNum: Int) = new Area {
    val rfReadSync = false
    val pgSpecs = List.fill(qubitNum)(qubitDrivePgSpec) ++ List.fill(qubitNum)(readoutDrivePgSpec)
    val cgSpecs = List.fill(qubitNum)(qubitDriveCgSpec) ++
      List.fill(qubitNum)(readoutDriveCgSpec) ++
      List.fill(qubitNum)(readoutDemodCgSpec)

    val pcReset = 0x80000000L
    val plugins = ArrayBuffer[FiberPlugin]()
    val pp = new schedule.PipelinePlugin()
    plugins += pp
    plugins += new riscv.RiscvPlugin(xlen = 32)
    plugins += new schedule.ReschedulePlugin()
    plugins += new fetch.PcPlugin()
    plugins += new fetch.FetchCachelessPlugin(
      wordWidth = 32,
      forkAt = 0,
      joinAt = 4
    )
    // plugins += new decode.DecoderSimplePlugin(decodeAt = 0)
    plugins += new decode.DecoderPlugin(decodeAt = 0)
    plugins += new regfile.RegFilePlugin(
      spec = riscv.IntRegFile,
      physicalDepth = 32,
      preferedWritePortForInit = "",
      syncRead = rfReadSync,
      dualPortRam = false,
      maskReadDuringWrite = false
    )
    val rfReadAt = -1 - rfReadSync.toInt
    val enableBypass = true
    plugins += new execute.RegReadPlugin(syncRead = true, rfReadAt = rfReadAt, enableBypass = enableBypass)
    plugins += new execute.SrcPlugin(executeAt = 0, relaxedRs = true)
    plugins += new schedule.HazardPlugin(rfReadAt = rfReadAt, hazardAt = rfReadAt, enableBypass = enableBypass)
    plugins += new execute.WriteBackPlugin(riscv.IntRegFile, writeAt = 2)
    plugins += new execute.IntFormatPlugin()
    plugins += new execute.IntAluPlugin(executeAt = 0, formatAt = 0)
    plugins += new execute.BarrelShifterPlugin(shiftAt = 0, formatAt = 0)
    plugins += new execute.BranchPlugin()
    plugins += new execute.lsu.LsuCachelessPlugin()
    // plugins += new test.WhiteboxerPlugin()
  }
}

case class MemoryMapSoc(
    qubitNum: Int = 2,
    withWhitebox: Boolean = false,
    withVivado: Boolean = false,
    withCocotb: Boolean = false,
    withTest: Boolean = true
) extends Component {

  // default cd
  val cd500m = ClockDomain.current
  cd500m.renamePulledWires("clk500m", "rst500m")
  cd500m.readResetWire.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:reset:1.0 rst500m rst")
  cd500m.readResetWire.addAttribute("X_INTERFACE_PARAMETERS", "POLARITY ACTIVE_HIGH")
  cd500m.readClockWire.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:clock:1.0 clk500m clk")
  cd500m.readClockWire.addAttribute(
    "X_INTERFACE_PARAMETERS", "FREQ_HZ 500000000, ASSOCIATED_RESET rst500m"
  )

  val pluginsArea = MemoryMapPlugins.getPlugins(qubitNum)
  val plugins = pluginsArea.plugins
  if (withWhitebox) {
    plugins += new test.WhiteboxerPlugin()
  }


  // cd100m
  val clk100m = in Bool ()
  val rst100m = in Bool ()
  val cd100m = ClockDomain(clk100m, rst100m)
  rst100m.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:reset:1.0 rst100m rst")
  rst100m.addAttribute("X_INTERFACE_PARAMETERS", "POLARITY ACTIVE_HIGH")
  clk100m.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:clock:1.0 clk100m clk")
  clk100m.addAttribute("X_INTERFACE_PARAMETERS", "FREQ_HZ 100000000, ASSOCIATED_RESET rst100m")

  val riscq_rst = in Bool ()
  // val riscqRst = RegNext(RegNext(riscq_rst))
  val riscqRst = riscq_rst
  riscqRst.addAttribute("MAX_FANOUT", "128")

  val axiConfig = Axi4Config(
    addressWidth = 32,
    dataWidth = 32,
    idWidth = 2,
  )

  val axi = cd100m(slave(Axi4(axiConfig)))
  val tlBus = withTest generate cd100m(tlBusNode)

  val shareBus = cd100m(Node())

  // pulse mem
  val pulseMems = pluginsArea.pgSpecs.map(spec =>
    DualClockRam(
      width = spec.batchSize * spec.dataWidth,
      depth = spec.bufferDepth,
      slowCd = cd100m,
      fastCd = ClockDomain.current
    )
  )

  // cpu instruction bus

  // instruction memory
  val pcOffset     = 0x80000000L
  // val pmAxiOffset  = 0x08000000L
  // val memAxiOffset = 0x00000000L
  val pmAxiOffset  = 0x00000000L
  val memAxiOffset = 0x01000000L

  val memOutReg = true
  val mem = DualClockRam(width = 32, depth = 1024, slowCd = cd500m, fastCd = cd500m, withOutRegFast = memOutReg, withOutRegSlow = memOutReg)

  val iBusDec = Node()
  iBusDec.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)

  val dBusArb = Node()
  dBusArb.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)

  val iBus = Node.down()
  val iBusFiber = TileLinkMemReadWriteFiber(mem.slowPort, withOutReg = memOutReg)
  iBusFiber.up at 0 of iBusDec
  // iBusFiber.up.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)
  iBusDec at pcOffset of iBus
  iBusDec.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)
  plugins += new fetch.FetchCachelessTileLinkPlugin(iBus)

  val dBus = Node.down()
  val dBusFiber = TileLinkMemReadWriteFiber(mem.fastPort, withOutReg = memOutReg)
  dBusFiber.up at pcOffset of dBusArb
  dBusFiber.up.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)
  dBusArb at 0 of dBus
  plugins += new execute.lsu.LsuCachelessTileLinkPlugin(dBus)

  val cd100mLogic = new ClockingArea(cd100m) {
    // blockSize is the maximal bytes that can be transfered in a transaction, which could takes multiple bits
    // slotsCount is the number of sources
    val bridge = new Axi4ToTilelinkFiber(blockSize = 32, slotsCount = 4)
    bridge.up load axi
    shareBus at 0 of bridge.down
    if (withVivado) { riscq.misc.Axi4VivadoHelper.addInference(axi, "S_AXIS") }
    if (withCocotb) { riscq.misc.Axi4CocotbHelper.setName(axi) }
    // axi.addAttribute("X_INTERFACE_PARAMETER", "CLK_DOMAIN clk100m_clk_p")

    if (withTest) {
      shareBus at 0 of tlBus.node
    }

    // envelope memory
    val pulseMemWa = WidthAdapter()
    pulseMemWa.up at pmAxiOffset of shareBus

    val pulseMemBus = Node()
    pulseMemBus at 0 of pulseMemWa.down
    pulseMemBus.setDownConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)

    val pulseMemFibers = for (i <- 0 until qubitNum * 2) yield new Area {
      val pulseMemFiber = TileLinkMemReadWriteFiber(pulseMems(i).slowPort)
      val step = 1 << 20
      val offset = step * i
      // println(s"!!!!!! pulseoffset: ${BigInt(offset).toString(16)}")
      pulseMemFiber.up at offset of pulseMemBus
      pulseMemFiber.up.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)
    }

    iBusDec at memAxiOffset of shareBus
  }

  val riscqArea = new ResetArea(riscqRst, false) {
    val riscq = RiscQ(plugins)
  }

  val core = riscqArea.riscq

  
    // pulse generator and carrier generator
  val dspArea = new ResetArea(riscqRst, false) {
    val pgs = pluginsArea.pgSpecs.map(spec => pulse.PulseGeneratorWithCarrierTop(QubicPlugins.puop, spec))
    pgs.foreach{_.addAttribute("KEEP_HIERARCHY", "TRUE")}
    val cgs = pluginsArea.cgSpecs.map(spec => pulse.CarrierGenerator(spec))

    val readAccWidth = 27
    val rds = List.fill(qubitNum)(pulse.ReadoutDecoder(batchSize = 4, inWidth = 16, accWidth = readAccWidth, timeWidth = 12))
  }
  val pgs = dspArea.pgs
  val cgs = dspArea.cgs
  val rds = dspArea.rds

  val dspConnectionArea = DspConnectionArea(qubitNum, pgs, pulseMems, cgs, rds)

  val mmFiber = MemMapRegFiber(pgs, cgs, rds)
  mmFiber.up at 0 of dBusArb
  mmFiber.up.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)

  // dac and adc ports
  val dac = List.fill(qubitNum * 2)(master port Stream(Bits(16 * 16 bits)))
  dac.zipWithIndex.foreach { case (d, id) =>
    riscq.misc.Axi4StreamVivadoHelper.addStreamInference(d, s"DAC${id}_AXIS")
  }
  val adc = List.fill(qubitNum * 2)(slave port Stream(Bits(4 * 16 bits)))
  adc.zipWithIndex.foreach { case (d, id) =>
    riscq.misc.Axi4StreamVivadoHelper.addStreamInference(d, s"ADC${id}_AXIS")
    d.ready := True
  }

  // val rbOffset = 0x0f000000
  // val rbStep   = 0x00100000
  // val rbTlWaLogic = new ClockingArea(cd100m) {
  //   val rbTlWa = WidthAdapter()
  //   rbTlWa.up at SizeMapping(rbOffset, rbStep * 16) of shareBus
  //   rbTlWa.up.setUpConnection(a = StreamPipe.FULL, d = StreamPipe.FULL)
  // }
  // val rbArea = for(rbId <- 0 until 1) yield new Area{
  //   val readoutBuffer = DualClockRam(width = 128, depth = 1024, slowCd = cd100m, fastCd = cd500m)
  //   val rbLogic = Fiber build new ResetArea(riscqRst, false) {
  //     val addr = Reg(readoutBuffer.fastPort.address) init 0
  //     val valid = rds(rbId).io.demodData.valid
  //     valid.simPublic()
  //     when(valid) {
  //       addr := addr + 1
  //     }

  //     readoutBuffer.fastPort.enable := True
  //     readoutBuffer.fastPort.mask.setAllTo(True)
  //     readoutBuffer.fastPort.address := addr
  //     readoutBuffer.fastPort.write := valid
  //     readoutBuffer.fastPort.wdata := rds(rbId).io.demodData.payload.asBits
  //   }

  //   val rbBusLogic = new ClockingArea(cd100m) {
  //     val rbTlFiber = TileLinkMemReadWriteFiber(readoutBuffer.slowPort)
  //     rbTlFiber.up at SizeMapping(rbId * rbStep, rbStep) of rbTlWaLogic.rbTlWa.down
  //   }
  // }

  // val rbId = 0
  // val readoutBuffer = DualClockRam(width = 128, depth = 1024, slowCd = cd100m, fastCd = cd500m)
  // val rbLogic = Fiber build new ResetArea(riscqRst, false) {
  //   val addr = Reg(readoutBuffer.fastPort.address) init 0
  //   val valid = rds(rbId).io.demodData.valid
  //   valid.simPublic()
  //   when(valid) {
  //     addr := addr + 1
  //   }

  //   readoutBuffer.fastPort.enable := True
  //   readoutBuffer.fastPort.mask.setAllTo(True)
  //   readoutBuffer.fastPort.address := addr
  //   readoutBuffer.fastPort.write := valid
  //   readoutBuffer.fastPort.wdata := rds(rbId).io.demodData.payload.asBits
  // }

  // val rbBusLogic = new ClockingArea(cd100m) {
  //   val rbTlFiber = TileLinkMemReadWriteFiber(readoutBuffer.slowPort)
  //   val rbTlWa = WidthAdapter()
  //   rbTlWa.up at 0x0f000000L of shareBus
  //   rbTlFiber.up at 0 of rbTlWa.down
  // }


  val test_adc = withTest generate (in port Vec.fill(qubitNum * 2)(pulse.ComplexBatch(batchSize = 4, dataWidth = 16)))

  // pulse generator output
  for((o, pg) <- (dac zip pgs)) {
    o.payload := pg.io.data.payload.map(_.r).asBits()
    o.valid := True
  }

  // readout input

  if(!withTest) {
    for((rd, inAdc) <- (rds zip adc)) {
      (rd.io.adc zip inAdc.payload.subdivideIn(16 bits)).foreach { case(o, i) =>
        o.r.assignFromBits(i)
        o.i := o.i.getZero
      }
    }
  } else {
    (rds zip test_adc).foreach { case (outs, ins) =>
      outs.io.adc := ins
    }
  }

  Fiber build new Area {
    withTest generate tlBus.node.bus.get.simPublic()
    iBus.bus.get.simPublic()
    dBus.bus.get.simPublic()
    dBusArb.bus.get.simPublic()
    shareBus.bus.get.simPublic()

    Fiber.awaitCheck()

    // val path = PathTracer.impl(shareBus.bus.get.d.valid, tlBus.node.bus.get.d.valid)
    // println(path.report())
    // println(path.reportPaths())
    // println(path.reportNodes())

  }
  
  def tlBusNode = {
    new MasterBus(
      tilelink.M2sParameters(
        addressWidth = 32,
        dataWidth = 32,
        masters = List(
          tilelink.M2sAgent(
            name = this,
            mapping = List(
              tilelink.M2sSource(
                id = SizeMapping(0, 4),
                emits = tilelink.M2sTransfers(
                  get = tilelink.SizeRange.upTo(0x100),
                  putFull = tilelink.SizeRange.upTo(0x100),
                  putPartial = tilelink.SizeRange.upTo(0x100)
                )
              )
            )
          )
        )
      )
    )
  }
}


object GenMMSocVivado extends App {
  SpinalConfig(
    mode = Verilog,
    targetDirectory = "./build/rtl",
    romReuse = true
  ).generate(
    MemoryMapSoc(
      qubitNum = 2,
      withVivado = true,
      withCocotb = false,
      withWhitebox = false,
      withTest = false
    )
  ) 
  SpinalConfig(
    mode = Verilog,
    targetDirectory = "./build/rtl",
    romReuse = true
  ).generate(
    riscq.misc.ClockInterface()
  )
}

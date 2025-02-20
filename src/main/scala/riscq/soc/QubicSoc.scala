package riscq.soc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.tilelink.fabric._
import spinal.lib.bus.amba4.axi.Axi4Config
import spinal.lib.bus.amba4.axi.Axi4
import riscq.misc.Axi4VivadoHelper
import spinal.lib.bus.amba4.axi.Axi4ToTilelinkFiber
import scala.collection.mutable.ArrayBuffer
import riscq._
import spinal.lib.misc.plugin.FiberPlugin
import riscq.misc.TileLinkMemReadWriteFiber
import spinal.core.fiber.Fiber
import spinal.lib.bus.tilelink.M2sParameters
import spinal.lib.bus.tilelink.M2sAgent
import spinal.lib.bus.tilelink.M2sSource
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.bus.tilelink.M2sTransfers
import spinal.lib.bus.tilelink.SizeRange
import riscq.execute.DacAdcBundle
import riscq.execute.DacAdcPlugin
import riscq.misc.Axi4CocotbHelper
import spinal.lib.eda.bench.Rtl
import riscq.pulse.CarrierGeneratorSpec
import riscq.misc.TileLinkFifoFiber
import riscq.misc.Axi4StreamVivadoHelper
import riscq.misc.TileLinkPipeFiber
import riscq.memory.DualClockRam

object QubicPlugins {
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
    val pgSpecs = List.fill(qubitNum)(qubitDrivePgSpec) ++ List.fill(qubitNum)(readoutDrivePgSpec)
    val cgSpecs = List.fill(qubitNum)(qubitDriveCgSpec) ++
      List.fill(qubitNum)(readoutDriveCgSpec) ++
      List.fill(qubitNum)(readoutDemodCgSpec)
    // val pgSpecs = List.fill(qubitNum)(qubitDrivePgSpec) ++ List.fill(1)(testAdcPgSpec) ++ List.fill(1)(readoutDrivePgSpec)
    // val cgSpecs = List.fill(qubitNum)(qubitDriveCgSpec) ++
    //   List.fill(1)(readoutDemodCgSpec) ++ List.fill(1)(readoutDriveCgSpec) ++
    //   List.fill(qubitNum)(readoutDemodCgSpec)

    val pcReset = 0x80000000L
    val plugins = ArrayBuffer[FiberPlugin]()
    plugins += new riscq.misc.PipelineBuilderPlugin()
    val pp = new schedule.PipelinePlugin()
    plugins += pp
    plugins += new riscv.RiscvPlugin(xlen = 32)
    plugins += new schedule.ReschedulePlugin()
    plugins += new fetch.PcPlugin()
    plugins += new fetch.FetchCachelessPlugin(
      wordWidth = 128,
      forkAt = 0,
      joinAt = 1
    )
    // plugins += new decode.DecoderSimplePlugin(decodeAt = 0)
    plugins += new decode.DecoderPlugin(decodeAt = 0)
    plugins += new regfile.RegFilePlugin(
      spec = riscv.IntRegFile,
      physicalDepth = 32,
      preferedWritePortForInit = "",
      syncRead = true,
      dualPortRam = false,
      maskReadDuringWrite = false
    )
    val rfReadAt = -2
    val enableBypass = true
    plugins += new execute.RegReadPlugin(syncRead = true, rfReadAt = rfReadAt, enableBypass = enableBypass)
    plugins += new execute.SrcPlugin(executeAt = 0, relaxedRs = true)
    plugins += new schedule.HazardPlugin(rfReadAt = rfReadAt, hazardAt = rfReadAt, enableBypass = enableBypass)
    plugins += new execute.WriteBackPlugin(riscv.IntRegFile, writeAt = 2)
    plugins += new execute.IntFormatPlugin()
    plugins += new execute.IntAluPlugin(executeAt = 0, formatAt = 0)
    plugins += new execute.BranchPlugin()
    plugins += new execute.TimerPlugin(32)
    plugins += new execute.CarrierPlugin(cgSpecs)
    val pgp = new execute.PulseGeneratorPlugin(puop, pgSpecs)
    plugins += pgp
    plugins += new execute.DacAdcPlugin(
      dacBatchSize = 16,
      adcBatchSize = 4,
      dataWidth = 16,
      dacNum = qubitNum * 2,
      adcNum = qubitNum
    )
    plugins += new execute.ReadoutPlugin(batchSize = 4, carrierWidth = 16, num = qubitNum)
    plugins += new execute.lsu.LsuCachelessPlugin()
    // plugins += new test.WhiteboxerPlugin()
  }
}

case class QubicSoc(
    qubitNum: Int = 2,
    withAxi4: Boolean = true,
    withWhitebox: Boolean = false,
    withVivado: Boolean = false,
    withCocotb: Boolean = false,
    withTest: Boolean = true
) extends Component {

  ClockDomain.current.renamePulledWires("clk500m", "rst500m")
  ClockDomain.current.readResetWire.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:reset:1.0 rst500m rst")
  ClockDomain.current.readResetWire.addAttribute("X_INTERFACE_PARAMETERS", "POLARITY ACTIVE_HIGH")
  ClockDomain.current.readClockWire.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:clock:1.0 clk500m clk")
  ClockDomain.current.readClockWire.addAttribute(
    "X_INTERFACE_PARAMETERS",
    "FREQ_HZ 500000000, ASSOCIATED_BUSIF DAC0_AXIS:DAC1_AXIS:DAC2_AXIS:DAC3_AXIS:ADC0_AXIS:ADC1_AXIS:ADC2_AXIS:ADC3_AXIS, ASSOCIATED_RESET rst500m"
  )

  val pluginsArea = QubicPlugins.getPlugins(qubitNum)
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
  clk100m.addAttribute("X_INTERFACE_PARAMETERS", "FREQ_HZ 100000000, ASSOCIATED_BUSIF S_AXIS, ASSOCIATED_RESET rst100m")

  val riscq_rst = in Bool()
  // val riscqRst = RegNext(RegNext(riscq_rst))
  val riscqRst = BufferCC(riscq_rst)

  val axiConfig = Axi4Config(
    addressWidth = 32,
    dataWidth = 32,
    idWidth = 2
  )

  val axi = withAxi4 generate cd100m(slave(Axi4(axiConfig)))
  val tlBus = !withAxi4 generate cd100m(
    new MasterBus(
      M2sParameters(
        addressWidth = 32,
        dataWidth = 32,
        masters = List(
          M2sAgent(
            name = this,
            mapping = List(
              M2sSource(
                id = SizeMapping(0, 4),
                emits = M2sTransfers(
                  get = SizeRange.upTo(0x100),
                  putFull = SizeRange.upTo(0x100),
                  putPartial = SizeRange.upTo(0x100)
                )
              )
            )
          )
        )
      )
    )
  )
  val shareBus = cd100m(Node())

  // pulse mem
  val pulseOffset = 0
  // val pulseSpec = pluginsArea.pgp.pulseSpec
  // val pulseMems = List.fill(channelNum)(PulseMem(pulseSpec, cd100m))
  // val pulseMems = pluginsArea.pgSpecs.map(spec => PulseMem(dataBits = spec.batchSize*spec.dataWidth, bufferDepth = spec.bufferDepth, cd100m))
  val pulseMems = pluginsArea.pgSpecs.map(spec => DualClockRam(width = spec.batchSize*spec.dataWidth, depth = spec.bufferDepth, slowCd = cd100m, fastCd = ClockDomain.current))

  // cpu instruction bus

  // instruction memory for qubic
  val pcOffset = 0x80000000L
  val pcAxiOffset = 0x01000000L
  val dMemOffset = 0x08000000L
  val memBits = 128
  // val iMem = Mem(Bits(memBits bits), wordCount = 1024)
  // val iMem = IMem(128, 1024, cd100m)
  val iMem = DualClockRam(width = 128, depth = 1024, slowCd = cd100m, fastCd = ClockDomain.current)
  // val iMemTlPort = iMem.readWriteSyncPort(memBits / 8)
  // val iMemPort = iMem.readWriteSyncPort(memBits / 8)
  // val iMemTlPort = iMem.slowPort
  // val iMemPort = iMem.fastPort
  // memTlFiber.up at pcOffset of shareBus

  val dMemBits = 32
  // val dMem = Mem(Bits(dMemBits bits), wordCount = 1024)
  val dMem = DualClockRam(width = 32, depth = 1024, slowCd = cd100m, fastCd = ClockDomain.current)
  // val memDbusPort = dMem.readWriteSyncPort(dMemBits / 8, clockCrossing = true)
  // val dMem = iMem
  // val memDbusPort = iMem.readWriteSyncPort(memBits / 8)
  // val memDbusFiber = TileLinkMemReadWriteFiber(dMem.fastPort)
  // val dBus = Node.down()
  // memDbusFiber.up at 0 of dBus
  // plugins += new execute.lsu.LsuCachelessTileLinkPlugin(dBus)

  // val iBus = Node.down()
  // iMemTlFiber.up at pcOffset of iBus
  // plugins += new fetch.FetchCachelessTileLinkPlugin(iBus)

  val rbp = execute.ReadoutBufferPlugin(0)
  plugins += rbp
  val readoutBuffer = DualClockRam(width = 128, depth = 1024, slowCd = cd100m, fastCd = ClockDomain.current)
  val rbLogic = Fiber build new ResetArea(riscqRst, false) {
    val addr = Reg(readoutBuffer.fastPort.address) init 0
    val valid = rbp.logic.outData.valid
    valid.simPublic()
    when(valid) {
      addr := addr + 1
    }
    readoutBuffer.fastPort.enable := True
    readoutBuffer.fastPort.mask.setAllTo(True)
    readoutBuffer.fastPort.address := addr
    readoutBuffer.fastPort.write := valid
    readoutBuffer.fastPort.wdata := rbp.logic.outData.payload
  }
  val rbBusLogic = new ClockingArea(cd100m) {
    val rbTlFiber = TileLinkMemReadWriteFiber(readoutBuffer.slowPort)
    val rbTlWa = WidthAdapter()
    rbTlWa.up at 0x0f000000L of shareBus
    rbTlFiber.up at 0 of rbTlWa.down
  }


  val memConnects = plugins.map{
    case p: fetch.FetchCachelessPlugin => {
      new fetch.FetchCachelessBramConnectArea(p, iMem.fastPort)
    }
    case p: execute.lsu.LsuCachelessPlugin => {
      new execute.lsu.LsuCachelessBramConnectArea(p, dMem.fastPort)
    }
    case _ =>
  }

  val cd100mLogic = new ClockingArea(cd100m) {
    if (withAxi4) {
      val bridge = withAxi4 generate new Axi4ToTilelinkFiber(32, 4)
      bridge.up load axi
      shareBus at 0 of bridge.down
      if (withVivado) { Axi4VivadoHelper.addInference(axi, "S_AXIS") }
      if (withCocotb) { Axi4CocotbHelper.setName(axi) }
      // axi.addAttribute("X_INTERFACE_PARAMETER", "CLK_DOMAIN clk100m_clk_p")
    }

    if (!withAxi4) {
      shareBus at 0 of tlBus.node
      Fiber build {
        println(s"!!!! bus: ${tlBus.node.bus.get.p}")
      }
    }

    // envelope memory
    val pulseMemWa = WidthAdapter()
    pulseMemWa.up at 0 of shareBus
    // val pulseMemFifo = TileLinkFifoFiber() // to improve timing
    // pulseMemFifo.up at 0 of pulseMemWa.down
    val pulseMemPipe = TileLinkPipeFiber(StreamPipe.FULL_KEEP) // to improve timing
    pulseMemPipe.up at 0 of pulseMemWa.down

    val pulseMemFibers = for (i <- 0 until qubitNum * 2) yield new Area {
      // println(s"${pulseMems(i).axiPort}")
      val pulseMemFiber = TileLinkMemReadWriteFiber(pulseMems(i).slowPort)
      // 32 bytes * 2^10 = 32KB, addrwidth as bytes = log(32) + 12 = 17
      // why 20?
      val offset = pulseOffset + (1 << 20) * i
      println(s"!!!!!! pulseoffset: ${BigInt(offset).toString(16)}")
      // pulseMemFiber.up at offset of pulseMemFifo.down
      pulseMemFiber.up at offset of pulseMemPipe.down
      // pulseMemFiber.up at offset of shareBus
    }

    val iMemTlFiber = TileLinkMemReadWriteFiber(iMem.slowPort)
    val iMemWa = WidthAdapter()
    iMemWa.up at pcAxiOffset of shareBus
    val iMemPipe = TileLinkPipeFiber(StreamPipe.FULL_KEEP)
    iMemPipe.up at 0 of iMemWa.down
    iMemTlFiber.up at 0 of iMemPipe.down

    // val dMemTlPort = cd100m(dMem.readWriteSyncPort(dMemBits / 8, clockCrossing = true))
    val dMemPipe = TileLinkPipeFiber(StreamPipe.FULL_KEEP)
    val dMemTlFiber = TileLinkMemReadWriteFiber(dMem.slowPort)
    dMemPipe.up at dMemOffset of shareBus
    dMemTlFiber.up at 0 of dMemPipe.down
    // dMemTlFiber.up at dMemOffset of shareBus
  }
  // memTlFiber.up at 0 of cd100mLogic.iMemWa.down
  val riscqArea = new ResetArea(riscqRst, false) { 
    val riscq = RiscQ(plugins) 
  }
  val riscq = riscqArea.riscq

  val test_adc = withTest generate (in port Vec.fill(qubitNum * 2)(DacAdcBundle(batchSize = 4, dataWidth = 16)))
  // val dac = out port Vec.fill(channelNum)(DacAdcBundle(batchSize = 16, dataWidth = 16))
  val dac = List.fill(qubitNum * 2)(master port Stream(Bits(16 * 16 bits)))
  dac.zipWithIndex.foreach { case (d, id) =>
    Axi4StreamVivadoHelper.addStreamInference(d, s"DAC${id}_AXIS")
  }
  val adc = List.fill(qubitNum * 2)(slave port Stream(Bits(4 * 16 bits)))
  adc.zipWithIndex.foreach { case (d, id) =>
    Axi4StreamVivadoHelper.addStreamInference(d, s"ADC${id}_AXIS")
    d.ready := True
  }
  val pgCgArea = new ResetArea(riscqRst, false) {
    val pgs = pluginsArea.pgSpecs.map(spec => pulse.PulseGeneratorWithCarrierTop(QubicPlugins.puop, spec))
    val cgs = pluginsArea.cgSpecs.map(spec => pulse.CarrierGenerator(spec))
  }
  val pgs = pgCgArea.pgs
  val cgs = pgCgArea.cgs
  // val pgs = pluginsArea.pgSpecs.map(spec => pulse.PulseGeneratorWithCarrierTop(QubicPlugins.puop, spec))
  // val cgs = pluginsArea.cgSpecs.map(spec => pulse.CarrierGenerator(spec))
  val ioLogic = Fiber build new Area {
    plugins.foreach {
      case p: execute.PulseGeneratorPlugin => {
        (pgs zip pulseMems).foreach { case (x, y) => {
          y.fastPort.enable := True
          y.fastPort.write := False
          y.fastPort.mask.setAllTo(False)
          y.fastPort.wdata.setAllTo(False)
          y.fastPort.address := x.memPort.cmd.payload
          x.memPort.rsp := y.fastPort.rdata
          // x.memPort <> y.envPort 
        }
      }
        (pgs zip p.logic.pgPorts).foreach { case (x, y) => x.io <> y }
      }
      case p: execute.CarrierPlugin => {
        (cgs zip p.logic.cgPorts).foreach { case (x, y) => x.io <> y }
      }
      case p: execute.DacAdcPlugin => {
        // (p.logic.adc, adc).zipped.foreach{ case (outs, ins) => outs := ins}
        // (dac, p.logic.dac).zipped.foreach{ case (outs, ins) => outs := ins}
        if (!withTest) {
          (p.logic.adc, adc).zipped.foreach {
            case (outs, ins) => {
              (outs.payload, ins.payload.subdivideIn(16 bits)).zipped.foreach { case (o, i) => o.r.assignFromBits(i) }
              outs.payload.map { _.i := U(0, 16 bits) }
              outs.valid := ins.valid
            }
          }
        } else {
          (p.logic.adc, test_adc).zipped.foreach { case (outs, ins) =>
            outs.payload := ins
            outs.valid := True
          }
        }
        (dac, p.logic.dac).zipped.foreach {
          case (outs, ins) => {
            val dacIn = ins.payload.map(_.r)
            outs.payload := dacIn.asBits()
            outs.valid := ins.valid
          }
        }
      }
      case _ =>
    }
  }

  val pc = withTest generate (out port UInt(32 bits))
  val readouts = withTest generate (out port Vec.fill(qubitNum)(pulse.ReadoutResult(32)))
  val globalTime = withTest generate (out port UInt(32 bits))
  // val carrier = withTest generate (out port Vec.fill(qubitNum)(pulse.CarrierBundle(16, 16)))
  val carrier = withTest generate (pluginsArea.cgSpecs.map(spec => out(pulse.CarrierBundle(spec))).toList)
  val testLogic = withTest generate {
    Fiber build {
      plugins.foreach {
        case p: fetch.PcPlugin => {
          pc := p.logic.output.payload
        }
        case p: execute.ReadoutPlugin => {
          readouts := p.logic.results
        }
        case p: execute.TimerPlugin => {
          globalTime := p.logic.time
        }
        case p: execute.CarrierPlugin => {
          (carrier zip p.logic.cgPorts).foreach { case (out, in) => out := in.carrier.payload }
          // carrier := p.logic.carrier
          // carrier.zipWithIndex.foreach{ case (c, id) => c := p.logic}
        }
        case _ =>
      }
    }
  }
}

object GenQubicCocotb extends App {
  SpinalConfig(
    mode = Verilog
    // targetDirectory="./riscq-vivado/rtl"
  ).generate(
    QubicSoc(
      qubitNum = 8,
      withAxi4 = true,
      withVivado = false,
      withCocotb = true,
      withWhitebox = false
    )
  )
}

object GenQubicVivado extends App {
  SpinalConfig(
    mode = Verilog,
    targetDirectory = "./riscq-vivado/rtl",
    romReuse = true
  ).generate(
    QubicSoc(
      qubitNum = 8,
      withAxi4 = true,
      withVivado = true,
      withCocotb = false,
      withWhitebox = false,
      withTest = false
    )
  )
}

object QubicTileLinkSoc {
  def apply() = QubicSoc(qubitNum = 2, withAxi4 = false, withWhitebox = true, withVivado = false, withCocotb = false)
}


// object QubicVivadoTest extends App {
//   SpinalVerilog{
//     val riscq = QubicAxi4Soc()
//     // Rtl.ffIo(riscq)
//     // Rtl.xorOutputs(riscq)
//     riscq
//   }
// }

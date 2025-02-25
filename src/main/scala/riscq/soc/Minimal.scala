package riscq.soc

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.tilelink.fabric._
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
import spinal.lib.eda.bench.Rtl
import riscq.misc.ClockInterface
import riscq.memory.DualClockRam
import spinal.lib.eda.bench.Bench
import riscq.misc.XilinxRfsocTarget

object MinimalSocPlugins {
  def getplugins = new Area {
    val wordWidth = 32
    val regFileSync = false
    val enableBypass = true

    val plugins = ArrayBuffer[FiberPlugin]()
    plugins += new riscq.misc.PipelineBuilderPlugin()
    plugins += new schedule.PipelinePlugin()
    plugins += new riscv.RiscvPlugin(xlen = 32)
    plugins += new schedule.ReschedulePlugin()
    val pcPlugin = new fetch.PcPlugin()
    plugins += pcPlugin
    plugins += new fetch.FetchCachelessPlugin(
      wordWidth = wordWidth,
      forkAt = 0,
      joinAt = 1
    )
    // plugins += new decode.DecoderSimplePlugin(decodeAt = 0)
    plugins += new decode.DecoderPlugin(decodeAt = 0)
    plugins += new regfile.RegFilePlugin(
      spec = riscv.IntRegFile,
      physicalDepth = 32,
      preferedWritePortForInit = "",
      syncRead = regFileSync,
      dualPortRam = false,
      maskReadDuringWrite = false
    )
    val rfReadAt = -1 - regFileSync.toInt
    plugins += new execute.RegReadPlugin(syncRead = true, rfReadAt = rfReadAt, enableBypass = enableBypass)
    plugins += new execute.SrcPlugin(executeAt = 0, relaxedRs = true)
    plugins += new schedule.HazardPlugin(rfReadAt = rfReadAt, hazardAt = rfReadAt, enableBypass = enableBypass)
    plugins += new execute.WriteBackPlugin(riscv.IntRegFile, writeAt = 2)
    plugins += new execute.IntFormatPlugin()
    plugins += new execute.IntAluPlugin(executeAt = 0, formatAt = 0)
    plugins += new execute.BranchPlugin()
    plugins += new execute.lsu.LsuCachelessPlugin()
    // plugins += new test.WhiteboxerPlugin()
  }
}

case class MinimalSoc() extends Component {
  val pluginArea = MinimalSocPlugins.getplugins
  val plugins = pluginArea.plugins
  val wordWidth = pluginArea.wordWidth
  val iMem = Mem.fill(1024)(Bits(wordWidth bit))
  val dMem = Mem.fill(1024)(Bits(32 bit))

  val memConnects = plugins.map {
    case p: fetch.FetchCachelessPlugin => {
      new fetch.FetchCachelessBramConnectArea(p, iMem.readWriteSyncPort(maskWidth = wordWidth / 8))
    }
    case p: execute.lsu.LsuCachelessPlugin => {
      new execute.lsu.LsuCachelessBramConnectArea(p, dMem.readWriteSyncPort(maskWidth = 32 / 8))
    }
    case _ =>
  }

  val riscq = RiscQ(pluginArea.plugins)

  // We need some output to avoid vivado removing everything in optimization
  val dummyPort = slave port iMem.readWriteSyncPort(maskWidth = wordWidth / 8)
}

// async rf - Virtex UltraScale+ -> 602 Mhz 713 LUT 966 FF 10 BRAM 0 URAM
// sync rf - Virtex UltraScale+ -> 536 Mhz 809 LUT 1020 FF 10 BRAM 0 URAM
object BenchMinimalSoc extends App {
  val rtl = Rtl(
    SpinalVerilog(
      MinimalSoc()
    )
  )
  Bench(List(rtl), XilinxRfsocTarget(), "./build/")
}

// - Virtex UltraScale+ -> 604 Mhz 727 LUT 882 FF 0 BRAM 0 URAM
object BenchMinimal extends App {
  val rtl = Rtl(SpinalVerilog {
    val pluginArea = MinimalSocPlugins.getplugins
    RiscQ(pluginArea.plugins)
  })
  Bench(List(rtl), XilinxRfsocTarget(), "./build/")
}

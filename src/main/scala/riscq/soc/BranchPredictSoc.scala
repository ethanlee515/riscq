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

case class BranchPredictSoc(whiteboxer: Boolean = false, wordWidth: Int = 32, regFileSync: Boolean = false)
    extends Component {

  val enableBypass = true
  val plugins = ArrayBuffer[FiberPlugin]()
  plugins += new schedule.PipelinePlugin()
  plugins += new riscv.RiscvPlugin(xlen = 32)
  plugins += new schedule.ReschedulePlugin()
  val pcPlugin = new fetch.PcPlugin()
  plugins += pcPlugin
  plugins += new fetch.BtbFetchPlugin(
    wordWidth = wordWidth,
    forkAt = 0,
    joinAt = 1
  )
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
  plugins += new execute.BtbBranchPlugin()
  plugins += new execute.lsu.LsuCachelessPlugin()
  plugins += new test.RegReaderPlugin()

  val iMem = Mem.fill(1024)(Bits(wordWidth bit)).simPublic()
  val dMem = Mem.fill(1024)(Bits(32 bit)).simPublic()

  val memConnects = plugins.map {
    case p: fetch.BtbFetchPlugin => {
      new fetch.BtbFetchBramConnectArea(p, iMem.readWriteSyncPort(maskWidth = wordWidth / 8))
    }
    case p: execute.lsu.LsuCachelessPlugin => {
      new execute.lsu.LsuCachelessBramConnectArea(p, dMem.readWriteSyncPort(maskWidth = 32 / 8))
    }
    case _ =>
  }

  val riscq = RiscQ(plugins)
}

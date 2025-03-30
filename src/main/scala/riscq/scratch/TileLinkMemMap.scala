package riscq.scratch

import spinal.core._
import spinal.lib._
import spinal.lib.bus.tilelink
import spinal.lib.bus.tilelink._
import spinal.lib.bus.tilelink.fabric._
import spinal.lib.bus.misc.SizeMapping
import spinal.core.fiber.Fiber
import spinal.lib.misc.Clint.addressWidth
import _root_.spinal.lib.experimental.hdl.VerilogToSpinal.data
import scala.collection.mutable.LinkedHashMap
import spinal.lib.eda.bench.Rtl
import riscq.misc.XilinxRfsocTarget
import spinal.lib.eda.bench.Bench

object TLRegMap extends App {
  case class TLRegMap() extends Component {
    val tlBus = new MasterBus(
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

    

    val baseAddr = 0x10000
    val mmBus = Node.up()
    mmBus at baseAddr of tlBus.node

    val n = 16 * 5
    val regMap = LinkedHashMap[Int, Data]()
    (0 until n).foreach{i => regMap(i * 4) = Reg(Bits(32 bit))}


    val port = UInt(16 bit)
    val allowBurst = false
    Fiber build new Area {
      mmBus.m2s.supported load SlaveFactory.getSupported(
        addressWidth = 32,
        dataWidth = 32,
        allowBurst = allowBurst,
        proposed = mmBus.m2s.proposed
      )
      mmBus.s2m.none()
      val factory = new SlaveFactory(mmBus.bus, allowBurst)

      for((addr, reg) <- regMap) {
        factory.readAndWrite(reg, addr)
      }
    }
  }

  val rtl = Rtl(SpinalVerilog(
    TLRegMap()
    ))
  Bench(List(rtl), XilinxRfsocTarget(600 MHz), "./bench/")
}
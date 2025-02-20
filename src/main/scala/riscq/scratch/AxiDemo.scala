package scratch

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi.{Axi4, Axi4Config, Axi4SpecRenamer, Axi4ToTilelinkFiber}
import spinal.lib.bus.tilelink.BusParameter
import spinal.lib.bus.tilelink.fabric.RamFiber
import spinal.lib.bus.tilelink
import spinal.core.fiber.Fiber
import riscq.misc.Axi4VivadoHelper

class AxiDemoM extends Component {
  val axiConfig = Axi4Config(
    addressWidth = 32,
    dataWidth = 32,
    idWidth = 4,
  )
  val axi = master(Axi4(axiConfig))
}

class AxiDemoS extends Component {
  val axiConfig = Axi4Config(
    addressWidth = 32,
    dataWidth = 32,
    idWidth = 4,
  )
  val axi = slave(Axi4(axiConfig))
}

class AxiDemoT extends Component {
  val m = new AxiDemoM()
  val s = new AxiDemoS()
  s.axi << m.axi
}

object AxiDemo extends App {
  SpinalVerilog(new AxiDemoT)
}
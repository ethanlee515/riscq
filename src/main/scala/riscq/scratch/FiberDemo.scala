package scratch

import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.core.fiber.Retainer
import spinal.lib.misc.plugin._
import spinal.core.SpinalVerilog
import spinal.lib.bus.tilelink._
import spinal.lib.bus.tilelink.fabric._
import spinal.lib.misc.Clint.addressWidth
import spinal.lib.bus.misc.SizeMapping
import spinal.core.fiber.Fiber

object TileLinkDemo extends App {
  case class MasterFiber() extends Area {
    this.setName("masterrrrr")
    val down = Node.down()
    val logic = Fiber build new Area {
      // down.m2s.proposed load M2sSupport(M2sParameters(
      //     addressWidth = 64,
      //     dataWidth = 64,
      //     masters = List(
      //       M2sAgent(
      //         name = MasterFiber.this,
      //         mapping = List(
      //           M2sSource(
      //             id = SizeMapping(0, 4),
      //             emits = M2sTransfers(
      //               get = SizeRange(1, 64),
      //               putFull = SizeRange(1, 64)
      //             )
      //           )
      //         )
      //       )
      //     )
      //   )
      // )

      // println(s"there: ${down.m2s.supported.dataWidth}")
      // down.m2s.parameters load M2sParameters(down.m2s.supported, 4)
      down.m2s.proposed load M2sSupport(
        addressWidth = 32,
        dataWidth = 64,
        transfers = M2sTransfers(
          get = SizeRange(1, 64)
        )
      )
      down.m2s.parameters load M2sParameters(down.m2s.supported, 4, MasterFiber.this).copy(addressWidth = 32)
      down.s2m.supported load S2mSupport.none()
      println(s"master: ${down.m2s.parameters}")
      // down.s2m.none()
    }
  }

  case class SlaveFiber() extends Area {
    val up = Node.up()
    val logic = Fiber build new Area {
      up.m2s.supported load up.m2s.proposed.copy(addressWidth = 64)
      up.s2m.none()
    }
  }
  SpinalVerilog{
    new Component {
      val myClk = in Bool()
      val myRst = in Bool()
      val myCd = ClockDomain(myClk, myRst)
      val master = myCd(MasterFiber())
      val slave = SlaveFiber()
      slave.up at 0x0000 of master.down
      val logic = Fiber check new Area {
        println(s"slave: ${slave.up.m2s.parameters}")
      }
    }
  }
}

object RetainerDemo extends App {
  case class TopLevel(plugins: Seq[FiberPlugin]) extends Component {
    val host = new PluginHost
      host.asHostOf(plugins)
  }

  case class PA() extends FiberPlugin {
    val lock = Retainer()

    val logic = during setup {
      awaitBuild()
      lock.await()
      println("unlocked")
    }
  }

  case class PB() extends FiberPlugin {
    val logic = during setup {
      val pa = host[PA]
      val retainer = retains(pa.lock)
      awaitBuild()
      retainer.release()
    }
  }

  case class PC() extends FiberPlugin {
    val logic = during setup {
      val retainer = retains(host.list[PA].map(_.lock))
      awaitBuild()
      retainer.release()
      retainer.release()
    }
  }

  SpinalVerilog{
    // val plugins = List(PA(), PB())
    val plugins = List(PA(), PB(), PC())
    TopLevel(plugins)
  }

}
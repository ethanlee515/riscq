package riscq

import spinal.core._
import spinal.lib.misc.database.Database
import spinal.lib.misc.plugin._
import riscq.execute._


case class RiscQ(plugins: Seq[FiberPlugin]) extends Component{
  val database = new Database
  val host = database on (new PluginHost)
  host.asHostOf(plugins)
}





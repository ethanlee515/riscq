package riscq.memory

import spinal.core._
import spinal.lib._

case class DualClockRam(width: Int, depth: Int, fastCd: ClockDomain, slowCd: ClockDomain, style: String = "block") extends Component {
  val mem = Mem.fill(depth)(Bits(width bit))
  mem.addAttribute("ram_style", style)
  Verilator.public(mem)
  val slowPort = slave port slowCd(mem.readWriteSyncPort(width / 8, clockCrossing = true))
  val fastPort = slave port fastCd(mem.readWriteSyncPort(width / 8, clockCrossing = true))
}
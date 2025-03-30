package riscq.memory

import spinal.core._
import spinal.lib._

case class DualClockRam(
    width: Int,
    depth: Int,
    fastCd: ClockDomain,
    slowCd: ClockDomain,
    withOutRegFast: Boolean = false,
    withOutRegSlow: Boolean = false,
    style: String = "block",
) extends Component {

  val mem = Mem.fill(depth)(Bits(width bit))
  mem.addAttribute("ram_style", style)
  Verilator.public(mem)

  val slowLogic = new ClockingArea(slowCd) {
    val port = mem.readWriteSyncPort(width / 8, clockCrossing = true)
    val slowPort = slave port cloneOf(port)
    if(withOutRegSlow) {
      slowPort.rdata := RegNext(port.rdata)
    } else {
      slowPort.rdata := port.rdata
    }
    port.wdata := slowPort.wdata
    port.write := slowPort.write
    port.address := slowPort.address
    port.mask := slowPort.mask
    port.enable := slowPort.enable
  }
  val slowPort = slowLogic.slowPort

  val fastLogic = new ClockingArea(fastCd) {
    val port = mem.readWriteSyncPort(width / 8, clockCrossing = true)
    val fastPort = slave port cloneOf(port)
    if(withOutRegFast) {
      fastPort.rdata := RegNext(port.rdata)
    } else {
      fastPort.rdata := port.rdata
    }
    port.wdata := fastPort.wdata
    port.write := fastPort.write
    port.address := fastPort.address
    port.mask := fastPort.mask
    port.enable := fastPort.enable
  }
  val fastPort = fastLogic.fastPort
}

case class DualClockRamTest(
    width: Int,
    depth: Int,
    fastCd: ClockDomain,
    slowCd: ClockDomain,
    withOutRegFast: Boolean = false,
    withOutRegSlow: Boolean = false,
    style: String = "block",
) extends Component {

  val mem = Mem.fill(depth)(Bits(width bit))
  mem.addAttribute("ram_style", style)
  Verilator.public(mem)

  val slowLogic = new ClockingArea(slowCd) {
    val port = mem.readWriteSyncPort(width / 8, clockCrossing = true)
    val slowPort = slave port cloneOf(port)
    if(withOutRegSlow) {
      slowPort.rdata := RegNext(port.rdata)
    } else {
      slowPort.rdata := port.rdata
    }
    port.wdata := slowPort.wdata
    port.write := slowPort.write
    port.address := slowPort.address
    port.mask := slowPort.mask
    port.enable := slowPort.enable
  }
  val slowPort = slowLogic.slowPort

  val fastLogic = new ClockingArea(fastCd) {
    val port = mem.readWriteSyncPort(width / 8, clockCrossing = true)
    val fastPort = slave port cloneOf(port)
    if(withOutRegFast) {
      fastPort.rdata := RegNext(port.rdata)
    } else {
      fastPort.rdata := port.rdata
    }
    port.wdata := fastPort.wdata
    port.write := fastPort.write
    port.address := fastPort.address
    port.mask := fastPort.mask
    port.enable := fastPort.enable
  }
  val fastPort = fastLogic.fastPort
}
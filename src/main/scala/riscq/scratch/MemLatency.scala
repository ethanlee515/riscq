package riscq.scratch

import spinal.core._
import spinal.lib
import spinal.lib._
import riscq.misc.Axi4VivadoHelper
import spinal.core.fiber.Fiber
import riscq.misc.GpioFiber

class MemLatencyTest extends Component {
  val mem = Mem.fill(1024)(Bits(32 bits))
  val wr = slave port mem.writePortWithMask(4)
  val addr = UInt(10 bits)
  val rd = out port mem.readSync(addr)
  val rst = in Bool()

  addr := 0
  when(rst) {
    addr := 1
  }
}

class DemoMemLatency extends Component {
  val axiConfig = lib.bus.amba4.axi.Axi4Config(
    addressWidth = 32,
    dataWidth = 32,
    idWidth = 4,
  )

  val axi = slave(lib.bus.amba4.axi.Axi4(axiConfig))
  Axi4VivadoHelper.addInference(axi, "S_AXIS")
  val bridge = new lib.bus.amba4.axi.Axi4ToTilelinkFiber(64, 4)
  bridge.up load axi

  val mem = new MemLatencyTest()
  val memWrFiber = TileLinkMemWriteFiber(mem.wr)
  memWrFiber.up at (0) of bridge.down
  val rd = out Bits(32 bits)
  rd := mem.rd

  val rst = in Bool()
  mem.rst := rst

  val gpio = GpioFiber()
  gpio.up at (0x1000) of bridge.down

  val gpio_rst = out Bool()

  val logic = Fiber build new Area{
    gpio_rst := gpio.fiber.pins(0)
  }

  // val pulseBufferFiber = TileLinkMemWriteFiber(pulseBufferWritePort)
  // pulseBufferFiber.up at (0x20000000) of sharedBus

  // val cpu = new CpuFiber(iBus, dBus)

}

object GenMemLatency extends App {
  SpinalVerilog(new DemoMemLatency())
}
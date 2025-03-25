package riscq.scratch

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.amba4.axi.{Axi4, Axi4Config, Axi4SpecRenamer, Axi4ToTilelinkFiber}
import spinal.lib.bus.tilelink.BusParameter
import spinal.lib.bus.tilelink.fabric.RamFiber
import spinal.lib.bus.tilelink._
import spinal.lib.bus.tilelink
import spinal.core.fiber.Fiber
import riscq.misc.Axi4VivadoHelper
import riscq.misc.TileLinkMemReadWriteFiber
// import riscq.pulse.PulseGenerator
import riscq.misc.TileLinkDriveFiber
import spinal.lib.bus.tilelink.sim._
import spinal.lib.bus.tilelink.fabric._
import riscq.misc.GpioFiber
import riscq.misc.TileLinkMemReadWriteFiber
import spinal.lib.bus.misc.SizeMapping
import riscq.misc.Axi4CocotbHelper

object AxiToTileLinkMemTest extends App {
  case class AxiToTileLinkMem() extends Component {
    val axiConfig = Axi4Config(
      addressWidth = 32,
      dataWidth = 32,
      idWidth = 4
    )
    val axi = slave(Axi4(axiConfig))

    // Axi4VivadoHelper.addInference(axi, "S_AXIS")
    Axi4CocotbHelper.setName(axi, ifcName = "AXI")
    val bridge = new Axi4ToTilelinkFiber(32, 4)
    bridge.up load axi

    val width = 128
    val mem = Mem.fill(1024)(Bits(width bits))
    val memFiber = TileLinkMemReadWriteFiber(mem.readWriteSyncPort(width / 8), withOutReg = false)
    memFiber.up at 0x0 of bridge.down
  }
  SpinalVerilog(AxiToTileLinkMem())
}

// object TileLinkConfigDemo extends App {
//   new Component {
//     val pulseBufferPort = MemReadWritePort(Bool(), 1)
//     val readoutBufferPort = MemReadWritePort(Bool(), 1)

//     val axiConfig = Axi4Config(
//       addressWidth = 64,
//       dataWidth = 64,
//       idWidth = 4
//     )
//     val axi = slave(Axi4(axiConfig))
//     val bridge = new Axi4ToTilelinkFiber(64, 4)
//     bridge.up load axi

//     val cpuFiber = CpuFiber(cpuPort)

//     val sharedBus = tilelink.fabric.Node()
//     sharedBus << List(cpuFiber.down, bridge.down)

//     val ram = new RamFiber(bytes = 4096)
//     ram.up.forceDataWidth(128)
//     ram.up at (0x1000000) of sharedBus

//     val pulseBufferFiber = TileLinkMemReadWriteFiber(pulseBufferPort)
//     pulseBufferFiber.up at (0x2000000) of sharedBus

//     val readoutBufferFiber = TileLinkMemReadWriteFiber(readoutBufferPort)
//     readoutBufferFiber.up at (0x3000000)
//   }
// }

object TileLinkDriveTest extends App {
  case class TileLinkDriveTester() extends Component {
    val addr = out(Reg(UInt(16 bits))) init 0
    val drive = TileLinkDriveFiber(addr)
    val down = tilelink.fabric.Node.down() 
    drive.up at 0 of down
    // implicit val idAllocator = new IdAllocator(16)
    val logic = Fiber build new Area {
      down.m2s.proposed load tilelink.M2sSupport(
        addressWidth = 32,
        dataWidth = 32,
        transfers = M2sTransfers.allGetPut
      )
      down.m2s.parameters load M2sParameters(down.m2s.supported, 4).copy(addressWidth = 32)
      down.s2m.supported load S2mSupport.none()
      Fiber.awaitCheck()
      val bus = slave port down.bus.get
      // val agent = new MasterAgent(bus, drive.up.clockDomain)
    }
  }
  SimConfig.compile{
    val dut = TileLinkDriveTester()
    dut.addr.simPublic()
    dut
  }.doSim{dut =>
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.waitRisingEdge(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitRisingEdge(10)
      dut.clockDomain.deassertReset()

      List(dut.logic.bus.a).map{a => 
        a.valid #= true
        a.opcode #= Opcode.A.PUT_FULL_DATA
        a.size    #= 1
        a.source  #= 0
        a.address #= 0
        a.debugId #= 0
        a.data #= Array(7.toByte, 0.toByte)
        a.mask #= Array.fill(2)(true)
      }
      for(i <- 0 until 10){
        println(s"${dut.addr.toLong}")
        dut.clockDomain.waitSampling()
      }
      // val response = dut.logic.agent.putFullData(0, 0, List(7.toByte, 7.toByte, 7.toByte, 7.toByte))
  }
}

object AxiTileLinkMemReadWriteTest extends App {
  case class AxiTileLinkMemReadWrite() extends Component {
      val axiConfig = Axi4Config(
        addressWidth = 32,
        dataWidth = 32,
        idWidth = 4
      )
      val axi = slave(Axi4(axiConfig))

      Axi4VivadoHelper.addInference(axi, "S_AXIS")
      val bridge = new Axi4ToTilelinkFiber(32, 4)
      bridge.up load axi
      val sharedBus = tilelink.fabric.Node()
      sharedBus at 0 of bridge.down

      val mem = Mem.fill(1024)(Bits(128 bits))
      val memPort = mem.readWriteSyncPort(maskWidth = mem.wordType.getBitsWidth/8)
      val memFiber = TileLinkMemReadWriteFiber(memPort, withOutReg = false)
      memFiber.up at 0x100000 of sharedBus
      val addr = UInt(mem.addressWidth bits)
      val addrFiber = TileLinkDriveFiber(addr)
      addrFiber.up at 0x200000 of sharedBus
      val output = out Bits(mem.wordType.getBitsWidth bits)
      output := mem.readSync(addr)
      // Fiber build new Area {
      //   Fiber.awaitCheck()
      //   println(s"${sharedBus.m2s.parameters}")
      // }
      // val addr = out port Reg(Bits(4 bits))
      // val addrFiber = TileLinkDriveFiber(addr, B(7, 4 bits))
      // addrFiber.up at 0x2000 of bridge.down
      // val readData = mem.readSync(addr)
      // val output = out Bits(mem.wordType.getBitsWidth bits)
      // output := readData
      // // op := 7
      // val op = out(Reg(Bits(4 bits)) init(7))
      // val gpio = GpioFiber()
      // gpio.up at (0x1000) of bridge.down
      // val logic = Fiber build new Area{
      //   op := gpio.fiber.pins.resized
      //   Fiber.awaitCheck()
      //   println(s"parameter: ${up.m2s.parameters}")
      // }
  }
  SpinalVerilog {
    AxiTileLinkMemReadWrite()
  }
}

case class DemoSharedBusCode(width: Int, depth: Int) extends Component {

  val axiConfig = Axi4Config(
    addressWidth = 64,
    dataWidth = 64,
    idWidth = 4
  )
  val axi = slave(Axi4(axiConfig))
  val bridge = new Axi4ToTilelinkFiber(64, 4)
  bridge.up load axi

  // val cpuFiber = CpuFiber(cpuComponent)

  val sharedBus = tilelink.fabric.Node()
  // sharedBus << List(cpuFiber.down, bridge.down)

  val ram = new RamFiber(0)
  ram.up.forceDataWidth(128)
  ram.up at (0x10000000) of sharedBus

  // val pulseBufferFiber = TileLinkMemWriteFiber(pulseBufferWritePort)
  // pulseBufferFiber.up at (0x20000000) of sharedBus

  // val cpu = new CpuFiber(iBus, dBus)

}

case class DemoSharedBus(width: Int, depth: Int) extends Component {
  val axiConfig = Axi4Config(
    addressWidth = 32,
    dataWidth = 32,
    idWidth = 4
  )

  val axi = slave(Axi4(axiConfig))
  Axi4VivadoHelper.addInference(axi, "S_AXIS")
  val bridge = new Axi4ToTilelinkFiber(64, 4)
  bridge.up load axi

  // val cpuFiber = CpuFiber(cpuComponent)

  val sharedBus = tilelink.fabric.Node()
  // sharedBus << List(cpuFiber.down, bridge.down)
  sharedBus << bridge.down

  val bytes = 1 << 12

  val ram = new RamFiber(bytes)
  ram.up.forceDataWidth(128)
  ram.up at (0x10000000) of sharedBus

  // val pulseBufferFiber = TileLinkMemWriteFiber(pulseBufferWritePort)
  // pulseBufferFiber.up at (0x20000000) of sharedBus

  // val cpu = new CpuFiber(iBus, dBus)

}

object GenSharedBus extends App {
  SpinalVerilog(DemoSharedBus(128, 1024))
}

case class AxiToTileLinkRam(width: Int, depth: Int) extends Component {
  val axiConfig = Axi4Config(
    addressWidth = 32,
    dataWidth = 32,
    idWidth = 4
  )

  val axi = slave(Axi4(axiConfig))
  Axi4VivadoHelper.addInference(axi, "S_AXIS")

  val bridge = new Axi4ToTilelinkFiber(64, 4)
  bridge.up load axi

  // val widthAdapter = new WidthAdapter()

  // widthAdapter.up at (0x0000) of bridge.down

  // val ram = new RamFiber(depth)
  val mem = Mem.fill(depth)(Bits(width bits))
  val bytes = 1 << 12
  val main = new RamFiber(bytes)
  main.up.forceDataWidth(128)

  val ram = TileLinkMemWriteFiber(mem.writePortWithMask(width / 8))
  // val ram = new PulseBufferFiber(depth)
  // ram.up.forceDataWidth(width) at(0x0000) of widthAdapter.down
  // ram.up.forceDataWidth(width) at(0x0000) of bridge.down
  ram.up at (0x0000) of bridge.down

  val io = new Bundle {
    val read24 = out Bits (width bits)
  }

  val ledLogic = Fiber build new Area {
    Fiber.awaitPatch()
    // val port = ram.thread.logic.io.read
    val port = mem.readSyncPort()
    port.cmd.valid := True
    port.cmd.payload := U(4).resized
    io.read24 := port.rsp
    // io.read24 := B(7).resized
  }

}

object GenAxiTLRam extends App {
  SpinalVerilog(AxiToTileLinkRam(128, 1024))
}

object TileLinkWidthAdapterBug extends App {
  SpinalVerilog {
    new Component {
      val axiConfig = Axi4Config(
        addressWidth = 64,
        dataWidth = 64,
        idWidth = 4
      )
      val axi = slave(Axi4(axiConfig))
      val bridge = new Axi4ToTilelinkFiber(64, 4)
      bridge.up load axi

      val dataWidth = 32
      val up = tilelink.fabric.Node.up()
      val upLogic = Fiber build new Area {
        up.forceDataWidth(dataWidth)
        up.m2s.supported load up.m2s.proposed
        up.s2m.none()

        val dummy = Bits(dataWidth bits)
        val factory = new tilelink.SlaveFactory(up.bus, allowBurst = false)
        factory.drive(dummy, 0)
      }
      up at 0 of bridge.down
    }
  }
}

object WidthAdapterExample extends App{
  SpinalVerilog{
    new Component {
      def bp(dataWidth: Int, sizeBytes: Int) = {
        NodeParameters(
          M2sParameters(
            addressWidth = 12,
            dataWidth = dataWidth,
            masters = List(
              M2sAgent(
                name = null,
                mapping = List(
                  M2sSource(
                    id = SizeMapping(0, 16),
                    emits = M2sTransfers(
                      get = SizeRange(sizeBytes),
                      putPartial = SizeRange(sizeBytes),
                    )
                  )
                )
              )
            )
          )
        ).toBusParameter()
      }

      val ip = bp(dataWidth = 128, sizeBytes = 8)
      val op = bp(dataWidth = 32, sizeBytes = 8)

      // val ip = bp(dataWidth = 128, sizeBytes = 8)
      // val op = bp(dataWidth = 64, sizeBytes = 8)

      new tilelink.WidthAdapter(ip, op)
    }
  }
}
package scratch

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.tilelink
import spinal.core.fiber.Fiber
import spinal.lib.bus.amba4.axi.{Axi4, Axi4Config, Axi4ToTilelinkFiber}
import spinal.lib.io.TriStateArray
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.misc.pipeline
import spinal.lib.misc.pipeline._
import spinal.lib.logic._

object MemClkCross extends App {
  case class MemClkCross() extends Component {
    val io = new Bundle {
      val cfgClk = in Bool()
      val cfgRst = in Bool()
    }
    val myCd = ClockDomain(io.cfgClk, io.cfgRst)
    val mem = Mem.fill(1024)(Bits(16 bits))
    val pa = slave port mem.readWriteSyncPort(clockCrossing = true)
    val myCdArea = new ClockingArea(myCd) {
      val pb = slave port mem.readWriteSyncPort(clockCrossing = true)
    }
    // val pa = slave port mem.readWriteSyncPort()
    // val pb = slave port mem.readWriteSyncPort()
  }

  SpinalVerilog(MemClkCross())
}

object DecodeTest extends App {
  case class DecodeAll() extends Component{
    val cmd = in UInt(32 bits)
    val v = out Bool()
    v := Symplify(cmd.asBits, (0 until 100).map{x => println(s"${x}"); Masked(x, (BigInt(1) << 32) - 1)})
  }
  case class DecodeBug() extends Component{
    val dc = new DecodingSpec(Bool())
    dc.setDefault((Masked.zero))
    val all = List(
      Masked(BigInt("480000000", 16), BigInt("7fffff000", 16)),
      Masked(BigInt("080000000", 16), BigInt("7fffff000", 16)),
      Masked(BigInt("180000000", 16), BigInt("7fffff000", 16)),
      Masked(BigInt("400000000", 16), BigInt("7fffe0000", 16)),
      Masked(BigInt("0", 16), BigInt("7fffe0000", 16)),
      Masked(BigInt("100000000", 16), BigInt("7fffe0000", 16)),
      Masked(BigInt("401000000", 16), BigInt("7fffe0000", 16)),
      Masked(BigInt("001000000", 16), BigInt("7fffe0000", 16)),
      Masked(BigInt("101000000", 16), BigInt("7fffe0000", 16)),
    )
    val one = List(
      Masked(BigInt("401000000", 16), BigInt("7fffe0000", 16)),
      Masked(BigInt("001000000", 16), BigInt("7fffe0000", 16)),
      Masked(BigInt("101000000", 16), BigInt("7fffe0000", 16)),
    )
    for(m <- one) {
      dc.addNeeds(m, Masked.one)
    }
    val o = out Bool()
    val key = in Bits(35 bits)
    o := dc.build(key, all)
  }
  SpinalVerilog(DecodeBug())
  // SimConfig.compile{
  //   val dut = DecodeBug()
  //   dut
  // }.doSim{ dut => 
  //   dut.key #= BigInt("d72d88f8", 16)
  //   sleep(1)
  //   println(s"${dut.o.toBoolean}")
  // }
}

object IndexTest extends App {
  case class IndexT() extends Component{
    val o = out port Vec.fill(3)(UInt(8 bits))
    o.foreach{ _ := U(0) }
    val i = in port UInt(8 bits)
    val v = in port Bool()
    when(v) {
      o(i.resized) := U(123, 8 bits)
    }
  }

  SimConfig.compile{
    IndexT()
  }.doSim{ dut =>
    dut.v #= false
    sleep(1)
    println(s"${dut.o.map{_.toInt}}")

    dut.v #= true
    dut.i #= 0
    sleep(1)
    println(s"${dut.o.map{_.toInt}}")

    dut.i #= 3
    sleep(1)
    println(s"${dut.o.map{_.toInt}}")
  }
}

object TimerTest extends App {
  case class MyTimer() extends Component {
    val counter = out port Reg(UInt(8 bits)) init 123
    counter := counter + 1
    // time.setName("time")
  }

  SpinalVerilog(MyTimer())
}

object AddTest extends App {
  case class MyAdder() extends Component {
    val a = in port AFix.S(0 exp, 8 bits)
    val b = in port AFix.S(0 exp, 8 bits)
    val c = out port AFix.S(0 exp, 8 bits)
    c := (a * b).saturated
  }

  SpinalVerilog(MyAdder())
}

object TestMultiInput extends App {
  SimConfig.compile{
    new Component {
      val v1 = in Bool()
      val d1 = in UInt(8 bits)
      val v2 = in Bool()
      val d2 = in UInt(8 bits)
      val o = out UInt(8 bits)
      o := 0
      when(v2) {
        o := d2
      }
      when(v1) {
        o := d1
      }
    }
  }.doSim{ dut =>
    dut.v1 #= true
    dut.d1 #= 123
    dut.v2 #= true
    dut.d2 #= 111
    sleep(1)
    println(s"${dut.o.toBigInt}")
  }
  
}

object TestOHMux extends App {
  SimConfig.compile{
    new Component {
      val bs = in(Bits(4 bits))
      val ds = List.fill(4)(in(UInt(8 bits)))
      val os = out(OHMux.or(bs, ds))
    }
  }.doSim{ dut =>
    dut.bs #= Array(false, false, false, false)
    dut.ds.map{d => d #= 123}
    sleep(1)
    println(s"${dut.os.toBigInt}")
  }
}

object TestSimDelay extends App {
  SimConfig.compile{
    new Component {
      val input = in(Bool())
      val output = out(Reg(Bool()) init False)
      output := input
    }
  }.doSim { dut =>
    dut.clockDomain.forkStimulus(10)
    dut.input #= false
    val clock = dut.clockDomain
    clock.assertReset()
    clock.waitSampling(10)
    clock.deassertReset()
    clock.waitSampling(10)
    dut.input #= true
    println(s"time: ${simTime()}, in: ${dut.input.toBoolean}, out: ${dut.output.toBoolean}")
    sleep(1)
    println(s"time: ${simTime()}, in: ${dut.input.toBoolean}, out: ${dut.output.toBoolean}")
    // for(i <- 0 until 3) {
    //   clock.waitFallingEdge()
    //   println(s"fallingEdge")
    //   println(s"time: ${simTime()}, in: ${dut.input.toBoolean}, out: ${dut.output.toBoolean}")
    //   clock.waitRisingEdge()
    //   println(s"risingEdge")
    //   println(s"time: ${simTime()}, in: ${dut.input.toBoolean}, out: ${dut.output.toBoolean}")
    // }
    for(i <- 0 until 20) {
      println(s"time: ${simTime()}, in: ${dut.input.toBoolean}, out: ${dut.output.toBoolean}")
      sleep(1)
    }
  }
}

object TestFlowVec extends App {
  case class Top() extends Component {
    val in = slave Flow(Vec.fill(10)(Bool()))
  }

  SpinalVerilog{
    Top()
  }
}

class EmptyRange extends Component {
  val x = U(0, 32 bits)
  val y = x(1 downto 2)
  val z = List.fill(1)(B(0, 1 bits))
  val a = z.read(y)
}

object GenEmptyRange extends App {
  SpinalVerilog(new EmptyRange())
}

class Stage1 extends Component {
  val xIn, yIn, zIn = in UInt(32 bits)
  val xPlusYOut, zOut = out UInt(32 bits)

  val stagedXPlusY = Reg(UInt(32 bits))
  stagedXPlusY := xIn + yIn
  xPlusYOut := stagedXPlusY
  val stagedZ = Reg(UInt(32 bits))
  stagedZ := zIn
  zOut := stagedZ
}

class Stage2 extends Component {
  val xPlusYIn, zIn = in UInt(32 bits)
  val xPlusYTimeZ = out UInt(32 bits)
  xPlusYTimeZ := (xPlusYIn * zIn).resized
}

class TraditionalToplevel extends Component {
  val xIn, yIn, zIn = in UInt(32 bits)
  val xPlusYTimeZ = out UInt(32 bits)
  val stage1 = new Stage1()
  stage1.xIn := xIn
  stage1.yIn := yIn
  stage1.zIn := zIn
  val stage2 = new Stage2()
  stage2.xPlusYIn := stage1.xPlusYOut
  stage2.zIn := stage1.zOut
  xPlusYTimeZ := stage2.xPlusYTimeZ
}

case class XPlusYTimeZPlugin(p: PipelineToplevel) extends Area {
  val xPlusY = pipeline.Payload(UInt(32 bits))
  val z = pipeline.Payload(UInt(32 bits))
  p.stage1(xPlusY) := p.xIn + p.yIn
  p.stage1(z) := p.zIn
  p.xPlusYTimeZ := (p.stage2(xPlusY) * p.stage2(z)).resized
}

class PipelineToplevel extends Component {
  val xIn, yIn, zIn = in UInt(32 bits)
  val xPlusYTimeZ = out UInt(32 bits)

  val stage1, stage2 = pipeline.Node()
  val link = pipeline.StageLink(stage1, stage2)

  val plugin = XPlusYTimeZPlugin(this)
  pipeline.Builder(link)
}

class PipelineToplevelDemo extends Component {

  val a, b, c, d, e = Payload(Bool())
  val stage1, stage2 = Node()
  val link = StageLink(stage1,stage2)
  // val link = DirectLink(stage1,stage2)
  stage1(d) := stage1(a) && stage1(b)
  stage2(e) := stage2(c) || stage2(d)

}

object genPipe extends App {
  SpinalVerilog(new TraditionalToplevel())
}

class GpioFiber extends Area {
  val up = tilelink.fabric.Node.up()

  val fiber = Fiber build new Area {
    up.m2s.proposed load tilelink.M2sSupport(
      addressWidth = 12,
      dataWidth = 32,
      transfers = tilelink.M2sTransfers(
        get = tilelink.SizeRange(4),
        putPartial = tilelink.SizeRange(4)
      )
    )
    up.m2s.supported load up.m2s.proposed.intersect(tilelink.M2sTransfers.allGetPut)
    up.s2m.none()

    val pins = master(TriStateArray(32 bits))

    println("parameter", up.bus.p)
    val factory = new tilelink.SlaveFactory(up.bus, allowBurst = false)
    val writeEnableReg = factory.drive(pins.writeEnable, 0x0) init (0)
    val writeReg = factory.drive(pins.write, 0x4) init(0)
    factory.read(pins.read, 0x8)
  }
}

object Demo extends App {
  SpinalVerilog(new Component {
    val axiConfig = Axi4Config(
        addressWidth = 32,
        dataWidth = 32,
        idWidth = 4,
      )
    val axi = slave port Axi4(axiConfig)

    val bridge = new Axi4ToTilelinkFiber(64, 4)
    bridge.up load axi

    // val gpio = new GpioFiber()
    // gpio.up at(0x0000) of bridge.down
    val ram = new tilelink.fabric.RamFiber(1024)
    ram.up at(0x0000) of bridge.down
    Fiber build new Area {
      println("param" + ram.up.bus.p)
    }
  })
}


object Demo2 extends App {

  {
    import spinal.lib.bus.tilelink
    import spinal.core.fiber.Fiber

    class CpuFiber extends Area {
      // Define a node facing downward (toward slaves only)
      val down = tilelink.fabric.Node.down()

      val fiber = Fiber build new Area {
        // Here we force the bus parameters to a specific configurations
        down.m2s forceParameters tilelink.M2sParameters(
          addressWidth = 32,
          dataWidth = 64,
          // We define the traffic of each master using this node. (one master => one M2sAgent)
          // In our case, there is only the CpuFiber.
          masters = List(
            tilelink.M2sAgent(
              name = CpuFiber.this, // Reference to the original agent.
              // A agent can use multiple sets of source ID for different purposes
              // Here we define the usage of every sets of source ID
              // In our case, let's say we use ID [0-3] to emit get/putFull requests
              mapping = List(
                tilelink.M2sSource(
                  id = SizeMapping(0, 4),
                  emits = tilelink.M2sTransfers(
                    get = tilelink.SizeRange(1, 64), //Meaning the get access can be any power of 2 size in [1, 64]
                    putFull = tilelink.SizeRange(1, 64)
                  )
                )
              )
            )
          )
        )

        // Lets say the CPU doesn't support any slave initiated requests (memory coherency)
        down.s2m.supported load tilelink.S2mSupport.none()

        val mappings = spinal.lib.system.tag.MemoryConnection.getMemoryTransfers(down)
        for(mapping <- mappings){
          println(s"- ${mapping.where} -> ${mapping.transfers}")
        }

        // Then we can generate some hardware (nothing usefull in this example)
        down.bus.a.setIdle()
        down.bus.d.ready := True
      }
    }

    import spinal.lib._


   SpinalVerilog(new Component {
     val cpu = new CpuFiber()

     val gpio = new GpioFiber()
     gpio.up at 0x20000 of cpu.down // map the gpio at [0x20000-0x20FFF], its range of 4KB being fixed internally
   })

  }

}
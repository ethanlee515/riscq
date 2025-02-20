package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.misc.pipeline._
import scala.math
import spinal.lib.bus.amba4.axi.{Axi4, Axi4Config, Axi4ToTilelinkFiber}
import spinal.lib.bus.tilelink.BusParameter
import spinal.lib.bus.tilelink.fabric.RamFiber
import spinal.lib.bus.tilelink._
import spinal.lib.bus.tilelink
import spinal.lib.eda.bench.{Bench, Rtl, Target, XilinxStdTargets}

import riscq.misc._

case class TableAndDspParam(width: Int) {
  assert(width % 2 == 0, "width must be even")
  val inType = HardType(AFix.S(0 exp, width bits))
  val tableWidth = width + 2
  val tableType = HardType(AFix.S(1 exp, tableWidth bits))
  val computeWidth = width + 2
  val computeType = HardType(SInt(computeWidth bits))
  val mulType = HardType(SInt(width + width + 4 bits))
  val msbWidth = width / 2
  val lsbWidth = width - msbWidth
  val quadWidth = 11
  val cubicWidth = 6
}

case class TableAndClassInData(p: TableAndDspParam) extends Bundle with IMasterSlave {
  val z = p.inType()
  def asMaster(): Unit = {out(z)}
}


object CosSinTable {
  def idxToZ(idx: Int, width: Int): Double = {
    val size = 1 << (width - 1)
    idx.toDouble / size
  }
  def clip(x: Double, width: Int): Double = {
    val maxValue = 1.0 - (1.0 / (1 << (width - 1)))
    x.min(maxValue)
  }
  def cos(idx: Int, width: Int): Double = {
    val ret = math.cos(idxToZ(idx, width) * math.Pi)
    ret
  }
  def sin(idx: Int, width: Int): Double = {
    val ret = math.sin(idxToZ(idx, width) * math.Pi)
    ret
  }
}

case class TableAndDsp(p: TableAndDspParam) extends Component {
  addAttribute("DONT_TOUCH", "TRUE")
  val delay = 10

  val io = new Bundle {
    val cmd = slave Flow(TableAndClassInData(p))
    val rsp = master Flow(Complex(p.width + 2))
  }

  val cosMsbTable = (0 until 1 << p.msbWidth).map(i => CosSinTable.cos(i, p.msbWidth)).map(CosSinTable.clip(_, p.tableWidth))
  val cosLsbTable = (0 until 1 << p.lsbWidth).map(i => CosSinTable.cos(i, p.width)).map(CosSinTable.clip(_, p.tableWidth))
  val cosTable = cosMsbTable ++ cosLsbTable
  val cosMem = Mem(p.tableType, 1 << (p.msbWidth + 1)) init cosTable.map(x => AF(x, p.tableType().Q)).toSeq
  val cosMsbPort = cosMem.readSyncPort
  cosMsbPort.cmd.valid := True
  val cosLsbPort = cosMem.readSyncPort
  cosLsbPort.cmd.valid := True
  val sinMsbTable = (0 until 1 << p.msbWidth).map(i => CosSinTable.sin(i, p.msbWidth)).map(CosSinTable.clip(_, p.tableWidth))
  val sinLsbTable = (0 until 1 << p.lsbWidth).map(i => CosSinTable.sin(i, p.width)).map(CosSinTable.clip(_, p.tableWidth))
  val sinTable = sinMsbTable ++ sinLsbTable
  val sinMem = Mem(p.tableType, 1 << (p.msbWidth + 1)) init sinTable.map(x => AF(x, p.tableType().Q)).toSeq
  val sinMsbPort = sinMem.readSyncPort
  sinMsbPort.cmd.valid := True
  val sinLsbPort = sinMem.readSyncPort
  sinLsbPort.cmd.valid := True
  
  val stages = List.fill(20)(Node())
  class StageArea(at: Int) extends NodeMirror(stages(at))

  val Z = Payload(io.cmd.payload.z)
  val inputLogic = new StageArea(0) {
    Z := io.cmd.payload.z
    valid := io.cmd.valid
  }

  val ZPOS = Payload(Bool())
  val memLogic = new StageArea(1) {
    ZPOS := Z.isPositive
    val sz = Z.asSInt
    val negz = ZPOS.mux(-sz, sz).asBits
    val zMsb = negz(negz.high - p.msbWidth + 1, p.msbWidth bits)
    cosMsbPort.cmd.payload := (False ## zMsb).asUInt
    sinMsbPort.cmd.payload := (False ## zMsb).asUInt
    val zLsb = negz(negz.high - p.width + 1, p.lsbWidth bits)
    cosLsbPort.cmd.payload := (True ## zLsb).asUInt
    sinLsbPort.cmd.payload := (True ## zLsb).asUInt
  }

  val COSMSB = Payload(p.computeType())
  val COSLSB = Payload(p.computeType())
  val SINMSB = Payload(p.computeType())
  val SINLSB = Payload(p.computeType())
  val preDspLogic = new StageArea(2) {
    COSMSB := cosMsbPort.rsp.asSInt.resized
    COSLSB := cosLsbPort.rsp.asSInt.resized
    SINMSB := sinMsbPort.rsp.asSInt.resized
    SINLSB := sinLsbPort.rsp.asSInt.resized
  }

  val dspStart = 3
  val compMul = ComplexMul(p.computeWidth)
  compMul.io.c0.r := stages(dspStart)(COSMSB)
  compMul.io.c0.i := stages(dspStart)(SINMSB)
  compMul.io.c1.r := stages(dspStart)(COSLSB)
  compMul.io.c1.i := stages(dspStart)(SINLSB)

  val resAt = dspStart + 6
  val OUTCOS = Payload(SInt(p.width + 2 bits))
  val OUTSIN = Payload(SInt(p.width + 2 bits))
  val signLogic = new StageArea(resAt) {
    val cos = compMul.io.c.r.asSInt
    val sin = compMul.io.c.i.asSInt
    val signSin = ZPOS.mux(-sin, sin)
    OUTSIN := signSin
    OUTCOS := cos
  }

  val outputLogic = new StageArea(resAt + 1) {
    io.rsp.valid := valid
    io.rsp.r := OUTCOS
    io.rsp.i := OUTSIN
  }


  val connections = (stages, stages.tail).zipped.map{ case (s0, s1) => StageLink(s0, s1)}
  Builder(connections)

  KeepAttribute(io.cmd)
}

object TableAndDspTest extends App {
  def msb(x: Double, b: Int): Double = {
    val neg = x < 0
    val xabs = x.abs
    val msb = math.floor(xabs * (1 << b)).toInt / (1 << b).toDouble
    if(neg) return -msb
    else return msb
  }
  def lsb(x: Double, b: Int): Double = {
    return (x - msb(x, b))
  }
  def myfmt(x: Int, b: Int): String = {
    String.format("%" + b + "s", x.toBinaryString).replace(' ', '0')
  }
  val p = TableAndDspParam(16)
  SpinalVerilog(TableAndDsp(p))
  SimConfig.compile{
    val dut = TableAndDsp(p)
    dut.cosMsbPort.simPublic()
    dut.cosLsbPort.simPublic()
    dut.sinLsbPort.simPublic()
    dut.sinMsbPort.simPublic()
    dut.memLogic.sz.simPublic()
    dut.memLogic.negz.simPublic()
    dut.memLogic.zMsb.simPublic()
    dut.memLogic.zLsb.simPublic()
    dut
  }.doSim { dut =>
    val clock = dut.clockDomain
    clock.forkStimulus(10) // clock.waitSampling() = sleep(10)
    clock.waitRisingEdge(10)
    dut.io.cmd.z #= 0.8
    dut.io.cmd.valid #= false
    clock.assertReset()
    clock.waitRisingEdge(10)
    clock.deassertReset()
    clock.waitRisingEdge(10)

    // val ang = 1.0/(1<<7) - 1
    // var ang = 1.0 - 1.0 / (1 << 15)
    // var ang = -1
    var ang = 0
    dut.io.cmd.z #= ang
    dut.io.cmd.valid #= true
    for(i <- 0 until 15) {
      sleep(2)
      val x = dut.io.rsp.r.toBigDecimal
      val y = dut.io.rsp.i.toBigDecimal
      val ex = math.cos(ang*math.Pi)
      val ey = math.sin(ang*math.Pi)
      println(s"${i},${dut.io.rsp.valid.toBoolean}")
      println(s"x:${x}, expected:${ex}, delta:${(x-ex).abs * (1 << 14)}")
      println(s"y:${y}, expected:${ey}, delta:${(y-ey).abs * (1 << 14)}")
      println("")
      clock.waitSampling()
      dut.io.cmd.valid #= false
    }
  }
}

object AxiTableAndDspTest extends App {
  val p = TableAndDspParam(16)
  SpinalVerilog {
    new Component {
      val tad = TableAndDsp(p)
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

      val tadZFiber = TileLinkDriveFiber(tad.io.cmd.z)
      val tadValidFiber = TileLinkDriveFiber(tad.io.cmd.valid)
      tadZFiber.up at 0 of sharedBus
      tadValidFiber.up at 0x1000 of sharedBus

      val output = out port cloneOf(tad.io.rsp)
      output := tad.io.rsp
    }
  }
}

object AxiDriveTest extends App {
  val p = TableAndDspParam(16)
  case class AxiDrive() extends Component {
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

      val output = out Bits(4 bits)
      val drive = TileLinkDriveFiber(output)
      drive.up at 0 of sharedBus
  }
  SpinalVerilog {
    AxiDrive()
  }
}
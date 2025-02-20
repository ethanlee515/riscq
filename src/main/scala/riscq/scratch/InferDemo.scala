package riscq.scratch

import spinal.core._
import spinal.lib._
import scala.math
import spinal.lib.eda.bench.{Bench, Rtl, Target, XilinxStdTargets}

object CosSinTable {
  def idxToZ(idx: Int, width: Int): Double = {
    val size = 1 << (width - 1)
    idx.toDouble / size
  }
  def cos(idx: Int, width: Int) = {
    val ret = math.cos(idxToZ(idx, width) * math.Pi)
    ret
  }
  def sin(idx: Int, width: Int) = {
    val ret = math.sin(idxToZ(idx, width) * math.Pi)
    ret
  }
}

object BramInferTest extends App {
  case class BramInfer() extends Component {
    val width = 8
    val dataType = HardType(AFix.S(1 exp, 2 * width bits))
    val cosMsbTable = (0 until 1 << width).map(i => CosSinTable.cos(i, width))
    val cosLsbTable = (0 until 1 << width).map(i => CosSinTable.cos(i, 2 * width))
    val cosTable = cosMsbTable ++ cosLsbTable
    val cosMem = Mem(dataType, 1 << width + 1) init cosTable.map(x => AF(x, dataType().Q)).toSeq
    val cosMsbPort = cosMem.readSyncPort
    cosMsbPort.cmd.valid := True
    val cosLsbPort = cosMem.readSyncPort
    cosLsbPort.cmd.valid := True
    val input = new Bundle {
      val inMsb = in port UInt(cosMsbPort.addressWidth bits)
      val inLsb = in port UInt(cosMsbPort.addressWidth bits)
    }
    cosMsbPort.cmd.payload := input.inMsb
    cosLsbPort.cmd.payload := input.inLsb
    val output = new Bundle {
      val outMsb = out port cloneOf(cosMsbPort.rsp)
      val outLsb = out port cloneOf(cosLsbPort.rsp)
    }
    output.outMsb := cosMsbPort.rsp
    output.outLsb := cosLsbPort.rsp
  }
  // SpinalVerilog(BramInfer())
  // val sc = SpinalConfig()
  // val rtls = List(Rtl(sc.generateVerilog{
  //   val bram = BramInfer()
  //   // Rtl.compactInputs(bram)
  //   Rtl.ffIo(bram)
  //   Rtl.xorOutputs(bram)
  // }))
  // val targets = XilinxStdTargets(withFMax = true, withArea = false)
  // Bench(rtls, targets)
  SpinalVerilog{
    val bram = BramInfer()
    // Rtl.compactInputs(bram)
    Rtl.ffIo(bram)
    Rtl.xorOutputs(bram)
    bram
  }
  

}
package riscq.misc

import spinal.core._
import spinal.lib._
import spinal.lib.eda.bench.Rtl
import spinal.lib.eda.xilinx.VivadoFlow
import riscq.pulse.TableAndDsp

import org.apache.commons.io.FileUtils
import spinal.core._
import spinal.lib.DoCmd.doCmd
import spinal.lib.eda.bench.{Report, Rtl}

import java.io.File
import java.nio.file.Paths
import scala.io.Source

import spinal.lib.eda.bench.Target
import spinal.lib.eda.bench.Bench

object XilinxRfsocTarget {
  def apply(FMax: HertzNumber = 500 MHz, vivadoPath: String = "/opt/Xilinx/Vivado/2024.2/bin/"): Seq[Target] = {
    return List(new Target {
      override def getFamilyName(): String = "Virtex UltraScale+"
      override def synthesise(rtl: Rtl, workspace: String): Report = {
        VivadoFlow(
          frequencyTarget = FMax,
          vivadoPath = vivadoPath,
          workspacePath = workspace + "_area",
          rtl = rtl,
          family = getFamilyName(),
          device = "xczu49dr-ffvf1760-2-e"
        )
      }
    })
  }
}

case class Cmult(width: Int) extends Component {
  val ar = in SInt (width bits)
  val br = in SInt (width bits)
  val ai = in SInt (width bits)
  val bi = in SInt (width bits)
  val ar_d, ar_dd, ar_ddd, ar_dddd = Reg(SInt(width bits))
  val br_d, br_dd, br_ddd, br_dddd = Reg(SInt(width bits))
  val ai_d, ai_dd, ai_ddd, ai_dddd = Reg(SInt(width bits))
  val bi_d, bi_dd, bi_ddd, bi_dddd = Reg(SInt(width bits))

  val pr = out SInt (width + width + 1 bits)
  val pi = out SInt (width + width + 1 bits)

  val addcommon, addr, addi = Reg(SInt(width + 1 bits))
  val mult0, multr, multi, pr_int, pi_int = Reg(SInt(width + width + 1 bits))
  val common, commonr1, commonr2 = Reg(SInt(width + width + 1 bits))

  ar_d := ar
  ar_dd := ar_d
  ar_ddd := ar_dd
  ar_dddd := ar_ddd
  br_d := br
  br_dd := br_d
  br_ddd := br_dd
  br_dddd := br_ddd
  ai_d := ai
  ai_dd := ai_d
  ai_ddd := ai_dd
  ai_dddd := ai_ddd
  bi_d := bi
  bi_dd := bi_d
  bi_ddd := bi_dd
  bi_dddd := bi_ddd

  addcommon := ar_d -^ ai_d
  mult0 := addcommon * bi_dd
  common := mult0

  addr := br_ddd -^ bi_ddd
  multr := addr * ar_dddd
  commonr1 := common
  pr_int := multr + commonr1

  addi := br_ddd +^ bi_ddd
  multi := addi * ai_dddd
  commonr2 := common
  pi_int := multi + commonr2

  pr := pr_int
  pi := pi_int
}

object BenchComplexMul extends App {
  import riscq.pulse._

  val rtl = Rtl(SpinalVerilog(ComplexMul(16)))
  Bench(List(rtl), XilinxRfsocTarget(), "./build/")
}

object BenchTableAndDsp extends App {
  import riscq.pulse._

  val param = TableAndDspParam(16)
  val rtl = Rtl(SpinalSystemVerilog(Rtl.ffIo {
    TableAndDsp(param)
  }))
  Bench(List(rtl), XilinxRfsocTarget(), "./build/")
}

object BenchCarrierGenerator extends App {
  import riscq.pulse._

  val param = CarrierGeneratorSpec(
    batchSize = 4,
    carrierWidth = 16,
    freqWidth = 16,
    clockWidth = 32
  )
  val rtl = Rtl(SpinalVerilog(Rtl.ffIo {
    CarrierGenerator(param)
  }))
  Bench(List(rtl), XilinxRfsocTarget(), "./build/")
}

object BenchPulseGenerator extends App {
  import riscq.pulse._

  val dataWidth = 16
  val addrWidth = 10
  val phaseWidth = 16
  val batchSize = 4
  val pgSpec = PulseGeneratorSpec(
    dataWidth = dataWidth,
    batchSize = batchSize,
    bufferDepth = 1 << addrWidth,
    clockWidth = 32,
    phaseWidth = phaseWidth,
    freqWidth = phaseWidth,
    ampWidth = 16,
    carrierDelay = (dataWidth max phaseWidth) + 1,
    defaultData = 0
  )
  val rtl = Rtl(SpinalVerilog(Rtl.ffIo {
    PulseGeneratorWithCarrierInput(pgSpec)
  }))
  Bench(List(rtl), XilinxRfsocTarget(), "./build/")
}

object BenchCordic extends App {
  import riscq.pulse._
  val param = CordicParam(16, 16, false)
  val rtl = Rtl(SpinalVerilog(Rtl.ffIo {
    Cordic(param)
  }))
  Bench(List(rtl), XilinxRfsocTarget(), "./build/")
}
package riscq.scratch

import spinal.core._
import spinal.lib._
import spinal.lib.eda.bench.Rtl
// import spinal.lib.eda.xilinx.VivadoFlow
import riscq.pulse.TableAndDsp

import org.apache.commons.io.FileUtils
import spinal.core._
import spinal.lib.DoCmd.doCmd
import spinal.lib.eda.bench.{Report, Rtl}

import java.io.File
import java.nio.file.Paths
import scala.io.Source

object VivadoFlow {
  def apply(rtl: Rtl, device: String, workspacePath: String = "SPINAL_BENCH_WORKSPACE", frequencyTarget: HertzNumber = null, processorCount: Int = 1): Unit = {
    val targetPeriod = (if (frequencyTarget != null) frequencyTarget else 500 MHz).toTime

    val workspacePathFile = new File(workspacePath)
    // FileUtils.deleteDirectory(workspacePathFile)
    // workspacePathFile.mkdir()
    for (file <- rtl.getRtlPaths()) {
      FileUtils.copyFileToDirectory(new File(file), workspacePathFile)
    }

    val isVhdl = (file: String) => file.endsWith(".vhd") || file.endsWith(".vhdl")
    val readRtl = rtl.getRtlPaths().map(file => s"""read_${if(isVhdl(file)) "vhdl" else "verilog"} ${Paths.get(file).getFileName()}""").mkString("\n")

    // generate tcl script
    val tcl = new java.io.FileWriter(Paths.get(workspacePath, "doit.tcl").toFile)
    tcl.write(
s"""
create_project -force project_bft_batch ./project_bft_batch -part $device

add_files {${rtl.getRtlPaths().mkString(" ")}}
add_files -fileset constrs_1 ./doit.xdc

import_files -force

set_param general.maxThreads ${processorCount}

set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name netlist_1

report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file syn_timing.rpt
report_power -file syn_power.rpt

launch_runs impl_1
wait_on_run impl_1

open_run impl_1
report_utilization
report_timing_summary -warn_on_violation
report_pulse_width -warn_on_violation -all_violators
report_design_analysis -logic_level_distribution
"""
    )
    tcl.flush();
    tcl.close();

    // generate xdc constraint
    val xdc = new java.io.FileWriter(Paths.get(workspacePath, "doit.xdc").toFile)
    xdc.write(s"""create_clock -period ${(targetPeriod * 1e9) toBigDecimal} [get_ports clk]""")
    xdc.flush();
    xdc.close();
  }
}


case class Cmult(width: Int) extends Component {
  val ar = in SInt(width bits)
  val br = in SInt(width bits)
  val ai = in SInt(width bits)
  val bi = in SInt(width bits)
  val ar_d, ar_dd, ar_ddd, ar_dddd = Reg(SInt(width bits))
  val br_d, br_dd, br_ddd, br_dddd = Reg(SInt(width bits))
  val ai_d, ai_dd, ai_ddd, ai_dddd = Reg(SInt(width bits))
  val bi_d, bi_dd, bi_ddd, bi_dddd = Reg(SInt(width bits))

  val pr = out SInt(width + width + 1 bits)
  val pi = out SInt(width + width + 1 bits)

  val addcommon, addr, addi = Reg(SInt(width + 1 bits))
  val mult0, multr, multi, pr_int, pi_int = Reg(SInt(width + width + 1 bits))
  val common, commonr1, commonr2= Reg(SInt(width + width + 1 bits))

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

  // val rtl = Rtl(SpinalVerilog(Rtl.ffIo{
  //   ComplexMul(16)
  // }))
  val rtl = Rtl(SpinalVerilog( ComplexMul(16)))
  // val rtl = Rtl(SpinalVerilog( Cmult(16)))
  VivadoFlow(rtl, "xczu49dr-ffvf1760-2-e", "SPINAL_BENCH_WORKSPACE/ComplexMulEval")
}

object BenchTableAndDsp extends App {
    import riscq.pulse._

    val param = TableAndDspParam(16)
    val rtl = Rtl(SpinalSystemVerilog(Rtl.ffIo{
        TableAndDsp(param)
    }))
    VivadoFlow(rtl, "xczu49dr-ffvf1760-2-e")
}

object BenchCarrierGenerator extends App {
    import riscq.pulse._

    val param = CarrierGeneratorSpec(
      batchSize = 4,
      carrierWidth = 16,
      freqWidth = 16,
      clockWidth = 32
    )
    val rtl = Rtl(SpinalVerilog(Rtl.ffIo{
        CarrierGenerator(param)
    }))
    VivadoFlow(rtl, "xczu49dr-ffvf1760-2-e")
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
    val rtl = Rtl(SpinalVerilog(Rtl.ffIo{
        PulseGeneratorWithCarrierInput(pgSpec)
    }))
    VivadoFlow(rtl, "xczu49dr-ffvf1760-2-e")
}

object BenchCordic extends App {
  import riscq.pulse._
  val param = CordicParam(16, 16, false)
  val rtl = Rtl(SpinalVerilog(Rtl.ffIo{
    Cordic(param)
  }))
  VivadoFlow(rtl, "xczu49dr-ffvf1760-2-e")
}

// object BenchDsp extends App {
//     import riscq.pulse._
//     import spinal.lib.misc.pipeline._
//     case class DspTest(n: Int) {
//       val x0 = in port SInt(n bits)
//       val y0 = in port SInt(n bits)
//       val x1 = in port SInt(n bits)
//       val y1 = in port SInt(n bits)

//       val stages = List.fill(10)(Node())

//       val 
      

//     }

//     val param = TableAndDspParam(16)
//     val rtl = Rtl(SpinalVerilog(Rtl.ffIo{
//         TableAndDsp(param)
//     }))
//     VivadoFlow(rtl, "xczu49dr-ffvf1760-2-e")
// }
package riscq.execute

import spinal.core._
import spinal.lib._
import spinal.lib.misc.pipeline._
import riscq.riscv.Riscv
import riscq.riscv.Rvi
import riscq.schedule.PipelinePlugin

object BarrelShifterPlugin extends AreaObject {
  val SIGNED = Payload(Bool())
  val LEFT = Payload(Bool())
  val IS_W = Payload(Bool())
  val IS_W_RIGHT = Payload(Bool())
  val IS_UW = Payload(Bool())
}

/**
 * Implements the RISC-V integer shift instructions
 * use a single left barrel shifter pre/post bit reverse for right shifts
 */
class BarrelShifterPlugin(var with_slli_uw: Boolean = false,
                          var shiftAt : Int = 0,
                          var formatAt : Int = 0) extends ExecutionUnit {
  import BarrelShifterPlugin._
  val SHIFT_RESULT = Payload(Bits(Riscv.XLEN bits))

  val logic = during setup new Area{
    val pp = host[PipelinePlugin]
    val ifp = host[IntFormatPlugin]
    val srcp = host[SrcPlugin]

    awaitBuild()
    import SrcKeys._

    val wb = newWriteback(ifp, formatAt)

    addUop(Rvi.SLL).srcs(SRC1.RF, SRC2.RF).decode(LEFT -> True, SIGNED -> False)
    addUop(Rvi.SRL).srcs(SRC1.RF, SRC2.RF).decode(LEFT -> False, SIGNED -> False)
    addUop(Rvi.SRA).srcs(SRC1.RF, SRC2.RF).decode(LEFT -> False, SIGNED -> True)
    addUop(Rvi.SLLI).srcs(SRC1.RF, SRC2.I).decode(LEFT -> True, SIGNED -> False)
    addUop(Rvi.SRLI).srcs(SRC1.RF, SRC2.I).decode(LEFT -> False, SIGNED -> False)
    addUop(Rvi.SRAI).srcs(SRC1.RF, SRC2.I).decode(LEFT -> False, SIGNED -> True)

    uopRetainer.release()

    val shift = new pp.Execute(shiftAt) {
      val ss = SrcStageables
      val amplitude = srcp.SRC2(log2Up(Riscv.XLEN.get) - 1 downto 0).asUInt
      val reversed = Mux[SInt](LEFT, srcp.SRC1.reversed, srcp.SRC1)
      val shifted = (S((SIGNED & srcp.SRC1.msb) ## reversed) >> amplitude).resize(Riscv.XLEN bits)
      val patched = LEFT ? shifted.reversed | shifted

      SHIFT_RESULT := B(patched)
    }

    val format = new pp.Execute(formatAt) {
      wb.valid := SEL
      wb.payload := SHIFT_RESULT
    }
  }
}



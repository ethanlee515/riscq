package riscq.execute

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin._
import spinal.lib.misc.pipeline._
import riscq.schedule.PipelinePlugin
import riscq.riscv.Riscv
import riscq.riscv.Rvi

object IntAluPlugin extends AreaObject {
  val AluBitwiseCtrlEnum = new SpinalEnum(binarySequential) {
    val XOR, OR, AND = newElement()
  }
  val AluCtrlEnum = new SpinalEnum(binarySequential) {
    val ADD_SUB, SLT_SLTU, BITWISE = newElement()
  }
}

class IntAluPlugin(executeAt: Int, formatAt: Int) extends ExecutionUnit {
  import IntAluPlugin._
  val ALU_BITWISE_CTRL = Payload(AluBitwiseCtrlEnum())
  val ALU_CTRL = Payload(AluCtrlEnum())
  val ALU_RESULT = Payload(Bits(Riscv.XLEN bits))

  val logic = during setup new Area {
    val pp = host[PipelinePlugin]
    val ifp = host[IntFormatPlugin]
    val srcp = host[SrcPlugin]
    val ifpRetainer = retains(ifp.elaborationLock)
    val buildBefore = retains(pp.elaborationLock)

    awaitBuild()

    import SrcKeys._
    
    val ace = AluCtrlEnum
    val abce = AluBitwiseCtrlEnum

    val wb = newWriteback(ifp, formatAt)

    addUop(Rvi.ADD ).srcs(Op.ADD   , SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.ADD_SUB )
    addUop(Rvi.SUB ).srcs(Op.SUB   , SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.ADD_SUB )
    addUop(Rvi.SLT ).srcs(Op.LESS  , SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.SLT_SLTU)
    addUop(Rvi.SLTU).srcs(Op.LESS_U, SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.SLT_SLTU)
    addUop(Rvi.XOR ).srcs(           SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.BITWISE , ALU_BITWISE_CTRL -> abce.XOR )
    addUop(Rvi.OR  ).srcs(           SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.BITWISE , ALU_BITWISE_CTRL -> abce.OR  )
    addUop(Rvi.AND ).srcs(           SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.BITWISE , ALU_BITWISE_CTRL -> abce.AND )

    addUop(Rvi.ADDI ).srcs(Op.ADD   , SRC1.RF, SRC2.I).decode(ALU_CTRL -> ace.ADD_SUB )
    addUop(Rvi.SLTI ).srcs(Op.LESS  , SRC1.RF, SRC2.I).decode(ALU_CTRL -> ace.SLT_SLTU)
    addUop(Rvi.SLTIU).srcs(Op.LESS_U, SRC1.RF, SRC2.I).decode(ALU_CTRL -> ace.SLT_SLTU)
    addUop(Rvi.XORI ).srcs(           SRC1.RF, SRC2.I).decode(ALU_CTRL -> ace.BITWISE , ALU_BITWISE_CTRL -> abce.XOR )
    addUop(Rvi.ORI  ).srcs(           SRC1.RF, SRC2.I).decode(ALU_CTRL -> ace.BITWISE , ALU_BITWISE_CTRL -> abce.OR  )
    addUop(Rvi.ANDI ).srcs(           SRC1.RF, SRC2.I).decode(ALU_CTRL -> ace.BITWISE , ALU_BITWISE_CTRL -> abce.AND )

    addUop(Rvi.LUI  ).srcs(Op.SRC1, SRC1.U         ).decode(ALU_CTRL -> ace.ADD_SUB)
    addUop(Rvi.AUIPC).srcs(Op.ADD , SRC1.U, SRC2.PC).decode(ALU_CTRL -> ace.ADD_SUB)

    if(Riscv.XLEN.get == 64){
      addUop(Rvi.ADDW ).srcs(Op.ADD   , SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.ADD_SUB)
      addUop(Rvi.SUBW ).srcs(Op.SUB   , SRC1.RF, SRC2.RF).decode(ALU_CTRL -> ace.ADD_SUB)
      addUop(Rvi.ADDIW).srcs(Op.ADD   , SRC1.RF, SRC2.I ).decode(ALU_CTRL -> ace.ADD_SUB)

      for(op <- List(Rvi.ADDW, Rvi.SUBW, Rvi.ADDIW)){
        ifp.signExtend(wb, uopSpecs(op), 32)
      }
    }

    ifpRetainer.release()
    uopRetainer.release()

    val alu = new pp.Execute(executeAt) {
      val ss = SrcStageables

      val bitwise = ALU_BITWISE_CTRL.mux(
        AluBitwiseCtrlEnum.AND  -> (srcp.SRC1 & srcp.SRC2),
        AluBitwiseCtrlEnum.OR   -> (srcp.SRC1 | srcp.SRC2),
        AluBitwiseCtrlEnum.XOR  -> (srcp.SRC1 ^ srcp.SRC2)
      )

      val result = ALU_CTRL.mux(
        AluCtrlEnum.BITWISE  -> bitwise,
        AluCtrlEnum.SLT_SLTU -> S(U(srcp.LESS, Riscv.XLEN bits)),
        AluCtrlEnum.ADD_SUB  -> this(srcp.ADD_SUB)
      )

      ALU_RESULT := result.asBits
    }

    val format = new pp.Execute(formatAt) {
      wb.valid := SEL
      wb.payload := ALU_RESULT
    }
    buildBefore.release()
  }
}

package riscq.execute
import spinal.core._
import spinal.lib._
import spinal.lib.misc.pipeline._
import riscq.riscv.SingleDecoding
import riscq.decode.Decode
import riscq.schedule.PipelinePlugin

object TimerPlugin extends AreaObject {
  val TimerCtrlEnum = new SpinalEnum(binarySequential) {
    val SET, WAIT = newElement()
  }
}

// format:
// | 32 bits  | 64 + 16 bits | 16 bits
// | instTime | 0            | opcode
case class TimerPlugin(width: Int = 32, executeAt: Int = 0) extends ExecutionUnit {
  val logic = during setup new Area {
    import TimerPlugin._
    val CTRL = Payload(TimerCtrlEnum())
    // instruction used to set the time
    val setUop = addUop(SingleDecoding(M"-----------------011000101111111", Nil)) 
                .decode(CTRL -> TimerCtrlEnum.SET) // add decoding logic
                .dontFlushFrom(executeAt) // this instruction has side effect. add hint for generating control hazard logic
    // instruction used to wait until specific time
    val waitUop = addUop(SingleDecoding(M"-----------------011000111111111", Nil)) // 
                 .decode(CTRL -> TimerCtrlEnum.WAIT) // add decoding logic
                 .mayFlushUpTo(executeAt + 1)

    val pp = host[PipelinePlugin]
    val buildBefore = retains(pp.elaborationLock)
    val time = Reg(UInt(width bits))
    out(time)
    time := time + 1
    val targetTime = Reg(time) init 0
    val timeLt = Reg(Bool()) init False

    awaitBuild()
    uopRetainer.release()

    val resetLogic = new pp.Execute(executeAt) {
      // extract the time from the first 32 bits
      val instTime = Decode.INSTRUCTION(128-width, width bits).asUInt
      when(SEL && isValid && CTRL === TimerCtrlEnum.SET) {
          time := instTime // set the current time
      }
    }
    val setWaitLogic = new pp.Execute(executeAt) {
      val instTime = Decode.INSTRUCTION(128-width, width bits).asUInt
      val isEx = SEL && isValid && CTRL === TimerCtrlEnum.WAIT
      val target = isEx.mux(instTime, targetTime)
      when(isEx) {
        targetTime := instTime
      }
    }
    timeLt := (time + 1) < setWaitLogic.target
    val exWaitLogic = new pp.Execute(executeAt + 1) {
      val haltCond = SEL && isValid && (CTRL === TimerCtrlEnum.WAIT) && timeLt
      haltWhen(haltCond)
    }
    buildBefore.release()
  }
}

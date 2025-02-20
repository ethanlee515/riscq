package riscq.execute

import riscq.pulse._
import spinal.core._
import spinal.lib._
import riscq.riscv.{MicroOp, RD, RfResource, SingleDecoding}
import riscq.decode.Decode
import riscq.schedule.PipelinePlugin

class CarrierPlugin(specs: Seq[CarrierGeneratorSpec], idWidth: Int = 5) extends ExecutionUnit {

  val logic = during setup new Area {
    val uop = addUop(SingleDecoding(M"-----------------011000011111111", Nil))

    val pp = host[PipelinePlugin]
    val tp = host[TimerPlugin]
    val buildBefore = retains(pp.elaborationLock)

    awaitBuild()
    
    uopRetainer.release()


    val cgPorts = specs.map(spec => master(CarrierGeneratorPort(spec))).toList

    val num = specs.length
    val freqWidth = specs.head.freqWidth
    val valids = Vec.fill(num)(Bool())
    cgPorts.zipWithIndex.foreach{ case (cg, id) => 
      cg.time := tp.logic.time 
      valids(id) := False
      cg.cmd.valid := valids(id)
    }

    val carrierLogic = new pp.Execute(0) {
      val id = Decode.INSTRUCTION(128 - 5, 5 bits)
      val freq = Decode.INSTRUCTION(128 - 5 - freqWidth, freqWidth bits)
      val phase = Decode.INSTRUCTION(128 - 5 - freqWidth - freqWidth, freqWidth bits)
      cgPorts.foreach{ cg =>
        cg.cmd.freq := freq.asSInt
        cg.cmd.phase := phase.asSInt
      }
      when(SEL && isValid) {
        valids(id.asUInt.resized) := True
      }
    }

    buildBefore.release()
  }
}
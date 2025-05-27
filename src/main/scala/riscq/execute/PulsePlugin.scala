package riscq.execute

import spinal.lib.misc.pipeline._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.core._
import spinal.lib.bus.tilelink.fabric
import spinal.core.sim._
import spinal.idslplugin.PostInitCallback
import riscq.riscv.{MicroOp, RD, RfResource, SingleDecoding}
import riscq.decode.DecoderSimplePlugin
import riscq.decode.Decode
import riscq.pulse._
import riscq.schedule.PipelinePlugin
import riscq.misc.TileLinkMemReadWriteFiber
import riscq.soc.QubicSocParams

class PulsePlugin() extends ExecutionUnit {
  import QubicSocParams._

  val logic = during setup new Area {
    val sel = out Bool()
    sel.simPublic()
    val start = out Bits(pulseStartWidth bits)
    start.simPublic()
    val addr = out Bits(pulseAddrWidth bits)
    addr.simPublic()
    val duration = out Bits(pulseDurWidth bits)
    duration.simPublic()
    val phase = out Bits(pulsePhaseWidth bits)
    phase.simPublic()
    val freq = out Bits(pulseFreqWidth bits)
    freq.simPublic()
    val amp = out Bits(pulseAmpWidth bits)
    amp.simPublic()
    val id = out Bits(pulseIdWidth bits)
    id.simPublic()
    val pulse_inst = Bits(128 bits)
    pulse_inst.simPublic()

    val uop = addUop(SingleDecoding(M"-----------------011000001111111", Nil))
    uop.dontFlushFrom(1)
    val pp = host[PipelinePlugin]
    val buildBefore = retains(pp.elaborationLock)
    awaitBuild()
    uopRetainer.release()
    new pp.Execute(0) {
      sel := SEL && isValid
      val idS = 128 - pulseIdWidth
      val phaseS = idS - pulsePhaseWidth
      val freqS = phaseS - pulseFreqWidth
      val durationS = freqS - pulseDurWidth
      val startS = durationS - pulseStartWidth
      val addrS = startS - pulseAddrWidth
      val ampS = addrS - pulseAmpWidth
      val instruction = Decode.INSTRUCTION
      id := instruction(idS, pulseIdWidth bits)
      phase := instruction(phaseS, pulsePhaseWidth bits)
      freq := instruction(freqS, pulseFreqWidth bits)
      duration := instruction(durationS, pulseDurWidth bits)
      start := instruction(startS, pulseStartWidth bits)
      addr := instruction(addrS, pulseAddrWidth bits)
      amp := instruction(ampS, pulseAmpWidth bits) 
      pulse_inst := instruction
    }
    buildBefore.release()
  }
}

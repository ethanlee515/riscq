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
import riscq.Global._
import riscq.decode.Decode
import riscq.pulse._
import riscq.schedule.PipelinePlugin
import riscq.misc.TileLinkMemReadWriteFiber

case class PulseOpParam(
    addrWidth: Int,
    startWidth: Int,
    durationWidth: Int,
    phaseWidth: Int,
    freqWidth: Int,
    ampWidth: Int,
    idWidth: Int = 5
)

case class Pulse(p: PulseOpParam, instruction: Bits) {
  val idS = 128 - p.idWidth
  val phaseS = idS - p.phaseWidth
  val freqS = phaseS - p.freqWidth
  val durationS = freqS - p.durationWidth
  val startS = durationS - p.startWidth
  val addrS = startS - p.addrWidth
  val ampS = addrS - p.ampWidth
  def id = instruction(idS, p.idWidth bits)
  def phase = instruction(phaseS, p.phaseWidth bits)
  def freq = instruction(freqS, p.freqWidth bits)
  def duration = instruction(durationS, p.durationWidth bits)
  def start = instruction(startS, p.startWidth bits)
  def addr = instruction(addrS, p.addrWidth bits)
  def amp = instruction(ampS, p.ampWidth bits)
}

class PulseGeneratorPlugin(puop: PulseOpParam, specs: Seq[PulseGeneratorSpec]) extends ExecutionUnit {
  for(spec <- specs) {
    assert(spec.phaseWidth == puop.phaseWidth)
    assert(spec.freqWidth == puop.freqWidth)
    assert(spec.ampWidth == puop.ampWidth)
  }

  val logic = during setup new Area {
    val uop = addUop(SingleDecoding(M"-----------------011000001111111", Nil))
    uop.dontFlushFrom(1)

    val pp = host[PipelinePlugin]
    val buildBefore = retains(pp.elaborationLock)

    awaitBuild()

    uopRetainer.release()

    val pgPorts = specs.map(spec => master(Stream(PulseEvent(spec)))).toList
    val valids = Vec.fill(specs.length)(Reg(Bool()) init False)
    valids.map { _ := False }
    (pgPorts zip valids).foreach { case (pg, valid) => pg.valid := valid }

    val pulseLogic = new pp.Execute(0) {
      val instBuffer = Vec.fill(specs.length)(Reg(this(Decode.INSTRUCTION))) // for timing
      for((pg, buf) <- pgPorts zip instBuffer) {
        buf := Decode.INSTRUCTION
        val pulse = Pulse(puop, buf)
        pg.start := U(pulse.start).resized
        pg.cmd.addr := U(pulse.addr).resized
        pg.cmd.duration := U(pulse.duration).resized
        pg.cmd.phase := S(pulse.phase).resized
        pg.cmd.freq := S(pulse.freq).resized
        pg.cmd.amp := S(pulse.amp).resized
      }
      val pulse = Pulse(puop, Decode.INSTRUCTION)
      valids(pulse.id.asUInt.resized) := SEL && down.isFiring
    }

    buildBefore.release()
  }
}

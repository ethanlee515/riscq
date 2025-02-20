package riscq.execute

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import riscq.pulse.Complex

object DacAdcBundle {
  def apply(batchSize: Int, dataWidth: Int) = Vec.fill(batchSize)(Complex(dataWidth))
}

case class DacAdcPlugin(dacBatchSize: Int, adcBatchSize: Int, dataWidth: Int, dacNum: Int = 1, adcNum: Int = 1) extends FiberPlugin {
  val logic = during setup new Area {
    val dac = out port Vec.fill(dacNum)(Flow(DacAdcBundle(dacBatchSize, dataWidth)))
    val adc = in port Vec.fill(adcNum)(Flow(DacAdcBundle(adcBatchSize, dataWidth)))
  }
}

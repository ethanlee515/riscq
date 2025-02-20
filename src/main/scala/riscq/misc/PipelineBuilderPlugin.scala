package riscq.misc

import spinal.core._

import spinal.core.Area
import spinal.core.fiber.Retainer
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.misc.pipeline
import spinal.lib.misc.pipeline.StageLink
import riscq.schedule.PipelinePlugin

class PipelineBuilderPlugin extends FiberPlugin{
  val elaborationLock = Retainer()
  val logic = during build new Area{
    elaborationLock.await()
    val chunks = host.list[PipelinePlugin]
    val links = chunks.flatMap(_.getLinks())
    pipeline.Builder(links)
  }
}

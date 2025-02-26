package riscq.schedule

import spinal.core._
import spinal.core.fiber.RetainerGroup
import spinal.lib._
import spinal.lib.misc.pipeline.CtrlLink
import spinal.lib.misc.plugin.FiberPlugin
import riscq.Global
import riscq.fetch.PcService

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer

class ReschedulePlugin extends FiberPlugin with ScheduleService {
  val flushPortsShared = mutable.LinkedHashMap[Nameable, Flow[FlushCmd]]()
  val flushPorts = ArrayBuffer[Flow[FlushCmd]]()
  val ctrls      = ArrayBuffer[CtrlSpec]()

  case class CtrlSpec(ctrl : CtrlLink)

  override def newFlushPort(age: Int) = flushPorts.addRet(Flow(FlushCmd(age)))
  override def isFlushedAt(age: Int): Option[Bool] = {
    elaborationLock.await()
    val filtred = flushPorts.filter(p => p.age >= age)
    if(filtred.isEmpty) return None
    val hits = filtred.map(p => p.age match {
      case `age` => p.valid && p.self
      case _ => p.valid
    })
    Some(hits.orR)
  }


  val logic = during build new Area{
    val ps = host[PcService]
    val pp = host[PipelinePlugin]
    val retainer = retains(ps.elaborationLock, pp.elaborationLock)
    elaborationLock.await() 
    retainer.release()
  }
}

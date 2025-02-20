package riscq.schedule

import spinal.core._
import spinal.core.fiber.Retainer
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.misc.pipeline
import spinal.lib.misc.pipeline.{CtrlLink, CtrlLinkMirror, Link}
import riscq.Global

import scala.collection.mutable
import riscq.misc.PipelineBuilderPlugin

trait PipelineService{
  def getLinks() : Seq[Link]
}

class PipelinePlugin(val withFetchStage: Boolean = true, val withDecodeStage: Boolean = true) extends FiberPlugin with PipelineService{
  val elaborationLock = Retainer()

  def feGetAge(id: Int ) = id * Ages.STAGE
  def deGetAge(id: Int ) = id * Ages.STAGE + 100
  def exGetAge(id: Int ) = id * Ages.STAGE + 200

  var connectors = mutable.ArrayBuffer[Link]()
  override def getLinks(): Seq[Link] = connectors
  val feIdToCtrl = mutable.LinkedHashMap[Int, pipeline.CtrlLink]() // instruction fetch pipeline
  val deIdToCtrl = mutable.LinkedHashMap[Int, pipeline.CtrlLink]() // instruction decoding pipeline
  val exIdToCtrl = mutable.LinkedHashMap[Int, pipeline.CtrlLink]() // execution pipeline
  def fetch(id : Int) = feIdToCtrl.getOrElseUpdate(id, pipeline.CtrlLink().setName(s"fetch${id}"))
  def decode(id : Int) = deIdToCtrl.getOrElseUpdate(id, pipeline.CtrlLink().setName(s"decode${id}"))

  def executeName(id: Int) = if(id < 0) s"pre_execute_${-id}" else s"execute${id}"
  def execute(id : Int) = exIdToCtrl.getOrElseUpdate(id, pipeline.CtrlLink().setName(executeName(id)))

  def up = fetch(0).up
  val logic = during setup new Area{
    val pbp = host[PipelineBuilderPlugin]
    val buildBefore = retains(pbp.elaborationLock)

    awaitBuild()
    elaborationLock.await()
    val feCtrls = feIdToCtrl.toList.sortBy(_._1).map(_._2)
    val deCtrls = deIdToCtrl.toList.sortBy(_._1).map(_._2)
    val exCtrls = exIdToCtrl.toList.sortBy(_._1).map(_._2)
    val sc = List(feCtrls, deCtrls).flatMap { ctrls =>
      (for((from, to) <- (ctrls, ctrls.tail).zipped) yield new pipeline.StageLink(from.down, to.up)).toSeq
    }
    val feDeSc = List(pipeline.StageLink(feCtrls.last.down, deCtrls.head.up))
    val exSc = (for((from, to) <- (exCtrls, exCtrls.tail).zipped) yield new pipeline.StageLink(from.down, to.up)).toSeq
    exSc.foreach{_.withoutCollapse()}

    val skidBufferNode = pipeline.Node()
    val skidSc = List(pipeline.StageLink(deCtrls.last.down, skidBufferNode), pipeline.S2MLink(skidBufferNode, exCtrls.head.up))

    connectors ++= (feCtrls ++ deCtrls ++ exCtrls ++ sc ++ exSc ++ feDeSc ++ skidSc).toSeq

    val rp = host[ReschedulePlugin]
    val ctrlAges = 
      feIdToCtrl.map{case (id, ctrl) => (ctrl, feGetAge(id))}.toList.tail ++
      deIdToCtrl.map{case (id, ctrl) => (ctrl, deGetAge(id))}.toList ++ 
      exIdToCtrl.map{case (id, ctrl) => (ctrl, exGetAge(id))}.toList
    val flushLogic = 
      for((ctrl, age) <- ctrlAges) yield new Area {
        val doIt = rp.isFlushedAt(age)
        doIt.foreach(v =>
          ctrl.throwWhen(v, usingReady = false)
        )
      }
    buildBefore.release()
  }

  class Fetch(id : Int) extends CtrlLinkMirror(fetch(id))
  class Decode(id : Int) extends CtrlLinkMirror(decode(id))
  class Execute(id : Int) extends CtrlLinkMirror(execute(id))
}

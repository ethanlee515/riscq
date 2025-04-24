package riscq.execute

import spinal.core._
import spinal.core.fiber.Retainer
import spinal.lib.misc.pipeline._
import spinal.lib.{Flow, OHMux}
import spinal.lib.misc.plugin.FiberPlugin
import riscq.regfile.{RegFileWriter, RegFileWriterService, RegfileService}
import riscq.riscv.{MicroOp, RD, RegfileSpec}
import riscq.decode.Decode._
import riscq.schedule.PipelinePlugin

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import riscq.decode.DecoderService
import riscq.Global

class WriteBackPlugin(val rf : RegfileSpec,
                      var writeAt : Int,
                      var allowBypassFrom : Int
                      ) extends FiberPlugin with RegFileWriterService{
  assert(allowBypassFrom >= 0)

  val elaborationLock = Retainer()

  case class Spec(port : Flow[Bits], ctrlAt : Int){ // ctrlAt is for bypassing
    val impls = ArrayBuffer[UopSpec]()
  }
  val portToSpec = mutable.LinkedHashMap[Flow[Bits],Spec]()
  def createPort(at : Int): Flow[Bits] = {
    val port = Flow(Bits(rf.width bits))
    portToSpec(port) = Spec(port, at)
    port
  }
  def addMicroOp(port: Flow[Bits], head: UopSpec, tail: UopSpec*): Unit = addMicroOp(port, head +: tail)
  def addMicroOp(port: Flow[Bits], impls: Seq[UopSpec]): Unit = {
    val spec = portToSpec(port)
    spec.impls ++= impls
  }

  val SEL = Payload(Bool())

  val logic = during setup new Area {
    val pp = host[PipelinePlugin]
    val dp = host[DecoderService]
    val rfp = host.find[RegfileService](_.rfSpec == rf)
    val buildBefore = retains(pp.elaborationLock, rfp.elaborationLock)
    val eus = host.list[ExecutionUnit]
    val uopRetainer = retains(eus.map(_.uopLock))

    for(i <- -1 to writeAt){
      pp.execute(i)
    }
    awaitBuild()

    elaborationLock.await()

    val specs = portToSpec.values
    val grouped = specs.groupByLinked(_.ctrlAt).values
    val sorted = grouped.toList.sortBy(_.head.ctrlAt)
    val DATA = Payload(Bits(rf.width bits))
    val broadcastMin = Math.min(writeAt + rfp.writeLatency, allowBypassFrom)
    dp.addPayloadDefault(SEL, False)
    for (group <- sorted) {
      val ctrlId = group.head.ctrlAt
      for (spec <- group) {
        for (impl <- spec.impls) {
          impl.setRdSpec(DATA, Math.max(ctrlId, broadcastMin), writeAt + rfp.writeLatency)
          impl.decode(SEL -> True)
          impl.dontFlushFrom(writeAt+1)
        }
      }
    }
    uopRetainer.release()

    val rfa = rfaKeys.get(RD)
    val stages = for (group <- sorted; ctrlId = group.head.ctrlAt) yield new pp.Execute(ctrlId) {
      val hits = B(group.map(_.port.valid))
      val muxed = OHMux.or(hits, group.map(_.port.payload))
      val merged = if(group == sorted.head) muxed else (up(DATA) | muxed)
      bypass(DATA) := merged

      // use for whitebox testing
      val write = Flow(RegFileWriter(rf))
      write.valid := down.isFiring && hits.orR && rfa.ENABLE // && !Global.TRAP
      write.data := muxed
    }


    val write = new pp.Execute(writeAt){
      val port = rfp.newWrite(false)
      port.valid := isValid && isReady && rfa.ENABLE && SEL
      port.address := rfa.PHYS
      port.data := DATA
    }
    buildBefore.release()
  }

  override def getRegFileWriters(): Seq[Flow[RegFileWriter]] = logic.stages.map(_.write)
}


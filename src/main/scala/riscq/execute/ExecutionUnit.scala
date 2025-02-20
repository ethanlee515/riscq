package riscq.execute

import spinal.lib.misc.pipeline._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.core._
import spinal.idslplugin.PostInitCallback
import spinal.lib.Flow
import riscq.riscv.{MicroOp, RD, RfResource}
import riscq.decode.DecoderService

import scala.collection.mutable
import spinal.core.fiber.Retainer
import spinal.core.fiber.RetainerGroup
import _root_.riscq.riscv.IntRegFile
import riscq.riscv.RfWrite


abstract class ExecutionUnit extends FiberPlugin {
  val SEL = Payload(Bool())

  var iwbpp = Option.empty[(IntFormatPlugin, Flow[Bits])]
  def setWriteback(ifp : IntFormatPlugin, bus : Flow[Bits]): Unit = {
    iwbpp = Some(ifp -> bus)
  }
  def newWriteback(ifp: IntFormatPlugin, at : Int) : Flow[Bits] = {
    val bus = ifp.access(at)
    setWriteback(ifp, bus)
    bus
  }
  val uopLock = Retainer() 
  val uopSpecs = mutable.LinkedHashMap[MicroOp, UopSpec]()
  def getUopSpecs(): Iterable[UopSpec] = {
    uopLock.await()
    uopSpecs.values
  }
  // has to be after newWriteBack if there is a writeback
  def addUop(uop: MicroOp): UopSpec = {
    assert(!uopSpecs.contains(uop))
    val spec = UopSpec(uop)
    uopSpecs(uop) = spec
    spec.decode(SEL -> True)
    uop.resources.foreach{
      case RfResource(IntRegFile, _: RfWrite) => iwbpp.foreach{v => v._1.addMicroOp(v._2, spec)}
      case _ =>
    }
    spec
  }

  // release after addUop, srcs, decode, addRsSpec, mayFlushUpTo, dontFlushFrom, newWriteBack
  val uopRetainer = retains(uopLock)

  val decLogic = during setup new Area {
    val dp = host[DecoderService]
    val sp = host.get[SrcPlugin]
    val dpLock = retains(dp.elaborationLock)
    val spLock = sp.map{p => retains(p.elaborationLock)}

    awaitBuild()

    dp.addPayloadDefault(SEL, False)

    uopLock.await()

    for((uop, spec) <- uopSpecs) {
      for(key <- spec.srcKeySpecs) {
        sp.map{_.specify(spec, key)}
      }
    }
    spLock.map{_.release()}
    sp.map{p => p.logic.await()} // wait until SRC1_CTRL, SRC2_CTRL are set in SrcPlugin
    for((uop, spec) <- uopSpecs) {
      for((payload, value) <- spec.decodings) {
        dp.addMicroOpDecoding(uop, payload, value)
      }
    }
    dpLock.release()
  }
}
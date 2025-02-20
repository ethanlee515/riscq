package riscq.execute

import spinal.core._
import spinal.lib._
import spinal.lib.misc.pipeline._
import riscq.riscv.RegfileSpec
import riscq.riscv.{RfRead, RfWrite, RfResource, MicroOp}
import riscq.decode.DecoderService
import scala.collection.mutable
import riscq.riscv.RD

case class RdSpec(rf : RegfileSpec,
                  DATA: Payload[Bits],
                  broadcastedFrom : Int, // ctrl id that rd result is available
                  rfReadableFrom : Int) // ctrl id that rd is written to the regfile

case class RsSpec(rf : RegfileSpec, rs : RfRead){
  var from = 0 // ctrl id from which rs is required
}


case class UopSpec(uop: MicroOp) {
  var rd = Option.empty[RdSpec]
  var rs = mutable.LinkedHashMap[RfRead, RsSpec]()
  val decodings = mutable.LinkedHashMap[Payload[_ <: BaseType], AnyRef]()
  val srcKeySpecs = mutable.ArrayBuffer[SrcKeys]()
  var mayFlushUpTo = Option.empty[Int]
  var dontFlushFrom = Option.empty[Int]

  def addRsSpec(rfRead : RfRead, executeAt : Int) = {
    assert(!rs.contains(rfRead))
    val rf = uop.resources.collectFirst{
      case r : RfResource if r.access == rfRead => r.rf
    }.get
    val rsSpec = rs.getOrElseUpdate(rfRead, new RsSpec(rf, rfRead))
    rsSpec.from = executeAt
  }
  def setRdSpec(data: Payload[Bits], broadcastedFrom : Int, rfReadableFrom : Int): Unit = {
    assert(rd.isEmpty)
    // println(s"DEBUG: ${uop}, ${uop.resources}")
    val rf = uop.resources.collectFirst {
      case r: RfResource if r.access == RD => r.rf
    }.get
    rd = Some(RdSpec(rf, data, broadcastedFrom, rfReadableFrom))
  }
  def doCheck(): Unit = {
    uop.resources.foreach{
      case RfResource(_, rfRead: RfRead) => assert(rs.contains(rfRead), s"$$uop doesn't has the $rfRead specification set")
      case RfResource(_, rfWrite: RfWrite) => assert(rd.nonEmpty, s"$uop doesn't has the rd specification set")
      case _ =>
    }
  }

  def decode(head: (Payload[_ <: BaseType], AnyRef), tail: (Payload[_ <: BaseType], AnyRef)*): UopSpec = decode(head :: tail.toList)
  def decode(values: Seq[(Payload[_ <: BaseType], AnyRef)]): UopSpec = {
    for ((key, value) <- values) {
      decodings(key) = value
    }
    this
  }

  def srcs(srcKeys: Seq[SrcKeys]): this.type = {
    if (srcKeys.nonEmpty) srcKeySpecs ++= srcKeys
    this
  }
  def srcs(head: SrcKeys, tail: SrcKeys*): this.type = {
    this.srcs(head +: tail)
    this
  }

  def mayFlushUpTo(ctrlId: Int): Unit = {
    var at = ctrlId
    mayFlushUpTo.foreach(v => v max at)
    mayFlushUpTo = Some(at)
  }
  def dontFlushFrom(ctrlId: Int): Unit = {
    var at = ctrlId
    dontFlushFrom.foreach(v => v min at)
    dontFlushFrom = Some(at)
  }

}
package riscq.decode

import spinal.core._
import spinal.lib.misc.database.Database._
import spinal.lib.misc.pipeline.Payload
import riscq.Global
import riscq.fetch.Fetch
import riscq.riscv.{RegfileSpec, RfAccess, MicroOp}

import java.util
import scala.collection.mutable
import spinal.core.fiber.Retainer

object Decode extends AreaObject {
  val INSTRUCTION_WIDTH = blocking[Int]
  val INSTRUCTION = Payload(Bits(INSTRUCTION_WIDTH bits))
  val INSTRUCTION_RAW = Payload(Bits(INSTRUCTION_WIDTH bits))
  val UOP = Payload(Bits(UOP_WIDTH bits))
  def UOP_WIDTH = INSTRUCTION_WIDTH.get

  val rfaKeys = blocking[mutable.LinkedHashMap[RfAccess, AccessKeys]]
}

case class AccessKeys(rfa : RfAccess, physWidth : Int, rfMapping : Seq[RegfileSpec]) extends Area{
  val rfIdWidth = log2Up(rfMapping.size)
  def is(rfs: RegfileSpec, that: UInt) = that === idOf(rfs)
  def idOf(rfs: RegfileSpec) = rfMapping.indexOf(rfs)

  val ENABLE = Payload(Bool()) // Note that for the execute pipeline, it is important for timings to use execute(x).up(rd.ENABLE)
  val PHYS = Payload(UInt(physWidth bits))
  val RFID = Payload(UInt(rfIdWidth bits))
}

trait DecoderService {
  val elaborationLock = Retainer()
  def addMicroOpDecoding(microOp: MicroOp, key: Payload[_ <: BaseType], value: AnyRef)
  def addPayloadDefault(key: Payload[_ <: BaseType], value: AnyRef)
}
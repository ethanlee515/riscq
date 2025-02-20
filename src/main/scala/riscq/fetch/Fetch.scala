package riscq.fetch

import spinal.core._
import spinal.lib.misc.pipeline.Payload
import spinal.lib.misc.database.Database._
import riscq.Global

object Fetch extends AreaObject {
  val WORD_WIDTH  = blocking[Int]
  def WORD_BYTES = WORD_WIDTH/8
  def PC_LOW = log2Up(WORD_BYTES)
  val ID_WIDTH = blocking[Int]
  val WORD = Payload(Bits(WORD_WIDTH bits))
  val WORD_PC = Payload(Global.PC)

  val ID = Payload(UInt(ID_WIDTH bits))

}


package riscq.schedule

import spinal.core._
import spinal.core.fiber.{Retainer, Lockable}
import spinal.lib.Flow
import spinal.lib.misc.pipeline.CtrlLink
import riscq.Global
import riscq.decode.Decode
import riscq.fetch.JumpCmd

object Ages {
  val STAGE = 10
  val NOT_PREDICTION = 1
  val FETCH = 0
  val DECODE = 1000
  val EU = 2000
  val TRAP = 3000
}

case class FlushCmd(age : Int) extends Bundle{
  val self = Bool()
}

// case class TrapCmd(age : Int, pcWidth : Int, tvalWidth : Int, causeWidth : Int, trapArgWidth : Int) extends Bundle {
//   val cause      = UInt(causeWidth bits)
//   val tval       = Bits(tvalWidth bits)
//   val arg        = Bits(trapArgWidth bits)
//   val skipCommit = Bool() //Want to skip commit for exceptions, but not for [jump, ebreak, redo]
// }

trait ScheduleService {
  def newFlushPort(age: Int): Flow[FlushCmd]
  // def newTrapPort(age : Int, causeWidth : Int = 4) : Flow[TrapCmd]
  def isFlushedAt(age: Int): Option[Bool]

  val elaborationLock = Retainer()
}



package riscq.fetch

import spinal.core._
import spinal.core.fiber.{Retainer, Lockable}
import spinal.lib.{misc, _}
import spinal.lib.misc.plugin.Plugin
import riscq._
import riscq.Global._

import scala.collection.mutable.ArrayBuffer

case class JumpCmd() extends Bundle{
  val pc = PC()
}

case class PcServiceHoldPortSpec(hartId : Int, valid : Bool)
trait PcService {
  val elaborationLock = Retainer()
  def newJumpInterface(age: Int) : Flow[JumpCmd] //High priority win
  def simSetPc(value : Long) : Unit
  def forcedSpawn() : Bool //As fetch stage 0 isn't persistant, this provide the information when a persistance break happend (ex to fork again a transaction to the memory system)
  def newHoldPort(hartId : Int) : Bool = holdPorts.addRet(PcServiceHoldPortSpec(hartId, Bool())).valid
  val holdPorts = ArrayBuffer[PcServiceHoldPortSpec]()
}

trait InitService{
  def initHold() : Bool
}
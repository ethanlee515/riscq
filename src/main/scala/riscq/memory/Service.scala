package riscq.memory

import spinal.core._
import spinal.core.fiber.Retainer
import spinal.lib._
import spinal.lib.misc.pipeline._
import spinal.lib.misc.plugin._
import riscq.Global
import riscq.Global._
import riscq.riscv.Riscv

import scala.collection.mutable.ArrayBuffer

trait DBusAccessService{
  def accessRefillCount : Int
  def accessWake: Bits
  def newDBusAccess() : DBusAccess = dbusAccesses.addRet(new DBusAccess(accessRefillCount))
  val dbusAccesses = ArrayBuffer[DBusAccess]()
  val accessRetainer = Retainer()
}

case class DBusAccess(refillCount : Int) extends Bundle {
  val cmd = Stream(DBusAccessCmd())
  val rsp = Flow(DBusAccessRsp(refillCount))
}

case class DBusAccessCmd() extends Bundle {
  val address = Global.PHYSICAL_ADDRESS()
  val size = UInt(2 bits)
}

case class DBusAccessRsp(refillCount : Int) extends Bundle {
  val data = Bits(Riscv.XLEN bits)
  val error = Bool()
  val redo = Bool()
  val waitSlot = Bits(refillCount bits)
  val waitAny  = Bool()
}

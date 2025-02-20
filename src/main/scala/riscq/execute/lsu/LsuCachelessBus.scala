package riscq.execute.lsu

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.core.fiber.Retainer
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.bus.tilelink
import spinal.lib.bus.tilelink.DebugId

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import spinal.core.fiber.Fiber


case class LsuCachelessBusParam(addressWidth : Int, dataWidth : Int, pendingMax : Int){
  def toTilelinkM2s(name: Nameable) = {
    // assert(!withAmo)
    new tilelink.M2sParameters(
      addressWidth = addressWidth,
      dataWidth = dataWidth,
      masters = List(
        new tilelink.M2sAgent(
          name = name,
          mapping = List(
            new tilelink.M2sSource(
              id = SizeMapping(0, pendingMax),
              emits = tilelink.M2sTransfers(
                get = tilelink.SizeRange(1, dataWidth / 8),
                putFull = tilelink.SizeRange(1, dataWidth / 8)
              )
            )
          )
        )
      )
    )
  }
}

case class LsuCachelessCmd(p : LsuCachelessBusParam) extends Bundle{
  val id = UInt(log2Up(p.pendingMax) bits)
  val write = Bool()
  val address = UInt(p.addressWidth bits)
  val data = Bits(p.dataWidth bit)
  val size = UInt(log2Up(log2Up(p.dataWidth / 8) + 1) bits)
  val mask = Bits(p.dataWidth / 8 bits)
}

case class LsuCachelessRsp(p : LsuCachelessBusParam, withId : Boolean = true) extends Bundle{
  val id = withId generate UInt(log2Up(p.pendingMax) bits)
  val error = Bool()
  val data  = Bits(p.dataWidth bits)
}

case class LsuCachelessBus(p : LsuCachelessBusParam) extends Bundle with IMasterSlave {
  var cmd = Stream(LsuCachelessCmd(p))
  var rsp = Flow(LsuCachelessRsp(p))

  override def asMaster(): Unit = {
    master(cmd)
    slave(rsp)
  }
}

class LsuCachelessBramConnectArea(lsu: LsuCachelessPlugin, port: MemReadWritePort[Bits]) extends Area {
  val logic = Fiber build new Area {
    port.enable := lsu.logic.bus.cmd.valid
    port.mask.setAllTo(True)
    port.address := lsu.logic.bus.cmd.address(2, port.address.getBitsWidth bit)
    port.write := lsu.logic.bus.cmd.write
    port.wdata := lsu.logic.bus.cmd.data

    val id1 = RegNext(lsu.logic.bus.cmd.id)
    val id2 = RegNext(id1)
    val valid1 = RegNext(lsu.logic.bus.cmd.valid)
    val valid2 = RegNext(valid1)

    when(lsu.logic.bus.cmd.valid && lsu.logic.bus.cmd.write && !valid1 && !valid2) {
      id2 := lsu.logic.bus.cmd.id
      valid2 := True
      valid1 := False
    }

    val word = RegNext(port.rdata)

    lsu.logic.bus.rsp.id := id2
    lsu.logic.bus.rsp.error := False
    lsu.logic.bus.rsp.data := word
    lsu.logic.bus.rsp.valid := valid2
    lsu.logic.bus.cmd.ready := True
  }
}
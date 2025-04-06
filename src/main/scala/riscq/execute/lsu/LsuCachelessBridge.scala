package riscq.execute.lsu

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.bus.tilelink
import spinal.lib.bus.tilelink.{DebugId, S2mSupport}
import spinal.lib.misc.pipeline._

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer

class LsuCachelessBusToTilelink(up : LsuCachelessBus, hashWidth : Int) extends Area{
  // assert(!up.p.withAmo)

  val m2sParam = up.p.toTilelinkM2s(this)
  val down = tilelink.Bus(m2sParam)

  val cmdHash = up.cmd.address(log2Up(up.p.dataWidth / 8), hashWidth bits)

  down.a.arbitrationFrom(up.cmd)
  down.a.opcode  := up.cmd.write.mux(tilelink.Opcode.A.PUT_FULL_DATA, tilelink.Opcode.A.GET)
  down.a.param   := 0
  down.a.source  := up.cmd.id
  down.a.address := up.cmd.address
  down.a.size    := up.cmd.size
  down.a.debugId := DebugId.withPostfix(up.cmd.id)
  down.a.mask    := up.cmd.mask
  down.a.data    := up.cmd.data
  down.a.corrupt := False

  down.d.ready := True
  up.rsp.valid := down.d.valid
  up.rsp.id    := down.d.source
  up.rsp.error := down.d.denied
  up.rsp.data  := down.d.data
}


class LsuCachelessTileLinkPlugin(node : bus.tilelink.fabric.Node, hashWidth : Int = 8) extends FiberPlugin {
  val logic = during build new Area{
    val lsucp = host[LsuCachelessPlugin]

    node.m2s.forceParameters(lsucp.busParam.toTilelinkM2s(LsuCachelessTileLinkPlugin.this))
    node.s2m.supported.load(S2mSupport.none())

    lsucp.logic.bus.setAsDirectionLess()

    val bridge = new LsuCachelessBusToTilelink(lsucp.logic.bus, hashWidth)
    master(bridge.down)
    node.bus.component.rework(node.bus << bridge.down)
  }
}

class LsuCachelessNoStoreRspTileLinkPlugin(node : bus.tilelink.fabric.Node, hashWidth : Int = 8) extends FiberPlugin {
  val logic = during build new Area{
    val lsucp = host[LsuCachelessNoStoreRspPlugin]

    node.m2s.forceParameters(lsucp.busParam.toTilelinkM2s(LsuCachelessNoStoreRspTileLinkPlugin.this))
    node.s2m.supported.load(S2mSupport.none())

    lsucp.logic.bus.setAsDirectionLess()

    val bridge = new LsuCachelessBusToTilelink(lsucp.logic.bus, hashWidth)
    master(bridge.down)
    node.bus.component.rework(node.bus << bridge.down)
  }
}
package riscq.scratch

import spinal.core._
import spinal.core.fiber._
import spinal.lib._
import spinal.lib.bus.tilelink._
import spinal.lib.bus.tilelink.coherent.OrderingCmd
import spinal.lib.system.tag.PMA
import spinal.lib.bus.tilelink.fabric.Node
import spinal.lib.pipeline._

case class TileLinkMemWriteFiber[T <: Data](wp: Flow[MemWriteCmdWithMask[T]]) extends Area{
  val up = Node.up()
  // up.addTag(PMA.MAIN)
  // up.addTag(PMA.EXECUTABLE)

  val thread = Fiber build new Area{
    val dataBytes = wp.data.getBitsWidth / 8
    up.forceDataWidth(wp.data.getBitsWidth)
    up.m2s.supported load up.m2s.proposed.intersect(M2sTransfers.allGetPut).copy(addressWidth = wp.address.getBitsWidth + log2Up(dataBytes))
    up.s2m.none()

    val logic = new TileLinkMemReadLogic(up.bus.p.node, wp)
    logic.io.up << up.bus
  }
}

class TileLinkMemReadLogic[T <: Data](p : NodeParameters, port: Flow[MemWriteCmdWithMask[T]]) extends Area {
  // val mem = Mem.fill(bytes/p.m.dataBytes)(Bits(p.m.dataWidth bits))
  val io = new Area{
    val up = Bus(p)
    // val read = slave port MemReadPort(Bits(p.m.dataWidth bits), log2Up(bytes/p.m.dataBytes))
    // val read = slave port mem.readSyncPort()
  }
  val dataBytes = port.data.getBitsWidth / 8
  val addressWidth = port.address.getBitsWidth + log2Up(dataBytes)
  // io.read <> mem.readSyncPort()

  // val port = mem.readWriteSyncPort(p.m.dataBytes)

  val pipeline = new Pipeline{
    val cmd = new Stage{
      val IS_PUT = insert(Opcode.A.isPut(io.up.a.opcode))
      val SIZE = insert(io.up.a.size)
      val SOURCE = insert(io.up.a.source)
      val LAST = insert(True)

      valid := io.up.a.valid
      io.up.a.ready := isReady

      // val addressShifted = (io.up.a.address)
      // val addressShifted = (io.up.a.address >> log2Up(p.m.dataBytes))
      val addressShifted = (io.up.a.address >> log2Up(dataBytes))
      // port.enable := isFireing
      port.valid := IS_PUT
      // port.data := io.up.a.data
      port.data.assignFromBits(io.up.a.data)
      port.mask := io.up.a.mask

      val withFsm = io.up.p.beatMax != 1
      if (!withFsm) port.address := addressShifted
      val fsm = withFsm generate new Area {
        val counter = Reg(io.up.p.beat) init (0)
        val address = Reg(cloneOf(port.address))
        val size = Reg(io.up.p.size)
        val source = Reg(io.up.p.source)
        val isGet = Reg(Bool())
        val busy = counter =/= 0
        // when(busy && isGet) {
        //   io.up.a.ready := False
        //   valid := True
        // }

        when(io.up.a.fire && !busy){
          size := io.up.a.size
          source := io.up.a.source
          // isGet := Opcode.A.isGet(io.up.a.opcode)
          address := addressShifted
        }

        LAST clearWhen(counter =/= sizeToBeatMinusOne(io.up.p,SIZE))
        when(busy){
          SIZE := size
          SOURCE := source
          // IS_GET := isGet
        }
        when(isFireing) {
          counter := counter + 1
          when(LAST) {
            counter := 0
          }
        }
        port.address := busy.mux(address, addressShifted) | counter.resized
      }

    }

    val rsp = new Stage(Connection.M2S()){
      // val takeIt = cmd.LAST || cmd.IS_GET
      val takeIt = cmd.LAST //|| cmd.IS_GET
      haltWhen(!io.up.d.ready && takeIt)
      io.up.d.valid := valid && takeIt
      // io.up.d.opcode := cmd.IS_GET.mux(Opcode.D.ACCESS_ACK_DATA, Opcode.D.ACCESS_ACK)
      io.up.d.opcode := Opcode.D.ACCESS_ACK
      io.up.d.param := 0
      io.up.d.source := cmd.SOURCE
      io.up.d.size := cmd.SIZE
      io.up.d.denied := False
      io.up.d.corrupt := False
      // io.up.d.data := port.rdata
      io.up.d.data := 0
    }
    build()
  }
}

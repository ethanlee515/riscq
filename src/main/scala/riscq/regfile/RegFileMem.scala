package riscq.regfile

import spinal.core._
import spinal.core.fiber._
import spinal.lib._
import spinal.lib.eda.bench.{Bench, Rtl, XilinxStdTargets}
import spinal.lib.misc.plugin.FiberPlugin
import riscq.riscv.RegfileSpec

import scala.collection.mutable.ArrayBuffer

case class RegFileReadParameter(withReady : Boolean)
case class RegFileWriteParameter(withReady : Boolean)

case class MemWriteCmd[T <: Data](payloadType : HardType[T], depth : Int) extends Bundle{
  val address = UInt(log2Up(depth) bits)
  val data    = payloadType()
}


case class MemRead[T <: Data](payloadType : HardType[T], depth : Int) extends Bundle with IMasterSlave {
  val cmd = Flow(UInt(log2Up(depth) bits))
  val rsp = payloadType()

  override def asMaster() = {
    master(cmd)
    in(rsp)
  }
}

case class RamMwIo[T <: Data](payloadType : HardType[T], depth : Int, writePorts : Int, readPorts : Int) extends Bundle {
  val writes = Vec.fill(writePorts)(slave(Flow(MemWriteCmd(payloadType, depth))))
  val read = Vec.fill(readPorts)(slave(MemRead(payloadType, depth)))
}


//The bankCount is currently useless, but maybe useful in the future with execution units which can stall
class RegFileMem(rfpp : RegFilePortParam,
                 readsParameter  : Seq[RegFileReadParameter],
                 writesParameter : Seq[RegFileWriteParameter],
                 headZero        : Boolean,
                 syncRead        : Boolean,
                 dualPortRam     : Boolean,
                 asyncReadBySyncReadRevertedClk : Boolean = false,
                 maskReadDuringWrite: Boolean = true) extends Component {
  import rfpp._

  val io = RegFileIo(rfpp, readsParameter, writesParameter)
  io.reads.foreach(e => assert(!e.withReady))
  io.writes.foreach(e => assert(!e.withReady))

  val conv = RamMwIo(Bits(rfpp.dataWidth bits), 1 << rfpp.addressWidth, writesParameter.size, readsParameter.size).setAsDirectionLess()
  for((to, from) <- (conv.writes, io.writes).zipped){
    to.valid := from.valid
    to.address := from.address
    to.data := from.data
  }
  for ((to, from) <- (conv.read, io.reads).zipped) {
    to.cmd.valid := from.valid
    to.cmd.payload := from.address
    from.data := to.rsp
  }

  assert(writesParameter.size == 1)

  val asMem = new Area {
    val ram = Mem.fill((1 << addressWidth))(Bits(dataWidth bits))
    ram.initBigInt(List.fill(1 << addressWidth)(BigInt(0)))
    Verilator.public(ram)

    val writes = for ((w, i) <- conv.writes.zipWithIndex) yield new Area {
      val port = ram.writePort()
      port.valid := w.valid
      port.address := w.address
      port.data := w.data
    }

    val reads = for ((r, i) <- conv.read.zipWithIndex) yield new Area {
      val async = !syncRead generate new Area {
        val port = if (asyncReadBySyncReadRevertedClk) ram.readAsyncPortBySyncReadRevertedClk else ram.readAsyncPort
        port.address := r.cmd.payload
        r.rsp := port.data
      }
      val sync = syncRead generate new Area {
        val port = ram.readSyncPort
        port.cmd.valid := r.cmd.valid
        port.cmd.payload := r.cmd.payload
        r.rsp := port.rsp
      }
    }
  }
}
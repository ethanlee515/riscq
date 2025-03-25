package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._

case class PulseMemReader(
  batchSize: Int,
  dataWidth: Int,
  addrWidth: Int,
  memLatency: Int = 2 // from input of address to output of data
) extends Component {
  val latency = memLatency + 1 + 1

  val batchWidth = batchSize * dataWidth
  val io = new Bundle {
    val addr = slave port Flow(UInt(addrWidth bit))
    val memPort = master port MemReadPort(Bits(batchWidth bits), addressWidth = addrWidth)
    val env = out port Vec.fill(batchSize)(SInt(dataWidth bit))
  }

  val addr = Reg(UInt(addrWidth bit))
  addr := addr + U(1)
  when(io.addr.fire) {
    addr := io.addr.payload
  }

  io.memPort.cmd.payload := RegNext(addr)
  io.memPort.cmd.valid := True
  (io.env zip io.memPort.rsp.subdivideIn(batchSize slices))
    .foreach{ case (env, memRsp) => env := memRsp.asSInt }
}



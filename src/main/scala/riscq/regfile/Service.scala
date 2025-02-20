package riscq.regfile

import spinal.core._
import spinal.core.fiber.{Retainer, Lockable}
import spinal.lib._
import riscq.Global
import riscq.decode.Decode
import riscq.riscv.RegfileSpec

case class RegFilePortParam(addressWidth: Int,
                            dataWidth: Int,
                            )

case class RegFileIo( rfpp : RegFilePortParam,
                      readsParameter: Seq[RegFileReadParameter],
                      writesParameter: Seq[RegFileWriteParameter]
                    ) extends Bundle{
  val writes = Vec(writesParameter.map(p => slave(RegFileWrite(rfpp, p.withReady))))
  val reads = Vec(readsParameter.map(p => slave(RegFileRead(rfpp, p.withReady))))
}

case class RegFileWrite(rfpp : RegFilePortParam, withReady : Boolean) extends Bundle with IMasterSlave {
  import rfpp._
  val valid = Bool()
  val ready = withReady generate Bool()
  val address = UInt(addressWidth bits)
  val data = Bits(dataWidth bits)

  def fire = if(withReady) valid && ready else valid

  def asWithoutReady() = {
    val ret = RegFileWrite(rfpp, false)
    ret.valid := this.fire
    ret.address := this.address
    ret.data := this.data
    ret
  }

  override def asMaster() = {
    out(valid, address, data)
    in(ready)
  }
}

case class RegFileRead(rfpp : RegFilePortParam, withReady : Boolean) extends Bundle with IMasterSlave{
  import rfpp._
  val valid = Bool()
  val ready = withReady generate Bool()
  val address = UInt(addressWidth bits)
  val data = Bits(dataWidth bits)

  override def asMaster() = {
    out(valid, address)
    in(ready, data)
  }
}

trait RegfileService {
  val elaborationLock = Retainer()

  def rfSpec : RegfileSpec
  def getPhysicalDepth : Int

  def writeLatency : Int
  def readLatency : Int

  def newRead(withReady : Boolean) : RegFileRead
  def newWrite(withReady : Boolean, sharingKey : Any = null, priority : Int = 0) : RegFileWrite

  def getWrites() : Seq[RegFileWrite]
}


case class RegFileWriter(rfSpec : RegfileSpec) extends Bundle{
  val data = Bits(rfSpec.width bits)
}

trait RegFileWriterService{
  def getRegFileWriters() : Seq[Flow[RegFileWriter]]
}
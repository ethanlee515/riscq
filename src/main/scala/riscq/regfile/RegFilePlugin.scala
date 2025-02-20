// SPDX-FileCopyrightText: 2023 "Everybody"
//
// SPDX-License-Identifier: MIT

package riscq.regfile

import spinal.core._
import spinal.core.fiber._
import spinal.lib._
import spinal.lib.eda.bench.{Bench, Rtl, XilinxStdTargets}
import spinal.lib.misc.plugin.FiberPlugin
import riscq.Global
import riscq.decode.Decode
import riscq.fetch.InitService
import riscq.riscv.RegfileSpec

import scala.collection.mutable.ArrayBuffer

class RegFilePlugin(var spec : RegfileSpec,
                    var physicalDepth : Int,
                    var preferedWritePortForInit : String,
                    var asyncReadBySyncReadRevertedClk : Boolean = false,
                    var allOne : Boolean = false,
                    var syncRead : Boolean = true,
                    var dualPortRam : Boolean = true,
                    var latchBased : Boolean = false,
                    var maskReadDuringWrite : Boolean = false) extends FiberPlugin with RegfileService with InitService {
  withPrefix(spec.getName())
  lazy val rfpp = RegFilePortParam(addressWidth, dataWidth)

  override def writeLatency: Int = 1
  override def readLatency: Int = syncRead.toInt

  override def getPhysicalDepth = physicalDepth
  override def rfSpec = spec

  case class WriteSpec(port : RegFileWrite,
                       withReady : Boolean,
                       sharingKey : Any,
                       priority : Int) //Higher first

  def addressWidth = log2Up(physicalDepth)
  def dataWidth = spec.width
  val reads = ArrayBuffer[RegFileRead]()
  val writes = ArrayBuffer[WriteSpec]()

  override def newRead(withReady : Boolean) = reads.addRet(RegFileRead(rfpp, withReady))
  override def newWrite(withReady : Boolean, sharingKey : Any = new{}, priority : Int = 0) = writes.addRet(
    WriteSpec(
      port       = RegFileWrite(rfpp, withReady),
      withReady  = withReady,
      sharingKey = sharingKey,
      priority   = priority
    )
  ).port

  override def getWrites() = {
    logic.await()
    writes.map(_.port)
  }


  override def initHold(): Bool = False

  val logic = during build new Area{
    elaborationLock.await()

    val writeGroups = writes.groupByLinked(_.sharingKey)
    val writeMerges = for((key, elements) <- writeGroups) yield new Area{
      val bus = RegFileWrite(rfpp , false)
      bus.valid   := elements.map(_.port.valid).orR

      val one = (elements.size == 1) generate new Area{
        val h = elements.head
        bus.address := h.port.address
        bus.data    := h.port.data
        if(h.withReady) h.port.ready := True
      }

      val multiple = (elements.size > 1) generate new Area {
        assert(elements.count(!_.withReady) <= 1)
        val sorted = elements.sortWith((a, b) => if(!a.withReady && b.withReady) true else a.priority > b.priority)
        assert(sorted.map(_.priority).indices.size == sorted.size, "Conflicting priorities for regfile writes")

        val mask = sorted.map(_.port.valid)
        val oh = OHMasking.firstV2(Vec(mask))
        bus.address := OhMux.or(oh, sorted.map(_.port.address))
        bus.data    := OhMux.or(oh, sorted.map(_.port.data))
        for((element, enable) <- (sorted, oh).zipped){
          if(element.withReady) element.port.ready := enable
        }
      }
    }

    val regfile = new Area{
      val readsParameter = reads.map(e => RegFileReadParameter(withReady = e.withReady))
      val writesParameter = writeMerges.map(e => RegFileWriteParameter(withReady = false)).toList
      val fpga = !latchBased generate new RegFileMem(
        rfpp = rfpp,
        readsParameter = readsParameter,
        writesParameter = writesParameter,
        headZero = spec.x0AlwaysZero,
        syncRead = syncRead,
        dualPortRam = dualPortRam,
        asyncReadBySyncReadRevertedClk = asyncReadBySyncReadRevertedClk,
        maskReadDuringWrite = maskReadDuringWrite
      )
      val io = !latchBased generate fpga.io
    }

    (regfile.io.reads, reads).zipped.foreach(_ <> _)
    (regfile.io.writes, writeMerges.map(_.bus)).zipped.foreach(_ <> _)

    val masker = maskReadDuringWrite generate new Area{
      for(r <- regfile.io.reads) {
        r.valid clearWhen(regfile.io.writes.map(w => w.valid && w.address === r.address).orR)
      }
    }

    //Used for tracing in verilator sim
    val writeEvents = Vec(writeMerges.map(e => CombInit(e.bus)))
    writeEvents.setName(spec.getName()+"_write").addAttribute(Verilator.public)
  }
}
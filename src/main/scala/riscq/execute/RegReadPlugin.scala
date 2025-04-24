package riscq.execute

import spinal.core._
import spinal.core.fiber.Retainer
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.misc.pipeline._
import scala.collection.mutable
import riscq.riscv._
import riscq.decode.Decode
import riscq.regfile._
import riscq.schedule.PipelinePlugin

class RegReadPlugin(val rfReadAt: Int, val enableBypass: Boolean) extends FiberPlugin {
  val elaborationLock = Retainer()
  
  val rfStageables = mutable.LinkedHashMap[RfResource, Payload[Bits]]()
  def getStageable(r: RfResource): Payload[Bits] = {
    rfStageables.getOrElseUpdate(r, Payload(Bits(r.rf.width bits)).setName(s"${r.rf.getName()}_${r.access.getName()}"))
  }
  def apply(rf: RegfileSpec, access: RfAccess) = getStageable(rf -> access)
  def apply(r: RfResource): Payload[Bits] = getStageable(r)
  
  apply(IntRegFile, RS1)
  apply(IntRegFile, RS2)

  val logic = during setup new Area{
    val pp = host[PipelinePlugin]
    val buildBefore = retains(host.list[RegfileService].map(_.elaborationLock) :+ pp.elaborationLock)

    awaitBuild()

    elaborationLock.await()

    val eus = host.list[ExecutionUnit]
    val uopSpecs = eus.flatMap(_.getUopSpecs()) // make sure all uops are specified
    // Generate the register files read + bypass
    val rf = new Area {
      val rfSpecs = rfStageables.keys.map(_.rf).distinctLinked
      val rfPlugins = rfSpecs.map(spec => host.find[RegfileService](_.rfSpec == spec))
      val readCtrl = pp.execute(rfReadAt)
      val reads = for ((spec, payload) <- rfStageables) yield new Area {
        setCompositeName(RegReadPlugin.this, s"bypasser_${spec.rf.getName()}_${spec.access.getName()}", weak = false)
        // Implement the register file read
        val rfa = Decode.rfaKeys.get(spec.access)
        val rfPlugin = host.find[RegfileService](_.rfSpec == spec.rf)
        val port = rfPlugin.newRead(false)
        port.valid := readCtrl.down.isMoving
        port.address := readCtrl(rfa.PHYS)

        // assert(rfReadAt + rfPlugin.readLatency + 1 == pp.executeIdStart, "as for now the bypass isn't implemented to udpate the data on the read latency + 1 until execute at")

        // Implement the bypass hardware
        val mainBypassAt = rfReadAt + rfPlugin.readLatency
        val dataCtrl = pp.execute(mainBypassAt)
        val noBypassLogic = !enableBypass generate new Area {
          dataCtrl(payload) := port.data
        }

        val bypassLogic = enableBypass generate new Area {
          // Generate a bypass specification for the regfile readed data
          case class BypassSpec(nodeId: Int, payload: Payload[Bits])
          val bypassSpecs = mutable.LinkedHashSet[BypassSpec]()
          for (opSpec <- uopSpecs) {
            val sameRf = opSpec.uop.resources.exists { // if there is a uop write to the rfStagable
              case RfResource(spec.rf, RD) => true
              case _ => false
            }
            if (sameRf) opSpec.rd match {
              case Some(rd) =>
                for (nodeId <- rd.broadcastedFrom until rd.rfReadableFrom + rfPlugin.readLatency) {
                  val bypassSpec = BypassSpec(nodeId, rd.DATA) // uop can bypass rd at nodeId
                  bypassSpecs += bypassSpec
                }
              case None => assert(opSpec.rd.nonEmpty, s"${opSpec.uop} must spec rd if used")
            }
          }

          val rfaRd = Decode.rfaKeys.get(RD)
          val bypassSorted = bypassSpecs.toSeq.sortBy(_.nodeId)
          val bypassEnables = Bits(bypassSorted.size + 1 bits)
          for ((b, id) <- bypassSorted.zipWithIndex) {
            val node = pp.execute(b.nodeId)
            bypassEnables(id) := node.isValid && node.up(rfaRd.ENABLE) && node(rfaRd.PHYS) === dataCtrl(rfa.PHYS) && node(rfaRd.RFID) === dataCtrl(rfa.RFID)
          }
          bypassEnables.msb := True
          val sel = OHMasking.firstV2(bypassEnables)
          val datas = bypassSorted.map(b => pp.execute(b.nodeId)(b.payload))
          // val isX0 = dataCtrl(rfa.PHYS) === U(0) // !!!
          // val bypassData = OHMux.or(sel, bypassSorted.map(b => pp.execute(b.nodeId)(b.payload)) :+ port.data, true)
          // dataCtrl(payload) := isX0.mux(B(0), bypassData)
          val tmp = OHMux.or(sel.dropLow(1), datas.tail :+ port.data, true)
          when(sel.lsb) {
            tmp := datas.head
          }
          KeepAttribute(tmp)  // Hurt me no more
          dataCtrl(payload) := tmp
        }

      }
    }
    buildBefore.release()
  }
}

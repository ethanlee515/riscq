package riscq.schedule

import spinal.core._
import spinal.lib._
import spinal.lib.misc.pipeline._
import spinal.lib.misc.plugin.FiberPlugin
import riscq.decode.DecoderService
import spinal.core.fiber.Retainer
import riscq.execute.ExecutionUnit
import scala.collection.mutable
import riscq.riscv.MicroOp
import riscq.decode.Decode
import riscq.riscv.RfRead
import riscq.riscv.RfResource
import riscq.riscv.RegfileSpec
import riscq.riscv.RD


class HazardPlugin(rfReadAt: Int = -1, hazardAt: Int = -1, enableBypass: Boolean = false) extends FiberPlugin {
  val elaborationLock = Retainer()

  val logic = during setup new Area{
    val pp = host[PipelinePlugin]
    val dp = host[DecoderService]

    val buildBefore = retains(pp.elaborationLock, dp.elaborationLock)

    awaitBuild()

    elaborationLock.await()

    val hazardCtrl = pp.execute(hazardAt)

    val eus = host.list[ExecutionUnit]

    // logic that check if there is a hazard caused by flush the current instruction
    val uopSpecs = eus.flatMap(_.getUopSpecs())
    val uopsMayFlushUpTo = uopSpecs.map(spec => spec.uop -> spec.mayFlushUpTo.getOrElse(-100))
    val mayFlushUpToMax = uopsMayFlushUpTo.map(_._2).max
    val uopsDontFlushFrom = uopSpecs.map(spec => spec.uop -> spec.dontFlushFrom.getOrElse(100))
    val dontFlushFromMin = uopsDontFlushFrom.map(_._2).min

    val dontFlushSpecs = mutable.LinkedHashMap[Int, Payload[Bool]]()
    def getDontFlush(at: Int): Payload[Bool] = {
      dontFlushSpecs.getOrElseUpdate(at, Payload(Bool()).setName(s"DONT_FLUSH_PRECISE_$at"))
    }
    val mayFlushSpecs = mutable.LinkedHashMap[Int, Payload[Bool]]()
    def getMayFlush(at: Int): Payload[Bool] = {
      mayFlushSpecs.getOrElseUpdate(at, Payload(Bool()).setName(s"MAY_FLUSH_PRECISE_$at"))
    }

    val flushChecker = new Area {
      val ctrlRange = dontFlushFromMin to mayFlushUpToMax - 1 // the stages that illegal flush may happen to the current uop0
      val hits = for(dist <- 1 to ctrlRange.length) yield { // the uop1 at dist ahead may flush the current uop0
        val otherCtrl = pp.execute(hazardAt + dist)
        val downstream = for(i <- ctrlRange.low to ctrlRange.high - dist + 1) yield { // if the flush happens when the current uop0 arrives i, check if that flush is illegal(dontflush) and possible(mayflush)
          hazardCtrl(getDontFlush(i)) && otherCtrl(getMayFlush(i + dist)) // && otherCtrl(Global.HART_ID) === c.ctx.hartId
        }
        downstream.orR && otherCtrl.isValid
      }
      val flushHazard = hits.orR
    }
    
    val dontFlushDecoding = for ((at, payload) <- dontFlushSpecs) yield new Area {
      pp.execute(at)
      for ((uop, dontFlushFrom) <- uopsDontFlushFrom) {
        dp.addMicroOpDecoding(uop, payload, Bool(dontFlushFrom <= at))
      }
    }
  
    val mayFlushDecoding = for ((at, payload) <- mayFlushSpecs) yield new Area {
      pp.execute(at)
      for ((uop, mayFlushUpTo) <- uopsMayFlushUpTo) {
        dp.addMicroOpDecoding(uop, payload, Bool(at <= mayFlushUpTo))
      }
    }

    // logic to detect RS bypassing hazard
    val bypassedSpecs = mutable.LinkedHashMap[Int, Payload[Bool]]()
    def getBypassed(at: Int): Payload[Bool] = {
      bypassedSpecs.getOrElseUpdate(at, Payload(Bool()).setName("BYPASSED_AT_" + at))
    }

    val rdKeys = Decode.rfaKeys.get(RD)
    val rfaReads = Decode.rfaKeys.filter(_._1.isInstanceOf[RfRead])
    val rdBroadcastedFromMaxList = eus.flatMap(_.getUopSpecs()).flatMap(_.rd.map(_.broadcastedFrom))
    val rsHazardChecker = new Area {
      val rsHazard = Bool()
      if(rdBroadcastedFromMaxList.nonEmpty) {
        val rdBroadcastedFromMax = rdBroadcastedFromMaxList.max
        val onRs = for (rs <- rfaReads.values) yield {
          val hazardFrom = rfReadAt + 1
          val hazardUntil = rdBroadcastedFromMax
          val hazardRange = hazardFrom until hazardUntil
          val hazards = for(id <- hazardRange) yield {
            val node = pp.execute(id)
            if(enableBypass) {
              node(rdKeys.ENABLE) && node(rdKeys.PHYS) === hazardCtrl(rs.PHYS) && !node(getBypassed(id + rfReadAt - hazardAt)) && node.isValid
            } else {
              node(rdKeys.ENABLE) && node(rdKeys.PHYS) === hazardCtrl(rs.PHYS) && node.isValid
            }
          }
          hazardCtrl(rs.ENABLE) && hazards.orR
        }
        rsHazard := onRs.orR
      } else {
        rsHazard := False
      }
    }

    val bypassDecoding = for ((at, payload) <- bypassedSpecs) yield new Area {
      for (uopSpec <- uopSpecs) {
        uopSpec.rd.foreach { rd =>
          dp.addMicroOpDecoding(uopSpec.uop, payload, Bool(rd.broadcastedFrom <= at))
        }
      }
    }

    hazardCtrl.haltWhen(flushChecker.flushHazard || rsHazardChecker.rsHazard)

    buildBefore.release()
  }
}
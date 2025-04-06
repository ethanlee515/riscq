package riscq.fetch

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin._
import riscq.Global._
import spinal.core.sim.{SimDataPimper, _}
import riscq.Global
import riscq.schedule.PipelinePlugin

import scala.collection.mutable.ArrayBuffer

class PcPlugin(var resetVector : BigInt = 0x80000000l) extends FiberPlugin with PcService{

  case class JumpSpec(bus : Flow[JumpCmd], priority : Int) extends Composite(bus) {
    // val valid = Bool()
  }
  val jumps = ArrayBuffer[JumpSpec]()
  override def newJumpInterface(age: Int): Flow[JumpCmd] = {
    jumps.addRet(JumpSpec(Flow(JumpCmd()), age)).bus
  }

  override def simSetPc(value: Long): Unit = {
    val pc = (value & logic.self.state.maxValue)
    logic.self.state #= pc
    logic.output.payload #= pc
  }

  override def forcedSpawn(): Bool = logic.forcedSpawn

  val logic = during setup new Area{
    PC_WIDTH.set(32)
    val pp = host[PipelinePlugin]
    val buildBefore = retains(pp.elaborationLock)
    awaitBuild()

    elaborationLock.await()
    val injectStage = pp.fetch(0).up

    // assert(Global.HART_COUNT.get == 1)
    val forcedSpawn = jumps.map(_.bus.valid).orR
    // println(s"debug jumps: ${jumps.map{_.getDisplayName()}}")
    // println(forcedSpawn.toString)

    // Self is a jump interface which store the PC
    val self = new Area {
      val flow = newJumpInterface(-1)
      val increment = RegInit(False)
      val state = Reg(PC) init (resetVector) simPublic
      val pc = state + U(Fetch.WORD_BYTES).andMask(increment)
      flow.valid := True
      flow.pc := pc
    }

    // Takes all the pc sources and aggregate them into a single value, based on priority
    val aggregator = new Area {

      val sortedByPriority = jumps.sortWith(_.priority > _.priority)
      val valids = sortedByPriority.map(e => e.bus.valid)
      val cmds = sortedByPriority.map(_.bus.payload)
      val oh = OHMasking.firstV2(valids.asBits)

      val target = OhMux.or(oh, cmds.map(_.pc))
    }

    // used for trap
    val holdComb = holdPorts.map(_.valid).orR
    val holdReg = RegNext(holdComb) init(True)

    // Stream of PC for the given hart
    val output = out port Stream(PC).simPublic
    output.valid := !holdReg // True when holdPorts is empty
    output.payload := aggregator.target

    // Update the PC state
    self.state := output.payload
    self.increment := False
    when(output.fire) {
      self.increment := True
    }

    val inject = new injectStage.Area {
      valid := output.valid
      output.ready := ready
      Fetch.WORD_PC := output.payload
    }

    //output (the pc stream) use holdPorts with one delay cycle (to improve timings), so here we need to prevent fetch(0) to fire down if the combinatorial check of holdPorts hits
    val holdHalter = new pp.Fetch(0) {
      haltWhen(holdComb)
    }
    buildBefore.release()
  }
}

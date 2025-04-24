package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.fsm._
import scala.math

// input frequency
// output: exp(i * freq * k) for k = 0, ..., batchSize - 1
case class FreqPhaseBatchGenerator(
  batchSize: Int,
  dataWidth: Int
) extends Component {
  val latency = 39

  val io = new Bundle {
    val freq = slave port Stream(AFix.S(0 exp, dataWidth bit))
    val phases = master port Flow(ComplexBatch(batchSize, dataWidth))
  }
  val cosSin = Cordic(xyWidth = dataWidth, zWidth = dataWidth)
  cosSin.io.cmd.x := cosSin.io.cmd.x.maxValue
  cosSin.io.cmd.y := 0.0

  val phaseList = Reg(ComplexBatch(batchSize, dataWidth))
  val phaseListId = Reg(UInt(log2Up(batchSize) bits))
  phaseListId := phaseListId + 1
  val freq = RegNextWhen(io.freq.payload, io.freq.valid)

  cosSin.io.cmd.valid := False

  val cosSinRsp = cosSin.io.rsp

  val cosSinBuffer = Reg(Flow(phaseList(0)))
  cosSinBuffer.r := cosSin.io.rsp.x
  cosSinBuffer.i := cosSin.io.rsp.y
  cosSinBuffer.valid := cosSin.io.rsp.valid
  cosSinBuffer.addAttribute("MAX_FANOUT", 16)

  (io.phases.payload, phaseList).zipped.foreach{ (o, i) => o := i }

  val multFreq = Reg(freq)
  multFreq := (multFreq + freq).truncated
  cosSin.io.cmd.z := multFreq

  when(cosSinBuffer.valid) {
    phaseList(phaseListId) := cosSinBuffer
  }

  val valid = Reg(Bool()) init True
  valid.addAttribute("MAX_FANOUT", 32)
  io.freq.ready := valid
  io.phases.valid := valid

  val fsm = new StateMachine{
    val running = makeInstantEntry()  // 0
      running.whenIsActive {
        when(io.freq.fire) {
          valid := False
          multFreq := multFreq.getZero
          var startId = (phaseListId.maxValue - cosSin.latency + 1) % (phaseListId.maxValue + 1)
          if (startId < 0) { startId += (phaseListId.maxValue + 1)}
          phaseListId := U(startId)
          goto(computeCompList)
        }
      }
    val computeCompList = new StateDelay(cyclesCount = batchSize) { // 1
      whenIsActive{
        cosSin.io.cmd.valid := True
      }
      whenCompleted {
        goto(waitLoadCompList)
      }
    }
    val waitLoadCompList = new StateDelay(cyclesCount = cosSin.latency) { // 2
      whenCompleted {
        valid := True
        goto(running)
      }
    }
  }
}

object TestFreqPhaseBatchGenerator extends App {
  SimConfig.compile{
    val dut = FreqPhaseBatchGenerator(batchSize = 16, dataWidth = 16)
    dut.fsm.stateReg.simPublic()
    dut.phaseList.map{_.simPublic()}
    dut.phaseListId.simPublic()
    dut.freq.simPublic()
    dut.multFreq.simPublic()
    dut.cosSinRsp.simPublic()
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    dut.io.freq.valid #= false
    dut.io.freq.payload #= 0
    cd.assertReset()
    cd.waitRisingEdge(100)
    cd.deassertReset()
    cd.waitSampling(100)

    dut.io.freq.valid #= true
    dut.io.freq.payload #= 1.0/16
    cd.waitSampling()
    dut.io.freq.valid #= false
    for(i <- 1 until 40) {
      println(s"time: $i, state: ${ dut.fsm.stateReg.toBigInt }, multFreq: ${dut.multFreq.toDouble}, id:${dut.phaseListId.toBigInt}, v: ${dut.io.phases.valid.toBoolean}")
      println(s"cossin valid: ${dut.cosSinRsp.valid.toBoolean}")
      println(s"phases: ${dut.io.phases.valid.toBoolean}, ${dut.io.phases.payload.map{_.r.toDouble}.toList} \n")
      cd.waitSampling()
    }
    // cd.waitSampling(100)
    // for(i <- 0 until 100) {
    //   println(s"${dut.io.rsp.payload.map{_.r.toDouble}}")
    //   cd.waitSampling()
    // }
    simSuccess()
  }
}
package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.fsm._
import spinal.lib.eda.efinix.Dev.log

case class CarrierGeneratorSpec(
  batchSize: Int,
  carrierWidth: Int,
  freqWidth: Int,
  clockWidth: Int,
) {
  val dataType = HardType(AFix.S(0 exp, freqWidth bits))
}

object CarrierBundle {
  def apply(spec: CarrierGeneratorSpec) = Vec.fill(spec.batchSize)(Complex(spec.freqWidth))
  def apply(batchSize: Int, freqWidth: Int) = Vec.fill(batchSize)(Complex(freqWidth))
}

case class CarrierGeneratorCmd(spec: CarrierGeneratorSpec) extends Bundle {
  val freq = spec.dataType()
  val phase = spec.dataType()
}

case class CarrierGeneratorPort(spec: CarrierGeneratorSpec) extends Bundle with IMasterSlave {
  val cmd = Stream(CarrierGeneratorCmd(spec))
  val time = UInt(spec.clockWidth bits)
  val carrier = Flow(CarrierBundle(spec))

  def asMaster() = {
    master(cmd)
    out(time)
    slave(carrier)
  }
}

// latency 34
case class CarrierGenerator(spec: CarrierGeneratorSpec) extends Component {
  val delay = spec.batchSize + 18
  val io = slave port CarrierGeneratorPort(spec)

  val compList = Vec.fill(spec.batchSize)(Reg(Complex(spec.freqWidth)))
  // compList.foreach { c => c.r init 0; c.i init 0}
  val compListId = Reg(UInt(log2Up(spec.batchSize) bits))
  compListId := compListId + 1
  val phase = Reg(io.cmd.phase)
  val freq = Reg(io.cmd.freq)
  val gPhase = Reg(io.cmd.phase)
  // assert(spec.batchSize == 16)
  // timePhase := (freq.asSInt * (io.time << 4)(0, spec.freqWidth - 4 bits).asSInt)(0, spec.freqWidth bits)
  assert(spec.batchSize == 16 || spec.batchSize == 4)
  val batchSizeLog2 = log2Up(spec.batchSize)
  val time = Reg(AFix.S(spec.freqWidth - 1 exp, spec.freqWidth bits))
  time.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  time := (io.time << batchSizeLog2)(0, spec.freqWidth bits).asSInt
  val timePhase = RegNext(freq * time)
  val gPhaseRaw = timePhase + phase
  gPhase := gPhaseRaw.truncated

  val cosSinParam = TableAndDspParam(spec.freqWidth)
  val cosSin = TableAndDsp(cosSinParam)
  cosSin.io.cmd.z := gPhase

  io.cmd.ready := False
  io.carrier.valid := False
  cosSin.io.cmd.valid := False
  val cosSinRsp = cosSin.io.rsp
  val compMul = List.fill(spec.batchSize)(ComplexMul(spec.freqWidth))
  val compMulDelay = List.fill(spec.batchSize)(Complex(spec.freqWidth))

  val cosSinBuffer = Reg(compMul(0).io.c0)
  cosSinBuffer.assignTruncated(cosSin.io.rsp)
  cosSinBuffer.addAttribute("MAX_FANOUT", 16)

  for(i <- 0 until spec.batchSize) {
    // compMul(i).io.c0.assignTruncated(cosSin.io.rsp)
    compMul(i).io.c0 := cosSinBuffer
    compMul(i).io.c1 := compList(i)
    compMulDelay(i) := compMul(i).io.c
  }
  (io.carrier.payload, compMulDelay).zipped.foreach{ (o, i) => o := i }

  val multFreq = Reg(io.cmd.freq)
  multFreq := (multFreq + freq).truncated

  val loadingCompList = Reg(Bool()) init False
  loadingCompList.addAttribute("MAX_FANOUT", 16)
  when(loadingCompList) {
    // compList(compListId).assignTruncated(cosSin.io.rsp)
    compList(compListId) := cosSinBuffer
  }

  val fsm = new StateMachine{
    val running = makeInstantEntry()  // 0
      running.whenIsActive {
        io.cmd.ready := True
        io.carrier.valid := True
        when(io.cmd.fire) {
          phase := io.cmd.phase
          freq := io.cmd.freq
          multFreq := multFreq.getZero
          // var startId = (compListId.maxValue - cosSin.delay + 1) % (compListId.maxValue + 1)
          var startId = (compListId.maxValue - cosSin.delay + 1 - 1) % (compListId.maxValue + 1)
          if (startId < 0) { startId += (compListId.maxValue + 1)}
          compListId := U(startId)
          goto(computeCompList)
        }
      }
    val computeCompList = new StateDelay(cyclesCount = spec.batchSize) { // 1
      onEntry {
        loadingCompList := True
      }
      whenIsActive {
        cosSin.io.cmd.z := multFreq
        cosSin.io.cmd.valid := True
        // compList(compListId).assignTruncated(cosSin.io.rsp)
      }
      whenCompleted {
        goto(waitLoadCompList)
      }
    }
    val waitLoadCompList = new StateDelay(cyclesCount = cosSin.delay + 1) { // 2
      whenIsActive {
        // compList(compListId).assignTruncated(cosSin.io.rsp)
      }
      whenCompleted {
        goto(waitLoadCarrier)
      }
      onExit {
        loadingCompList := False
      }
    }
    val waitLoadCarrier = new StateDelay(cyclesCount = compMul(0).delay) { // 3
      whenCompleted {
        goto(running)
      }
    }
  }
}

object CarrierGeneratorTest extends App {
  val spec = CarrierGeneratorSpec(batchSize = 16, carrierWidth = 16, freqWidth = 16, clockWidth = 32)
  SimConfig.compile{
    val dut = CarrierGenerator(spec)
    dut.fsm.stateReg.simPublic()
    dut.phase.simPublic()
    dut.gPhase.simPublic()
    dut.gPhaseRaw.simPublic()
    dut.compList.map{_.simPublic()}
    dut.compListId.simPublic()
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    dut.io.cmd.valid #= false
    cd.waitSampling()
    cd.assertReset()
    cd.waitRisingEdge()
    cd.deassertReset()
    cd.waitSampling(100)

    val timer = fork {
      var time = 0
      while(true) {
        dut.io.time #= time
        time += 1
        cd.waitSampling()
      }
    }

    dut.io.cmd.valid #= true
    dut.io.cmd.phase #= 0.1
    dut.io.cmd.freq #= 1.0/64
    cd.waitSampling()
    dut.io.cmd.valid #= false
    for(i <- 0 until 60) {
      println(s"${dut.io.time.toBigInt}")
      println(s"${ dut.fsm.stateReg.toBigInt }, ${dut.phase.toDouble}, id:${dut.compListId.toBigInt}")
      println(s"cossinRaw: ${dut.gPhaseRaw.toDouble}")
      println(s"cossin: ${dut.gPhase.toDouble}")
      println(s"complistid: ${dut.compListId.toBigInt}")
      println(s"cossinvalid: ${dut.cosSinRsp.valid.toBoolean}, ${dut.io.carrier.valid.toBoolean}")
      println(s"${dut.compList.map(_.r.toDouble)}")
      println(s"carrier: ${dut.io.carrier.payload.map{_.r.toDouble}.toList} \n")
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

object CarrierGeneratorTest4 extends App {
  val spec = CarrierGeneratorSpec(batchSize = 4, carrierWidth = 16, freqWidth = 16, clockWidth = 32)
  SimConfig.compile{
    val dut = CarrierGenerator(spec)
    dut.fsm.stateReg.simPublic()
    dut.phase.simPublic()
    dut.gPhase.simPublic()
    dut.gPhaseRaw.simPublic()
    dut.compList.map{_.simPublic()}
    dut.compListId.simPublic()
    dut
  }.doSimUntilVoid{ dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)
    dut.io.cmd.valid #= false
    cd.waitSampling()
    cd.assertReset()
    cd.waitRisingEdge()
    cd.deassertReset()
    cd.waitSampling(100)

    val timer = fork {
      var time = 0
      while(true) {
        dut.io.time #= time
        time += 1
        cd.waitSampling()
      }
    }

    dut.io.cmd.valid #= true
    dut.io.cmd.phase #= 0.5
    dut.io.cmd.freq #= 1.0/64
    cd.waitSampling()
    dut.io.cmd.valid #= false
    for(i <- 0 until 60) {
      println(s"${dut.io.time.toBigInt}")
      println(s"${ dut.fsm.stateReg.toBigInt }, ${dut.phase.toDouble}, id:${dut.compListId.toBigInt}")
      println(s"cossinRaw: ${dut.gPhaseRaw.toDouble}")
      println(s"cossin: ${dut.gPhase.toDouble}")
      println(s"${dut.compList.map(_.r.toDouble)}")
      println(s"complistid: ${dut.compListId.toBigInt}")
      println(s"cossinvalid: ${dut.cosSinRsp.valid.toBoolean}, ${dut.io.carrier.valid}")
      println(s"carrier: ${dut.io.carrier.payload.map{_.r.toDouble}.toList} \n")
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

// case class CarrierGeneratorPort(spec: CarrierGeneratorSpec) extends Bundle with IMasterSlave {
//   val cmd = Stream(CarrierGeneratorCmd(spec)) // 2 Pi / freq
//   // val cosSin = CosSinPort(spec.freqWidth)
//   val carrier = Flow(Vec.fill(spec.batchSize)(Complex(spec.freqWidth)))

//   def asMaster(): Unit = {
//     master(cmd)
//     // master(cosSin)
//     slave(carrier)
//   }
// }



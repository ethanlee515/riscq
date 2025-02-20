package riscq.scratch

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.fsm._
import riscq.pulse._

case class PulseMem(spec: PulseGeneratorSpec) extends Component {
  val dataBits = spec.dataWidth
  val mem = Mem.fill(spec.bufferDepth)(Bits(dataBits bits))
  val axiPort = slave port mem.readWriteSyncPort(dataBits / 8)
  val envPort = slave port mem.readSyncPort()
}

case class PGBugMin(spec: PulseGeneratorSpec) extends Component {
  val io = new Bundle {
    val carrier = slave port Flow((Complex(spec.freqWidth)))
    val cmd = slave port Flow(PulseCmd(spec))
    val data = master port Flow(SInt(spec.dataWidth bits))
  }  
  io.data.valid := False
  io.data.payload := S(0)
  val dataBits = spec.dataWidth
  // val mem = Mem(Bits(dataBits bits), wordCount = spec.bufferDepth)
  val mem = PulseMem(spec)
  // val mem = Mem.fill(spec.bufferDepth)(Bits(dataBits bits))
  // mem.addAttribute(name = "ram_style", value = "block")
  // // mem.generateAsBlackBox()
  // mem.setTechnology(ramBlock)
  // val memPort = slave port mem.readWriteSyncPort(dataBits / 8)
  val memPort = slave port cloneOf(mem.axiPort)
  memPort <> mem.axiPort
  val envPort = cloneOf(mem.envPort)
  envPort <> mem.envPort
  val addr = Reg(UInt(log2Up(spec.bufferDepth) bits)) init 0
  val aIn = in port cloneOf(addr)
  addr := aIn

  val envData = SInt(spec.dataWidth bits)
  // val envTmp = Reg(SInt(spec.dataWidth bits))
  // envData := mem.readSync(addr).asSInt
  // val envPort = mem.readWriteSyncPort(dataBits / 8)
  // KeepAttribute(envPort)
  // envPort.address := addr
  // envPort.wdata := 0
  // envPort.enable := True
  // envPort.write := False
  // envPort.mask := 0
  // envTmp := envPort.rdata.asSInt
  // envData := envTmp
  // envData := envPort.rdata.asSInt
  envPort.cmd.valid := True
  envPort.cmd.payload := addr
  envData := envPort.rsp.asSInt

  val cosSinParam = TableAndDspParam(spec.freqWidth)
  val cosSin = TableAndDsp(cosSinParam)
  cosSin.io.cmd.valid := False
  cosSin.io.cmd.z := io.cmd.phase
  val phaseC = Reg(Complex(spec.freqWidth)).simPublic
  phaseC := cosSin.io.rsp.payload
  
  // c: carrier
  // p: phase
  // amp: amplification
  // env: envelope
  val amp = Reg(AFix.U(0 exp, spec.freqWidth bits)) init 0
  amp := io.cmd.amp
  val carrierMulPhase = Reg(Complex(spec.freqWidth))
  val carrierMul = ComplexMul(spec.freqWidth)
  carrierMul.io.c0 := io.carrier.payload
  carrierMul.io.c1 := phaseC
  carrierMulPhase := carrierMul.io.c
  val cpa = out port Reg(AFix.S(0 exp, spec.freqWidth bits))
  cpa := (carrierMulPhase.r * amp).truncated
  val cpae = out port Reg(SInt(spec.freqWidth bits))
  val m = cpa.asSInt * envData
  cpae := m(m.getWidth - spec.freqWidth - 1, spec.freqWidth bits)
  // val timer = Reg(UInt(spec.clockWidth bits)) init 0

  // val fsm = new StateMachine {
  //   val init = new State with EntryPoint{
  //     whenIsActive{
  //       goto(idle)
  //     }
  //   }
  //   // val idle = makeInstantEntry()
  //   // idle.whenIsActive {
  //   val idle = new State {
  //     whenIsActive{
  //     when(io.cmd.fire){
  //       cosSin.io.cmd.valid := True
  //       amp := io.cmd.amp
  //       addr := io.cmd.addr
  //       // phase := io.cmd.phase
  //       timer := io.cmd.duration - 1
  //       goto(waitCosSin)
  //     }
  //   }
  //   }
  //   val waitCosSin = new State {
  //     whenIsActive{
  //       when(cosSin.io.rsp.fire) {
  //         phaseC := cosSin.io.rsp
  //         goto(waitMul)
  //       }
  //     }
  //   }
  //   val waitMul = new StateDelay(cyclesCount = 7) {
  //     whenIsActive{
  //       addr := addr + 1
  //     }
  //     whenCompleted{
  //       goto(running)
  //     }
  //   }
  //   val running = new State {
  //     whenIsActive{
  //       io.data.payload := cpae
  //       io.data.valid := True
  //       addr := addr + 1
  //       timer := timer - 1
  //       when(timer === 0) {
  //         exit()
  //       }
  //     }
  //   }
  // }
}

object PGBug extends App {
  val dataWidth = 16
  val batchSize = 16
  val depth = 1 << 12
  val pulseSpec = PulseGeneratorSpec(
    dataWidth = dataWidth,
    batchSize = batchSize,
    bufferDepth = depth,
    clockWidth = 32,
    phaseWidth = 16,
    freqWidth = 16,
    ampWidth = 16,
    carrierDelay = 4,
  )

  SpinalConfig(
    mode=Verilog,
    device=Device.XILINX,
    targetDirectory="./pgtest/rtl"
  ).generate(
    PGBugMin(pulseSpec)
  ).printPruned()
}
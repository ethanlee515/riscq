package riscq.pulse

import spinal.core._
import spinal.core.sim._
import spinal.lib._

case class EnvelopeMultiplier(
  batchSize: Int,
  dataWidth: Int,
) extends Component {
  val latency = 4
  val batchWidth = batchSize * dataWidth
  val io = new Bundle {
    // val duration = slave port Flow(UInt(durWidth bit))
    val carrier = in port Vec.fill(batchSize)(Complex(dataWidth)) // carrier * amp
    val env = in port Vec.fill(batchSize)(SInt(dataWidth bit))
    val pulse = out port ComplexBatch(batchSize, dataWidth)
  }

  // c: carrier
  // env: envelope
  val envARegR = RegNext(io.env)
  envARegR.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  val envARegI = RegNext(io.env)
  envARegI.addAttribute("EQUIVALENT_REGISTER_REMOVAL", "NO")
  val carrierAReg = RegNext(io.carrier)

  val ecMReg = ComplexBatch(batchSize, dataWidth)
  for (i <- 0 until batchSize) {
    val real = RegNext(envARegR(i) * carrierAReg(i).r.asSInt)
    val imag = RegNext(envARegI(i) * carrierAReg(i).i.asSInt)
    ecMReg(i).r := real(real.getBitsWidth - dataWidth - 1, dataWidth bits)
    ecMReg(i).i := imag(imag.getBitsWidth - dataWidth - 1, dataWidth bits)
  }
  val ecPReg = RegNext(ecMReg)

  io.pulse := RegNext(ecPReg)
}

object TestEnvelopeMultiplierLatency extends App {
  val dataWidth = 16
  val batchSize = 16
  SimConfig.compile{
    val dut = EnvelopeMultiplier(
      batchSize,
      dataWidth,
    )
    dut.carrierAReg.simPublic()
    dut.envARegR.simPublic()
    dut
  }.doSimUntilVoid { dut =>
    val cd = dut.clockDomain
    cd.forkStimulus(10)

    cd.assertReset()
    cd.waitRisingEdge(10)
    cd.deassertReset()

    dut.io.carrier.foreach{c => c.r #= c.r.maxValue; c.i #= c.i.maxValue}
    dut.io.env.foreach{e => e #= ((1 << 15) - 1)}
    cd.waitRisingEdge(20)

    dut.io.carrier.foreach{c => c.r #= 0.5; c.i #= 0.5}
    dut.io.env.foreach{e => e #= ((1 << 14) - 1)}

    for(i <- 0 until 10) {
      println(s"time: ${i}")
      println(s"envAReg: ${dut.envARegR(0).toBigInt}")
      println(s"carrier: ${dut.carrierAReg(0).r.toDouble * (1 << 15)}")
      println(s"pulse: ${dut.io.pulse.map{c => c.r.toDouble * (1 << 15)}}")
      cd.waitRisingEdge()
    }
    simSuccess()
  }
}

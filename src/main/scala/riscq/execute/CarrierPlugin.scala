// package riscq.execute

// import riscq.pulse._
// import spinal.core._
// import spinal.lib._
// import riscq.riscv.{MicroOp, RD, RfResource, SingleDecoding}
// import riscq.decode.Decode
// import riscq.schedule.PipelinePlugin

// class CarrierPlugin(specs: Seq[CarrierGeneratorSpec], idWidth: Int = 5) extends ExecutionUnit {

//   val logic = during setup new Area {
//     val uop = addUop(SingleDecoding(M"-----------------011000011111111", Nil))

//     val pp = host[PipelinePlugin]
//     val buildBefore = retains(pp.elaborationLock)

//     awaitBuild()
    
//     uopRetainer.release()


//     val cgPorts = specs.map(spec => master(Stream(CarrierGeneratorCmd(spec)))).toList

//     val num = specs.length
//     val freqWidth = specs.head.freqWidth
//     val valids = Vec.fill(num)(Reg(Bool()))
//     cgPorts.zipWithIndex.foreach{ case (cg, id) => 
//       valids(id) := False
//       cg.valid := valids(id)
//     }

//     val carrierLogic = new pp.Execute(0) {
//       val instBuffer = Vec.fill(specs.length)(Reg(this(Decode.INSTRUCTION))) // for timing
//       for((cg, buf) <- cgPorts zip instBuffer) {
//         buf := Decode.INSTRUCTION
//         val freq = buf(128 - 5 - freqWidth, freqWidth bits)
//         val phase = buf(128 - 5 - freqWidth - freqWidth, freqWidth bits)
//         cg.freq := freq.asSInt
//         cg.phase := phase.asSInt
//       }
//       val id = Decode.INSTRUCTION(128 - 5, 5 bits)
//       when(SEL && isValid && isReady) {
//         valids(id.asUInt.resized) := True
//       }
//     }

//     buildBefore.release()
//   }
// }
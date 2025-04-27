/* 
  def rdIdOffset(i: Int) = rdStep * i
  def rdDurOffset(i: Int) = rdIdOffset(i) + 0
  def rdRefROffset(i: Int) = rdIdOffset(i) + 4
  def rdRefIOffset(i: Int) = rdIdOffset(i) + 8
  def rdResOffset(i: Int) = rdIdOffset(i) + 12
 */

 
    /*
    val readAccWidth = 27
    val rds = List.fill(qubitNum)(
      pulse.ReadoutDecoder(
        batchSize = demodBatchSize,
        inWidth = dataWidth,
        accWidth = readAccWidth,
        durWidth = demodDurWidth,
        timeWidth = 32
      )
    )
    */

// package riscq.execute

// import spinal.core._
// import spinal.lib._
// import spinal.lib.misc.pipeline._
// import riscq.execute.ReadoutPlugin.{ReadoutCtrlEnum => ReadoutCtrlEnum}
// import riscq.riscv.{MicroOp, RD, RfResource, SingleDecoding}
// import riscq.schedule.PipelinePlugin
// import riscq.pulse.{ReadoutAccumulator, ReadoutResult}
// import riscq.decode.Decode
// import riscq.riscv.IntRegFile
// import spinal.lib.misc.plugin.FiberPlugin
// import riscq.pulse.ComplexBatch

// object ReadoutPlugin extends AreaObject {
//   val ReadoutCtrlEnum = new SpinalEnum(binarySequential) {
//     val READ, WRITE_RE, WRITE_IM = newElement()
//   }
// }

// case class ReadoutPlugin(batchSize: Int, carrierWidth: Int, num: Int = 1, idWidth: Int = 5, wbAt: Int = 0) extends ExecutionUnit {

//   val logic = during setup new Area {
//     import ReadoutPlugin._
//     val rce = ReadoutCtrlEnum
//     val READ_CTRL = Payload(ReadoutCtrlEnum())
//     val readout = addUop(SingleDecoding(M"-----------------000-----1111011", Nil)).decode(READ_CTRL -> rce.READ).dontFlushFrom(0)
//     val writeR = addUop(SingleDecoding(M"-----------------001-----1111011", List(IntRegFile -> RD))).decode(READ_CTRL -> rce.WRITE_RE)
//     val writeI = addUop(SingleDecoding(M"-----------------010-----1111011", List(IntRegFile -> RD))).decode(READ_CTRL -> rce.WRITE_IM)

//     val pp = host[PipelinePlugin]
//     val wbp = host[WriteBackPlugin]
//     val carriers = in port Vec.fill(num)(ComplexBatch(batchSize, carrierWidth))
//     val adcs = in port Vec.fill(num)(ComplexBatch(batchSize, carrierWidth))
//     val buildBefore = retains(pp.elaborationLock, wbp.elaborationLock)

//     awaitBuild()

//     val wb = wbp.createPort(wbAt)
//     wbp.addMicroOp(wb, writeR)
//     wbp.addMicroOp(wb, writeI)

//     uopRetainer.release()

//     val WRITE_DATA = Payload(Bits(32 bits))
//     val results = out port Vec.fill(num)(Reg(ReadoutResult(32)))
//     results.foreach{ result =>
//       result.r init S(0)
//       result.i init S(0)
//     }

//     val outWidth = 32
//     val readAccs = List.fill(num)(ReadoutAccumulator(batchSize, inWidth = carrierWidth, outWidth = outWidth, timeWidth = 12))
//     val valids = Vec.fill(num)(Bool())

//     for((readAcc, valid) <- (readAccs, valids).zipped) {
//       valid := False
//       readAcc.io.cmd.valid := valid
//     }

//     for((readAcc, result) <- (readAccs, results).zipped) {
//       when(readAcc.io.rsp.fire){
//         result.r := readAcc.io.rsp.r
//         result.i := readAcc.io.rsp.i
//       }
//     }

//     (readAccs zip adcs).foreach{ case (r, a) => r.io.adc := a}
//     for(i <- 0 until num) {
//       readAccs(i).io.carrier := carriers(i)
//     }
    
//     val readoutLogic = new pp.Execute(0) {
//       WRITE_DATA := 0
//       readAccs.foreach{ r => r.io.cmd.payload := Decode.INSTRUCTION(20, 12 bits).asUInt }
//       when(SEL && isValid) {
//         val id = Decode.INSTRUCTION(15, 5 bits).asUInt
//         when(READ_CTRL === ReadoutCtrlEnum.READ) {
//           valids(id.resized) := True
//         }
//         when(READ_CTRL === ReadoutCtrlEnum.WRITE_RE) {
//           WRITE_DATA := results(id.resized).r.asBits
//         }
//         when(READ_CTRL === ReadoutCtrlEnum.WRITE_IM) {
//           WRITE_DATA := results(id.resized).i.asBits
//         }
//       }
//     }

//     val wbLogic = new pp.Execute(wbAt){
//       wb.valid := SEL && (READ_CTRL =/= ReadoutCtrlEnum.READ)
//       wb.payload := WRITE_DATA
//     }
//     buildBefore.release()
//   }
// }

// case class ReadoutBufferPlugin(id: Int) extends FiberPlugin {
//   val logic = during setup new Area {
//     val rop = host[ReadoutPlugin]

//     awaitBuild()

//     val adcNum = rop.num
//     val adcBatchWidth = rop.batchSize * rop.carrierWidth * 2
//     val outData = master port Flow(Bits(adcBatchWidth bit))
//     outData.payload := rop.logic.readAccs(id).io.demodData.payload.asBits
//     outData.valid := rop.logic.readAccs(id).io.demodData.valid
//   }
// }
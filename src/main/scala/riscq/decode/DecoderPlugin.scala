package riscq.decode

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.misc.pipeline._
import spinal.lib.logic.{DecodingSpec, Masked, Symplify}

import scala.collection.mutable
import riscq.riscv._
import riscq.riscv
import riscq.schedule.PipelinePlugin
import riscq.fetch.Fetch

class DecoderPlugin(val decodeAt: Int) extends FiberPlugin with DecoderService {
    val decodingSpecs = mutable.LinkedHashMap[Payload[_ <: BaseType], DecodingSpec[_ <: BaseType]]()
    def getDecodingSpec(key: Payload[_ <: BaseType]) = decodingSpecs.getOrElseUpdate(key, new DecodingSpec(key))

    val microOps = mutable.LinkedHashSet[MicroOp]()
    def addMicroOpDecoding(microOp: MicroOp, key: Payload[_ <: BaseType], value: AnyRef) = {
        val maskedOp = Masked(microOp.key)
        getDecodingSpec(key).addNeeds(maskedOp, Masked(value))
        microOps += microOp
    }

    def addPayloadDefault(key: Payload[_ <: BaseType], value: AnyRef) = {
        getDecodingSpec(key).setDefault(Masked(value))
    }

    val logic = during setup new Area{
        val pp = host[PipelinePlugin]
        val buildBefore = retains(pp.elaborationLock)

        awaitBuild()

        Decode.INSTRUCTION_WIDTH.set(Fetch.WORD_WIDTH)

        val rfAccesses = mutable.LinkedHashSet[RfAccess](RS1, RS2, RD)

        val rfaKeys = mutable.LinkedHashMap[RfAccess, AccessKeys]()
        for(rfa <- rfAccesses){
            val physWidth = 5
            // we only use IntRegFile currently
            val rfMapping = List(IntRegFile)
            val ak = AccessKeys(rfa, physWidth, rfMapping)
            ak.setPartialName(rfa)
            rfaKeys(rfa) = ak
        }
        Decode.rfaKeys.set(rfaKeys)
        class RfAccessDecoding(val rfa : RfAccess){
            val rfaKey = rfaKeys(rfa)
            val read = new DecodingSpec(Bool()).setDefault(Masked.zero)
            val rfid = new DecodingSpec(UInt(rfaKey.rfIdWidth bits))
        }
        val rfAccessDec = rfAccesses.map(rfa => rfa -> new RfAccessDecoding(rfa)).toMapLinked()

        elaborationLock.await()

        val decodeStage = pp.decode(decodeAt)
        val decodeCtrl = new decodeStage.Area {
            Decode.INSTRUCTION := Fetch.WORD
            val inst32 = Decode.INSTRUCTION(31 downto 0)

            for(microOp <- microOps) {
                val maskedOp = Masked(microOp.key)
                microOp.resources.foreach {
                    case r: RfResource => {
                        val dec = rfAccessDec(r.access)
                        dec.read.addNeeds(maskedOp, Masked.one)
                        dec.rfid.addNeeds(maskedOp, Masked(dec.rfaKey.idOf(r.rf), (1 << dec.rfaKey.rfIdWidth)-1))
                    }
                    case _ =>
                }
            }

            val maskedOps = microOps.map(op => Masked(op.key))
            for(rfa <- rfAccesses) {
                val keys = rfaKeys(rfa)
                val dec = rfAccessDec(rfa)
                keys.ENABLE := dec.read.build(inst32, maskedOps)
                keys.RFID := dec.rfid.build(inst32, maskedOps)
                keys.PHYS := Decode.INSTRUCTION(rfa match {
                    case RS1 => riscv.Const.rs1Range
                    case RS2 => riscv.Const.rs2Range
                    case RS3 => riscv.Const.rs3Range
                    case RD  => riscv.Const.rdRange
                    }).asUInt
            }
            val x0Logic = Decode.rfaKeys.get.get(RD) map { rfaRd =>
                val rdRfidZero = rfaRd.rfMapping.zipWithIndex.filter(_._1.x0AlwaysZero).map(_._2)
                val rdZero = Decode.INSTRUCTION(riscv.Const.rdRange) === 0 && rdRfidZero.map(rfaRd.RFID === _).orR
                rfaRd.ENABLE clearWhen (rdZero)
            }

            for((payload, spec) <- decodingSpecs) {
                payload.assignFromBits(spec.build(inst32, maskedOps).asBits)
            }

            val legalCmd = Symplify(inst32, maskedOps)
            throwWhen(~legalCmd)
        }

        buildBefore.release()
    }
}


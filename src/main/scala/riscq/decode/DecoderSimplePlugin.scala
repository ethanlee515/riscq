package riscq.decode

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.misc.pipeline._
import riscq.Global._
import riscq.fetch._
import scala.collection.mutable
import riscq.riscv
import riscq.riscv._
import riscq.schedule.PipelinePlugin

class DecoderSimplePlugin(val decodeAt: Int) extends FiberPlugin with DecoderService {
    val decodingSpecs = mutable.LinkedHashMap[MicroOp, mutable.ArrayBuffer[(Payload[_ <: BaseType], AnyRef)]]()
    def addMicroOpDecoding(microOp: MicroOp, key: Payload[_ <: BaseType], value: AnyRef) = {
        val instructionModel = decodingSpecs.getOrElseUpdate(microOp, mutable.ArrayBuffer[(Payload[_ <: BaseType], AnyRef)]())
        instructionModel.map{ 
            case(payload, _) => {
                assert(key != payload, s"Over specification of $key")
            }
        }
        instructionModel += (key->value)
    }

    val payloadDefaults = mutable.LinkedHashMap[Payload[_ <: BaseType], AnyRef]()
    def addPayloadDefault(key: Payload[_ <: BaseType], value: AnyRef) = {
        assert(!payloadDefaults.contains(key), s"Over specification of $key")
        payloadDefaults(key) = value
    }

    val logic = during setup new Area{
        val pp = host[PipelinePlugin]
        val buildBefore = retains(pp.elaborationLock)

        awaitBuild()

        Decode.INSTRUCTION_WIDTH.set(Fetch.WORD_WIDTH)

        val invalidCmd = Bool()
        invalidCmd := True

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

        elaborationLock.await()

        val decodeStage = pp.decode(decodeAt)
        val decodeCtrl = new decodeStage.Area {
            Decode.INSTRUCTION := Fetch.WORD

            val payloads = (decodingSpecs.flatMap(_._2.map(_._1)) ++ payloadDefaults.map(_._1)).toList.distinct
            for(payload <- payloads){
                if(payloadDefaults.contains(payload)){
                    payload.assignFrom(payloadDefaults(payload))
                } else {
                    payload.assignDontCare()
                }
            }

            for((rfa, keys) <- rfaKeys){
                keys.ENABLE := False
                keys.RFID := U(0)
                keys.PHYS := Decode.INSTRUCTION(rfa match {
                    case RS1 => riscv.Const.rs1Range
                    case RS2 => riscv.Const.rs2Range
                    case RS3 => riscv.Const.rs3Range
                    case RD  => riscv.Const.rdRange
                    }).asUInt
            }

            for((microOp, tasks) <- decodingSpecs){
                when(Decode.INSTRUCTION(31 downto 0) === microOp.key && isValid){
                    invalidCmd := False
                    for((payload, value) <- tasks){
                        val v = value match {
                            case e: SpinalEnumElement[_] => e()
                            case e: BaseType => e
                        } 
                        payload.assignFrom(v)
                    }
                    for(resource <- microOp.resources){
                        resource match {
                            case r : RfResource => {
                                val keys = rfaKeys(r.access)
                                keys.ENABLE := True
                            }
                            case _ =>
                        }
                    }
                }
            }
            throwWhen(invalidCmd)
        }

        buildBefore.release()
    }
}

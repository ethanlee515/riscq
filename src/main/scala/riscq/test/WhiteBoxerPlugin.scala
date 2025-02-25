package riscq.test

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import riscq.Global
// import riscq.Global.{COMMIT, HART_COUNT, TRAP}
import riscq.schedule.PipelinePlugin
import riscq.decode.{Decode, DecoderSimplePlugin}
import riscq.fetch.FetchCachelessPlugin
import riscq.execute._
import riscq.execute.lsu._
import riscq.fetch.{Fetch}
import riscq.misc.{PipelineBuilderPlugin}
// import riscq.prediction.{BtbPlugin, LearnCmd, LearnPlugin}
import riscq.regfile.{RegFileWrite, RegFileWriter, RegFileWriterService, RegFilePlugin}
import riscq.riscv.{Const, Riscv}
import riscq.schedule.{FlushCmd, ReschedulePlugin}

import scala.collection.mutable.ArrayBuffer
import riscq.fetch.PcService
import riscq.fetch.PcPlugin
import riscq.riscv.IntRegFile
import riscq.riscv.RS1
import riscq.schedule.HazardPlugin
import riscq.riscv.RS2
import scala.collection.mutable.LinkedHashMap

class WhiteboxerPlugin() extends FiberPlugin{

  // val logic = during setup new Logic()
  // class Logic extends Area{
  val logic = during setup new Area{
    val pbp = host[PipelineBuilderPlugin]
    val buildBefore = retains(pbp.elaborationLock)

    awaitBuild()

    def wrap[T <: Data](that: T): T = {
      val buffered = CombInit(that).simPublic
      buffered
    }

    val pp = host[PipelinePlugin]

    val pcp = host[PcPlugin]
    val pc = new Area {
      val state = wrap(pcp.logic.self.state)
      val output = wrap(pcp.logic.output.payload)
      val ready = wrap(pcp.logic.output.ready)
      val valid = wrap(pcp.logic.output.valid)
    }

    val exInsts = new Area {
      pp.logic.await()
      val exCtrls = pp.exIdToCtrl.toList.sortBy(_._1).map(_._2)
      val data = for(ctrl <- exCtrls) yield new Area {
        val inst = wrap(ctrl(Decode.INSTRUCTION))
        val valid = wrap(ctrl.isValid)
        val ready = wrap(ctrl.isReady)
      }
      // val ex_2 = wrap(pp.execute(-2)(Decode.INSTRUCTION))
      // val v_2 = wrap(pp.execute(-2).isValid)
      // val r_2 = wrap(pp.execute(-2).isReady)
      // val pc_2 = wrap(pp.execute(-2)(Fetch.WORD_PC))
      // val ex_1 = wrap(pp.execute(-1)(Decode.INSTRUCTION))
      // val v_1 = wrap(pp.execute(-1).isValid)
      // val r_1 = wrap(pp.execute(-1).isReady)
      // val ex0 = wrap(pp.execute(0)(Decode.INSTRUCTION))
      // val v0 = wrap(pp.execute(0).isValid)
      // val r0 = wrap(pp.execute(0).isReady)
      // val ex1 = wrap(pp.execute(1)(Decode.INSTRUCTION))
      // val v1 = wrap(pp.execute(1).isValid)
      // val r1 = wrap(pp.execute(1).isReady)
      // val ex2 = wrap(pp.execute(2)(Decode.INSTRUCTION))
      // val v2 = wrap(pp.execute(2).isValid)
      // val r2 = wrap(pp.execute(2).isReady)
      // val ex3 = wrap(pp.execute(3)(Decode.INSTRUCTION))
      // val v3 = wrap(pp.execute(3).isValid)
      // val r3 = wrap(pp.execute(3).isReady)
    }

    val fcp = host[FetchCachelessPlugin]

    val fetch = new Area {
      val c = pp.fetch(0)
      val fire = wrap(c.down.isFiring)
      val pc0 = wrap(pp.fetch(0)(Fetch.WORD_PC))
      val pc1 = wrap(pp.fetch(1)(Fetch.WORD_PC))
      val pc2 = wrap(pp.fetch(2)(Fetch.WORD_PC))
      val inflight = wrap(fcp.logic.buffer.inflight)
      // val word1 = wrap(pp.fetch(2)(Fetch.WORD))
    }

    val bp = host[BranchPlugin]
    val branch = new Area {
      val doIt = wrap(bp.logic.jumpLogic.doIt)
      val sel = wrap(pp.execute(1)(bp.SEL))
      val inst = wrap(pp.execute(1)(Decode.INSTRUCTION))
      val valid = wrap(pp.execute(1).isValid)
      val pc = wrap(pp.execute(1)(Fetch.WORD_PC))
    }

    val decode = new Area {
      val c = pp.decode(0)
      val fire = wrap(c.up.isFiring)
      val pc = wrap(Global.expendPc(c(Fetch.WORD_PC), 64).asSInt)
      val inst = wrap(c(Decode.INSTRUCTION))
    }

    val timep = host.get[TimerPlugin]
    val timer = timep.nonEmpty generate new Area {
      val tp = timep.get
      val time = wrap(tp.logic.time)
      val ctrl = wrap(pp.execute(0)(tp.logic.CTRL))
      val SEL = wrap(pp.execute(0)(timep.get.SEL))
      val ctrl1 = wrap(pp.execute(1)(tp.logic.CTRL))
      val SEL1 = wrap(pp.execute(1)(timep.get.SEL))
      val haltCond = wrap(tp.logic.exWaitLogic.haltCond)
      val target = wrap(tp.logic.targetTime)
      val timeLt = wrap(tp.logic.timeLt)
    }

    val pgp = host.get[PulseGeneratorPlugin]
    val pg = pgp.nonEmpty.option(new Area {
      val pg = pgp.get.logic.pgPorts(0)
      // val pgmem = pg.pg.mem.mem.simPublic
      // pg.pg.memPort.write := False
      // pg.pg.memPort.enable := True
      // pgp.get.logic.memPort.write := False
      // pgp.get.logic.memPort.enable := True
      val pgdata = pg.data.simPublic
      val pgcarrier = pg.carrier.simPublic
      val pgevent = pg.event.simPublic
      // val pgtimer = pg.timer.simPublic
      // val phaseR = wrap(pg.pg.phaseC.r)
    })

    val rfp = host.get[RegFilePlugin]
    val rf = rfp.nonEmpty generate new Area {
      val p = rfp.get
      val mem = p.logic.regfile.fpga.asMem.ram
    }

    val wbpo = host.get[WriteBackPlugin]
    val wbp = wbpo.nonEmpty generate new Area {
      val p = wbpo.get
      // val DATA = LinkedHashMap[Int, Bits]()
      // for(ex <- 0 until 3) {
      //   DATA(ex) = wrap(pp.execute(ex)(p.logic.DATA))
      // }
      val DATA1 = wrap(pp.execute(1)(p.logic.DATA))
      val DATA2 = wrap(pp.execute(2)(p.logic.DATA))
    }
    val wb = host.list[WriteBackPlugin].flatMap(_.getRegFileWriters()).map(wrap)

    val rrpo = host.get[RegReadPlugin]
    val rs = rrpo.nonEmpty generate new Area {
      val rrp = rrpo.get
      val rs1 = wrap(pp.execute(-1)(rrp(IntRegFile, RS1)))
      val rs1k = Decode.rfaKeys.get(RS1)
      val rs1e = wrap(pp.execute(-1)(rs1k.ENABLE))
      val rs1p = wrap(pp.execute(-1)(rs1k.PHYS))
      val rs1i = wrap(pp.execute(-1)(rs1k.RFID))
      val rs2 = wrap(pp.execute(-1)(rrp(IntRegFile, RS2)))
      val rs2k = Decode.rfaKeys.get(RS2)
      val rs2e = wrap(pp.execute(-1)(rs2k.ENABLE))
      val rs2p = wrap(pp.execute(-1)(rs2k.PHYS))
      val rs2i = wrap(pp.execute(-1)(rs2k.RFID))
      val rsp = rrp.logic.rf.reads.map(_.port).map(wrap)
      // val bpse = rrp.logic.rf.reads.map(_.bypassEnables).map(wrap)
    }

    val srcp = host.get[SrcPlugin]
    val src = srcp.nonEmpty generate new Area {
      val src1 = wrap(pp.execute(-1)(srcp.get.SRC1))
      val src2 = wrap(pp.execute(-1)(srcp.get.SRC2))
      val src1k = wrap(pp.execute(-1)(srcp.get.logic.SRC1_CTRL))
      val src2k = wrap(pp.execute(-1)(srcp.get.logic.SRC2_CTRL))
      val addsub = wrap(pp.execute(0)(srcp.get.ADD_SUB))
    }

    val hp = host.get[HazardPlugin]
    val hazard = hp.nonEmpty generate new Area {
      val p = hp.get
      val rs = wrap(hp.get.logic.rsHazardChecker.rsHazard)
      val flush = wrap(hp.get.logic.flushChecker.flushHazard)
      val valid0 = wrap(pp.execute(0).isValid)
      val bypass_1 = for( (id, payload) <- p.logic.bypassedSpecs ) yield {
        (id, wrap(pp.execute(-1)(payload)))
      }
      val bypass  = LinkedHashMap[Int, LinkedHashMap[Int, Bool]]()
      for(ex <- -2 until 3) {
        val id_data= LinkedHashMap[Int, Bool]()
        for( (id, payload) <- p.logic.bypassedSpecs) { 
          id_data(id) = wrap(pp.execute(ex)(payload))
        }
        bypass(ex) = id_data
      }
    }

    val cp = host.get[CarrierPlugin]
    val carrier = cp.nonEmpty generate new Area{
      val data = wrap(cp.get.logic.cgPorts(5).carrier)
    }

    val rop = host.get[ReadoutPlugin]
    val readout = rop.nonEmpty generate new Area{
      val readR = wrap(rop.get.logic.results(1).r)
      val cmdv = wrap(rop.get.logic.readAccs(1).io.cmd.valid)
      val accR = wrap(rop.get.logic.readAccs(1).io.rsp.r)
      val accv = wrap(rop.get.logic.readAccs(1).io.rsp.valid)
      val carrier = wrap(rop.get.logic.readAccs(1).io.carrier)
      val adc = wrap(rop.get.logic.readAccs(1).io.adc)
    }

    val dap = host.get[DacAdcPlugin]
    val da = dap.nonEmpty generate new Area{
      val dac = wrap(dap.get.logic.dac)
    }

    val lsup = host.get[LsuCachelessPlugin]
    val lsu = lsup.nonEmpty generate new Area {
      val p = lsup.get
      val SEL0 = wrap(pp.execute(0)(p.SEL))
      val RAW_ADDRESS0 = wrap(pp.execute(0)(p.logic.onAddress.RAW_ADDRESS))
      val skip = wrap(p.logic.onFork.skip)
      val bv = wrap(p.logic.bus.cmd.valid)
      val data = wrap(p.logic.bus.cmd.data)
      val mask = wrap(p.logic.bus.cmd.mask)
      val addr = wrap(p.logic.bus.cmd.address)
      val write = wrap(p.logic.bus.cmd.write)
      val WRITE_DATA = wrap(pp.execute(0)(p.logic.onFirst.WRITE_DATA))
      val READ_DATA1 = wrap(pp.execute(1)(p.logic.onJoin.READ_DATA))
      val READ_DATA2 = wrap(pp.execute(2)(p.logic.onJoin.READ_DATA))
    }




    buildBefore.release()
  }
}


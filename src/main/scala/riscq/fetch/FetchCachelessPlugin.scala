package riscq.fetch

import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.lib.misc.database.Database._
import spinal.lib.misc.pipeline._
import riscq.Global._
import riscq.schedule.PipelinePlugin
import spinal.lib.bus.tilelink
import spinal.lib.bus.misc.SizeMapping
import spinal.core.fiber.Fiber

case class CachelessBusParam(addressWidth : Int, dataWidth : Int, idCount : Int, cmdPersistence : Boolean){
  val idWidth = log2Up(idCount)

  def toTilelinkM2s(name : Nameable) = new tilelink.M2sParameters(
    addressWidth = addressWidth,
    dataWidth = dataWidth,
    masters = List(
      new tilelink.M2sAgent(
        name = name,
        mapping = List(
          new tilelink.M2sSource(
            id = SizeMapping(0, idCount),
            emits = tilelink.M2sTransfers(
              get = tilelink.SizeRange(dataWidth/8)
            )
          )
        )
      )
    )
  )
}

case class CachelessCmd(p : CachelessBusParam) extends Bundle{
  val id = UInt(p.idWidth bits)
  val address = UInt(p.addressWidth bits)
}

case class CachelessRsp(p : CachelessBusParam) extends Bundle{
  val id = UInt(p.idWidth bits)
  val error = Bool()
  val word  = Bits(p.dataWidth bits)
}

case class CachelessBus(p : CachelessBusParam) extends Bundle with IMasterSlave {
  var cmd = Stream(CachelessCmd(p))
  var rsp = Flow(CachelessRsp(p))

  override def asMaster(): Unit = {
    master(cmd)
    slave(rsp)
  }
}

class CachelessBusToTilelink(up : CachelessBus) extends Area{
  // assert(up.p.cmdPersistence)
  val m2sParam = up.p.toTilelinkM2s(this)
  val down = tilelink.Bus(m2sParam)
  down.a.arbitrationFrom(up.cmd)
  down.a.opcode  := tilelink.Opcode.A.GET
  down.a.param   := 0
  down.a.source  := up.cmd.id
  down.a.address := up.cmd.address
  down.a.size    := log2Up(up.p.dataWidth/8)
  down.a.debugId := tilelink.DebugId.withPostfix(up.cmd.id)

  down.d.ready := True
  up.rsp.valid := down.d.valid
  up.rsp.id    := down.d.source
  up.rsp.error := down.d.denied
  up.rsp.word  := down.d.data
}

class FetchCachelessTileLinkPlugin(node : bus.tilelink.fabric.Node) extends FiberPlugin {
  val logic = during build new Area{
    val fcp = host[FetchCachelessPlugin]
    fcp.logic.bus.setAsDirectionLess()

    val bridge = new CachelessBusToTilelink(fcp.logic.bus)
    master(bridge.down)

    node.m2s.forceParameters(bridge.m2sParam)
    node.s2m.supported.load(tilelink.S2mSupport.none())
    node.bus.component.rework(node.bus << bridge.down)
  }
}

class FetchCachelessBramConnectArea(fcp: FetchCachelessPlugin, port: MemReadWritePort[Bits]) extends Area {
  val logic = Fiber build new Area {
    port.enable := True
    port.write := False
    port.wdata := 0
    port.mask.setAllTo(True)

    val wordWidth = fcp.wordWidth
    val addrShift = log2Up(wordWidth / 8)
    port.address := fcp.logic.bus.cmd.address(addrShift, port.addressWidth bit)
    // val id = RegNext(RegNext(fcp.logic.bus.cmd.id))
    // val valid = RegNext(RegNext(fcp.logic.bus.cmd.valid) init False) init False
    // val word = RegNext(port.rdata)
    val id = RegNext(fcp.logic.bus.cmd.id)
    val valid = RegNext(fcp.logic.bus.cmd.valid) init False
    val word = port.rdata

    fcp.logic.bus.rsp.id := id
    fcp.logic.bus.rsp.error := False
    fcp.logic.bus.rsp.word := word
    fcp.logic.bus.rsp.valid := valid
    fcp.logic.bus.cmd.ready := True
  }
}

// object CachelessPlugin{
//   val ID_WIDTH = blocking[Int]
//   val ID = blocking[Int]
// }

class FetchCachelessPlugin(var wordWidth : Int,
                      var forkAt : Int = 0,
                      var joinAt : Int = 1,
                      var cmdForkPersistence : Boolean = true) extends FiberPlugin{


  val logic = during setup new Area{
    PHYSICAL_WIDTH.set(32)
    // VIRTUAL_WIDTH.set(32)
    // val pp = host[FetchPipelinePlugin]
    val pp = host[PipelinePlugin]
    for(i <- forkAt to joinAt){
      pp.fetch(i)
    }
    val buildBefore = retains(pp.elaborationLock)
    awaitBuild()

    Fetch.WORD_WIDTH.set(wordWidth)

    val idCount = joinAt - forkAt + 1 // default 2
    val p = CachelessBusParam(PHYSICAL_WIDTH, Fetch.WORD_WIDTH, idCount, false)
    // val p = CachelessBusParam(32, Fetch.WORD_WIDTH, idCount, false)
    val bus = master(CachelessBus(p))

    val BUFFER_ID = Payload(UInt(log2Up(idCount) bits)) // reserveId of current data

    val buffer = new Area{ // buffer for full fetch pipeline
      val reserveId = Counter(idCount) // next slot for data
      val inflight = Vec.fill(idCount)(RegInit(False)) // if a slot is loading
      val words = Mem.fill(idCount)(Fetch.WORD) // memory for saving fetched data
      val reservedHits = for (ctrlId <- forkAt+1 to joinAt; ctrl = pp.fetch(ctrlId)) yield {
        ctrl.isValid && ctrl(BUFFER_ID) === reserveId // reservedId is being used
      }
      val full = CombInit(reservedHits.orR || inflight.read(reserveId)) //TODO that's one cycle late, can use sort of ahead value

      when(bus.cmd.fire) { // sending loading message to memory
        inflight(reserveId) := True
      }

      when(bus.rsp.valid) { // respond received
        inflight(bus.rsp.id) := False
        words(bus.rsp.id) := bus.rsp.word
      }
    }

    val fork = new pp.Fetch(forkAt){ // send address to memory
      // forcedSpawn: fire a new one even if the last one is not fired
      val fresh = (forkAt == 0).option(host[PcPlugin].forcedSpawn()) // used for jump inst to resend the memory query
      // forkStream: payloades go to both bus and down. only move when both bus and down are available
      val cmdFork = forkStream(fresh)
      bus.cmd.arbitrationFrom(cmdFork.haltWhen(buffer.full)) // set valid and ready
      bus.cmd.id := buffer.reserveId // sending request
      bus.cmd.address := Fetch.WORD_PC  // set in PcPlugin

      BUFFER_ID := buffer.reserveId // id of the issued request

      when(up.isMoving) { // up is logic.inject in PcPlugin, isMoving = valid && (isReady || isCancel) 
        buffer.reserveId.increment() // fetch next data
      }
    }

    // using payload in pp.Fetch(forkAt) is equivalent to in pp.fetch(forkAt).down, but has access to haltWhen
    val join = new pp.Fetch(joinAt){
      val haltIt = buffer.inflight.read(BUFFER_ID) // check if the data fetched in fork is ready
      Fetch.WORD := buffer.words.readAsync(BUFFER_ID) // get the data
      // // Implement bus rsp bypass into the pipeline (without using the buffer)
      when(bus.rsp.valid && bus.rsp.id === BUFFER_ID){ // bypass the fetched data when ready without entering buffer 
        haltIt := False
        Fetch.WORD := bus.rsp.word
      }
      haltWhen(haltIt)
    }
    buildBefore.release()
  }
}
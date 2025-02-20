package riscq.riscv

import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin
import riscq.Global
// import riscq.decode.Decode
import riscq.fetch.Fetch

class RiscvPlugin(var xlen : Int,
                  // var hartCount : Int,
                  var rvc: Boolean = false,
                  var rvf: Boolean = false,
                  var rvd: Boolean = false) extends FiberPlugin{

  val logic = during build new Area{
    if(Riscv.RVC.isEmpty) Riscv.RVC.set(rvc)
    if(Riscv.RVM.isEmpty) Riscv.RVM.set(false)
    if(Riscv.RVF.isEmpty) Riscv.RVF.set(rvf)
    if(Riscv.RVD.isEmpty) Riscv.RVD.set(rvd)
    if(Riscv.RVZba.isEmpty) Riscv.RVZba.set(false)
    if(Riscv.RVZbb.isEmpty) Riscv.RVZbb.set(false)
    if(Riscv.RVZbc.isEmpty) Riscv.RVZbc.set(false)
    if(Riscv.RVZbs.isEmpty) Riscv.RVZbs.set(false)
    Riscv.XLEN.set(xlen)
    Riscv.FLEN.set(List(Riscv.RVF.get.toInt*32, Riscv.RVD.get.toInt*64).max)
    Riscv.LSLEN.set(List(Riscv.XLEN.get, Riscv.FLEN.get).max)
    Fetch.ID_WIDTH.set(10)
  }
}

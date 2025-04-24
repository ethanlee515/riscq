package riscq.execute.lsu

trait LsuCachelessBusProvider {
  def getLsuCachelessBus() : LsuCachelessBus
  def busParam() : LsuCachelessBusParam
}
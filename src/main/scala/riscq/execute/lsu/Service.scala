package riscq.execute.lsu

trait LsuCachelessBusProvider {
  def getLsuCachelessBus() : LsuCachelessBus
}

trait CmoService{
  def withSoftwarePrefetch : Boolean
}

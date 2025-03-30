#include "mmio.h"

int main() {
  WRITE_INT32(MTIME, 0);

  int freq = FREQ_GHZ(0.1);
  CARRIER(0, freq, 0);

  WRITE_INT32(MTIMECMP, 50);
  int x = READ_INT32(MTIMEWAIT);
  x = READ_INT32(MTIMEWAIT);
  x = READ_INT32(MTIMEWAIT);

  WRITE_INT32(RD_0_REFR, -7);
  WRITE_INT32(RD_0_REFI, 7);
  WRITE_INT32(RD_0_DUR, 10);

  int res = READ_INT32(RD_0_RES);

  return 0;
}

#include "mmio.h"

int main() {
  WRITE_INT32(MTIME, 0);

  int freq = FREQ_GHZ(0.1);
  int freq_step = FREQ_GHZ(0.1);
  int start_time = TIME_NS(200);
  int time_step = TIME_NS(200);

  for(int i = 0; i < 5; ++i) {
    CARRIER(2, freq, 0);
    PULSE(2, 0, 0x7000, TIME_NS(8), PHASE_PI(0), start_time);

    WRITE_INT32(MTIMECMP, start_time + TIME_NS(30));
    int x = READ_INT32(MTIMEWAIT);
    x = READ_INT32(MTIMEWAIT);
    x = READ_INT32(MTIMEWAIT);

    freq += freq_step;
    start_time += time_step;
  }

  return 0;
}

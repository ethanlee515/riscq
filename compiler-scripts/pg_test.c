#include "mmio.h"

// int main() {
//   WRITE_INT32(MTIME, 0);

//   int freq = FREQ_GHZ(0.1);
//   int freq_step = FREQ_GHZ(0.1);
//   int start_time = TIME_NS(200);
//   int time_step = TIME_NS(200);

//   for(int i = 0; i < 5; ++i) {
//     SET_PULSE_FREQ(2, freq);
//     SET_START_TIME(start_time);
//     PULSE(2, PHASE_PI(0), 0x7fff, 0, TIME_NS(8));

//     WRITE_INT32(MTIMECMP, start_time + TIME_NS(30));
//     int x = READ_INT32(MTIMEWAIT);
//     x = READ_INT32(MTIMEWAIT);
//     x = READ_INT32(MTIMEWAIT);

//     freq += freq_step;
//     start_time += time_step;
//   }

//   return 0;
// }

int main() {
  WRITE_INT32(MTIME, 0);

  int freq = FREQ_GHZ(0.1);
  int freq_step = FREQ_GHZ(0.1);
  int start_time = TIME_NS(200);
  int time_step = TIME_NS(200);

  SET_START_TIME(start_time);
  SET_PULSE_FREQ(0, freq);
  SET_PULSE_FREQ(2, freq);
  PULSE(2, PHASE_PI(0.5), 0x7ff0, 3, TIME_NS(12));
  PULSE(0, PHASE_PI(0.2), 0x7fff, 2, TIME_NS(8));


  return 0;
}

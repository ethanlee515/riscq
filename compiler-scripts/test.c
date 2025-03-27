#include<stdint.h>
#define WRITE_INT32(ADDR, DATA) *(volatile int32_t *)ADDR = DATA
#define READ_INT32(ADDR) *(volatile int32_t *)ADDR

// const volatile int32_t * MTIME = (volatile int32_t *) 0xBFF8;
// const volatile int32_t * MTIMECMP = (volatile int32_t *) 0x4000;
// const volatile int32_t * MTIMEWAIT = (volatile int32_t *) 0x4008;
#define MTIME 0xBFF8
#define MTIMECMP 0x4000
#define MTIMEWAIT 0x4008

#define PG_0_ADDR 0x10000
#define PG_0_AMP 0x10004
#define PG_0_DUR 0x10008
#define PG_0_PHASE 0x1000c
#define PG_0_START 0x10010

#define CG_0_FREQ 0x20000
#define CG_0_PHASE 0x20004

#define FREQ_GHZ(x) (int)(x * (1 << 13))
#define TIME_NS(x) (int)(x * 2)
#define PHASE_PI(x) (int)(x * (1 << 15))



int main() {
  // WRITE_INT32(MTIME, 123);
  // * ((volatile int32_t *) 0xBFF8) = 123;
  WRITE_INT32(MTIME, 0);
  WRITE_INT32(CG_0_FREQ, FREQ_GHZ(0.1));
  WRITE_INT32(CG_0_PHASE, 0);

  WRITE_INT32(PG_0_ADDR, 0);
  WRITE_INT32(PG_0_AMP, 1 << 14);
  WRITE_INT32(PG_0_DUR, TIME_NS(4));
  WRITE_INT32(PG_0_PHASE, PHASE_PI(0));
  WRITE_INT32(PG_0_START, 100);

  WRITE_INT32(MTIMECMP, 90);
  int x = READ_INT32(MTIMEWAIT);
  return 0;
}

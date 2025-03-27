#include<stdint.h>
#define WRITE_INT32(ADDR, DATA) *(volatile int32_t *)ADDR = DATA
#define WRITE_INT32_HIGH(ADDR, DATA) *(volatile int32_t *)ADDR = (DATA << 16)
#define READ_INT32(ADDR) *(volatile int32_t *)ADDR

// const volatile int32_t * MTIME = (volatile int32_t *) 0xBFF8;
// const volatile int32_t * MTIMECMP = (volatile int32_t *) 0x4000;
// const volatile int32_t * MTIMEWAIT = (volatile int32_t *) 0x4008;
#define MTIME 0xBFF8
#define MTIMECMP 0x4000
#define MTIMEWAIT 0x4008

#define PG_0_ADDR 0x100000
#define PG_0_AMP 0x100010
#define PG_0_DUR 0x100020
#define PG_0_PHASE 0x100030
#define PG_0_START 0x100040

#define CG_0_FREQ 0x200000
#define CG_0_PHASE 0x200010

#define FREQ_GHZ(x) (int)(x * (1 << 13))
#define TIME_NS(x) (int)(x / 2)
#define PHASE_PI(x) (int)(x * (1 << 15))



int main() {
  // WRITE_INT32(MTIME, 123);
  // * ((volatile int32_t *) 0xBFF8) = 123;
  WRITE_INT32_HIGH(MTIME, 0);
  WRITE_INT32_HIGH(CG_0_FREQ, FREQ_GHZ(0.1));
  WRITE_INT32_HIGH(CG_0_PHASE, 0);

  WRITE_INT32_HIGH(PG_0_ADDR, 0);
  WRITE_INT32_HIGH(PG_0_AMP, 0x7000);
  WRITE_INT32_HIGH(PG_0_DUR, TIME_NS(8));
  WRITE_INT32_HIGH(PG_0_PHASE, PHASE_PI(0));
  WRITE_INT32_HIGH(PG_0_START, 100);

  WRITE_INT32(MTIMECMP, 100);
  WRITE_INT32(MTIMECMP, 100);
  WRITE_INT32(MTIMECMP, 100);
  int x = READ_INT32(MTIMEWAIT);
  x = READ_INT32(MTIMEWAIT);
  x = READ_INT32(MTIMEWAIT);
  x = READ_INT32(MTIMEWAIT);
  return 0;
}

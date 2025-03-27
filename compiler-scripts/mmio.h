#include<stdint.h>
#define WRITE_INT32(ADDR, DATA) *(volatile int32_t *)ADDR = DATA

// #define MTIME 0x0000BFF8
const volatile int32_t * MTIME = (volatile int32_t *) 0xBFF8;
const volatile int32_t * MTIMECMP = (volatile int32_t *) 0x4000;
const volatile int32_t * MTIMEWAIT = (volatile int32_t *) 0x4008;
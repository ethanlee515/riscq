.section .text
.globl _start
.option norvc
_start:
  # cgOffset = 0x20000
  li x1, 0x20000
  # carrier
  li x2, 1 << 9
  sw x2, 0(x1)
  sw x0, 4(x1)
  # pgOffset = 0x10000
  li x1, 0x10000
  # addr = 0
  sw x0, 0(x1)
  # amp = (1 << (puop.ampWidth - 1)) - 1
  li x2, ((1 << (16 - 1)) - 1)
  sw x2, 4(x1)
  # duration = 4
  li x2, 4
  sw x2, 8(x1)
  # phase = 0
  sw x0, 12(x1)
  # start = 100
  li x2, 100
  sw x2, 16(x1) 
  # TODO freq = 0
  # why no mmap correspondance here?

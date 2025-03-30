.section .text
.globl _start
.option norvc
_start:
  addi x1, x0, 3
  addi x2, x0, 0
loop:
  add x2, x1, x2
  jal x0, loop

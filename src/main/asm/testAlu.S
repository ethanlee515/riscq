.section .text
.globl _start
.option norvc
_start:
  li x0, 3
  li x1, 5
  jal x0, 0

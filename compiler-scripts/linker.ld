ENTRY(_start)

SECTIONS
{
  /* Place everything starting from 0x80000000 */
  . = 0x80000000;

  .text : {
    KEEP(start.o(.text))     /* place entire .text from start.o first */
    *(.text)
  }

  .rodata : {
    *(.rodata)
  }

  .data : {
    *(.data)
  }

  .bss : {
    *(.bss)
    *(COMMON)
  }

  /DISCARD/ : {
    *(.comment)
    *(.note*)
    *(.eh_frame)
  }
}
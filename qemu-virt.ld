OUTPUT_ARCH(riscv)
OUTPUT_FORMAT(elf64-littleriscv)

ENTRY(_reset)
SECTIONS
{
  . = 0x80000000;
  __origin = .;

  .text :
  {
    *(.text)
    . = ALIGN(32);
  }

  . = __origin + 1M;
  .data :
  {
    *(.data)
    . = ALIGN(32);
  }

  .riscv.attributes :
  {
    KEEP(*(.riscv.attributes))
  }
}

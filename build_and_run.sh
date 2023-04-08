#!/bin/bash
set -e
set -x
riscv-none-elf-gcc -march=rv64gc -mabi=lp64f -mcmodel=medany -static -nostdlib -Tqemu-virt.ld startup.s -o test.elf

set +e

qemu-system-riscv64 -nographic -machine virt -bios test.elf -d int,mmu
QEMU_EXIT="$?"

spike -l test.elf
SPIKE_EXIT="$?"

set +x
echo
echo
echo "QEMU exited with code $QEMU_EXIT"
echo "Spike exited with code $SPIKE_EXIT"

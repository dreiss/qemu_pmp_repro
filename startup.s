.section .text, "ax", %progbits

.align 2
.globl _reset
.type _reset, %function
_reset:
  # Program our ISR address.
  la t0, _isr
  csrw mtvec, t0

  # Make sure MPRV=0 and MPP=U.
  li t0, ((1<<17)|(3<<11))
  csrc mstatus, t0

  # Make sure PMP region 0 is off.
  # Spike turns it on for backward compatibility.
  csrci pmpcfg0, (3<<3)

  # Attempt count.  When this counts down to 0,
  # we assume we're in an infinite interrupt loop.
  li s0, 4

  # Set MPRV to 1.
  li t0, (1<<17)  # MPRV
  csrs mstatus, t0

  # Load instruction should fault, and it does on the first iteration.
  # However, after the interrupt, it succeeds due to a QEMU TLB hit.
  la t2, dummy
  lw t0, (t2)

  # Turn off MPRV.
  li t0, (1<<17)  # MPRV
  csrc mstatus, t0

  # Exit with a failure code if we did not fault.
  li a0, 6
  j _exit

.align 2
.type _isr, %function
_isr:
  # Decrement our counter and exit successfully after multiple iterations
  # (since we're probably in an infinite loop).
  addi s0, s0, -1
  li a0, 0
  beqz s0, _exit


  # Load the dummy value from our interrupt handler.
  # This should have no effect, but it appears to populate the TLB.
  # Commenting this out causes the test to succeed.
  lw s1, dummy

  # Return back to the main program.  This should cause the fault to repeat,
  # causing an infinite interrupt loop.
  mret


.align 2
.type _exit, %function
_exit:
  csrr t0, marchid
  li t1, 5
  beq t0, t1, _exit_spike
  # Probably running in QEMU.  Write to the SiFive test device.
  # (We always use the fail opcode, but it still works with exit code 0.)
  li t0, 0x100000
  sll t1, a0, 16
  li t2, 0x3333
  or t1, t1, t2
  sw t1, 0(t0)
1:
  j 1b
_exit_spike:
  la t0, tohost
  sll t1, a0, 1
  ori t1, t1, 1
  sw t1, 0(t0)
1:
  j 1b
  

.section .data, "aw", %progbits

.align 2
.type dummy, %object
.size dummy, 4
dummy:
  .long 0

. =  (. + 0x1000 - 4)

# HTIF registers for Spike.
.align 3
.type tohost, %object
.size tohost, 8
tohost:
 .quad 0
.type fromhost, %object
.size fromhost, 8
fromhost:
 .quad 0

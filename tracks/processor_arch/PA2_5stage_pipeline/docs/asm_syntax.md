# Assembly Syntax (v1)

- Registers: r0-r7
- Comments: start with #
- Labels: label: at start of line
- Immediates: decimal (12) or hex (0x0C)

Pseudo-ops:
- NOP  -> opcode 0x0
- LI rd, imm -> expands to ADDI rd, r0, imm (if imm fits)
- .word 0xABCD -> raw 16-bit word

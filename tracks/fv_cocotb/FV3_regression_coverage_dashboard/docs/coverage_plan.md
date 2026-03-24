# Coverage Plan — Project 3 (v1)

## DUTs covered (from Project 2)
- ALU: opcodes + corner data patterns
- FIFO (optional in Project 2): empty/full transitions + ordering + illegal ops

## Functional coverage bins (examples)
- ALU opcode bins: op in {0..7}
- ALU data bins: a/b include {0, 1, max, 0xAAAA, 0x5555}
- FIFO depth bins: hit empty, hit full, hit mid-occupancy
- Illegal bins: pop_when_empty, push_when_full (checker must flag)

## Closure target
- Required bins: 100% hit for opcode bins + required corner bins
- Stretch bins: additional random distributions / stress scenarios

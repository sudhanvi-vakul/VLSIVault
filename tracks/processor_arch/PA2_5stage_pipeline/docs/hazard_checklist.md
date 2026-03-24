# Hazard Checklist (Project 2)

1) RAW (ALU->ALU):   add r3,r1,r2  ; addi r4,r3,1        => forwarding
2) RAW (ALU->store): add r3,r1,r2  ; st r3,[r6+0]        => forwarding store_data
3) Load-use:         ld r3,[r6+0]  ; add r4,r3,r5         => stall + bubble
4) Load->store:      ld r3,[r6+0]  ; st r3,[r6+4]         => usually stall + forward
5) Branch uses reg:  add r3,r1,r2  ; beq r3,r0,label      => forwarding into EX compare
6) Taken branch:     beq r1,r1,label ; next fetched instr => flush

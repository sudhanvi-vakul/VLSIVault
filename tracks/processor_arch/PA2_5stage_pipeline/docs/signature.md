# End-State Signature (Module 5)

**Signature location:** Register **r7** at HALT.

**PASS criteria (exact values):**
- demo_arith: PASS if **r7 == 0x000000A5**
- demo_branch: PASS if **r7 == 0x000000B7**
- demo_mem: PASS if **r7 == 0x00000036** (checksum value)

Notes:
- Each demo program must place its signature into r7 immediately before HALT.
- The simulation runner reads r7 at the end of simulation and writes it to signature.txt.

# Test Plan (Register Slice)

- Directed tests:
  - no stalls (out_ready always 1)
  - long stall burst (out_ready held 0 for many cycles)
  - single-cycle random stalls

- Random tests:
  - N tokens (default 2000)
  - repeatable +seed
  - multiple seeds (at least 3)

- PASS criteria:
  - received_count == sent_count == N
  - no mismatches
  - assertions never fire

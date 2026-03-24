# Ready/Valid Handshake Contract (Register Slice)

- Transfer condition (fire event):
  fire = valid && ready

- Stability rule (sender responsibility):
  If valid=1 and ready=0, sender must keep:
  - valid asserted
  - data stable
  until fire occurs.

- No drop / in-order rule:
  Every token accepted at the input must appear exactly once at the output, in the same order.
Definitions:
  stored_valid = 0 -> EMPTY
  stored_valid = 1 -> FULL

  out_valid = stored_valid
  in_ready  = (~stored_valid) | out_ready

  fire_in   = in_valid  && in_ready
  fire_out  = out_valid && out_read
Current State	in_valid	out_ready	in_ready	fire_in	fire_out	Next State	Meaning
EMPTY	0	0	1	0	0	EMPTY	Nothing stored, no input arrives
EMPTY	0	1	1	0	0	EMPTY	Still empty
EMPTY	1	0	1	1	0	FULL	New token enters buffer
EMPTY	1	1	1	1	0	FULL	New token enters buffer
FULL	0	0	0	0	0	FULL	Stall: hold token stable
FULL	1	0	0	0	0	FULL	Stall: block producer, hold token
FULL	0	1	1	0	1	EMPTY	Consumer takes token, no replacement
FULL	1	1	1	1	1	FULL	Simultaneous consume + refill

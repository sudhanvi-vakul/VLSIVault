def alu_ref(a, b, op, nbits=16):
    mask = (1 << nbits) - 1
    a &= mask; b &= mask
    if op == 0:   y = (a + b) & mask
    elif op == 1: y = (a - b) & mask
    elif op == 2: y = (a & b) & mask
    elif op == 3: y = (a | b) & mask
    elif op == 4: y = (a ^ b) & mask
    elif op == 5: y = (a << 1) & mask
    elif op == 6: y = (a >> 1) & mask
    else:         y = a & mask
    return y

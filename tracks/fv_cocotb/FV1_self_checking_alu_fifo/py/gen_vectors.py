import random
import csv
import argparse

def alu_ref(a, b, op, nbits=16):
    mask = (1 << nbits) - 1
    if op == 0:  y = (a + b) & mask
    elif op == 1: y = (a - b) & mask
    elif op == 2: y = (a & b) & mask
    elif op == 3: y = (a | b) & mask
    elif op == 4: y = (a ^ b) & mask
    elif op == 5: y = (a << 1) & mask
    elif op == 6: y = (a >> 1) & mask
    else:        y = a & mask
    return y

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--num", type=int, default=200)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--nbits", type=int, default=16)
    ap.add_argument("--out", default="vectors/alu_vectors.csv")
    args = ap.parse_args()

    random.seed(args.seed)

    corner = [
        0, 1, (1<<args.nbits)-1,
        int("AAAA", 16) & ((1<<args.nbits)-1),
        int("5555", 16) & ((1<<args.nbits)-1),
    ]

    with open(args.out, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["a","b","op","exp_y"])

        # forced corner cases
        for op in range(8):
            for a in corner:
                b = random.choice(corner)
                w.writerow([a, b, op, alu_ref(a,b,op,args.nbits)])

        # random cases
        for _ in range(args.num):
            a = random.getrandbits(args.nbits)
            b = random.getrandbits(args.nbits)
            op = random.randrange(0, 8)
            w.writerow([a, b, op, alu_ref(a,b,op,args.nbits)])

    print(f"Wrote {args.out} with seed={args.seed}")

if __name__ == "__main__":
    main()

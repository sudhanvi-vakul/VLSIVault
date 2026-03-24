#!/usr/bin/env python3
import csv, os, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SIM  = ROOT / "sim" / "obj_dir" / "sim"
ASM  = ROOT / "scripts" / "asm.py"

TESTS = [
    ("demo_arith",  "asm/demo_arith.s",  "0x00A5"),
    ("demo_branch", "asm/demo_branch.s", "0x00B7"),
    ("demo_mem",    "asm/demo_mem.s",    "0x0036"),
]

def run(cmd, cwd=None):
    print("+", " ".join(map(str, cmd)))
    subprocess.check_call(cmd, cwd=cwd)

def parse_signature(sig_path: Path):
    txt = sig_path.read_text().splitlines()
    d = {}
    for line in txt:
        if "=" in line:
            k,v = line.split("=",1)
            d[k.strip()] = v.strip()
        else:
            d["RESULT"] = line.strip()
    return d

def main():
    ts = time.strftime("%Y%m%d_%H%M%S")
    outroot = ROOT / "results" / f"regress_{ts}"
    outroot.mkdir(parents=True, exist_ok=True)

    summary_path = outroot / "summary.csv"
    with summary_path.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["test", "expected", "signature", "halted", "result", "run_dir"])

        for name, asm_src, expected in TESTS:
            run_dir = outroot / name
            run_dir.mkdir(parents=True, exist_ok=True)

            # assemble into run folder
            run(["python3", str(ASM), str(ROOT/asm_src), "--run-dir", str(run_dir)])

            # run sim in that folder
            run([str(SIM), name, expected, "5000", "--outdir", "."], cwd=run_dir)

            sig = parse_signature(run_dir / "signature.txt")
            w.writerow([
                name,
                expected,
                sig.get("signature",""),
                sig.get("HALTED",""),
                sig.get("RESULT",""),
                str(run_dir),
            ])

    print("Wrote:", summary_path)

if __name__ == "__main__":
    main()

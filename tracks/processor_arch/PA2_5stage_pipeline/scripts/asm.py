#!/usr/bin/env python3
"""
Toy ISA v1 Assembler (32-bit)
- Output: program.hex (32-bit words, 8 hex digits/line) + program.lst
- ISA (from your Module 1):
  * opcode = instr[31:28]
  * R-type: rd[27:24], rs1[23:20], rs2[19:16], low16 = 0
  * I-type: rd[27:24], rs1[23:20], imm16[15:0] (signed)
            ST uses rs2 in [19:16] (per your spec)
  * J-type: rs1[27:24], rs2[23:20], off20[19:0] (signed word offset)
            Effective byte offset in RTL = (off20 << 2)
            PC target in RTL = PC+4 + (off<<2)

Assembly Syntax:
- Comments: start with #
- Labels: label: at start of line
- Registers: r0-r15
- Immediates: decimal or hex (0x...)
- Pseudo-ops:
  * NOP        -> encodes as 0x00000000 (opcode 0)
  * LI rd, imm -> expands to ADDI rd, r0, imm
  * .word X    -> raw 32-bit word
"""

import argparse
import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, List, Optional, Tuple


# -----------------------------
# Opcode table (from your Module 1)
# -----------------------------
OPC = {
    "NOP":  0x0,
    "ADD":  0x1,
    "SUB":  0x2,
    "AND":  0x3,
    "OR":   0x4,
    "XOR":  0x5,
    "ADDI": 0x6,
    "LD":   0x7,
    "ST":   0x8,
    "BEQ":  0x9,
    "JAL":  0xA,
    "HALT": 0xF,
}

REG_RE = re.compile(r"^r([0-9]|1[0-5])$", re.IGNORECASE)


@dataclass
class SrcLine:
    lineno: int
    raw: str          # original line (with comment)
    text: str         # stripped comment + whitespace
    label: Optional[str]
    op: Optional[str]
    args: List[str]


class AsmError(Exception):
    def __init__(self, lineno: int, rawline: str, msg: str):
        super().__init__(msg)
        self.lineno = lineno
        self.rawline = rawline
        self.msg = msg

    def pretty(self) -> str:
        return f"ERROR line {self.lineno}: {self.msg}\n> {self.rawline.rstrip()}"


def strip_comment(line: str) -> str:
    # comments start with #
    if "#" in line:
        line = line.split("#", 1)[0]
    return line.strip()


def parse_line(lineno: int, raw: str) -> SrcLine:
    txt = strip_comment(raw)
    label = None
    op = None
    args: List[str] = []

    if txt == "":
        return SrcLine(lineno, raw, txt, None, None, [])

    # label: must be at start of line like "foo:"
    # allow "foo:   ADD r1, r2, r3"
    if ":" in txt:
        before, after = txt.split(":", 1)
        if before.strip() == "":
            raise AsmError(lineno, raw, "Empty label before ':'")
        label = before.strip()
        txt = after.strip()
        if txt == "":
            return SrcLine(lineno, raw, txt, label, None, [])

    parts = txt.split(None, 1)
    op = parts[0].upper()
    if len(parts) > 1:
        args = [a.strip() for a in parts[1].split(",") if a.strip() != ""]

    return SrcLine(lineno, raw, txt, label, op, args)


def parse_reg(token: str, sl: SrcLine) -> int:
    m = REG_RE.match(token.strip())
    if not m:
        raise AsmError(sl.lineno, sl.raw, f"Invalid register '{token}'. Expected r0-r15.")
    return int(m.group(1))


def parse_imm(token: str, sl: SrcLine) -> int:
    t = token.strip().lower()
    try:
        if t.startswith("0x"):
            return int(t, 16)
        return int(t, 10)
    except ValueError:
        raise AsmError(sl.lineno, sl.raw, f"Invalid immediate '{token}'. Expected decimal or hex (0x...).")


def fits_signed(val: int, bits: int) -> bool:
    lo = -(1 << (bits - 1))
    hi = (1 << (bits - 1)) - 1
    return lo <= val <= hi


def mask_bits(val: int, bits: int) -> int:
    return val & ((1 << bits) - 1)


# -----------------------------
# Encoders (exactly match your ISA layout)
# -----------------------------
def enc_r(op: int, rd: int, rs1: int, rs2: int) -> int:
    # [31:28]=op, [27:24]=rd, [23:20]=rs1, [19:16]=rs2, [15:0]=0
    return ((op & 0xF) << 28) | ((rd & 0xF) << 24) | ((rs1 & 0xF) << 20) | ((rs2 & 0xF) << 16)


def enc_i(op: int, rd: int, rs1: int, imm16: int) -> int:
    # [31:28]=op, [27:24]=rd, [23:20]=rs1, [15:0]=imm16
    return ((op & 0xF) << 28) | ((rd & 0xF) << 24) | ((rs1 & 0xF) << 20) | mask_bits(imm16, 16)


def enc_st(op: int, rs2: int, rs1: int, imm16: int) -> int:
    # ST special per spec: opcode, rd field unused in v1 (keep 0),
    # rs1 in [23:20], rs2 in [19:16], imm16 in [15:0]
    return ((op & 0xF) << 28) | ((rs1 & 0xF) << 20) | ((rs2 & 0xF) << 16) | mask_bits(imm16, 16)


def enc_j(op: int, rs1: int, rs2: int, off20: int) -> int:
    # [31:28]=op, [27:24]=rs1, [23:20]=rs2, [19:0]=off20 (signed word offset)
    return ((op & 0xF) << 28) | ((rs1 & 0xF) << 24) | ((rs2 & 0xF) << 20) | mask_bits(off20, 20)


# -----------------------------
# Pseudo-op expansion
# -----------------------------
def expand_pseudo(sl: SrcLine) -> Tuple[str, List[str]]:
    if sl.op is None:
        return ("", [])
    op = sl.op.upper()

    if op == "NOP":
        return ("NOP", [])

    if op == "LI":
        # LI rd, imm -> ADDI rd, r0, imm
        if len(sl.args) != 2:
            raise AsmError(sl.lineno, sl.raw, "LI expects 2 args: LI rd, imm")
        return ("ADDI", [sl.args[0], "r0", sl.args[1]])

    return (op, sl.args)


# -----------------------------
# Pass 1: labels
# -----------------------------
def first_pass(lines: List[SrcLine]) -> Dict[str, int]:
    labels: Dict[str, int] = {}
    pc_word = 0  # word index, each instruction/.word consumes 1 word

    for sl in lines:
        if sl.label:
            if sl.label in labels:
                raise AsmError(sl.lineno, sl.raw, f"Duplicate label '{sl.label}'")
            labels[sl.label] = pc_word

        if sl.op is None:
            continue

        # every instruction or .word consumes 1 word in this single-cycle ISA
        pc_word += 1

    return labels


# -----------------------------
# Offset resolution for J-type (BEQ/JAL)
# off20 is a signed *word offset* relative to PC+4
# so: target = PC+4 + (off<<2)
# => off_words = (target_word - (pc_word + 1))
# -----------------------------
def compute_off20_words(pc_word: int, target_word: int) -> int:
    return target_word - (pc_word + 1)


# -----------------------------
# Pass 2: encoding
# Produces tuples: (pc_byte_addr, word32, SrcLine)
# -----------------------------
def second_pass(lines: List[SrcLine], labels: Dict[str, int]) -> List[Tuple[int, int, SrcLine]]:
    out: List[Tuple[int, int, SrcLine]] = []
    pc_word = 0

    for sl in lines:
        if sl.op is None:
            continue

        op0 = sl.op.upper()

        # .word 32-bit raw
        if op0 == ".WORD":
            if len(sl.args) != 1:
                raise AsmError(sl.lineno, sl.raw, ".word expects 1 arg: .word 0x12345678")
            w = parse_imm(sl.args[0], sl)
            w32 = w & 0xFFFFFFFF
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        op, args = expand_pseudo(sl)

        if op not in OPC:
            raise AsmError(sl.lineno, sl.raw, f"Unknown opcode '{op}'")

        opc = OPC[op]

        # NOP: encode as 0x00000000 (opcode 0)
        if op == "NOP":
            w32 = 0x00000000
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        # HALT: opcode in top nibble, rest 0 => 0xF0000000
        if op == "HALT":
            if len(args) != 0:
                raise AsmError(sl.lineno, sl.raw, "HALT takes no args")
            w32 = (opc & 0xF) << 28
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        # R-type: ADD/SUB/AND/OR/XOR
        if op in ("ADD", "SUB", "AND", "OR", "XOR"):
            if len(args) != 3:
                raise AsmError(sl.lineno, sl.raw, f"{op} expects 3 args: {op} rd, rs1, rs2")
            rd = parse_reg(args[0], sl)
            rs1 = parse_reg(args[1], sl)
            rs2 = parse_reg(args[2], sl)
            w32 = enc_r(opc, rd, rs1, rs2)
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        # I-type: ADDI, LD
        if op in ("ADDI", "LD"):
            if len(args) != 3:
                raise AsmError(sl.lineno, sl.raw, f"{op} expects 3 args: {op} rd, rs1, imm")
            rd = parse_reg(args[0], sl)
            rs1 = parse_reg(args[1], sl)
            imm = parse_imm(args[2], sl)
            if not fits_signed(imm, 16):
                raise AsmError(sl.lineno, sl.raw, f"Immediate {imm} out of signed imm16 range (-32768..32767)")
            w32 = enc_i(opc, rd, rs1, imm)
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        # ST: ST rs2, rs1, imm  (matches your v1 mapping: rs2 encoded in [19:16])
        # NOTE: If you want ST syntax as "ST rs2, rs1, imm" keep as-is.
        if op == "ST":
            if len(args) != 3:
                raise AsmError(sl.lineno, sl.raw, "ST expects 3 args: ST rs2, rs1, imm")
            rs2 = parse_reg(args[0], sl)
            rs1 = parse_reg(args[1], sl)
            imm = parse_imm(args[2], sl)
            if not fits_signed(imm, 16):
                raise AsmError(sl.lineno, sl.raw, f"Immediate {imm} out of signed imm16 range (-32768..32767)")
            w32 = enc_st(opc, rs2, rs1, imm)
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        # BEQ: BEQ rs1, rs2, label_or_imm
        if op == "BEQ":
            if len(args) != 3:
                raise AsmError(sl.lineno, sl.raw, "BEQ expects 3 args: BEQ rs1, rs2, label/off")
            rs1 = parse_reg(args[0], sl)
            rs2 = parse_reg(args[1], sl)
            tgt = args[2]

            if tgt in labels:
                target_word = labels[tgt]
                off_words = compute_off20_words(pc_word, target_word)
            else:
                off_words = parse_imm(tgt, sl)

            if not fits_signed(off_words, 20):
                raise AsmError(sl.lineno, sl.raw, f"Offset {off_words} out of signed off20 range")
            w32 = enc_j(opc, rs1, rs2, off_words)
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        # JAL: JAL rd, label_or_off
        # Per your RTL doc: rd is in [27:24] and J-type uses rs1 field position.
        # We'll encode: rs1 = rd, rs2 = 0, off20 = target offset words.
        if op == "JAL":
            if len(args) != 2:
                raise AsmError(sl.lineno, sl.raw, "JAL expects 2 args: JAL rd, label/off")
            rd = parse_reg(args[0], sl)
            tgt = args[1]

            if tgt in labels:
                target_word = labels[tgt]
                off_words = compute_off20_words(pc_word, target_word)
            else:
                off_words = parse_imm(tgt, sl)

            if not fits_signed(off_words, 20):
                raise AsmError(sl.lineno, sl.raw, f"Offset {off_words} out of signed off20 range")
            w32 = enc_j(opc, rd, 0, off_words)
            out.append((pc_word * 4, w32, sl))
            pc_word += 1
            continue

        raise AsmError(sl.lineno, sl.raw, f"Encoding not implemented for opcode '{op}'")

    return out


def write_hex(path: str, enc: List[Tuple[int, int, SrcLine]]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        for _, word, _ in enc:
            f.write(f"{word:08X}\n")


def write_lst(path: str, enc: List[Tuple[int, int, SrcLine]], labels: Dict[str, int]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        f.write("# Listing\n")
        f.write("# addr(hex)  word(hex)   source\n")
        f.write("# ---------------------------------------------\n")
        if labels:
            f.write("# labels (word_addr -> byte_addr):\n")
            for k in sorted(labels.keys()):
                f.write(f"#   {k}: {labels[k]} -> 0x{labels[k]*4:08X}\n")
            f.write("# ---------------------------------------------\n")
        for addr, word, sl in enc:
            f.write(f"{addr:08X}  {word:08X}  {sl.raw.rstrip()}\n")


def main() -> int:
    ap = argparse.ArgumentParser(description="Toy ISA v1 assembler (32-bit) -> program.hex + program.lst")
    ap.add_argument("input", help="Input assembly file (.s)")
    ap.add_argument("--run-dir", default="", help="Output folder (default: runs/asm_YYYYMMDD_HHMMSS)")
    args = ap.parse_args()

    if not os.path.isfile(args.input):
        print(f"ERROR: input file not found: {args.input}", file=sys.stderr)
        return 2

    if args.run_dir.strip() == "":
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        run_dir = os.path.join("runs", f"asm_{ts}")
    else:
        run_dir = args.run_dir

    os.makedirs(run_dir, exist_ok=True)

    with open(args.input, "r", encoding="utf-8") as f:
        raw_lines = f.readlines()

    parsed: List[SrcLine] = []
    for i, raw in enumerate(raw_lines, start=1):
        try:
            parsed.append(parse_line(i, raw))
        except AsmError as e:
            print(e.pretty(), file=sys.stderr)
            return 1

    try:
        labels = first_pass(parsed)
        enc = second_pass(parsed, labels)
    except AsmError as e:
        print(e.pretty(), file=sys.stderr)
        return 1

    hex_path = os.path.join(run_dir, "program.hex")
    lst_path = os.path.join(run_dir, "program.lst")

    write_hex(hex_path, enc)
    write_lst(lst_path, enc, labels)

    print(f"Wrote: {hex_path}")
    print(f"Wrote: {lst_path}")
    if labels:
        print("Label table (word addresses):")
        for k in sorted(labels.keys()):
            print(f"  {k}: {labels[k]}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())


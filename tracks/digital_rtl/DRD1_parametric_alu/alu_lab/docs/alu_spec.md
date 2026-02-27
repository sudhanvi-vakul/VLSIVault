Parametric ALU Functional Specification

Project: RTL Kickstart Lab – Parametric ALU + Flags
Author: Harish Sekar
Date: 02-24-2026

1. Overview

This document defines the functional specification of a parameterized Arithmetic Logic Unit (ALU).
The ALU performs arithmetic and logical operations on two W-bit operands and generates four status flags:

Z – Zero

N – Negative

C – Carry / No-Borrow

V – Overflow

This specification defines expected behavior independently of RTL implementation.

The reference model and testbench are derived strictly from this document.

2. Parameterization

The ALU is parameterized by:

parameter int W = 8;

The design must operate correctly for:

W = 8

W = 16

W = 32

All data paths, internal arithmetic, and flags must scale automatically with W.

3. Interface Definition
Inputs
Signal	Width	Description
a	[W-1:0]	Operand A
b	[W-1:0]	Operand B
op	[2:0]	Operation select
Outputs
Signal	Width	Description
y	[W-1:0]	Result
Z	1 bit	Zero flag
N	1 bit	Negative flag
C	1 bit	Carry / No-Borrow
V	1 bit	Overflow flag
4. Opcode Definitions
Opcode (op)	Operation	Description
000	ADD	y = a + b
001	SUB	y = a - b
010	AND	y = a & b
011	OR	y = a | b
100	XOR	y = a ^ b
101	SHL	y = a << shift_amount
110	SHR	y = a >> shift_amount
others	DEFAULT	y = 0
5. Shift Operation Rules

Shift amount is determined using the lower bits of operand b:

shift_amount = b[$clog2(W)-1:0]

This ensures:

For W=8 → 3-bit shift range (0–7)

For W=16 → 4-bit shift range (0–15)

For W=32 → 5-bit shift range (0–31)

Shifts are logical (not arithmetic).

6. Flag Definitions

All flags are derived from the final result y.

6.1 Zero Flag (Z)

Z = 1 when:

y == 0

Otherwise:

Z = 0
6.2 Negative Flag (N)
N = y[W-1]

Indicates sign bit in signed interpretation.

6.3 Carry Flag (C)
ADD Operation

Carry is the carry-out of the MSB during unsigned addition.

C = carry_out
SUB Operation

The design uses carry-out-as-not-borrow convention:

C = 1 → No borrow occurred

C = 0 → Borrow occurred

This matches common CPU carry semantics.

6.4 Overflow Flag (V)

Overflow detects signed arithmetic overflow.

ADD Overflow Condition

Overflow occurs when:

Operands have same sign

Result sign differs from operands

Boolean form:

V = (~(a[W-1] ^ b[W-1])) & (y[W-1] ^ a[W-1])
SUB Overflow Condition

Overflow occurs when:

Operands have different signs

Result sign differs from A

Boolean form:

V = (a[W-1] ^ b[W-1]) & (y[W-1] ^ a[W-1])
7. Timing Contract

The ALU is purely combinational.

Outputs update immediately when inputs change.

No clock is used.

The testbench samples outputs after a small delay (#1) to allow settle time.

8. Reset Behavior

This implementation is combinational and has:

No clock

No reset

No stored state

Outputs are fully determined by inputs at all times.

9. Corner Cases to Validate

The following cases must be explicitly verified:

Case	Expected Behavior
Max positive + 1	Signed overflow
Min negative - 1	Signed overflow
All 1s + 1	Carry
0 - 1	Borrow
0 result	Z = 1
Shift by 0	No change
Shift by W-1	Maximum shift
XOR 0xAA ^ 0x55	Alternating pattern
10. Design Assumptions

All operations are single-cycle combinational.

Undefined opcodes produce zero result.

Shift operations ignore upper bits of operand B.

Arithmetic is two’s complement.

11. Validation Plan

The ALU will be validated using:

Directed corner-case testing

Randomized testing (seed-controlled)

Multi-width regression (W=8,16,32)

Self-checking scoreboard

Waveform inspection
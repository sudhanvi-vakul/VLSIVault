from dataclasses import dataclass

@dataclass
class AluTxn:
    a: int
    b: int
    op: int
    # Optional: add an id for better debug
    tid: int = 0

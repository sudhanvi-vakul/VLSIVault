# Pipeline Spec (Project 2)

## Stage responsibilities
- IF: PC update + instruction fetch
- ID: decode + regfile read + immediate/offset generation
- EX: ALU ops + BEQ compare + JAL/branch target calc
- MEM: data memory read/write
- WB: writeback to regfile

## Bubble + flush rules
- Bubble (stall): ID/EX control bits forced to 0 (prevents reg/mem commit)
- Flush (taken branch/jump): IF/ID forced to NOP and ID/EX bubbled

## Pipeline registers (minimum)
### IF/ID
- pc_if, pc_plus4_if, instr_if

### ID/EX
- pc_id, pc_plus4_id
- rs1_val, rs2_val
- rs1, rs2, rd
- imm_ext, off_ext_bytes
- control bits: reg_we, mem_rd, mem_we, wb_sel_mem, wb_sel_pc4, branch, jump, alu_op, alu_src_imm

### EX/MEM
- pc_plus4_ex
- alu_result
- store_data
- rd
- control bits: reg_we, mem_rd, mem_we, wb_sel_mem, wb_sel_pc4

### MEM/WB
- pc_plus4_mem
- alu_result
- mem_rdata
- rd
- control bits: reg_we, wb_sel_mem, wb_sel_pc4

module cpu_top (
    input  wire        clk,
    input  wire        rst_n,
    output wire        halted,

    // -------- Module 5 debug outputs --------
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_instr,
    output wire        dbg_mem_we,
    output wire [31:0] dbg_mem_addr,
    output wire [31:0] dbg_mem_wdata
);
    wire [31:0] pc_q;
    wire [31:0] next_pc;
    wire [31:0] instr;

    rom u_rom (.addr(pc_q >> 2), .data(instr));

    wire [3:0] opcode = instr[31:28];
    assign halted = (opcode == 4'hF);
    wire pc_en = ~halted;

    // decode outputs
    wire [3:0]  rd, rs1, rs2;
    wire [31:0] imm_ext, off_ext_bytes;

    // control
    wire        reg_we;
    wire [3:0]  alu_op;
    wire        alu_src_imm;
    wire        mem_rd;
    wire        mem_we;
    wire        wb_sel_mem;
    wire        branch;
    wire        jump;
    wire        wb_sel_pc4;

    control_decode u_dec(
      .instr(instr),
      .rd(rd), .rs1(rs1), .rs2(rs2),
      .imm_ext(imm_ext),
      .off_ext_bytes(off_ext_bytes),
      .reg_we(reg_we),
      .alu_op(alu_op),
      .alu_src_imm(alu_src_imm),
      .mem_rd(mem_rd),
      .mem_we(mem_we),
      .wb_sel_mem(wb_sel_mem),
      .branch(branch),
      .jump(jump),
      .wb_sel_pc4(wb_sel_pc4)
    );

    // regfile
    wire [31:0] rd1, rd2;
    wire [31:0] wb_data;

    regfile u_rf(
      .clk(clk),
      .rst_n(rst_n),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .wd(wb_data),
      .we(reg_we & ~halted),
      .rd1(rd1),
      .rd2(rd2)
    );

    // ALU
    wire [31:0] alu_b = alu_src_imm ? imm_ext : rd2;
    wire [31:0] alu_y;
    wire        alu_z;

    alu u_alu(
      .alu_op(alu_op),
      .a(rd1),
      .b(alu_b),
      .y(alu_y),
      .z(alu_z)
    );

    // dmem
    wire [31:0] dmem_rdata;
    wire        dmem_we_i = (mem_we & ~halted);
    dmem u_dmem(
      .clk(clk),
      .we(dmem_we_i),
      .addr(alu_y),
      .wdata(rd2),
      .rdata(dmem_rdata)
    );

    // writeback
    wire [31:0] pc_plus4 = pc_q + 32'd4;

    assign wb_data =
      (wb_sel_pc4) ? pc_plus4 :
      (wb_sel_mem & mem_rd) ? dmem_rdata :
                              alu_y;

    // next PC
    wire beq_taken = branch & alu_z;
    wire [31:0] pc_target = pc_plus4 + off_ext_bytes;

    assign next_pc =
      (jump)      ? pc_target :
      (beq_taken) ? pc_target :
                   pc_plus4;

    pc u_pc(
      .clk(clk),
      .rst_n(rst_n),
      .en(pc_en),
      .next_pc(next_pc),
      .pc_q(pc_q)
    );

    // -------- Debug wiring (Module 5) --------
    assign dbg_pc        = pc_q;
    assign dbg_instr     = instr;
    assign dbg_mem_we    = dmem_we_i;
    assign dbg_mem_addr  = alu_y;
    assign dbg_mem_wdata = rd2;

endmodule

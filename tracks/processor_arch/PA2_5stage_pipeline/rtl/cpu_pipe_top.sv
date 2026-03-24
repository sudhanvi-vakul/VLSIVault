module cpu_pipe_top(
  input  logic clk,
  input  logic rst_n
);

  // =========================
  // IF stage
  // =========================
  logic [31:0] pc_if, pc_next;
  logic [31:0] instr_if;
  logic        pc_en;
  logic        if_id_en;

  pc u_pc (
    .clk(clk),
    .rst_n(rst_n),
    .en(pc_en),
    .next_pc(pc_next),
    .pc_q(pc_if)
  );

  rom u_rom (
    .addr(pc_if),
    .data(instr_if)
  );

  logic [31:0] pc_plus4_if;
  assign pc_plus4_if = pc_if + 32'd4;

  // =========================
  // IF/ID pipeline register
  // =========================
  typedef struct packed {
    logic [31:0] pc;
    logic [31:0] pc_plus4;
    logic [31:0] instr;
  } if_id_t;

  if_id_t if_id_q, if_id_d;

  // =========================
  // ID/EX pipeline register
  // =========================
  typedef struct packed {
    logic [31:0] pc;
    logic [31:0] pc_plus4;
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
    logic [31:0] imm_ext;
    logic [31:0] off_ext_bytes;
    logic [3:0]  rs1;
    logic [3:0]  rs2;
    logic [3:0]  rd;

    logic        reg_we;
    logic [3:0]  alu_op;
    logic        alu_src_imm;
    logic        mem_rd;
    logic        mem_we;
    logic        wb_sel_mem;
    logic        wb_sel_pc4;
    logic        branch;
    logic        jump;
  } id_ex_t;

  /* verilator lint_off UNUSEDSIGNAL */
  id_ex_t id_ex_q, id_ex_d;
  /* verilator lint_on UNUSEDSIGNAL */

  // =========================
  // EX/MEM pipeline register
  // =========================
  typedef struct packed {
    logic [31:0] pc_plus4;
    logic [31:0] alu_result;
    logic [31:0] store_data;
    logic [3:0]  rd;

    logic        reg_we;
    logic        mem_rd;
    logic        mem_we;
    logic        wb_sel_mem;
    logic        wb_sel_pc4;
  } ex_mem_t;

  /* verilator lint_off UNUSEDSIGNAL */
  ex_mem_t ex_mem_q, ex_mem_d;
  /* verilator lint_on UNUSEDSIGNAL */

  // =========================
  // MEM/WB pipeline register
  // =========================
  typedef struct packed {
    logic [31:0] pc_plus4;
    logic [31:0] alu_result;
    logic [31:0] mem_rdata;
    logic [3:0]  rd;

    logic        reg_we;
    logic        wb_sel_mem;
    logic        wb_sel_pc4;
  } mem_wb_t;

  mem_wb_t mem_wb_q, mem_wb_d;

  // =========================
  // ID stage signals
  // =========================
  logic [31:0] instr_id;
  logic [3:0]  rs1_id, rs2_id, rd_id;
  logic [31:0] imm_ext_id;
  logic [31:0] off_ext_bytes_id;

  logic        reg_we_id;
  logic [3:0]  alu_op_id;
  logic        alu_src_imm_id;
  logic        mem_rd_id;
  logic        mem_we_id;
  logic        wb_sel_mem_id;
  logic        wb_sel_pc4_id;
  logic        branch_id;
  logic        jump_id;

  logic [31:0] rs1_val_id;
  logic [31:0] rs2_val_id;
  logic [31:0] dbg_r7_unused;

  assign instr_id = if_id_q.instr;

  control_decode u_decode(
    .instr(instr_id),

    .rd(rd_id),
    .rs1(rs1_id),
    .rs2(rs2_id),

    .imm_ext(imm_ext_id),
    .off_ext_bytes(off_ext_bytes_id),

    .reg_we(reg_we_id),
    .alu_op(alu_op_id),
    .alu_src_imm(alu_src_imm_id),
    .mem_rd(mem_rd_id),
    .mem_we(mem_we_id),
    .wb_sel_mem(wb_sel_mem_id),
    .branch(branch_id),
    .jump(jump_id),
    .wb_sel_pc4(wb_sel_pc4_id)
  );

  regfile u_regfile(
    .clk(clk),
    .rst_n(rst_n),
    .we(mem_wb_q.reg_we),
    .rs1(rs1_id[2:0]),
    .rs2(rs2_id[2:0]),
    .rd(mem_wb_q.rd[2:0]),
    .wd(
      mem_wb_q.wb_sel_pc4 ? mem_wb_q.pc_plus4 :
      mem_wb_q.wb_sel_mem ? mem_wb_q.mem_rdata :
                            mem_wb_q.alu_result
    ),
    .rd1(rs1_val_id),
    .rd2(rs2_val_id),
    .dbg_r7(dbg_r7_unused)
  );

  // =========================
  // Forwarding unit
  // =========================
  logic [1:0] fwdA_sel;
  logic [1:0] fwdB_sel;

  hazard_unit u_hazard(
    .id_ex_rs1(id_ex_q.rs1),
    .id_ex_rs2(id_ex_q.rs2),
    .ex_mem_rd(ex_mem_q.rd),
    .ex_mem_reg_we(ex_mem_q.reg_we),
    .mem_wb_rd(mem_wb_q.rd),
    .mem_wb_reg_we(mem_wb_q.reg_we),
    .fwdA_sel(fwdA_sel),
    .fwdB_sel(fwdB_sel)
  );

  // =========================
  // Load-use stall detection
  // =========================
  logic stall_load_use;

  assign stall_load_use =
    id_ex_q.mem_rd &&
    (id_ex_q.rd != 4'd0) &&
    (
      (id_ex_q.rd == rs1_id) ||
      (id_ex_q.rd == rs2_id)
    );

  // =========================
  // EX stage
  // =========================
  logic [31:0] wb_data;
  assign wb_data =
    mem_wb_q.wb_sel_pc4 ? mem_wb_q.pc_plus4 :
    mem_wb_q.wb_sel_mem ? mem_wb_q.mem_rdata :
                          mem_wb_q.alu_result;

  logic [31:0] ex_srcA_forwarded;
  logic [31:0] ex_srcB_forwarded;
  logic [31:0] alu_a_ex;
  logic [31:0] alu_b_ex;
  logic [31:0] alu_y_ex;
  logic        alu_z_ex;

  always_comb begin
    case (fwdA_sel)
      2'b10: ex_srcA_forwarded = ex_mem_q.alu_result;
      2'b01: ex_srcA_forwarded = wb_data;
      default: ex_srcA_forwarded = id_ex_q.rs1_val;
    endcase
  end

  always_comb begin
    case (fwdB_sel)
      2'b10: ex_srcB_forwarded = ex_mem_q.alu_result;
      2'b01: ex_srcB_forwarded = wb_data;
      default: ex_srcB_forwarded = id_ex_q.rs2_val;
    endcase
  end

  assign alu_a_ex = ex_srcA_forwarded;
  assign alu_b_ex = id_ex_q.alu_src_imm ? id_ex_q.imm_ext : ex_srcB_forwarded;

  alu u_alu(
    .alu_op(id_ex_q.alu_op),
    .a(alu_a_ex),
    .b(alu_b_ex),
    .y(alu_y_ex),
    .z(alu_z_ex)
  );

  logic        branch_taken_ex;
  logic        jump_taken_ex;
  logic [31:0] target_pc_ex;
  logic        flush_ex;

  assign branch_taken_ex = id_ex_q.branch & alu_z_ex;
  assign jump_taken_ex   = id_ex_q.jump;
  assign target_pc_ex    = id_ex_q.pc_plus4 + id_ex_q.off_ext_bytes;
  assign flush_ex        = branch_taken_ex | jump_taken_ex;

  // =========================
  // PC / IF control
  // Flush has priority over stall
  // =========================
  assign pc_en    = flush_ex ? 1'b1 : ~stall_load_use;
  assign if_id_en = flush_ex ? 1'b1 : ~stall_load_use;
  assign pc_next  = flush_ex ? target_pc_ex : pc_plus4_if;

  // =========================
  // MEM stage
  // =========================
  logic [31:0] dmem_rdata_mem;

  dmem u_dmem(
    .clk(clk),
    .we(ex_mem_q.mem_we),
    .addr(ex_mem_q.alu_result),
    .wdata(ex_mem_q.store_data),
    .rdata(dmem_rdata_mem)
  );

  // =========================
  // Next-state logic
  // =========================
  always_comb begin
    // IF/ID normal path
    if_id_d.pc       = pc_if;
    if_id_d.pc_plus4 = pc_plus4_if;
    if_id_d.instr    = instr_if;

    // On taken branch/jump, squash IF/ID
    if (flush_ex) begin
      if_id_d = '0;
    end

    // ID/EX normal path
    id_ex_d.pc             = if_id_q.pc;
    id_ex_d.pc_plus4       = if_id_q.pc_plus4;
    id_ex_d.rs1_val        = rs1_val_id;
    id_ex_d.rs2_val        = rs2_val_id;
    id_ex_d.imm_ext        = imm_ext_id;
    id_ex_d.off_ext_bytes  = off_ext_bytes_id;
    id_ex_d.rs1            = rs1_id;
    id_ex_d.rs2            = rs2_id;
    id_ex_d.rd             = rd_id;

    id_ex_d.reg_we         = reg_we_id;
    id_ex_d.alu_op         = alu_op_id;
    id_ex_d.alu_src_imm    = alu_src_imm_id;
    id_ex_d.mem_rd         = mem_rd_id;
    id_ex_d.mem_we         = mem_we_id;
    id_ex_d.wb_sel_mem     = wb_sel_mem_id;
    id_ex_d.wb_sel_pc4     = wb_sel_pc4_id;
    id_ex_d.branch         = branch_id;
    id_ex_d.jump           = jump_id;

    // Bubble on load-use stall OR flush
    if (stall_load_use || flush_ex) begin
      id_ex_d = '0;
    end

    // EX/MEM
    ex_mem_d.pc_plus4      = id_ex_q.pc_plus4;
    ex_mem_d.alu_result    = alu_y_ex;
    ex_mem_d.store_data    = ex_srcB_forwarded;
    ex_mem_d.rd            = id_ex_q.rd;

    ex_mem_d.reg_we        = id_ex_q.reg_we;
    ex_mem_d.mem_rd        = id_ex_q.mem_rd;
    ex_mem_d.mem_we        = id_ex_q.mem_we;
    ex_mem_d.wb_sel_mem    = id_ex_q.wb_sel_mem;
    ex_mem_d.wb_sel_pc4    = id_ex_q.wb_sel_pc4;

    // MEM/WB
    mem_wb_d.pc_plus4      = ex_mem_q.pc_plus4;
    mem_wb_d.alu_result    = ex_mem_q.alu_result;
    mem_wb_d.mem_rdata     = dmem_rdata_mem;
    mem_wb_d.rd            = ex_mem_q.rd;

    mem_wb_d.reg_we        = ex_mem_q.reg_we;
    mem_wb_d.wb_sel_mem    = ex_mem_q.wb_sel_mem;
    mem_wb_d.wb_sel_pc4    = ex_mem_q.wb_sel_pc4;
  end

  // =========================
  // Pipeline register flops
  // =========================
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      if_id_q  <= '0;
      id_ex_q  <= '0;
      ex_mem_q <= '0;
      mem_wb_q <= '0;
    end else begin
      if (if_id_en)
        if_id_q <= if_id_d;

      id_ex_q  <= id_ex_d;
      ex_mem_q <= ex_mem_d;
      mem_wb_q <= mem_wb_d;
    end
  end

endmodule

module control_decode(
  input  wire [31:0] instr,

  output wire [3:0]  rd,
  output wire [3:0]  rs1,
  output wire [3:0]  rs2,

  output wire [31:0] imm_ext,
  output wire [31:0] off_ext_bytes,

  output reg         reg_we,
  output reg  [3:0]  alu_op,
  output reg         alu_src_imm,
  output reg         mem_rd,
  output reg         mem_we,
  output reg         wb_sel_mem,
  output reg         branch,
  output reg         jump,
  output reg         wb_sel_pc4
);
  wire [3:0] opcode = instr[31:28];

  // imm16 sign-extend
  wire [15:0] imm16 = instr[15:0];
  assign imm_ext = {{16{imm16[15]}}, imm16};

  // off20 sign-extend, shift left 2 for byte offset
  wire [19:0] off20 = instr[19:0];
  wire [31:0] off_ext_words = {{12{off20[19]}}, off20};
  assign off_ext_bytes = off_ext_words << 2;

  // J-type field mapping differs:
  // BEQ/JAL: rs1=instr[27:24], rs2=instr[23:20]
  // R/I:     rs1=instr[23:20], rs2=instr[19:16]
  wire is_jtype = (opcode == 4'h9) || (opcode == 4'hA);

  assign rd  = instr[27:24]; // for JAL: link register comes from [27:24]
  assign rs1 = is_jtype ? instr[27:24] : instr[23:20];
  assign rs2 = is_jtype ? instr[23:20] : instr[19:16];

  always @(*) begin
    // defaults prevent unintended latches
    reg_we      = 1'b0;
    alu_op      = 4'h0;
    alu_src_imm = 1'b0;
    mem_rd      = 1'b0;
    mem_we      = 1'b0;
    wb_sel_mem  = 1'b0;
    branch      = 1'b0;
    jump        = 1'b0;
    wb_sel_pc4  = 1'b0;

    case (opcode)
      4'h0: begin /* NOP */ end
      4'h1: begin reg_we=1'b1; alu_op=4'h0; end // ADD
      4'h2: begin reg_we=1'b1; alu_op=4'h1; end // SUB
      4'h3: begin reg_we=1'b1; alu_op=4'h2; end // AND
      4'h4: begin reg_we=1'b1; alu_op=4'h3; end // OR
      4'h5: begin reg_we=1'b1; alu_op=4'h4; end // XOR
      4'h6: begin 
    reg_we=1'b1;   // BUG introduced intentionally
    alu_op=4'h0; 
    alu_src_imm=1'b1; end 
      4'h7: begin reg_we=1'b1; mem_rd=1'b1; wb_sel_mem=1'b1; alu_op=4'h0; alu_src_imm=1'b1; end // LD
      4'h8: begin mem_we=1'b1; alu_op=4'h0; alu_src_imm=1'b1; end // ST
      4'h9: begin branch=1'b1; alu_op=4'h1; end // BEQ uses SUB->Z
      4'hA: begin jump=1'b1; reg_we=1'b1; wb_sel_pc4=1'b1; end // JAL
      4'hF: begin /* HALT handled in cpu_top */ end
      default: begin
        // keep defaults
      end
    endcase
  end
endmodule

module top_pc_fetch (
    input  wire clk,
    input  wire rst_n
);

wire [31:0] pc_val;
wire [31:0] instr;
wire [31:0] next_pc;

assign next_pc = pc_val + 32'd4;

pc u_pc (
    .clk(clk),
    .rst_n(rst_n),
    .en(1'b1),
    .next_pc(next_pc),
    .pc_val(pc_val)
);

imem u_imem (
    .addr(pc_val),
    .instr(instr)
);

// Decode fields
wire [3:0] opcode = instr[31:28];
wire [3:0] rd     = instr[27:24];
wire [3:0] rs1    = instr[23:20];
wire [3:0] rs2    = instr[19:16];

// Regfile
wire [31:0] reg_a;
wire [31:0] reg_b;
wire [31:0] alu_result;

wire reg_write = (opcode == 4'h1) || (opcode == 4'h2);

regfile u_regfile (
    .clk(clk),
    .we(reg_write),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .wd(alu_result),
    .rd1(reg_a),
    .rd2(reg_b)
);

// ALU
alu u_alu (
    .alu_op(opcode),
    .a(reg_a),
    .b(reg_b),
    .result(alu_result)
);

// Debug print
always @(posedge clk) begin
    if (rst_n) begin
        $display("PC=%h OPC=%h RD=%h RS1=%h RS2=%h A=%h B=%h RES=%h",
                  pc_val, opcode, rd, rs1, rs2, reg_a, reg_b, alu_result);
    end
end

endmodule

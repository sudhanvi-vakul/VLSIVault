module hazard_unit(
  input  logic [3:0] id_ex_rs1,
  input  logic [3:0] id_ex_rs2,
  input  logic [3:0] ex_mem_rd,
  input  logic       ex_mem_reg_we,
  input  logic [3:0] mem_wb_rd,
  input  logic       mem_wb_reg_we,
  output logic [1:0] fwdA_sel,
  output logic [1:0] fwdB_sel
);
  // 00 = use ID/EX values
  // 10 = forward from EX/MEM
  // 01 = forward from MEM/WB
  always_comb begin
    fwdA_sel = 2'b00;
    fwdB_sel = 2'b00;

    if (ex_mem_reg_we && (ex_mem_rd != 4'd0) && (ex_mem_rd == id_ex_rs1))
      fwdA_sel = 2'b10;
    else if (mem_wb_reg_we && (mem_wb_rd != 4'd0) && (mem_wb_rd == id_ex_rs1))
      fwdA_sel = 2'b01;

    if (ex_mem_reg_we && (ex_mem_rd != 4'd0) && (ex_mem_rd == id_ex_rs2))
      fwdB_sel = 2'b10;
    else if (mem_wb_reg_we && (mem_wb_rd != 4'd0) && (mem_wb_rd == id_ex_rs2))
      fwdB_sel = 2'b01;
  end
endmodule

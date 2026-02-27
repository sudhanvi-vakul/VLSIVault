// Width W = 8 bits (a, b, result)
// 3'b000 -> ADD (a+b)
// 3'b001 -> SUB (a-b)
// 3'b010 -> AND (a & b)
// 3'b011 -> OR (a | b)
// 3'b100 -> XOR (a ^ b)
// 3'b101 -> SHL (a << b[2:0]) log(DATA_WIDTH) bits
// 3'b110 -> SHR (a >>  b[2:0]) log(DATA_WIDTH) bits
// Unsigned for all
// Latency: ALU has 1 cycle latency - input handshake at cycle N, result at cycle N+1
// Input accepted when in_valid && in_ready at posedge clk
// result and out_valid asserted on the next posedge clk
// while out_valid == 1 && out_ready == 0 result must stay stable
// output consumed when out_valid && out_ready at posedge clk

`timescale 1ns / 1ps

module alu #(parameter DATA_WIDTH = 8, OP_WIDTH = 3)(
  input logic clk,
  input logic rst_n,
  input logic in_valid,
  output logic in_ready,
  input logic [DATA_WIDTH-1:0] a,
  input logic [DATA_WIDTH-1:0] b,
  input logic [OP_WIDTH-1:0] op,
  output logic out_valid,
  input logic out_ready,
  output logic [DATA_WIDTH-1:0] result);
  
  logic [DATA_WIDTH-1:0] temp_result;
  logic         busy;
  logic out_valid_reg;
  
  localparam [OP_WIDTH-1:0] ADD = 3'b000;
  localparam [OP_WIDTH-1:0] SUB = 3'b001;
  localparam [OP_WIDTH-1:0] AND = 3'b010;
  localparam [OP_WIDTH-1:0] OR  = 3'b011;
  localparam [OP_WIDTH-1:0] XOR = 3'b100;
  localparam [OP_WIDTH-1:0] SHL = 3'b101;
  localparam [OP_WIDTH-1:0] SHR = 3'b110;
  

  assign result    = temp_result;
  assign out_valid = out_valid_reg;

  assign in_ready = !busy;   
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      temp_result    <= '0;
      busy <= 1'b0;
      out_valid_reg <= 1'b0;
    end
    else begin
      out_valid_reg <= busy;
      
      if(busy && out_valid_reg && out_ready)
        busy <= 1'b0;
      
      if (in_valid && in_ready) begin
        unique case(op)
          ADD: temp_result <= a+b;
          SUB: temp_result <= a-b;
          AND: temp_result <= a&b;
          OR: temp_result <= a|b;
          XOR: temp_result <= a^b;
          SHL: temp_result <= a<<(b & (DATA_WIDTH - 1));
          SHR: temp_result <= a>>(b & (DATA_WIDTH - 1));
          default: temp_result <= '0;
          endcase
          busy <= 1'b1;
      end
    end
  end   
endmodule

  
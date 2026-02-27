module alu #(
  parameter N = 16
)(
  input  wire [N-1:0] a,
  input  wire [N-1:0] b,
  input  wire [2:0]   op,
  output reg  [N-1:0] y
);

  always @(*) begin
    case (op)
      3'b000: y = a + b;
      3'b001: y = a - b;
      3'b010: y = a & b;
      3'b011: y = a | b;
      3'b100: y = a ^ b;
      3'b101: y = a << 1;
      3'b110: y = a >> 1;
      default: y = a;
    endcase
  end
endmodule

module top #(
  parameter N = 16
) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [N-1:0] a,
  input  logic [N-1:0] b,
  input  logic [2:0]   op,
  output logic [N-1:0] result
);

  logic [N-1:0] comb_result;

  always_comb begin
    unique case (op)
      3'd0: comb_result = a + b;     // add (often the longest)
      3'd1: comb_result = a - b;     // sub
      3'd2: comb_result = a & b;
      3'd3: comb_result = a | b;
      3'd4: comb_result = a ^ b;
      3'd5: comb_result = a << 1;
      default: comb_result = '0;
    endcase
  end

  always_ff @(posedge clk) begin
    if (!rst_n) result <= '0;
    else        result <= comb_result;
  end

endmodule






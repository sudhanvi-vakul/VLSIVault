// tb/smoke.sv
`timescale 1ns/1ps
module smoke;
  logic clk = 0;
  logic rst = 1;
  logic a;

  always #5 clk = ~clk;

  initial begin
    a = 0;
    repeat (3) @(posedge clk);
    rst = 0;
    repeat (5) begin
      @(posedge clk);
      a <= ~a;
    end
    $finish;
  end
endmodule

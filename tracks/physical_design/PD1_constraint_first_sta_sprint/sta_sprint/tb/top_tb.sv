`timescale 1ns/1ps
module top_tb;
  localparam int N = 16;
  logic clk, rst_n;
  logic [N-1:0] a, b;
  logic [2:0] op;
  logic [N-1:0] result;

  top #(.N(N)) dut (.*);

  always #5 clk = ~clk;

  initial begin
    $dumpfile("build/waves.vcd");
    $dumpvars(0, top_tb);

    clk = 0; rst_n = 0;
    a = 0; b = 0; op = 0;
    repeat (3) @(posedge clk);
    rst_n = 1;

    @(posedge clk); a=16'd10; b=16'd20; op=3'd0;
    @(posedge clk); a=16'd50; b=16'd3;  op=3'd1;
    @(posedge clk); a=16'h0F0F; b=16'h00FF; op=3'd2;
    @(posedge clk); a=16'h0F0F; b=16'h00FF; op=3'd3;
    repeat (5) @(posedge clk);
    $finish;
  end
endmodule

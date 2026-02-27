import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "alu_pkg.sv"
import alu_pkg::*;
//`include "alu_if.sv"

module alu_tb_top;
  
  logic clk;
  logic rst_n;
  alu_if #(8,3) alu_vif (.*);
  
  initial clk = 0;
  always #5 clk = ~clk;
  
  initial begin
    rst_n  = 0;
    repeat(5) @(posedge clk);
    rst_n = 1;
  end
  
  alu #(.DATA_WIDTH(8), .OP_WIDTH(3)) dut (
    .clk       (alu_vif.clk),
    .rst_n     (alu_vif.rst_n),
    .in_valid  (alu_vif.in_valid),
    .in_ready  (alu_vif.in_ready),
    .a         (alu_vif.a),
    .b         (alu_vif.b),
    .op        (alu_vif.op),
    .out_valid (alu_vif.out_valid),
    .out_ready (alu_vif.out_ready),
    .result    (alu_vif.result)
  );
  
  /*initial begin
    alu_seq_item t;
    $display("RANDOMIZATION SMOKE TEST");
    repeat (5) begin
      t = new("t");
      if (!t.randomize())
        $display("Randomization FAILED");
      else
        $display("Randomized item: %s", t.convert2string());
    end
    $display("END OF SMOKE TEST");
    $finish;
  end*/
  
  initial begin
    uvm_config_db#(virtual alu_if)::set(null, "*", "vif", alu_vif);
    run_test();
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, alu_tb_top);
  end
  
endmodule
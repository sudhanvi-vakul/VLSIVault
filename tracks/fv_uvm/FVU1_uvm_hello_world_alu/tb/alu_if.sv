`timescale 1ns / 1ps

interface alu_if #(parameter DATA_WIDTH =8, parameter OP_WIDTH = 3)
                  (input logic clk, input logic rst_n);
  
  logic in_valid;
  logic in_ready;
  logic [DATA_WIDTH-1:0] a;
  logic [DATA_WIDTH-1:0] b;
  logic [OP_WIDTH-1:0] op;
  
  logic out_valid;
  logic out_ready;
  logic [DATA_WIDTH-1:0] result;
  
  
  modport drv (input in_ready,
    input out_valid,
    input result,
    output in_valid,
    output a,
    output b,
    output op,
    output out_ready, input clk, input rst_n);
  
  modport mon (input in_valid,
    input in_ready,
    input a,
    input b,
    input op,
    input out_valid,
    input out_ready,
    input result, input clk, input rst_n);
  
  modport dut (input clk, rst_n, 
               input in_valid, a, b, op, out_ready, 
               output in_ready, out_valid, result
              );
  
   /*clocking cb_drv @(posedge clk);
    default input #1step output #1step;
    input in_ready;
    input out_valid;
    input result;
    output in_valid;
    output a;
    output b;
    output op;
    output out_ready;
  endclocking
  
  clocking cb_mon @(posedge clk);
    default input #1step;
    input in_valid;
    input in_ready;
    input a;
    input b;
    input op;
    input out_valid;
    input out_ready;
    input result; 
  endclocking*/
  
endinterface


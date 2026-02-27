package alu_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

parameter int SIZE = 8;

function automatic logic [SIZE-1:0] alu_ref (
  input logic [SIZE-1:0] a,
  input logic [SIZE-1:0] b,
  input logic [2:0] op );
  logic [SIZE-1:0] result;
  logic [$clog2(SIZE)-1:0] shamt;
  
  shamt = b & (SIZE - 1);
  
  unique case(op)
    3'd0: result = a + b;
    3'd1: result = a - b;
    3'd2: result = a & b;
    3'd3: result = a | b;
    3'd4: result = a ^ b;
    3'd5: result = a << shamt;
    3'd6: result = a >> shamt;
    default: result = '0;
  endcase
  
  return result;
endfunction

`include "alu_seq_item.sv"
`include "alu_sequence.sv"
`include "alu_directed_seq.sv"
`include "alu_random_seq.sv"
`include "alu_sequencer.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_scoreboard.sv"
`include "alu_agent.sv"
`include "alu_env.sv"
`include "alu_base_test.sv"
`include "alu_smoke_test.sv"
`include "alu_rand_test.sv"
`include "alu_test.sv"

endpackage
// tb/assertions_reg_slice.sv
`timescale 1ns/1ps
module assertions_reg_slice #(parameter int W = 32) (
  input logic         clk,
  input logic         rst_n,
  input logic         out_valid,
  input logic [W-1:0] out_data,
  input logic         out_ready
);

  // If out_valid is high and out_ready is low, out_data must remain stable next cycle
  property hold_data_while_stalled;
    @(posedge clk) disable iff (!rst_n)
      (out_valid && !out_ready) |=> (out_valid && $stable(out_data));
  endproperty
  assert property (hold_data_while_stalled)
    else $fatal(1, "[ASSERT] out_data changed while stalled");

  // out_valid should not spontaneously drop while stalled
  property hold_valid_while_stalled;
    @(posedge clk) disable iff (!rst_n)
      (out_valid && !out_ready) |=> out_valid;
  endproperty
  assert property (hold_valid_while_stalled)
    else $fatal(1, "[ASSERT] out_valid dropped while stalled");

endmodule

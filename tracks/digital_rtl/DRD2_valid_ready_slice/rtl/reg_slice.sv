// rtl/reg_slice.sv
`timescale 1ns/1ps
module reg_slice #(
  parameter int W = 32
)(
  input  logic         clk,
  input  logic         rst_n,

  // Producer side
  input  logic         in_valid,
  input  logic [W-1:0] in_data,
  output logic         in_ready,

  // Consumer side
  output logic         out_valid,
  output logic [W-1:0] out_data,
  input  logic         out_ready
);

  logic         stored_valid;
  logic [W-1:0] stored_data;

  // Elastic rule:
  // Can accept new input if buffer is empty OR consumer is ready to take current item.
  always_comb begin
    in_ready  = (~stored_valid) | out_ready;
    out_valid = stored_valid;
    out_data  = stored_data;
  end

  // Storage update:
  // If in_ready=1, we may load new data (or clear if in_valid=0).
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      stored_valid <= 1'b0;
      stored_data  <= '0;
    end else if (in_ready) begin
      stored_valid <= in_valid;
      if (in_valid) stored_data <= in_data;
    end
  end

endmodule

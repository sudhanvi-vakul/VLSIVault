`timescale 1ns/1ps
module tb_reg_slice;

  localparam int W = 32;

  logic clk = 0;
  logic rst_n = 0;

  logic         in_valid;
  logic [W-1:0] in_data;
  logic         in_ready;

  logic         out_valid;
  logic [W-1:0] out_data;
  logic         out_ready;

  // Plusargs
  int unsigned seed;
  int          n_tokens;

  // Scoreboard / monitor variables
  int unsigned sent;
  int unsigned recv;
  int unsigned exp_token;
  int unsigned cycle;
  int unsigned r;

  // DUT
  reg_slice #(.W(W)) dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .in_valid (in_valid),
    .in_data  (in_data),
    .in_ready (in_ready),
    .out_valid(out_valid),
    .out_data (out_data),
    .out_ready(out_ready)
  );

  // Assertions
  assertions_reg_slice #(.W(W)) asrt (
    .clk      (clk),
    .rst_n    (rst_n),
    .out_valid(out_valid),
    .out_data (out_data),
    .out_ready(out_ready)
  );

  // Clock
  always #5 clk = ~clk;

  // Random helper (deterministic per seed)
  function automatic int unsigned urand();
    seed = seed * 32'h9E3779B9 + 32'h7F4A7C15;
    return (seed ^ (seed >> 16));
  endfunction

  task automatic fail(input string msg);
    $display("[FAIL] %s", msg);
    $display("[FAIL] seed=%0d sent=%0d recv=%0d exp=%0h got=%0h time=%0t",
             seed, sent, recv, exp_token, out_data, $time);
    $finish;
  endtask

  // Cycle counter
  always_ff @(posedge clk) begin
    if (!rst_n)
      cycle <= 0;
    else
      cycle <= cycle + 1;
  end

  // Transfer monitor
  always_ff @(posedge clk) begin
    if (rst_n && in_valid && in_ready) begin
      $display("[MON] C%0d FIRE_IN  token=%0h", cycle, in_data);
    end
    if (rst_n && out_valid && out_ready) begin
      $display("[MON] C%0d FIRE_OUT token=%0h", cycle, out_data);
    end
  end

  initial begin
    // Defaults
    in_valid  = 0;
    in_data   = '0;
    out_ready = 0;

    // Read plusargs
    if (!$value$plusargs("seed=%d", seed)) seed = 7;
    if (!$value$plusargs("n=%d", n_tokens)) n_tokens = 2000;

    sent      = 0;
    recv      = 0;
    exp_token = 0;
    r         = 0;
    // DO NOT assign cycle here; always_ff already drives it

    // Hold reset for a few cycles
    repeat (3) @(posedge clk);
    rst_n = 1;

    // Main loop: keep going until all tokens are received
    while (recv < n_tokens) begin
      // Drive inputs on the falling edge so they are stable before next posedge
      @(negedge clk);
      r = urand() % 100;
      out_ready = (r < 70);        // 70% chance ready
      in_valid  = (sent < n_tokens);
      in_data   = sent[W-1:0];

      // Observe/check at posedge
      @(posedge clk);

      if (in_valid && in_ready) begin
        sent = sent + 1;
      end

      if (out_valid && out_ready) begin
        if (out_data !== exp_token[W-1:0]) begin
          fail($sformatf("Token mismatch at recv=%0d", recv));
        end
        exp_token = exp_token + 1;
        recv      = recv + 1;
      end
    end

    // Stop driving once done
    @(negedge clk);
    in_valid  = 0;
    out_ready = 0;

    $display("[SUMMARY] seed=%0d n=%0d sent=%0d recv=%0d FAIL=0",
             seed, n_tokens, sent, recv);
    $finish;
  end

endmodule
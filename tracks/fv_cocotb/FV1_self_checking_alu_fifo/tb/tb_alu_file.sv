module tb_alu_file;

  localparam int N = 16;

  logic [N-1:0] a, b;
  logic [2:0]   op;
  logic [N-1:0] y;

  alu #(.N(N)) dut (.a(a), .b(b), .op(op), .y(y));

  int f;
  int lineno = 0;
  int fail = 0;

  string line;
  int ai, bi, opi, expi;

  initial begin
    $dumpfile("reports/alu_file_tb.vcd");
    $dumpvars(0, tb_alu_file);

    f = $fopen("vectors/alu_vectors.csv", "r");
    if (f == 0) begin
      $display("ERROR: cannot open vectors/alu_vectors.csv");
      $finish;
    end

    // skip header
    void'($fgets(line, f)); lineno++;

    while (!$feof(f)) begin
      void'($fgets(line, f)); lineno++;
      if ($sscanf(line, "%d,%d,%d,%d", ai, bi, opi, expi) == 4) begin
        a  = ai[N-1:0];
        b  = bi[N-1:0];
        op = opi[2:0];
        #1;
        if (y !== expi[N-1:0]) begin
          $display("FAIL line=%0d a=%0d b=%0d op=%0d exp=%0d got=%0d",
                   lineno, ai, bi, opi, expi, y);
          fail++;
        end
      end
    end

    if (fail == 0) $display("PASS: all tests passed");
    else           $display("FAIL: %0d mismatches", fail);

    $fclose(f);
    $finish;
  end

endmodule

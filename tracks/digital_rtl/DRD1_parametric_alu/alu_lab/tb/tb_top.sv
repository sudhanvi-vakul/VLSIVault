module tb_top;

    localparam int W = 8;
    localparam int RES_W = W + 4; // y + Z N C V

    logic [W-1:0] a, b;
    logic [2:0]   op;
    logic [W-1:0] y;
    logic Z, N, C, V;

    int pass_cnt = 0;
    int fail_cnt = 0;

    // DUT
    param_alu #(W) dut (
        .a(a), .b(b), .op(op),
        .y(y), .Z(Z), .N(N), .C(C), .V(V)
    );

    // -------------------------------------------------
    // Reference model (packed return)
    // [RES_W-1:4] -> y
    // [3] -> Z
    // [2] -> N
    // [1] -> C
    // [0] -> V
    // -------------------------------------------------
    function automatic logic [RES_W-1:0] ref_model(
        input logic [W-1:0] a,
        input logic [W-1:0] b,
        input logic [2:0]   op
    );
        logic [W-1:0] ry;
        logic rZ, rN, rC, rV;
        logic [W:0] tmp;

        // defaults
        ry = '0;
        rZ = 0; rN = 0; rC = 0; rV = 0;

        case (op)
            3'b000: begin // ADD
                tmp = {1'b0,a} + {1'b0,b};
                ry  = tmp[W-1:0];
                rC  = tmp[W];
                rV  = (~(a[W-1]^b[W-1])) & (ry[W-1]^a[W-1]);
            end

            3'b001: begin // SUB
                tmp = {1'b0,a} - {1'b0,b};
                ry  = tmp[W-1:0];
                rC  = ~tmp[W]; // no borrow
                rV  = (a[W-1]^b[W-1]) & (ry[W-1]^a[W-1]);
            end

            3'b010: ry = a & b;
            3'b011: ry = a | b;
            3'b100: ry = a ^ b;
            3'b101: ry = a << b[$clog2(W)-1:0];
            3'b110: ry = a >> b[$clog2(W)-1:0];
        endcase

        rZ = (ry == '0);
        rN = ry[W-1];

        ref_model = {ry, rZ, rN, rC, rV};
    endfunction

    task automatic check;
        logic [RES_W-1:0] exp;
        #1; // combinational settle
        exp = ref_model(a,b,op);

        if ({y,Z,N,C,V} !== exp) begin
            $display("FAIL op=%0d a=%h b=%h | exp=%h ZNCV=%b%b%b%b got=%h %b%b%b%b",
                op,a,b,
                exp[RES_W-1:4],
                exp[3],exp[2],exp[1],exp[0],
                y,Z,N,C,V);
            fail_cnt++;
        end else begin
            pass_cnt++;
        end
    endtask
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_top);

 // Directed tests
       // a=8'h7F; b=8'h01; op=3'b000; check(); // ADD overflow
       // a=8'h80; b=8'h01; op=3'b001; check(); // SUB overflow
       // a=8'hFF; b=8'h01; op=3'b000; check(); // carry
       // a=8'h00; b=8'h01; op=3'b001; check(); // borrow
       // a=8'h00; b=8'h00; op=3'b010; check(); // zero
// ADD overflow
a = (1 << (W-1)) - 1;
b = 1;
op = 3'b000;
check();

// SUB overflow
a = 1 << (W-1);
b = 1;
op = 3'b001;
check();

// ADD carry
a = {W{1'b1}};
b = 1;
op = 3'b000;
check();

// SUB borrow
a = 0;
b = 1;
op = 3'b001;
check();

// Zero case
a = 0;
b = 0;
op = 3'b010;
check();

        // Random tests (reproducible)
        repeat (500) begin
            a  = $urandom;
            b  = $urandom;
            op = $urandom_range(0,6);
            check();
        end

        $display("=================================");
        $display("ALU TEST SUMMARY: PASS=%0d FAIL=%0d", pass_cnt, fail_cnt);
        $display("=================================");

        $finish;
    end

endmodule

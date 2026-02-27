module param_alu #(
    parameter int W = 8
)(
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic [2:0]   op,
    output logic [W-1:0] y,
    output logic         Z,
    output logic         N,
    output logic         C,
    output logic         V
);

    logic [W:0] sum_ext;
    logic [W:0] sub_ext;

    always_comb begin
        // defaults
        y = '0;
        C = 1'b0;
        V = 1'b0;

        case (op)
            3'b000: begin // ADD
                sum_ext = {1'b0, a} + {1'b0, b};
                y = sum_ext[W-1:0];
                C = sum_ext[W];
                V = (~(a[W-1] ^ b[W-1])) & (y[W-1] ^ a[W-1]);
            end

            3'b001: begin // SUB
                sub_ext = {1'b0, a} - {1'b0, b};
                y = sub_ext[W-1:0];
                C = ~sub_ext[W]; // no borrow = 1
                V = (a[W-1] ^ b[W-1]) & (y[W-1] ^ a[W-1]);
            end

            3'b010: y = a & b;
            3'b011: y = a | b;
            3'b100: y = a ^ b;
            3'b101: y = a << b[$clog2(W)-1:0];
            3'b110: y = a >> b[$clog2(W)-1:0];

            default: y = '0;
        endcase

        Z = (y == '0);
        N = y[W-1];
    end

endmodule

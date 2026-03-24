module alu (
    input  wire [3:0]  alu_op,
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] y,
    output wire        z
);
    always @(*) begin
        case (alu_op)
            4'h0: y = a + b; // ADD
            4'h1: y = a - b; // SUB
            4'h2: y = a & b; // AND
            4'h3: y = a | b; // OR
            4'h4: y = a ^ b; // XOR
            default: y = 32'h00000000;
        endcase
    end
    assign z = (y == 32'h00000000);
endmodule

module imem (
    input  wire [31:0] addr,
    output reg  [31:0] instr
);

wire [3:0] index = addr[5:2];

always @(*) begin
    case (index)
        4'd0: instr = 32'h10012000; // ADD r0=r1+r2 (dummy)
        4'd1: instr = 32'h11023000; // ADD r1=r2+r3
        4'd2: instr = 32'h12034000; // ADD r2=r3+r4
        default: instr = 32'h00000000;
    endcase
end

endmodule

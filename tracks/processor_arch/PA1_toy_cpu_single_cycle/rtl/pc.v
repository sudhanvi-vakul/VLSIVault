module pc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc_q
);
    always @(posedge clk) begin
        if (!rst_n)
            pc_q <= 32'h00000000;
        else if (en)
            pc_q <= next_pc;
    end
endmodule

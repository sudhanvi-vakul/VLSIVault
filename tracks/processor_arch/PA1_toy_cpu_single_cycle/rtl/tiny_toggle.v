module tiny_toggle (
    input  wire clk,
    input  wire rst_n,
    output reg  q
);

always @(posedge clk) begin
    if (!rst_n)
        q <= 1'b0;
    else
        q <= ~q;
end

endmodule

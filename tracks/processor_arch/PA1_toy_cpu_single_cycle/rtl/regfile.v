module regfile (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        we,
    input  wire [2:0]  rs1,
    input  wire [2:0]  rs2,
    input  wire [2:0]  rd,
    input  wire [31:0] wd,

    output wire [31:0] rd1,
    output wire [31:0] rd2,

    output wire [31:0] dbg_r7
);

    reg [31:0] rf[0:7];

    // reads (combinational)
    assign rd1 = (rs1 == 3'd0) ? 32'd0 : rf[rs1];
    assign rd2 = (rs2 == 3'd0) ? 32'd0 : rf[rs2];

    // debug
    assign dbg_r7 = rf[3'd7];

    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) rf[i] <= 32'd0;
        end else begin
            if (we && (rd != 3'd0)) rf[rd] <= wd;
            rf[3'd0] <= 32'd0;
        end
    end

endmodule

module top (
    input  wire        clk,
    input  wire        rst_n,

    output wire        halted,
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_instr,
    output wire        dbg_mem_we,
    output wire [31:0] dbg_mem_addr,
    output wire [31:0] dbg_mem_wdata,

    output wire [31:0] dbg_r7
);

    cpu_top_wrap u (
        .clk(clk),
        .rst_n(rst_n),

        .halted(halted),
        .dbg_pc(dbg_pc),
        .dbg_instr(dbg_instr),
        .dbg_mem_we(dbg_mem_we),
        .dbg_mem_addr(dbg_mem_addr),
        .dbg_mem_wdata(dbg_mem_wdata),

        .dbg_r7(dbg_r7)
    );

endmodule

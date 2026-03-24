module cpu_top (
    input  logic        clk,
    input  logic        rst,

    // Debug outputs for Module 5
    output logic [31:0] dbg_pc,
    output logic [31:0] dbg_instr,
    output logic        dbg_mem_we,
    output logic [31:0] dbg_mem_addr,
    output logic [31:0] dbg_mem_wdata,
    output logic        dbg_halt
);

  // ============================================================
  // INTERNAL SIGNALS (REPLACE THESE WITH YOUR REAL SIGNAL NAMES)
  // ============================================================

  logic [31:0] pc_q;         // <-- replace with your PC signal
  logic [31:0] instr_f;      // <-- replace with your fetched instruction
  logic        dmem_we;      // <-- replace with your data memory write enable
  logic [31:0] dmem_addr;    // <-- replace with your data memory address
  logic [31:0] dmem_wdata;   // <-- replace with your data memory write data
  logic        halted;       // <-- replace with your halt signal (optional)

  // ============================================================
  // YOUR EXISTING CPU + MEMORY INSTANTIATION GOES HERE
  // ============================================================

  // Example (REMOVE if you already have this)
  // cpu u_cpu (
  //   .clk(clk),
  //   .rst(rst),
  //   .pc_out(pc_q),
  //   .instr_out(instr_f),
  //   .dmem_we(dmem_we),
  //   .dmem_addr(dmem_addr),
  //   .dmem_wdata(dmem_wdata),
  //   .halt(halted)
  // );

  // ============================================================
  // DEBUG SIGNAL CONNECTIONS
  // ============================================================

  always_comb begin
    dbg_pc        = pc_q;
    dbg_instr     = instr_f;
    dbg_mem_we    = dmem_we;
    dbg_mem_addr  = dmem_addr;
    dbg_mem_wdata = dmem_wdata;
    dbg_halt      = halted;
  end

endmodule

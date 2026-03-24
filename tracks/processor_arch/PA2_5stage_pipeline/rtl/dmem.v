module dmem(
  input  wire        clk,
  input  wire        we,
  input  wire [31:0] addr,   // byte address
  input  wire [31:0] wdata,
  output wire [31:0] rdata
);
  reg [31:0] mem [0:255];

  // word index from byte address
  wire [7:0] a = addr[9:2];

  // consume unused bits to avoid fatal warnings
  wire _unused_dmem_addr = ^{addr[31:10], addr[1:0]};

  always @(posedge clk) begin
    if (we) mem[a] <= wdata;
  end

  assign rdata = mem[a];
endmodule

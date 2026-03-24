module rom (
    input  wire [31:0] addr,   // byte address
    output reg  [31:0] data
);
    reg [31:0] mem [0:65535];

    // word index (32-bit aligned)
    wire [15:0] word_addr = addr[17:2];

    // consume unused address bits to avoid fatal warnings
    wire _unused_rom_addr = ^{addr[31:18], addr[1:0]};

    initial begin
        $readmemh("program.hex", mem);
    end

    always @(*) begin
        data = mem[word_addr];
    end
endmodule

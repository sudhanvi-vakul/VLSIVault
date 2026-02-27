`timescale 1ns/1ps

module smoke;
    logic x;

    initial begin
        $dumpfile("results/00_smoke.vcd");
        $dumpvars(0, smoke);

        x = 0;
        #5 x = 1;
        #5 x = 0;
        #5 $finish;
    end
endmodule

#include "Vtop_pc_fetch.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vtop_pc_fetch* dut = new Vtop_pc_fetch;

    // Turn on waveform tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("sim/pc_fetch.vcd");

    // Initialize inputs
    dut->clk = 0;
    dut->rst_n = 0;

    // Run for a while
    for (int t = 0; t < 40; t++) {
        // Deassert reset after a few ticks
        if (t == 4) dut->rst_n = 1;

        // Toggle clock
        dut->clk = !dut->clk;

        dut->eval();
        tfp->dump(t);
    }

    tfp->close();
    delete dut;
    return 0;
}

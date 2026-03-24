#include "Vtiny_toggle.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vtiny_toggle* dut = new Vtiny_toggle;

    // Enable tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);

    // Put wave in sim/
    tfp->open("sim/tiny_toggle.vcd");

    // Init
    dut->clk = 0;
    dut->rst_n = 0;

    // Run for some cycles
    for (int t = 0; t < 40; t++) {
        // Deassert reset after a few time steps
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

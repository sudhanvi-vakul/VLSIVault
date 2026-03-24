#include "Vwave_smoke.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

static vluint64_t main_time = 0;
double sc_time_stamp() { return (double)main_time; }

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vwave_smoke* dut = new Vwave_smoke;
    VerilatedVcdC* tfp = new VerilatedVcdC;

    dut->trace(tfp, 99);

    system("mkdir -p results/wave_smoke");
    tfp->open("results/wave_smoke/waves.vcd");

    dut->clk = 0;
    dut->rst = 1;

    for (int t = 0; t < 40; t++) {
        if (t == 6) dut->rst = 0;   // deassert reset
        dut->clk = !dut->clk;

        dut->eval();
        tfp->dump(main_time++);
    }

    tfp->close();
    delete dut;
    return 0;
}

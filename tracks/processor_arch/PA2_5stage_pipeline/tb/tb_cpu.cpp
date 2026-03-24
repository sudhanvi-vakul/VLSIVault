#include "Vcpu_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <cstdio>

static vluint64_t main_time = 0;
double sc_time_stamp() { return (double)main_time; }

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    system("mkdir -p results/run_module3");

    Vcpu_top* dut = new Vcpu_top;
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("results/run_module3/waves.vcd");

    FILE* log = fopen("results/run_module3/transcript.log", "w");

    dut->clk = 0;
    dut->rst_n = 0;

    for (int t = 0; t < 200; t++) {
        if (t == 6) dut->rst_n = 1;

        dut->clk = !dut->clk;
        dut->eval();
        tfp->dump(main_time++);

        if (dut->clk == 1) {
            fprintf(log, "cycle=%3d halted=%d\n", t/2, dut->halted);
            fflush(log);
            if (dut->halted) break;
        }
    }

    fclose(log);
    tfp->close();
    delete dut;
    return 0;
}

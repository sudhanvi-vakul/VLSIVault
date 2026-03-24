#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include <cstdlib>
#include "Vcpu_pipe_top.h"

static vluint64_t main_time = 0;
double sc_time_stamp() { return (double)main_time; }

static int plusarg_int(const char* key, int def) {
  const char* m = Verilated::commandArgsPlusMatch(key);
  if (!m || !m[0]) return def;
  const char* eq = std::strchr(m, '=');
  if (!eq) return def;
  return std::atoi(eq + 1);
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);

  int max_cycles = plusarg_int("+max_cycles", 2000);
  int waves      = plusarg_int("+waves", 1);

  Vcpu_pipe_top* top = new Vcpu_pipe_top;

  VerilatedVcdC* tfp = nullptr;
  if (waves) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waves.vcd");
  }

  auto tick = [&]() {
    top->clk = !top->clk;
    top->eval();
    if (tfp) tfp->dump(main_time++);
  };

  // reset (active-low rst_n)
  top->clk = 0;
  top->rst_n = 0;
  for (int i=0; i<4; i++) tick();
  top->rst_n = 1;

  for (int c=0; c<max_cycles; c++) {
    tick(); // posedge
    tick(); // negedge
  }

  if (tfp) { tfp->close(); delete tfp; }
  delete top;
  return 0;
}

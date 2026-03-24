#include <verilated.h>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

#include "Vtop.h"

static std::string hex32(uint32_t v) {
    std::ostringstream oss;
    oss << "0x" << std::hex << std::setw(8) << std::setfill('0') << v;
    return oss.str();
}

static void tick(Vtop* dut) {
    dut->clk = 0; dut->eval();
    dut->clk = 1; dut->eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    if (argc < 5) {
        std::cerr << "Usage: " << argv[0]
                  << " <test> <expected_hex> <max_cycles> --outdir <dir>\n";
        return 2;
    }

    std::string test_name = argv[1];
    uint32_t expected_sig = std::stoul(argv[2], nullptr, 0);
    uint64_t max_cycles   = std::stoull(argv[3]);

    std::string outdir;
    for (int i = 4; i < argc; i++) {
        if (std::string(argv[i]) == "--outdir" && i + 1 < argc)
            outdir = argv[++i];
    }

    if (outdir.empty()) return 2;
    std::filesystem::create_directories(outdir);

    std::ofstream tr(outdir + "/transcript.log");
    tr << "TEST=" << test_name
       << " expected=" << hex32(expected_sig)
       << " max_cycles=" << max_cycles << "\n";

    Vtop* dut = new Vtop();

    dut->rst_n = 0;
    for (int i = 0; i < 5; i++) tick(dut);
    dut->rst_n = 1;

    uint64_t cyc = 0;
    while (!Verilated::gotFinish() && cyc < max_cycles) {
        tr << "CYC=" << std::dec << cyc
           << " PC=" << hex32(dut->dbg_pc)
           << " INSTR=" << hex32(dut->dbg_instr)
           << " R7=" << hex32(dut->dbg_r7)
           << " HALTED=" << (dut->halted ? 1 : 0)
           << "\n";

        if (dut->halted) break;

        tick(dut);
        cyc++;
    }
    tr.close();

    uint32_t sig = dut->dbg_r7;

    std::ofstream sf(outdir + "/signature.txt");
    sf << "expected=" << hex32(expected_sig) << "\n";
    sf << "signature=" << hex32(sig) << "\n";
    sf << "HALTED=" << (dut->halted ? 1 : 0) << "\n";

    bool pass = (sig == expected_sig) && dut->halted;
    sf << (pass ? "PASS\n" : "FAIL\n");
    sf.close();

    delete dut;
    return pass ? 0 : 1;
}

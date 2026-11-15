#include "Vj2_tang_primer.h"
#include "verilated.h"

#include <cstdio>
#include <string>

int main(int argc, char **argv) {
  Vj2_tang_primer top;
  top.clk24 = 0;
  top.rst_n = 0;
  top.uart_rx = 1;
  top.spi_miso = 1;
  top.eval();

  for (int cycle = 0; cycle < 8; ++cycle) {
    top.clk24 = 1;
    top.eval();
    top.clk24 = 0;
    top.eval();
  }
  top.rst_n = 1;

  constexpr double bit_cycles = 24000000.0 / 19200.0;
  int state = -1;
  double next_sample = 0;
  unsigned shift = 0;
  bool previous_tx = true;
  std::string output;

  for (uint64_t cycle = 0; cycle < 20000000 && output.find("CPU tests passed") == std::string::npos;
       ++cycle) {
    top.clk24 = 1;
    top.eval();

    bool tx = top.uart_tx;
    if (state < 0) {
      if (previous_tx && !tx) {
        state = 0;
        next_sample = cycle + 1.5 * bit_cycles;
        shift = 0;
      }
    } else if (cycle >= next_sample) {
      if (state < 8) {
        shift |= unsigned(tx) << state;
        ++state;
        next_sample += bit_cycles;
      } else {
        if (!tx) {
          std::printf("[verilog-soc] UART framing error at cycle %llu\n",
                      (unsigned long long)cycle);
          return 1;
        }
        output.push_back(char(shift));
        state = -1;
      }
    }
    previous_tx = tx;

    top.clk24 = 0;
    top.eval();
  }

  std::printf("[verilog-soc] UART output:\n%s\n", output.c_str());
  bool ok = output.find("CPU tests passed") != std::string::npos;
  std::printf("[verilog-soc] %s\n", ok ? "PASS" : "FAIL");
  return ok ? 0 : 1;
}

// Simulate the Tang Primer top at its native 24 MHz clock and decode the
// UART console. The SRAM image is supplied with the shared +sram plusarg.
#include "Vj2_tang_primer.h"
#include "verilated.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

int main(int argc, char **argv) {
  if (argc < 2) {
    std::fprintf(stderr, "usage: %s image.hex [--expect STR] [--max-cycles N]\n",
                 argv[0]);
    return 2;
  }
  std::string plus = std::string("+sram=") + argv[1];
  const char *vargs[] = {argv[0], plus.c_str()};
  Verilated::commandArgs(2, vargs);

  std::string expect;
  uint64_t max_cycles = 3000000;
  for (int i = 2; i < argc; i++) {
    if (!std::strcmp(argv[i], "--expect") && i + 1 < argc)
      expect = argv[++i];
    else if (!std::strcmp(argv[i], "--max-cycles") && i + 1 < argc)
      max_cycles = std::strtoull(argv[++i], nullptr, 0);
  }

  Vj2_tang_primer t;
  t.clk24 = 0;
  t.rst_n = 0;
  t.uart_rx = 1;
  t.spi_miso = 0;

  // DDS_INC rounds to 53 at 24 MHz. The UART advances its 16x phase while
  // DDS[12] is high, so one bit is 16 * 8192 / DDS_INC cycles (~2473).
  const double bit = 131072.0 / 53.0;
  std::string uart_out;
  int state = -1;
  double next_sample = 0;
  unsigned shift = 0;
  bool prev_tx = true;
  uint64_t cyc = 0;
  const bool uart_debug = std::getenv("UART_DEBUG") != nullptr;

  auto cycle = [&]() {
    t.clk24 = 1;
    t.eval();
    t.clk24 = 0;
    t.eval();
    cyc++;
  };
  for (int i = 0; i < 4; i++) cycle();
  t.rst_n = 1;

  for (; cyc < max_cycles; cyc++) {
    cycle();
    bool tx = t.uart_tx;
    if (uart_debug && tx != prev_tx && uart_out.size() < 8)
      std::fprintf(stderr, "tx %d at %llu\n", tx, (unsigned long long)cyc);
    if (state < 0) {
      if (prev_tx && !tx) {
        state = 0;
        next_sample = cyc + 1.5 * bit;
        shift = 0;
      }
    } else if (cyc >= next_sample) {
      if (state < 8) {
        shift |= (unsigned)tx << state++;
        next_sample += bit;
      } else {
        if (!tx) {
          std::fprintf(stderr, "[fpga] UART framing error at %llu\n",
                       (unsigned long long)cyc);
        }
        uart_out.push_back((char)shift);
        state = -1;
      }
    }
    prev_tx = tx;
    if (!expect.empty() && uart_out.find(expect) != std::string::npos) break;
  }

  bool ok = !expect.empty() && uart_out.find(expect) != std::string::npos;
  if (!ok && !uart_out.empty())
    std::fprintf(stderr, "[fpga] UART output: %s\n", uart_out.c_str());
  std::printf("[fpga] Tang Primer 24 MHz: %llu cycles, LED=%x: %s\n",
              (unsigned long long)cyc, (unsigned)t.rgb_led, ok ? "PASS" : "FAIL");
  return ok ? 0 : 1;
}

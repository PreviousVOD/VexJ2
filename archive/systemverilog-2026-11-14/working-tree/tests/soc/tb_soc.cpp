// SoC simulation: j2_soc_ref / j2_soc with pin-level models.
//
//   Vtb_soc <image.hex> [--max-cycles N] [--expect STR]... [--uart-bit CYCLES]
//           [--uart-in STR] [--quiet]
//
//   - SRAM is loaded from the $readmemh image (+sram=<file>).
//   - UART: the TX pin is decoded (8N1) and echoed; --uart-in sends a string
//     to the RX pin after the first TX character.
//   - PIO: pi = po (as on the Mimas v2 board); LED (po[7:0]) changes logged.
//   - SPI: MISO = MOSI (loopback).
//   - External Wishbone port: DDR region and the sim magic block
//     (TEST_RESULT at 0xBCDE0010).
#include "Vtb_soc.h"
#include "verilated.h"
#include "sysmodel.h"
#include "wbslave.h"
#include <cstring>

using namespace j2sim;

int main(int argc, char **argv) {
  if (argc < 2) { fprintf(stderr, "usage: %s image.hex [options]\n", argv[0]); return 2; }
  std::string plus = std::string("+sram=") + argv[1];
  const char *vargs[] = {argv[0], plus.c_str()};
  Verilated::commandArgs(2, vargs);

  uint64_t max_cycles = 20000000;
  double bit = 50e6 / 19073.5;  // uartlite DDS: 19200 baud nominal at 50 MHz
  std::vector<std::string> expect;
  std::string uart_in;
  bool quiet = false;
  for (int i = 2; i < argc; i++) {
    std::string o = argv[i];
    if (o == "--max-cycles") max_cycles = strtoull(argv[++i], 0, 0);
    else if (o == "--expect") expect.push_back(argv[++i]);
    else if (o == "--uart-bit") bit = atof(argv[++i]);
    else if (o == "--uart-in") uart_in = argv[++i];
    else if (o == "--quiet") quiet = true;
    else { fprintf(stderr, "unknown option %s\n", o.c_str()); return 2; }
  }

  SysBus ext;  // DDR region / sim magic block (no RAM image here)
  ext.echo_uart = false;
  WbSlave xd, xi;

  Vtb_soc t;
  t.clk = 0; t.rst = 1; t.uart_rx = 1; t.spi_miso = 0; t.pi = 0;
  t.eval();
  for (int i = 0; i < 4; i++) { t.clk = 1; t.eval(); t.clk = 0; t.eval(); }
  t.rst = 0; t.eval();

  // UART TX decoder
  std::string uart_out;
  int rx_state = -1;  // -1 idle, else bit index
  double next_sample = 0;
  unsigned shift = 0;
  bool prev_tx = true;
  // UART RX driver
  size_t in_pos = 0;
  double rx_next = 0;
  int rx_bit = -1;
  unsigned rx_char = 0;
  // LEDs
  uint32_t last_po = t.po;
  std::vector<uint32_t> leds;

  uint64_t cyc = 0;
  bool done = false;
  for (; cyc < max_cycles && !done; cyc++) {
    t.clk = 1; t.eval();
    uint32_t d;
    bool st;
    t.xd_ack = xd.step(t.xd_cyc, t.xd_stb, t.xd_adr, t.xd_we, t.xd_sel, t.xd_dat_o, st, d,
                       [&](uint32_t a, bool w, unsigned s, uint32_t v) { return ext.access(a, w, s, v); });
    t.xd_stall = st; t.xd_dat_i = d;
    t.xi_ack = xi.step(t.xi_cyc, t.xi_stb, t.xi_adr, false, 0xf, 0, st, d,
                       [&](uint32_t a, bool, unsigned, uint32_t) { return ext.fetch32(a); });
    t.xi_stall = st; t.xi_dat_i = d;
    t.pi = t.po;
    t.spi_miso = t.spi_mosi;

    // TX decode
    bool tx = t.uart_tx;
    if (rx_state < 0) {
      if (prev_tx && !tx) { rx_state = 0; next_sample = cyc + 1.5 * bit; shift = 0; }
    } else if (cyc >= next_sample) {
      if (rx_state < 8) { shift |= (unsigned)tx << rx_state; rx_state++; next_sample += bit; }
      else {
        if (!tx) printf("[soc] UART framing error at cycle %llu\n", (unsigned long long)cyc);
        uart_out.push_back((char)shift);
        if (!quiet) { fputc((char)shift, stdout); fflush(stdout); }
        rx_state = -1;
      }
    }
    prev_tx = tx;
    // RX drive (after the first TX character)
    if (in_pos < uart_in.size() && !uart_out.empty()) {
      if (rx_bit < 0) { rx_bit = 0; rx_char = (unsigned char)uart_in[in_pos]; rx_next = cyc + bit; t.uart_rx = 0; }
      else if (cyc >= rx_next) {
        if (rx_bit < 8) { t.uart_rx = (rx_char >> rx_bit) & 1; rx_bit++; }
        else if (rx_bit == 8) { t.uart_rx = 1; rx_bit++; }
        else { rx_bit = -1; in_pos++; }
        rx_next += bit;
      }
    }
    // LEDs
    if ((t.po & 0xff) != (last_po & 0xff)) leds.push_back(t.po);
    last_po = t.po;

    t.eval();
    t.clk = 0; t.eval();

    if (ext.test_result >= 0) done = true;
    if (!expect.empty()) {
      bool all = true;
      for (auto &e : expect) all &= uart_out.find(e) != std::string::npos;
      done |= all;
    }
  }
  printf("\n[soc] %llu cycles; LEDs:", (unsigned long long)cyc);
  for (size_t i = 0; i < leds.size() && i < 32; i++) printf(" %02x", leds[i] & 0xff);
  printf("\n");
  bool ok = true;
  if (ext.test_result >= 0) { printf("[soc] TEST_RESULT=%d\n", ext.test_result); ok = ext.test_result == 0; }
  else if (!expect.empty()) { ok = done; if (!done) printf("[soc] expected UART output not seen\n"); }
  printf("[soc] %s\n", ok ? "PASS" : "FAIL");
  return ok ? 0 : 1;
}

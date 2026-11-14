// Random cycle-by-cycle comparison of j2_regfile with the original.
#include "Vtb_regfile.h"
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <random>

int main(int argc, char **argv) {
  uint64_t seed = argc > 1 ? strtoull(argv[1], 0, 0) : 1;
  uint64_t n = argc > 2 ? strtoull(argv[2], 0, 0) : 2000000;
  std::mt19937_64 rng(seed);
  Vtb_regfile t;
  uint64_t bad = 0;
  auto check = [&](uint64_t cyc) {
#define CHK(x)                                                                        \
    if (t.x != t.r_##x && bad++ < 10)                                                 \
      printf("cycle %llu MISMATCH %s: new=%08x ref=%08x\n", (unsigned long long)cyc, #x, \
             t.x, t.r_##x);
    CHK(dout_a) CHK(dout_b) CHK(dout_0) CHK(wr_data_o)
  };
  t.clk = 0; t.rst = 1; t.ce = 0; t.eval();
  t.clk = 1; t.eval(); t.clk = 0; t.eval();
  t.rst = 0;
  bool p1 = false, p2 = false;  // model of the EX write pipe enables
  for (uint64_t c = 0; c < n; c++) {
    uint64_t r = rng(), r2 = rng();
    bool init = c < 32;  // first write every register through the WB port
    t.ce = init ? 1 : ((r & 7) != 0);
    t.addr_ra = (r >> 3) % 24;   // includes out-of-range numbers 21..23
    t.addr_rb = (r >> 8) % 24;
    t.we_wb = init ? 1 : (r >> 13) & 1;
    t.w_addr_wb = init ? (c % 21) : (r >> 14) % 22;
    t.din_wb = (uint32_t)r2;
    // Avoid a WB write colliding with an EX write committing in the same slot:
    // the decoder guarantees this; both designs prioritise EX, but the VHDL
    // asserts on it.
    t.we_ex = init ? 0 : (r >> 19) & 1;
    t.w_addr_ex = (r >> 20) % 22;
    t.din_ex = (uint32_t)(r2 >> 32);
    if (p2) t.we_wb = 0;  // keep stimulus legal (no Z/W commit clash)
    if ((r >> 40) % 1000 == 0) t.rst = 1;  // occasional reset
    t.eval();
    if (t.rst) { p1 = p2 = false; }
    else if (t.ce) { p2 = p1; p1 = t.we_ex; }
    check(c);
    t.clk = 1; t.eval();
    t.clk = 0; t.rst = 0; t.eval();
    check(c);
  }
  printf("regfile: %llu cycles, seed %llu: %llu mismatches\n", (unsigned long long)n,
         (unsigned long long)seed, (unsigned long long)bad);
  return bad ? 1 : 0;
}

// Random cycle-by-cycle comparison of j2_mult with the original.
#include "Vtb_mult.h"
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <random>

int main(int argc, char **argv) {
  uint64_t seed = argc > 1 ? strtoull(argv[1], 0, 0) : 1;
  uint64_t n = argc > 2 ? strtoull(argv[2], 0, 0) : 2000000;
  std::mt19937_64 rng(seed);
  // commands the decoder issues (mult_state_t positions)
  static const uint8_t cmds[] = {0, 1, 4, 7, 10, 14, 17, 19};  // NOP DMULSL DMULUL MACL MACW MULL MULSW MULUW
  static const uint32_t edge[] = {0, 1, 0x7fff, 0x8000, 0xffff, 0x7fffffff, 0x80000000,
                                  0xffffffff, 0x00007fff, 0xffff8000};
  Vtb_mult t;
  uint64_t bad = 0;
  auto check = [&](uint64_t cyc) {
#define CHK(x)                                                                         \
    if (t.x != t.r_##x && bad++ < 10)                                                  \
      printf("cycle %llu MISMATCH %s: new=%08x ref=%08x\n", (unsigned long long)cyc, #x,  \
             (unsigned)t.x, (unsigned)t.r_##x);
    CHK(mach) CHK(macl) CHK(busy)
  };
  t.clk = 0; t.rst = 1; t.eval(); t.clk = 1; t.eval(); t.clk = 0; t.rst = 0; t.eval();
  for (uint64_t c = 0; c < n; c++) {
    uint64_t r = rng(), r2 = rng();
    t.slot = (r & 3) != 0;
    // mostly NOP, sometimes a command; occasionally any state value
    t.command = ((r >> 2) & 3) ? 0 : (((r >> 4) & 31) == 0 ? (r >> 9) % 21 : cmds[(r >> 14) & 7]);
    t.s = (r >> 17) & 1;
    t.wr_m1 = (r >> 18) & 1;
    t.wr_mach = ((r >> 19) & 7) == 0;
    t.wr_macl = ((r >> 22) & 7) == 0;
    t.in1 = ((r >> 25) & 3) == 0 ? edge[(r >> 27) % 10] : (uint32_t)r2;
    t.in2 = ((r >> 31) & 3) == 0 ? edge[(r >> 33) % 10] : (uint32_t)(r2 >> 32);
    if ((r >> 40) % 5000 == 0) t.rst = 1;
    t.eval();
    check(c);
    t.clk = 1; t.eval();
    t.clk = 0; t.rst = 0; t.eval();
    check(c);
  }
  printf("mult: %llu cycles, seed %llu: %llu mismatches\n", (unsigned long long)n,
         (unsigned long long)seed, (unsigned long long)bad);
  return bad ? 1 : 0;
}

// Random + edge-case comparison of the new ALU functions with the original.
#include "Vtb_alu.h"
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <random>

int main(int argc, char **argv) {
  uint64_t seed = argc > 1 ? strtoull(argv[1], 0, 0) : 1;
  uint64_t n = argc > 2 ? strtoull(argv[2], 0, 0) : 4000000;
  std::mt19937_64 rng(seed);
  static const uint32_t edge[] = {0, 1, 2, 0x7f, 0x80, 0xff, 0x7fff, 0x8000, 0xffff, 0x7fffffff,
                                  0x80000000, 0x80000001, 0xfffffffe, 0xffffffff, 0x00ff00ff};
  const int NE = sizeof(edge) / sizeof(edge[0]);
  Vtb_alu t;
  uint64_t bad = 0;
  for (uint64_t i = 0; i < n; i++) {
    uint64_t r = rng(), r2 = rng();
    // a third of the vectors use edge operands
    t.a = (i % 3 == 0) ? edge[r % NE] : (uint32_t)r;
    t.b = (i % 3 == 0) ? edge[(r >> 8) % NE] : (uint32_t)(r >> 32);
    t.arith_func = r2 & 1;
    t.ci = (r2 >> 1) & 1;
    t.sr_in = (r2 >> 2) & 0xff;
    t.a_msb = t.a >> 31;   // the datapath feeds X/Y bus MSBs; also test arbitrary
    t.b_msb = t.b >> 31;
    if ((r2 >> 10) & 1) { t.a_msb = (r2 >> 11) & 1; t.b_msb = (r2 >> 12) & 1; }
    t.arith_sr = (r2 >> 13) & 7;
    t.logic_func = (r2 >> 16) & 3;
    t.logic_sr = (r2 >> 18) & 1;
    t.shift_b = (i < 64 * 4 * 2) ? (i & 63) : ((r2 >> 19) & 63);
    t.shift_c = (r2 >> 25) & 1;
    t.shift_func = (i < 64 * 4 * 2) ? ((i >> 6) & 3) : ((r2 >> 26) & 3);
    t.manip_func = (r2 >> 28) & 7;
    t.eval();
#define CHK(x)                                                                          \
  if (t.x != t.r_##x) {                                                                 \
    if (bad++ < 10)                                                                     \
      printf("MISMATCH %-10s a=%08x b=%08x af=%u ci=%u sr=%02x asr=%u lf=%u sb=%02x sf=%u " \
             "mf=%u: new=%llx ref=%llx\n", #x, t.a, t.b, t.arith_func, t.ci, t.sr_in,   \
             t.arith_sr, t.logic_func, t.shift_b, t.shift_func, t.manip_func,           \
             (unsigned long long)t.x, (unsigned long long)t.r_##x);                     \
  }
    CHK(arith_o) CHK(arith_sr_o) CHK(logic_o) CHK(logic_sr_o) CHK(shift_o) CHK(manip_o)
  }
  printf("alu: %llu vectors, seed %llu: %llu mismatches\n", (unsigned long long)n,
         (unsigned long long)seed, (unsigned long long)bad);
  return bad ? 1 : 0;
}

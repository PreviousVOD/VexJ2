// Run a program on the ORIGINAL J2 CPU (converted by tools/ref_synth.sh)
// with native-bus memory/peripheral models. Establishes the baseline that
// the new core must reproduce.
//
//   Vref_cpu <image.bin> [--ilat N] [--dlat N] [--rand N] [--seed S]
//            [--max-cycles N] [--expect STR]... [--quiet] [--trace-bus]
#include "Vref_cpu.h"
#include "sysmodel.h"
#include <cstring>

using namespace j2sim;

int main(int argc, char **argv) {
  if (argc < 2) { fprintf(stderr, "usage: %s image.bin [options]\n", argv[0]); return 2; }
  SysBus sys;
  NativeSlave ibus, dbus;
  uint64_t max_cycles = 2000000;
  std::vector<std::string> expect;
  bool trace_bus = false;
  for (int i = 2; i < argc; i++) {
    std::string o = argv[i];
    auto next = [&]() { return strtoull(argv[++i], 0, 0); };
    if (o == "--ilat") ibus.lat.fixed = next();
    else if (o == "--dlat") dbus.lat.fixed = next();
    else if (o == "--rand") ibus.lat.rand_max = dbus.lat.rand_max = next();
    else if (o == "--seed") { unsigned s = next(); ibus.lat.rng.seed(s); dbus.lat.rng.seed(s * 7 + 1); }
    else if (o == "--max-cycles") max_cycles = next();
    else if (o == "--expect") expect.push_back(argv[++i]);
    else if (o == "--quiet") sys.echo_uart = false;
    else if (o == "--trace-bus") trace_bus = true;
    else if (o == "--verbose") sys.verbose = true;
    else { fprintf(stderr, "unknown option %s\n", o.c_str()); return 2; }
  }
  if (!sys.mem.load_bin(argv[1])) return 2;

  Vref_cpu t;
  t.clk = 0; t.rst = 1;
  t.ev_i_en = 0; t.ev_i_lvl = 0xf; t.dbg_i_en = 0;
  t.eval();
  for (int i = 0; i < 4; i++) { t.clk = 1; t.eval(); t.clk = 0; t.eval(); }
  t.rst = 0; t.eval();

  uint64_t cyc = 0;
  bool done = false;
  for (; cyc < max_cycles && !done; cyc++) {
    t.clk = 1; t.eval();
    uint32_t idata = 0, ddata = 0;
    t.inst_ack = ibus.step(t.inst_en, [&] {
      uint32_t a = t.inst_a << 1;
      if (trace_bus) printf("%8llu IF  %08x\n", (unsigned long long)cyc, a);
      return (uint32_t)sys.fetch(a);
    }, idata);
    t.inst_d = idata;
    t.db_ack = dbus.step(t.db_en, [&] {
      uint32_t r = sys.access(t.db_a, t.db_wr, t.db_we, t.db_do);
      if (trace_bus)
        printf("%8llu %s %08x we=%x d=%08x%s\n", (unsigned long long)cyc, t.db_wr ? "WR" : "RD",
               t.db_a, t.db_we, t.db_wr ? t.db_do : r, t.db_lock ? " lock" : "");
      return r;
    }, ddata);
    t.db_di = ddata;
    t.ev_i_en = sys.ev_en(); t.ev_i_cmd = sys.ev_cmd(); t.ev_i_msk = sys.ev_msk();
    t.ev_i_lvl = sys.ev_lvl(); t.ev_i_vec = sys.ev_vec();
    t.eval();
    sys.ev_ack(t.ev_o_ack);
    t.clk = 0; t.eval();
    if (sys.test_result >= 0) done = true;
    if (!expect.empty()) {
      bool all = true;
      for (auto &e : expect) all &= sys.uart_out.find(e) != std::string::npos;
      if (all) done = true;
    }
  }
  printf("\n[ref_cpu] %llu cycles, %llu ifetch, %llu data txns; LEDs:",
         (unsigned long long)cyc, (unsigned long long)ibus.transactions,
         (unsigned long long)dbus.transactions);
  for (auto v : sys.leds) printf(" %02x", v & 0xff);
  printf("\n");
  if (sys.test_result >= 0) {
    printf("[ref_cpu] TEST_RESULT=%d -> %s\n", sys.test_result, sys.test_result ? "FAIL" : "PASS");
    return sys.test_result ? 1 : 0;
  }
  if (!expect.empty()) {
    printf("[ref_cpu] %s\n", done ? "PASS (expected output seen)" : "FAIL (timeout)");
    return done ? 0 : 1;
  }
  return 0;
}

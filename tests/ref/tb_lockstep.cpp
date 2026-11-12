// Cycle-exact lockstep: new j2_cpu (Wishbone) vs converted original CPU.
//
//   Vtb_lockstep <image.bin> [--stall S] [--kmin K] [--kmax K] [--seed N]
//                [--max-cycles N] [--expect STR]... [--quiet] [--max-errors N]
//                [--irq-rand N] [--dbg-rand N] [--dbg-safe] [--no-undef]
//
// --dbg-safe   debug INSERT only inserts NOPs (program state stays valid)
// --no-undef   fail if the run stops at an undefined opcode
//
// --irq-rand N / --dbg-rand N inject random events (interrupt, error, break,
// reset) / debug commands (BREAK, STEP, INSERT, CONTINUE) about every N
// cycles, identically into both CPUs. The program's own result is then not
// meaningful; only the lockstep comparison is checked.
//
// Per bus transaction a timing (s, k) is drawn from identically seeded
// generators on both sides: the Wishbone slave stalls s cycles then acks k
// (>= 1) cycles after accepting; the native slave acks s + k cycles after it
// first sees 'en'. Both CPUs must then behave identically cycle for cycle.
#include "Vtb_lockstep.h"
#include "sysmodel.h"
#include <cstring>
#if VM_TRACE
#include "verilated_fst_c.h"
#endif

using namespace j2sim;

// Opcode table generated from the spec (tools/gen_decode.py --c-table).
struct OpDef { uint16_t mask, value; int plane; const char *name; };
static const OpDef op_defs[] = {
#define J2_OP(m, v, p, n, f, s) {m, v, p, n},
#include "j2_isa_table.inc"
#undef J2_OP
};
static bool opcode_defined(uint16_t code) {
  for (auto &o : op_defs)
    if (o.plane == 0 && (code & o.mask) == o.value) return true;
  return false;
}

struct TxnTiming {
  std::mt19937 rng;
  unsigned smax = 0, kmin = 1, kmax = 1;
  void seed(unsigned s) { rng.seed(s); }
  void next(unsigned &s, unsigned &k) {
    s = smax ? rng() % (smax + 1) : 0;
    k = kmin + (kmax > kmin ? rng() % (kmax - kmin + 1) : 0);
  }
};

// Wishbone B4 pipelined slave model (one outstanding access).
struct WbSlave {
  TxnTiming t;
  bool active = false, accepted = false;
  unsigned stall_left = 0, lat_left = 0;
  uint32_t adr = 0, dat = 0;
  unsigned sel = 0;
  bool we = false;
  uint64_t txns = 0;
  // returns ack; sets stall and read data
  template <class F>
  bool step(bool cyc, bool stb, uint32_t a, bool w, unsigned s, uint32_t d, bool &stall,
            uint32_t &rdata, F access) {
    stall = false;
    rdata = 0;
    if (!active && cyc && stb) {
      unsigned ss, kk;
      t.next(ss, kk);
      active = true; accepted = false; stall_left = ss; lat_left = kk;
    }
    if (!active) return false;
    if (!accepted) {
      if (stall_left) { stall_left--; stall = true; return false; }
      accepted = true; adr = a; we = w; sel = s; dat = d;
      return false;
    }
    if (--lat_left == 0) {
      rdata = access(adr, we, sel, dat);
      active = false;
      txns++;
      return true;
    }
    return false;
  }
};

// Native slave with per-transaction latency s + k from the same generator.
struct NatSlave {
  TxnTiming t;
  bool in_txn = false, acked = false;
  unsigned wait = 0, target = 0;
  uint64_t txns = 0;
  template <class F> bool step(bool en, uint32_t &data, F fn) {
    if (acked) { in_txn = false; acked = false; }
    data = 0;
    if (!en) { in_txn = false; return false; }
    if (!in_txn) { unsigned s, k; t.next(s, k); target = s + k; wait = 0; in_txn = true; }
    if (wait >= target) { data = fn(); acked = true; txns++; return true; }
    wait++;
    return false;
  }
};

int main(int argc, char **argv) {
  if (argc < 2) { fprintf(stderr, "usage: %s image.bin [options]\n", argv[0]); return 2; }
  SysBus nsys, rsys;
  WbSlave nib, ndb;
  NatSlave rib, rdb;
  uint64_t max_cycles = 3000000, max_errors = 10;
  std::vector<std::string> expect;
  unsigned seed = 1, smax = 0, kmin = 1, kmax = 1, irq_rand = 0, dbg_rand = 0;
  const char *trace_file = nullptr;
  uint64_t watch_from = ~0ull, watch_to = 0;
  bool dbg_safe = false, no_undef = false;
  uint64_t trace_from = 0, trace_to = 0;
  for (int i = 2; i < argc; i++) {
    std::string o = argv[i];
    auto next = [&]() { return strtoull(argv[++i], 0, 0); };
    if (o == "--stall") smax = next();
    else if (o == "--kmin") kmin = next();
    else if (o == "--kmax") kmax = next();
    else if (o == "--seed") seed = next();
    else if (o == "--max-cycles") max_cycles = next();
    else if (o == "--max-errors") max_errors = next();
    else if (o == "--expect") expect.push_back(argv[++i]);
    else if (o == "--quiet") nsys.echo_uart = false;
    else if (o == "--irq-rand") irq_rand = next();
    else if (o == "--dbg-rand") dbg_rand = next();
    else if (o == "--dbg-safe") dbg_safe = true;
    else if (o == "--no-undef") no_undef = true;
    else if (o == "--watch") { watch_from = next(); watch_to = next(); }
    else if (o == "--trace") { trace_file = argv[++i]; trace_from = next(); trace_to = next(); }
    else { fprintf(stderr, "unknown option %s\n", o.c_str()); return 2; }
  }
  if (kmin < 1) kmin = 1;
  if (kmax < kmin) kmax = kmin;
  rsys.echo_uart = false;
  if (!nsys.mem.load_bin(argv[1]) || !rsys.mem.load_bin(argv[1])) return 2;
  for (TxnTiming *t : {&nib.t, &ndb.t, &rib.t, &rdb.t}) { t->smax = smax; t->kmin = kmin; t->kmax = kmax; }
  nib.t.seed(seed); rib.t.seed(seed);
  ndb.t.seed(seed * 7 + 1); rdb.t.seed(seed * 7 + 1);

  Vtb_lockstep t;
#if VM_TRACE
  VerilatedFstC *tfp = nullptr;
  if (trace_file) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedFstC;
    t.trace(tfp, 99);
    tfp->open(trace_file);
  }
  uint64_t tstamp = 0;
  auto dump = [&](uint64_t c) { if (tfp && c >= trace_from && c <= trace_to) tfp->dump(tstamp); tstamp++; };
#else
  if (trace_file) { fprintf(stderr, "built without --trace\n"); return 2; }
  auto dump = [&](uint64_t) {};
#endif
  t.clk = 0; t.rst = 1; t.ev_en = 0; t.ev_lvl = 0xf; t.dbg_en = 0;
  t.eval();
  for (int i = 0; i < 4; i++) { t.clk = 1; t.eval(); t.clk = 0; t.eval(); }
  t.rst = 0; t.eval();

  uint64_t cyc = 0, errors = 0, n_irq = 0, n_dbg = 0;
  bool undef_stop = false;
  bool done = false;
  std::mt19937 rng(seed * 31 + 5);
  // random event injection: held until the CPU acks (ack falling edge)
  struct { bool en = false, msk = false, ack_prev = false; unsigned cmd = 0, vec = 0, lvl = 0, age = 0; } rev;
  // random debug commands: held until acked
  struct { bool en = false, d_en = false; unsigned cmd = 0, ir = 0, d = 0; } rdbg;
  static const uint16_t dbg_irs[] = {0x0009, 0x6013 /*mov r1,r0*/, 0x001a /*sts macl,r0*/,
                                     0x0002 /*stc sr,r0*/, 0x7001 /*add #1,r0*/, 0xe105 /*mov #5,r1*/};
  auto err = [&](const char *what, uint64_t n, uint64_t r) {
    if (errors++ < max_errors)
      printf("[lockstep] cycle %llu: %s differs: new=%llx ref=%llx\n", (unsigned long long)cyc,
             what, (unsigned long long)n, (unsigned long long)r);
  };

  for (; cyc < max_cycles && !done && errors < max_errors; cyc++) {
    t.clk = 1; t.eval();

    // ---- original CPU (native)
    uint32_t d;
    t.r_inst_ack = rib.step(t.r_inst_en, d, [&] { return (uint32_t)rsys.fetch(t.r_inst_a << 1); });
    t.r_inst_d = d;
    t.r_db_ack = rdb.step(t.r_db_en, d, [&] { return rsys.access(t.r_db_a, t.r_db_wr, t.r_db_we, t.r_db_do); });
    t.r_db_di = d;
    // ---- new CPU (Wishbone)
    bool st;
    t.n_ib_ack = nib.step(t.n_ib_cyc, t.n_ib_stb, t.n_ib_adr, false, t.n_ib_sel, 0, st, d,
                          [&](uint32_t a, bool, unsigned, uint32_t) { return nsys.mem.read32(a); });
    t.n_ib_stall = st; t.n_ib_dat = d;
    t.n_db_ack = ndb.step(t.n_db_cyc, t.n_db_stb, t.n_db_adr, t.n_db_we, t.n_db_sel, t.n_db_dat_o, st, d,
                          [&](uint32_t a, bool w, unsigned s, uint32_t v) { return nsys.access(a, w, s, v); });
    t.n_db_stall = st; t.n_db_dat_i = d;
    // ---- events: from the program's trigger, or random
    if (irq_rand) {
      if (!rev.en && rng() % irq_rand == 0) {
        unsigned r = rng() % 100;
        rev.en = true;
        rev.cmd = r < 75 ? 0 : r < 85 ? 1 : r < 95 ? 2 : 3;  // INT, ERROR, BREAK, RESET
        rev.msk = rev.cmd != 0 || (rng() & 1);
        rev.lvl = rng() & 15;
        // interrupts/errors: not the reset vectors (PC/SP entries);
        // reset: power-on vector (PC = @0, SP = @4)
        rev.vec = rev.cmd == 3 ? 0 : 4 + rng() % 60;
        rev.age = 0;
        n_irq++;
      }
      t.ev_en = rev.en; t.ev_cmd = rev.cmd; t.ev_msk = rev.msk; t.ev_lvl = rev.lvl; t.ev_vec = rev.vec;
    } else {
      t.ev_en = nsys.ev_en(); t.ev_cmd = nsys.ev_cmd(); t.ev_msk = nsys.ev_msk();
      t.ev_lvl = nsys.ev_lvl(); t.ev_vec = nsys.ev_vec();
    }
    // ---- debug commands
    if (dbg_rand) {
      if (!rdbg.en && rng() % dbg_rand == 0) {
        rdbg.en = true;
        rdbg.cmd = rng() & 3;
        rdbg.ir = dbg_safe ? 0x0009 : dbg_irs[rng() % (sizeof(dbg_irs) / sizeof(dbg_irs[0]))];
        rdbg.d_en = dbg_safe ? 0 : (rng() & 1);
        rdbg.d = rng();
        n_dbg++;
      }
      t.dbg_en = rdbg.en; t.dbg_cmd = rdbg.cmd; t.dbg_ir = rdbg.ir;
      t.dbg_d_en = rdbg.d_en; t.dbg_d = rdbg.d;
    }
    t.eval();

    if (cyc >= watch_from && cyc <= watch_to)
      printf("%8llu pc=%08x/%08x ir=%04x/%04x new: slot=%d st=%d ed=%x stop=%d ip=%d ib=%d/%d db=%d | ref: slot=%d st=%d ed=%x stop=%d ip=%d ib=%d db=%d | dbg en=%d cmd=%d ack=%d/%d ev en=%d cmd=%d vec=%d ack=%d\n",
             (unsigned long long)cyc, t.n_pc, t.r_pc, t.n_ifdr, t.r_ifdr, t.n_slot, t.n_dstate, t.n_ed, t.n_stoppc, t.n_ipend,
             t.n_ib_cyc, t.n_ib_ack, t.n_db_pending, t.r_slot, t.r_dstate, t.r_ed, t.r_stoppc,
             t.r_ipend, t.r_inst_ack, t.r_db_en, t.dbg_en, t.dbg_cmd, t.n_dbg_ack, t.r_dbg_ack, t.ev_en, t.ev_cmd, t.ev_vec, t.r_ev_ack);
    // The original executes undefined opcodes (other than 0xFFxx) as whatever
    // its minimised decoder produces; that is not reproduced. Stop comparing
    // once the original starts executing one.
    {
      uint64_t dc = t.r_dc;
      unsigned plane = (dc >> 4) & 1, code = (dc >> 5) & 0xffff;
      if (plane == 0 && !opcode_defined(code)) {
        printf("[lockstep] cycle %llu: original CPU executes undefined opcode %04x at PC %08x; "
               "stopping comparison\n", (unsigned long long)cyc, code, t.r_pc);
        undef_stop = true;
        break;
      }
    }
    // ---- compare
    if (t.n_slot != t.r_slot) err("slot", t.n_slot, t.r_slot);
    if (t.n_pc != t.r_pc) err("PC", t.n_pc, t.r_pc);
    if (t.n_sr != t.r_sr) err("SR", t.n_sr, t.r_sr);
    if (t.n_ifdr != t.r_ifdr) err("IR (if_dr)", t.n_ifdr, t.r_ifdr);
    if (t.n_dc != t.r_dc) err("decode_core state", t.n_dc, t.r_dc);
    if (t.n_ib_pending != t.r_inst_en) err("ibus request", t.n_ib_pending, t.r_inst_en);
    else if (t.r_inst_en) {
      uint32_t na = t.n_ib_adr | (t.n_ib_sel == 0x3 ? 2 : 0), ra = t.r_inst_a << 1;
      if (na != ra) err("ifetch address", na, ra);
      if (t.n_ib_jp != t.r_inst_jp) err("ifetch jp", t.n_ib_jp, t.r_inst_jp);
    }
    if (t.n_db_pending != t.r_db_en) err("dbus request", t.n_db_pending, t.r_db_en);
    else if (t.r_db_en) {
      if (t.n_db_a != t.r_db_a) err("data address", t.n_db_a, t.r_db_a);
      if (t.n_db_we != t.r_db_wr) err("data wr", t.n_db_we, t.r_db_wr);
      if (t.r_db_wr) {
        if (t.n_db_sel != t.r_db_we) err("data sel/we", t.n_db_sel, t.r_db_we);
        if (t.n_db_dat_o != t.r_db_do) err("write data", t.n_db_dat_o, t.r_db_do);
      }
    }
    if (t.n_db_lock != t.r_db_lock) err("lock", t.n_db_lock, t.r_db_lock);
    if (t.n_ev_ack != t.r_ev_ack) err("event ack", t.n_ev_ack, t.r_ev_ack);
    if (t.n_ev_lvl != t.r_ev_lvl) err("event lvl (SR.I)", t.n_ev_lvl, t.r_ev_lvl);
    if (t.n_ev_slp != t.r_ev_slp) err("sleep", t.n_ev_slp, t.r_ev_slp);
    if (t.n_ev_dbg != t.r_ev_dbg) err("debug", t.n_ev_dbg, t.r_ev_dbg);
    if (t.n_dbg_ack != t.r_dbg_ack) err("debug ack", t.n_dbg_ack, t.r_dbg_ack);
    if (t.n_dbg_rdy != t.r_dbg_rdy) err("debug rdy", t.n_dbg_rdy, t.r_dbg_rdy);
    if (t.r_dbg_ack && t.n_dbg_d != t.r_dbg_d) err("debug data", t.n_dbg_d, t.r_dbg_d);

    if (irq_rand) {  // release the random event after the ack pulse
      if (rev.ack_prev && !t.r_ev_ack) rev.en = false;
      // a request that is not taken (masked) is withdrawn after a while
      if (rev.en && !t.r_ev_ack && ++rev.age > 200) rev.en = false;
      rev.ack_prev = t.r_ev_ack;
    }
    if (dbg_rand && rdbg.en && t.r_dbg_ack) rdbg.en = false;

    nsys.ev_ack(t.n_ev_ack);
    dump(cyc);
    t.clk = 0; t.eval();
    dump(cyc);

    if (nsys.test_result >= 0) done = true;
    if (!expect.empty()) {
      bool all = true;
      for (auto &e : expect) all &= nsys.uart_out.find(e) != std::string::npos;
      done |= all;
    }
  }
  if (!undef_stop) {
    if (nsys.uart_out != rsys.uart_out) { errors++; printf("[lockstep] UART output differs\n"); }
    if (nsys.mem.m != rsys.mem.m) { errors++; printf("[lockstep] final memory differs\n"); }
    if (nsys.leds != rsys.leds) { errors++; printf("[lockstep] LED writes differ\n"); }
  }
#if VM_TRACE
  if (tfp) tfp->close();
#endif
  printf("\n[lockstep] %llu cycles, ifetch %llu/%llu, data %llu/%llu (new/ref), stall<=%u k=%u..%u seed %u\n",
         (unsigned long long)cyc, (unsigned long long)nib.txns, (unsigned long long)rib.txns,
         (unsigned long long)ndb.txns, (unsigned long long)rdb.txns, smax, kmin, kmax, seed);
  bool ok = errors == 0 && !(no_undef && undef_stop);
  bool random_mode = irq_rand || dbg_rand || undef_stop;
  if (random_mode) printf("[lockstep] injected %llu events, %llu debug commands\n",
                          (unsigned long long)n_irq, (unsigned long long)n_dbg);
  else if (nsys.test_result >= 0) ok &= nsys.test_result == 0;
  else if (!expect.empty()) ok &= done;
  printf("[lockstep] %s: %llu mismatches%s\n", ok ? "PASS" : "FAIL", (unsigned long long)errors,
         nsys.test_result > 0 ? " (program reported failure)" : "");
  return ok ? 0 : 1;
}

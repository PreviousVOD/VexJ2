// j2sim: Verilator simulator for the J2 CPU (j2_cpu, Wishbone buses).
//
//   j2sim <image.bin> [options]
//     --max-cycles N        stop after N cycles (default 5M)
//     --stall S --kmin K --kmax K --seed N   random Wishbone timing
//     --expect STR          stop (pass) when STR has appeared on the UART
//     --iss                 check against the j2iss instruction-set simulator
//     --irq-rand N          inject random interrupts/errors/resets ~every N cycles
//     --log-ops             print every instruction as it starts executing
//                           (cycle, PC register = next sequential address, opcode)
//     --trace FILE A B      FST waveform for cycles A..B (build with TRACE=1)
//     --quiet               do not echo the UART
//
// The ISS checker executes one instruction each time the RTL starts one and
// takes events where the RTL accepts them. It compares the opcode of every
// started instruction (control flow), every data-bus access in order, and
// the sequence of values written to each register.
#include "Vtb_cpu.h"
#include "j2iss.h"
#include "sysmodel.h"
#include "wbslave.h"
#include <cstring>
#include <deque>
#if VM_TRACE
#include "verilated_fst_c.h"
#endif

using namespace j2sim;

namespace {

struct OpDef { uint16_t mask, value; int plane; const char *name; };
const OpDef op_defs[] = {
#define J2_OP(m, v, p, n, f, s) {m, v, p, n},
#include "j2_isa_table.inc"
#undef J2_OP
};
const char *op_name(uint16_t code, bool sys) {
  for (auto &o : op_defs)
    if (o.plane == (sys ? 1 : 0) && (code & o.mask) == o.value) return o.name;
  return "(undefined)";
}

struct IssBus : j2iss::Bus {
  SysBus &sys;
  explicit IssBus(SysBus &s) : sys(s) {}
  uint32_t read32(uint32_t a) override { return sys.access(a, false, 0, 0); }
  void write(uint32_t a, unsigned sel, uint32_t d) override { sys.access(a, true, sel, d); }
  uint16_t fetch(uint32_t a) override { return sys.fetch(a); }
};

struct Checker {
  SysBus sys;
  IssBus bus{sys};
  j2iss::Cpu cpu{bus};
  struct MemOp { bool wr; uint32_t a; unsigned sel; uint32_t d; };
  std::deque<uint32_t> regq[19];
  std::deque<MemOp> memq;
  uint64_t errors = 0, max_errors = 10, checked_ops = 0, checked_mem = 0, checked_reg = 0;
  bool enabled = true;
  uint64_t *cyc = nullptr;

  void err(const char *fmt, uint64_t a = 0, uint64_t b = 0, uint64_t c = 0) {
    if (errors++ < max_errors) {
      printf("[iss] cycle %llu: ", (unsigned long long)*cyc);
      printf(fmt, (unsigned long long)a, (unsigned long long)b, (unsigned long long)c);
      printf("  (ISS pc=%08x, %llu instructions)\n", cpu.pc, (unsigned long long)cpu.icount);
    }
  }

  void init(const std::string &image, bool vec_fix, bool trap) {
    sys.echo_uart = false;
    sys.mem.load_bin(image);
    cpu.illegal_vec_fix = vec_fix;
    cpu.opcode_trap = trap;
    cpu.on_reg = [this](int r, uint32_t v) { regq[r].push_back(v); };
    cpu.on_write = [this](uint32_t a, unsigned s, uint32_t d) { memq.push_back({true, a, s, d}); };
    cpu.on_read = [this](uint32_t a, unsigned s) { memq.push_back({false, a, s, 0}); };
    cpu.power_on();
  }

  // RTL started an operation
  void op_start(bool sys_plane, uint16_t code, unsigned ev_lvl) {
    if (!enabled) return;
    checked_ops++;
    if (!sys_plane) {
      uint16_t want = cpu.peek_opcode();
      if (code != want) err("RTL executes opcode %04llx, ISS expects %04llx", code, want);
      cpu.step();
      if (cpu.last_kind != j2iss::Cpu::Kind::NORMAL)
        err("ISS took an illegal-instruction exception for %04llx, RTL did not", code);
      return;
    }
    unsigned cmd = (code >> 8) & 7, vec = code & 0xff;
    switch (cmd) {
    case 0: case 1: case 3:  // interrupt, error, reset
      if (cpu.in_delay_slot()) err("RTL accepted an event in a delay slot");
      cpu.event(cmd, vec, ev_lvl);
      break;
    case 6: case 7: {        // slot illegal, general illegal
      cpu.step();
      auto want = cmd == 6 ? j2iss::Cpu::Kind::SLOT_ILLEGAL : j2iss::Cpu::Kind::GENERAL_ILLEGAL;
      if (cpu.last_kind != want)
        err("RTL raised illegal-instruction exception %llu (6 slot, 7 general) for %04llx, ISS did not",
            cmd, cpu.last_opcode);
      break;
    }
    default:
      printf("[iss] cycle %llu: BREAK/debug operation; ISS checking disabled\n",
             (unsigned long long)*cyc);
      enabled = false;
    }
  }

  void reg_write(unsigned n, uint32_t v) {
    if (!enabled || n >= 19) return;  // TEMP0/TEMP1 are micro-architectural
    checked_reg++;
    if (regq[n].empty()) { err("RTL writes r%llu = %08llx, ISS has no pending write", n, v); return; }
    uint32_t want = regq[n].front();
    regq[n].pop_front();
    if (v != want) err("RTL writes r%llu = %08llx, ISS expects %08llx", n, v, want);
  }

  void mem_access(bool wr, uint32_t a, unsigned sel, uint32_t d) {
    if (!enabled) return;
    a &= ~3u;  // the ISS records word addresses
    checked_mem++;
    if (memq.empty()) {
      err(wr ? "RTL write %08llx with no ISS access pending" : "RTL read %08llx with no ISS access pending", a);
      return;
    }
    MemOp o = memq.front();
    memq.pop_front();
    uint32_t mask = (sel & 8 ? 0xff000000u : 0) | (sel & 4 ? 0xff0000u : 0) |
                    (sel & 2 ? 0xff00u : 0) | (sel & 1 ? 0xffu : 0);
    if (o.wr != wr || o.a != a || o.sel != sel || (wr && (o.d & mask) != (d & mask)))
      err("RTL access %llx, ISS expects %llx (wr<<36 | sel<<32 | addr; data r=%08llx)",
          (uint64_t)wr << 36 | (uint64_t)sel << 32 | a, (uint64_t)o.wr << 36 | (uint64_t)o.sel << 32 | o.a, d);
  }
};

}  // namespace

int main(int argc, char **argv) {
  if (argc < 2) { fprintf(stderr, "usage: %s image.bin [options]\n", argv[0]); return 2; }
  std::string image = argv[1];
  SysBus sys;
  WbSlave ib, db;
  uint64_t max_cycles = 5000000;
  std::vector<std::string> expect;
  unsigned seed = 1, smax = 0, kmin = 1, kmax = 1, irq_rand = 0;
  bool use_iss = false, log_ops = false;
  const char *trace_file = nullptr;
  uint64_t trace_from = 0, trace_to = 0;
  for (int i = 2; i < argc; i++) {
    std::string o = argv[i];
    auto next = [&]() { return strtoull(argv[++i], 0, 0); };
    if (o == "--max-cycles") max_cycles = next();
    else if (o == "--stall") smax = next();
    else if (o == "--kmin") kmin = next();
    else if (o == "--kmax") kmax = next();
    else if (o == "--seed") seed = next();
    else if (o == "--expect") expect.push_back(argv[++i]);
    else if (o == "--iss") use_iss = true;
    else if (o == "--irq-rand") irq_rand = next();
    else if (o == "--log-ops") log_ops = true;
    else if (o == "--quiet") sys.echo_uart = false;
    else if (o == "--trace") { trace_file = argv[++i]; trace_from = next(); trace_to = next(); }
    else { fprintf(stderr, "unknown option %s\n", o.c_str()); return 2; }
  }
  if (kmin < 1) kmin = 1;
  if (kmax < kmin) kmax = kmin;
  if (!sys.mem.load_bin(image)) return 2;
  for (TxnTiming *t : {&ib.t, &db.t}) { t->smax = smax; t->kmin = kmin; t->kmax = kmax; }
  ib.t.seed(seed);
  db.t.seed(seed * 7 + 1);

  Vtb_cpu t;
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
  if (trace_file) { fprintf(stderr, "built without tracing (make TRACE=1)\n"); return 2; }
  auto dump = [&](uint64_t) {};
#endif

  uint64_t cyc = 0;
  Checker chk;
  chk.cyc = &cyc;
  if (use_iss) chk.init(image, true, true);

  t.clk = 0; t.rst = 1; t.ev_en = 0; t.ev_lvl = 0xf; t.dbg_en = 0;
  t.eval();
  for (int i = 0; i < 4; i++) { t.clk = 1; t.eval(); t.clk = 0; t.eval(); }
  t.rst = 0; t.eval();

  std::mt19937 rng(seed * 31 + 5);
  struct { bool en = false, msk = false, ack_prev = false; unsigned cmd = 0, vec = 0, lvl = 0, age = 0; } rev;
  uint64_t n_irq = 0;
  bool done = false;

  for (; cyc < max_cycles && !done; cyc++) {
    t.clk = 1; t.eval();

    uint32_t d;
    bool st;
    t.ib_ack = ib.step(t.ib_cyc, t.ib_stb, t.ib_adr, false, t.ib_sel, 0, st, d,
                       [&](uint32_t a, bool, unsigned, uint32_t) { return sys.fetch32(a); });
    t.ib_stall = st; t.ib_dat = d;
    t.db_ack = db.step(t.db_cyc, t.db_stb, t.db_adr, t.db_we, t.db_sel, t.db_dat_o, st, d,
                       [&](uint32_t a, bool w, unsigned s, uint32_t v) {
                         if (use_iss) chk.mem_access(w, a, s, v);
                         return sys.access(a, w, s, v);
                       });
    t.db_stall = st; t.db_dat_i = d;

    if (irq_rand) {
      if (!rev.en && rng() % irq_rand == 0) {
        unsigned r = rng() % 100;
        rev.en = true;
        rev.cmd = r < 85 ? 0 : r < 95 ? 1 : 3;  // interrupt, error, reset (no BREAK)
        rev.msk = rev.cmd != 0 || (rng() & 1);
        rev.lvl = rng() & 15;
        // vectors 8..63 (0-3: reset PC/SP, 4/6: illegal-instruction handlers)
        rev.vec = rev.cmd == 3 ? 0 : 8 + rng() % 56;
        rev.age = 0;
        n_irq++;
      }
      t.ev_en = rev.en; t.ev_cmd = rev.cmd; t.ev_msk = rev.msk; t.ev_lvl = rev.lvl; t.ev_vec = rev.vec;
    } else {
      t.ev_en = sys.ev_en(); t.ev_cmd = sys.ev_cmd(); t.ev_msk = sys.ev_msk();
      t.ev_lvl = sys.ev_lvl(); t.ev_vec = sys.ev_vec();
    }
    t.eval();

    if (t.tr_start) {
      if (log_ops)
        printf("%9llu %08x %s %04x %s\n", (unsigned long long)cyc, t.tr_pc, t.tr_op_sys ? "SYS" : "   ",
               t.tr_op_code, op_name(t.tr_op_code, t.tr_op_sys));
      if (use_iss) chk.op_start(t.tr_op_sys, t.tr_op_code, t.ev_lvl);
    }
    if (use_iss && t.tr_reg_we) chk.reg_write(t.tr_reg_n, t.tr_reg_d);

    sys.ev_ack(t.ev_ack);
    if (irq_rand) {
      if (rev.ack_prev && !t.ev_ack) rev.en = false;
      if (rev.en && !t.ev_ack && ++rev.age > 200) rev.en = false;
      rev.ack_prev = t.ev_ack;
    }
    dump(cyc);
    t.clk = 0; t.eval();
    dump(cyc);

    if (sys.test_result >= 0) done = true;
    if (!expect.empty()) {
      bool all = true;
      for (auto &e : expect) all &= sys.uart_out.find(e) != std::string::npos;
      done |= all;
    }
    if (use_iss && chk.errors >= chk.max_errors) break;
  }
#if VM_TRACE
  if (tfp) tfp->close();
#endif

  printf("\n[j2sim] %llu cycles, %llu ifetch, %llu data accesses", (unsigned long long)cyc,
         (unsigned long long)ib.txns, (unsigned long long)db.txns);
  if (irq_rand) printf(", %llu random events", (unsigned long long)n_irq);
  printf("; LEDs:");
  for (size_t i = 0; i < sys.leds.size() && i < 24; i++) printf(" %02x", sys.leds[i] & 0xff);
  printf("%s\n", sys.leds.size() > 24 ? " ..." : "");
  bool ok = true;
  if (use_iss) {
    printf("[j2sim] ISS check: %llu operations, %llu memory accesses, %llu register writes: %llu errors\n",
           (unsigned long long)chk.checked_ops, (unsigned long long)chk.checked_mem,
           (unsigned long long)chk.checked_reg, (unsigned long long)chk.errors);
    ok &= chk.errors == 0;
  }
  if (sys.test_result >= 0) {
    printf("[j2sim] TEST_RESULT=%d\n", sys.test_result);
    ok &= sys.test_result == 0;
  } else if (!expect.empty()) {
    if (!done) printf("[j2sim] expected UART output not seen\n");
    ok &= done;
  }
  printf("[j2sim] %s\n", ok ? "PASS" : "FAIL");
  return ok ? 0 : 1;
}

// Wishbone B4 pipelined slave model and per-transaction timing generator,
// shared by the J2 testbenches.
#pragma once
#include <cstdint>
#include <random>

namespace j2sim {

// Per-transaction timing: stall s in [0, smax], ack k in [kmin, kmax] cycles
// after the request is accepted.
struct TxnTiming {
  std::mt19937 rng;
  unsigned smax = 0, kmin = 1, kmax = 1;
  void seed(unsigned s) { rng.seed(s); }
  void next(unsigned &s, unsigned &k) {
    s = smax ? rng() % (smax + 1) : 0;
    k = kmin + (kmax > kmin ? rng() % (kmax - kmin + 1) : 0);
  }
};

// One outstanding access at a time (the J2 masters never issue more).
struct WbSlave {
  TxnTiming t;
  bool active = false, accepted = false;
  unsigned stall_left = 0, lat_left = 0;
  uint32_t adr = 0, dat = 0;
  unsigned sel = 0;
  bool we = false;
  uint64_t txns = 0;
  // Call once per cycle after the posedge eval. Returns ack; sets stall and
  // read data. 'access(adr, we, sel, dat)' performs the access at ack time.
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

}  // namespace j2sim

// j2iss: J2 instruction-set simulator. See j2iss.h.
#include "j2iss.h"
#include <cstdio>

namespace j2iss {

namespace {
struct OpDef { uint16_t mask, value; int plane; };
const OpDef op_defs[] = {
#define J2_OP(m, v, p, n, f, s) {m, v, p},
#include "j2_isa_table.inc"
#undef J2_OP
};
inline int32_t sx8(uint32_t v) { return (int8_t)v; }
inline int32_t sx12(uint32_t v) { return (int32_t)(v << 20) >> 20; }
}  // namespace

bool Cpu::opcode_defined(uint16_t op) {
  for (auto &o : op_defs)
    if (o.plane == 0 && (op & o.mask) == o.value) return true;
  return false;
}

// Same predicate as the decoder's check_illegal_delay_slot (decode_body.vhd).
bool Cpu::pc_modifying(uint16_t c) {
  return ((c >> 12) == 0x0 && ((c >> 2) & 3) == 0 && (c & 1)) ||
         ((c >> 14) == 2 && ((c >> 11) & 3) == 1 && ((c >> 8) & 1)) ||
         ((c >> 13) == 5) ||
         ((c >> 15) && ((c >> 8) & 0x3f) == 0x03) ||
         (!(c >> 15) && ((c >> 12) & 3) == 0 && (c & 0x1f) == 0x0b);
}

void Cpu::wreg(int n, uint32_t v) {
  if (n < 16) R[n] = v;
  else if (n == GBR) gbr = v;
  else if (n == VBR) vbr = v;
  else if (n == PR) pr = v;
  if (on_reg) on_reg(n, v);
}

uint32_t Cpu::rd(uint32_t a, int size) {
  uint32_t w = bus_.read32(a & ~3u);
  unsigned sel;
  uint32_t v;
  if (size == 1) {
    sel = 8u >> (a & 3);
    v = (uint32_t)sx8(w >> (24 - 8 * (a & 3)));
  } else if (size == 2) {
    sel = (a & 2) ? 0x3 : 0xc;
    v = (uint32_t)(int32_t)(int16_t)((a & 2) ? w : w >> 16);
  } else {
    sel = 0xf;
    v = w;
  }
  if (on_read) on_read(a & ~3u, sel);
  return v;
}

void Cpu::wr(uint32_t a, int size, uint32_t v) {
  unsigned sel;
  uint32_t d;
  if (size == 1) { sel = 8u >> (a & 3); d = (v & 0xff) * 0x01010101u; }
  else if (size == 2) { sel = (a & 2) ? 0x3 : 0xc; d = (v & 0xffff) * 0x00010001u; }
  else { sel = 0xf; d = v; }
  bus_.write(a & ~3u, sel, d);
  if (on_write) on_write(a & ~3u, sel, d);
}

void Cpu::power_on() {
  I = 0xf; T = S = Q = M = false;
  delay_ = false;
  event(EV_RESET, 0, 0);
}

// TRAPA / illegal-instruction entry: push SR, PC at R15-4, R15-8.
void Cpu::exception(unsigned vec, uint32_t ret_pc) {
  wreg(15, R[15] - 4);
  wr(R[15], 4, sr());
  wreg(15, R[15] - 4);
  wr(R[15], 4, ret_pc);
  pc = rd(vbr + vec * 4, 4);
  delay_ = false;
}

void Cpu::event(int cmd, unsigned vec, unsigned lvl) {
  if (cmd == EV_RESET) {
    // J2 reset sequence: PC = @(vec*4), R15 = @(vec*4 + 4), VBR = 0
    uint32_t t0 = vec * 4;
    uint32_t npc = rd(t0, 4);
    wreg(15, rd(t0 + 4, 4));
    pc = npc;
    wreg(VBR, 0);
    delay_ = false;
    return;
  }
  // interrupt / error: push at the word-aligned stack pointer, R15 -= 8
  uint32_t t0 = R[15] & ~3u;
  uint32_t old_sr = sr();
  wr(t0 - 4, 4, old_sr);
  wr(t0 - 8, 4, pc);
  uint32_t npc = rd(vbr + vec * 4, 4);
  uint32_t r15 = R[15];
  if (cmd == EV_INTERRUPT) I = lvl & 0xf;
  wreg(15, r15 - 4);
  wreg(15, r15 - 8);
  pc = npc;
  delay_ = false;
}

void Cpu::step() {
  uint32_t a = pc;
  uint16_t op = bus_.fetch(a);
  bool slot = delay_;
  uint32_t next_pc = slot ? delay_target_ : a + 2;
  delay_ = false;
  last_opcode = op;
  icount++;

  bool undefined = opcode_trap ? !opcode_defined(op) : (op >> 8) == 0xff;
  if (slot && (undefined || pc_modifying(op))) {
    last_kind = Kind::SLOT_ILLEGAL;
    // J2: the return PC is the branch target (the slot instruction is skipped)
    exception(illegal_vec_fix ? 6 : 0, next_pc);
    return;
  }
  if (undefined) {
    last_kind = Kind::GENERAL_ILLEGAL;
    exception(illegal_vec_fix ? 4 : 0, a);
    return;
  }
  last_kind = Kind::NORMAL;
  execute(op, a, next_pc);
  pc = next_pc;
}

void Cpu::mac_w(uint32_t va, uint32_t vb) {
  int64_t prod = (int64_t)(int16_t)va * (int16_t)vb;
  if (S) {
    int64_t sum = (int64_t)(int32_t)macl + prod;
    if (sum > 0x7fffffffLL) { macl = 0x7fffffff; mach |= 1; }
    else if (sum < -0x80000000LL) { macl = 0x80000000; mach |= 1; }
    else macl = (uint32_t)sum;
  } else {
    uint64_t acc = ((uint64_t)mach << 32 | macl) + (uint64_t)prod;
    mach = (uint32_t)(acc >> 32);
    macl = (uint32_t)acc;
  }
}

void Cpu::mac_l(uint32_t va, uint32_t vb) {
  int64_t prod = (int64_t)(int32_t)va * (int32_t)vb;
  int64_t mac = (int64_t)((uint64_t)mach << 32 | macl);
  if (S) {
    __int128 sum = (__int128)mac + prod;
    const int64_t P48 = 0x00007fffffffffffLL, N48 = (int64_t)0xffff800000000000ULL;
    if (sum > P48) sum = P48;
    else if (sum < N48) sum = N48;
    mac = (int64_t)sum;
  } else {
    mac = (int64_t)((uint64_t)mac + (uint64_t)prod);
  }
  mach = (uint32_t)((uint64_t)mac >> 32);
  macl = (uint32_t)mac;
}

void Cpu::execute(uint16_t op, uint32_t a, uint32_t &next_pc) {
  const unsigned n = (op >> 8) & 15, m = (op >> 4) & 15;
  const uint32_t imm8 = op & 0xff, d4 = op & 15;
  uint32_t &Rn = R[n];
  const uint32_t Rm = R[m];
  // PC-relative base: instruction address + 4; in a delay slot the branch
  // target + 2 (SH-2 manual). Both are "next PC + 2".
  const uint32_t pcr = next_pc + 2;
  auto setT = [&](bool v) { T = v; };

  switch (op >> 12) {
  case 0x0:
    switch (op & 0xff) {
    case 0x08: setT(false); return;                                   // CLRT
    case 0x09: return;                                                // NOP
    case 0x0b: delayed(pr); return;                                   // RTS
    case 0x18: setT(true); return;                                    // SETT
    case 0x19: M = Q = T = false; return;                             // DIV0U
    case 0x1b: return;                                                // SLEEP (J2: no halt)
    case 0x28: mach = macl = 0; return;                               // CLRMAC
    case 0x2b: {                                                      // RTE
      uint32_t r15 = R[15];
      uint32_t npc = rd(r15, 4);
      wreg(15, r15 + 4);
      uint32_t nsr = rd(r15 + 4, 4);
      wreg(15, r15 + 8);
      set_sr(nsr & 0x3f3);
      delayed(npc);
      return;
    }
    case 0x3b: return;                                                // BGND (debug)
    }
    switch (op & 0xf) {
    case 0x2:
      if (m == 0) { wreg(n, sr()); return; }                          // STC SR,Rn
      if (m == 1) { wreg(n, gbr); return; }                           // STC GBR,Rn
      if (m == 2) { wreg(n, vbr); return; }                           // STC VBR,Rn
      break;
    case 0x3:
      if (m == 0) { wreg(PR, pcr); delayed(pcr + R[n]); return; }     // BSRF Rm
      if (m == 2) { delayed(pcr + R[n]); return; }                    // BRAF Rm
      break;
    case 0x4: wr(Rn + R[0], 1, Rm); return;                           // MOV.B Rm,@(R0,Rn)
    case 0x5: wr(Rn + R[0], 2, Rm); return;                           // MOV.W
    case 0x6: wr(Rn + R[0], 4, Rm); return;                           // MOV.L
    case 0x7: macl = Rn * Rm; return;                                 // MUL.L
    case 0x9: if (m == 2) { wreg(n, T); return; } break;              // MOVT
    case 0xa:
      if (m == 0) { wreg(n, mach); return; }                          // STS MACH
      if (m == 1) { wreg(n, macl); return; }                          // STS MACL
      if (m == 2) { wreg(n, pr); return; }                            // STS PR
      break;
    case 0xc: wreg(n, rd(Rm + R[0], 1)); return;                      // MOV.B @(R0,Rm),Rn
    case 0xd: wreg(n, rd(Rm + R[0], 2)); return;
    case 0xe: wreg(n, rd(Rm + R[0], 4)); return;
    case 0xf: {                                                       // MAC.L @Rm+,@Rn+
      uint32_t vn = rd(Rn, 4); wreg(n, R[n] + 4);
      uint32_t vm = rd(R[m], 4); wreg(m, R[m] + 4);
      mac_l(vn, vm);
      return;
    }
    }
    break;
  case 0x1: wr(Rn + d4 * 4, 4, Rm); return;                           // MOV.L Rm,@(disp,Rn)
  case 0x2:
    switch (op & 0xf) {
    case 0x0: wr(Rn, 1, Rm); return;
    case 0x1: wr(Rn, 2, Rm); return;
    case 0x2: wr(Rn, 4, Rm); return;
    case 0x3: {                                                       // CAS.L Rm,Rn,@R0
      uint32_t tmp = Rn, addr = R[0];
      uint32_t v = rd(addr, 4);
      wreg(n, v);
      // J2 micro-code compares with Rm read after Rn was loaded, so for
      // m == n the compare always succeeds.
      T = (v == R[m]);
      if (T) wr(addr, 4, tmp);
      return;
    }
    case 0x4: { uint32_t v = Rm; wreg(n, Rn - 1); wr(R[n], 1, v); return; }   // MOV.B Rm,@-Rn
    case 0x5: { uint32_t v = Rm; wreg(n, Rn - 2); wr(R[n], 2, v); return; }
    case 0x6: { uint32_t v = Rm; wreg(n, Rn - 4); wr(R[n], 4, v); return; }
    case 0x7: Q = Rn >> 31; M = Rm >> 31; T = Q != M; return;         // DIV0S
    case 0x8: T = (Rn & Rm) == 0; return;                             // TST
    case 0x9: wreg(n, Rn & Rm); return;                               // AND
    case 0xa: wreg(n, Rn ^ Rm); return;                               // XOR
    case 0xb: wreg(n, Rn | Rm); return;                               // OR
    case 0xc: {                                                       // CMP/STR
      uint32_t x = Rn ^ Rm;
      T = !(x & 0xff000000) || !(x & 0xff0000) || !(x & 0xff00) || !(x & 0xff);
      return;
    }
    case 0xd: wreg(n, (Rm << 16) | (Rn >> 16)); return;               // XTRCT
    case 0xe: macl = (uint32_t)((uint16_t)Rn * (uint16_t)Rm); return; // MULU.W
    case 0xf: macl = (uint32_t)((int16_t)Rn * (int16_t)Rm); return;   // MULS.W
    }
    break;
  case 0x3:
    switch (op & 0xf) {
    case 0x0: T = Rn == Rm; return;                                   // CMP/EQ
    case 0x2: T = Rn >= Rm; return;                                   // CMP/HS
    case 0x3: T = (int32_t)Rn >= (int32_t)Rm; return;                 // CMP/GE
    case 0x4: {                                                       // DIV1
      bool old_q = Q, tmp1;
      Q = Rn >> 31;
      uint32_t r = (Rn << 1) | T, tmp0 = r;
      if (old_q == M) { r -= Rm; tmp1 = r > tmp0; }   // borrow
      else            { r += Rm; tmp1 = r < tmp0; }   // carry
      // SH-2 manual case table, independent of old_q: Q = Q ^ M ^ tmp1
      Q = Q ^ M ^ tmp1;
      T = Q == M;
      wreg(n, r);
      return;
    }
    case 0x5: { uint64_t p = (uint64_t)Rn * Rm; mach = p >> 32; macl = (uint32_t)p; return; }  // DMULU.L
    case 0x6: T = Rn > Rm; return;                                    // CMP/HI
    case 0x7: T = (int32_t)Rn > (int32_t)Rm; return;                  // CMP/GT
    case 0x8: wreg(n, Rn - Rm); return;                               // SUB
    case 0xa: {                                                       // SUBC
      uint32_t t1 = Rn - Rm, r = t1 - T;
      T = (Rn < t1) || (t1 < r);
      wreg(n, r);
      return;
    }
    case 0xb: {                                                       // SUBV
      uint32_t r = Rn - Rm;
      T = ((Rn ^ Rm) & (Rn ^ r)) >> 31;
      wreg(n, r);
      return;
    }
    case 0xc: wreg(n, Rn + Rm); return;                               // ADD
    case 0xd: { int64_t p = (int64_t)(int32_t)Rn * (int32_t)Rm; mach = (uint64_t)p >> 32; macl = (uint32_t)p; return; }
    case 0xe: {                                                       // ADDC
      uint32_t t1 = Rn + Rm, r = t1 + T;
      T = (Rn > t1) || (t1 > r);
      wreg(n, r);
      return;
    }
    case 0xf: {                                                       // ADDV
      uint32_t r = Rn + Rm;
      T = (~(Rn ^ Rm) & (Rn ^ r)) >> 31;
      wreg(n, r);
      return;
    }
    }
    break;
  case 0x4:
    switch (op & 0xff) {
    case 0x00: T = Rn >> 31; wreg(n, Rn << 1); return;                // SHLL
    case 0x01: T = Rn & 1; wreg(n, Rn >> 1); return;                  // SHLR
    case 0x02: { wreg(n, Rn - 4); wr(R[n], 4, mach); return; }        // STS.L MACH,@-Rn
    case 0x03: { uint32_t v = sr(); wreg(n, Rn - 4); wr(R[n], 4, v); return; }  // STC.L SR
    case 0x04: T = Rn >> 31; wreg(n, (Rn << 1) | T); return;          // ROTL
    case 0x05: T = Rn & 1; wreg(n, (Rn >> 1) | (T ? 0x80000000u : 0)); return;  // ROTR
    case 0x06: { uint32_t v = rd(Rn, 4); wreg(n, R[n] + 4); mach = v; return; } // LDS.L @Rm+,MACH
    case 0x07: { uint32_t v = rd(Rn, 4); wreg(n, R[n] + 4); set_sr(v & 0x3f3); return; }
    case 0x08: wreg(n, Rn << 2); return;                              // SHLL2
    case 0x09: wreg(n, Rn >> 2); return;                              // SHLR2
    case 0x0a: mach = Rn; return;                                     // LDS Rm,MACH
    case 0x0b: wreg(PR, pcr); delayed(Rn); return;                    // JSR @Rm
    case 0x0e: set_sr(Rn & 0x3f3); return;                            // LDC Rm,SR
    case 0x10: wreg(n, Rn - 1); T = R[n] == 0; return;                // DT
    case 0x11: T = (int32_t)Rn >= 0; return;                          // CMP/PZ
    case 0x12: { wreg(n, Rn - 4); wr(R[n], 4, macl); return; }
    case 0x13: { uint32_t v = gbr; wreg(n, Rn - 4); wr(R[n], 4, v); return; }
    case 0x15: T = (int32_t)Rn > 0; return;                           // CMP/PL
    case 0x16: { uint32_t v = rd(Rn, 4); wreg(n, R[n] + 4); macl = v; return; }
    case 0x17: { uint32_t v = rd(Rn, 4); wreg(n, R[n] + 4); wreg(GBR, v); return; }
    case 0x18: wreg(n, Rn << 8); return;                              // SHLL8
    case 0x19: wreg(n, Rn >> 8); return;                              // SHLR8
    case 0x1a: macl = Rn; return;                                     // LDS Rm,MACL
    case 0x1b: {                                                      // TAS.B @Rn
      uint32_t v = rd(Rn, 1);
      T = (v & 0xff) == 0;
      wr(Rn, 1, v | 0x80);
      return;
    }
    case 0x1e: wreg(GBR, Rn); return;                                 // LDC Rm,GBR
    case 0x20: T = Rn >> 31; wreg(n, Rn << 1); return;                // SHAL
    case 0x21: T = Rn & 1; wreg(n, (uint32_t)((int32_t)Rn >> 1)); return;  // SHAR
    case 0x22: { wreg(n, Rn - 4); wr(R[n], 4, pr); return; }          // STS.L PR
    case 0x23: { uint32_t v = vbr; wreg(n, Rn - 4); wr(R[n], 4, v); return; }
    case 0x24: { bool t = T; T = Rn >> 31; wreg(n, (Rn << 1) | t); return; }        // ROTCL
    case 0x25: { bool t = T; T = Rn & 1; wreg(n, (Rn >> 1) | (t ? 0x80000000u : 0)); return; }
    case 0x26: { uint32_t v = rd(Rn, 4); wreg(n, R[n] + 4); wreg(PR, v); return; }
    case 0x27: { uint32_t v = rd(Rn, 4); wreg(n, R[n] + 4); wreg(VBR, v); return; }
    case 0x28: wreg(n, Rn << 16); return;                             // SHLL16
    case 0x29: wreg(n, Rn >> 16); return;                             // SHLR16
    case 0x2a: wreg(PR, Rn); return;                                  // LDS Rm,PR
    case 0x2b: delayed(Rn); return;                                   // JMP @Rm
    case 0x2e: wreg(VBR, Rn); return;                                 // LDC Rm,VBR
    }
    switch (op & 0xf) {
    case 0xc: {                                                       // SHAD Rm,Rn
      int32_t s = (int32_t)Rm;
      uint32_t r;
      if (s >= 0) r = Rn << (s & 31);
      else if ((s & 31) == 0) r = ((int32_t)Rn < 0) ? 0xffffffffu : 0;
      else r = (uint32_t)((int32_t)Rn >> ((~s & 31) + 1));
      wreg(n, r);
      return;
    }
    case 0xd: {                                                       // SHLD Rm,Rn
      int32_t s = (int32_t)Rm;
      uint32_t r;
      if (s >= 0) r = Rn << (s & 31);
      else if ((s & 31) == 0) r = 0;
      else r = Rn >> ((~s & 31) + 1);
      wreg(n, r);
      return;
    }
    case 0xf: {                                                       // MAC.W @Rm+,@Rn+
      uint32_t vn = rd(Rn, 2); wreg(n, R[n] + 2);
      uint32_t vm = rd(R[m], 2); wreg(m, R[m] + 2);
      mac_w(vn, vm);
      return;
    }
    }
    break;
  case 0x5: wreg(n, rd(Rm + d4 * 4, 4)); return;                      // MOV.L @(disp,Rm),Rn
  case 0x6:
    switch (op & 0xf) {
    case 0x0: wreg(n, rd(Rm, 1)); return;
    case 0x1: wreg(n, rd(Rm, 2)); return;
    case 0x2: wreg(n, rd(Rm, 4)); return;
    case 0x3: wreg(n, Rm); return;                                    // MOV Rm,Rn
    case 0x4: { uint32_t v = rd(Rm, 1); wreg(m, Rm + 1); wreg(n, v); return; }  // MOV.B @Rm+,Rn
    case 0x5: { uint32_t v = rd(Rm, 2); wreg(m, Rm + 2); wreg(n, v); return; }
    case 0x6: { uint32_t v = rd(Rm, 4); wreg(m, Rm + 4); wreg(n, v); return; }
    case 0x7: wreg(n, ~Rm); return;                                   // NOT
    case 0x8: wreg(n, (Rm & 0xffff0000u) | (Rm & 0xff) << 8 | (Rm >> 8 & 0xff)); return;  // SWAP.B
    case 0x9: wreg(n, (Rm << 16) | (Rm >> 16)); return;               // SWAP.W
    case 0xa: {                                                       // NEGC
      uint32_t t = 0 - Rm, r = t - T;
      T = (0 < t) || (t < r);
      wreg(n, r);
      return;
    }
    case 0xb: wreg(n, 0 - Rm); return;                                // NEG
    case 0xc: wreg(n, Rm & 0xff); return;                             // EXTU.B
    case 0xd: wreg(n, Rm & 0xffff); return;                           // EXTU.W
    case 0xe: wreg(n, (uint32_t)(int32_t)(int8_t)Rm); return;         // EXTS.B
    case 0xf: wreg(n, (uint32_t)(int32_t)(int16_t)Rm); return;        // EXTS.W
    }
    break;
  case 0x7: wreg(n, Rn + (uint32_t)sx8(imm8)); return;                // ADD #imm,Rn
  case 0x8:
    switch (n) {
    case 0x0: wr(R[m] + d4, 1, R[0]); return;                         // MOV.B R0,@(disp,Rn)
    case 0x1: wr(R[m] + d4 * 2, 2, R[0]); return;
    case 0x4: wreg(0, rd(R[m] + d4, 1)); return;                      // MOV.B @(disp,Rm),R0
    case 0x5: wreg(0, rd(R[m] + d4 * 2, 2)); return;
    case 0x8: T = R[0] == (uint32_t)sx8(imm8); return;                // CMP/EQ #imm,R0
    case 0x9: if (T) next_pc = pcr + sx8(imm8) * 2; return;           // BT
    case 0xb: if (!T) next_pc = pcr + sx8(imm8) * 2; return;          // BF
    case 0xd: if (T) delayed(pcr + sx8(imm8) * 2); return;            // BT/S
    case 0xf: if (!T) delayed(pcr + sx8(imm8) * 2); return;           // BF/S
    }
    break;
  case 0x9: wreg(n, rd(pcr + imm8 * 2, 2)); return;                   // MOV.W @(disp,PC),Rn
  case 0xa: delayed(pcr + sx12(op & 0xfff) * 2); return;              // BRA
  case 0xb: wreg(PR, pcr); delayed(pcr + sx12(op & 0xfff) * 2); return;  // BSR
  case 0xc: {
    uint32_t ga = gbr + R[0];
    switch (n) {
    case 0x0: wr(gbr + imm8, 1, R[0]); return;                        // MOV.B R0,@(disp,GBR)
    case 0x1: wr(gbr + imm8 * 2, 2, R[0]); return;
    case 0x2: wr(gbr + imm8 * 4, 4, R[0]); return;
    case 0x3:                                                         // TRAPA #imm
      exception(imm8, a + 2);
      next_pc = pc;
      return;
    case 0x4: wreg(0, rd(gbr + imm8, 1)); return;
    case 0x5: wreg(0, rd(gbr + imm8 * 2, 2)); return;
    case 0x6: wreg(0, rd(gbr + imm8 * 4, 4)); return;
    case 0x7: wreg(0, (pcr & ~3u) + imm8 * 4); return;                // MOVA
    case 0x8: T = (R[0] & imm8) == 0; return;                         // TST #imm,R0
    case 0x9: wreg(0, R[0] & imm8); return;                           // AND #imm,R0
    case 0xa: wreg(0, R[0] ^ imm8); return;
    case 0xb: wreg(0, R[0] | imm8); return;
    case 0xc: { uint32_t v = rd(ga, 1); T = (v & imm8 & 0xff) == 0; return; }      // TST.B
    case 0xd: { uint32_t v = rd(ga, 1); wr(ga, 1, v & imm8); return; }             // AND.B
    case 0xe: { uint32_t v = rd(ga, 1); wr(ga, 1, v ^ imm8); return; }             // XOR.B
    case 0xf: { uint32_t v = rd(ga, 1); wr(ga, 1, v | imm8); return; }             // OR.B
    }
    break;
  }
  case 0xd: wreg(n, rd((pcr & ~3u) + imm8 * 4, 4)); return;           // MOV.L @(disp,PC),Rn
  case 0xe: wreg(n, (uint32_t)sx8(imm8)); return;                     // MOV #imm,Rn
  }
  // Defined by the spec but not handled above: should not happen.
  fprintf(stderr, "j2iss: unimplemented opcode %04x at %08x\n", op, a);
}

}  // namespace j2iss

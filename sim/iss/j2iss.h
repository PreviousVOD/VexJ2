// j2iss: instruction-set simulator for the J-Core J2 (SH-2 + CAS.L, SHAD,
// SHLD), used as the architectural golden model for the RTL.
//
// Semantics follow the SH-2 programming manual, except where the J2
// micro-code defines different behaviour (documented at each place):
//   - SLEEP does not halt (it only pulses the sleep output).
//   - Slot-illegal exceptions stack the branch target as the return PC.
//   - Interrupt/error entry pushes at the word-aligned (R15 & ~3).
//   - CAS.L Rm,Rn,@R0 with m == n: the compare uses the loaded value, so it
//     always succeeds (J2 reads Rm after Rn has been written).
//   - PC-relative operands in a delay slot use branch target + 2 (SH-2).
//   - Undefined opcodes: illegal-instruction exception (opcode_trap) or, as
//     the released J2, only 0xFFxx.
//
// The ISS executes one instruction per step() and reports architectural
// side effects (register writes, data memory accesses) through callbacks so
// a checker can compare them with the RTL.
#pragma once
#include <cstdint>
#include <functional>

namespace j2iss {

struct Bus {
  virtual ~Bus() = default;
  // aligned 32-bit word containing 'a' (big-endian); size/lanes are applied by the ISS
  virtual uint32_t read32(uint32_t a) = 0;
  // write with big-endian byte lanes (sel[3] = byte offset 0 = d[31:24])
  virtual void write(uint32_t a, unsigned sel, uint32_t d) = 0;
  virtual uint16_t fetch(uint32_t a) = 0;
};

enum Reg { GBR = 16, VBR = 17, PR = 18 };
enum EventCmd { EV_INTERRUPT = 0, EV_ERROR = 1, EV_BREAK = 2, EV_RESET = 3 };

class Cpu {
 public:
  // architectural state
  uint32_t R[16] = {};
  uint32_t gbr = 0, vbr = 0, pr = 0, mach = 0, macl = 0;
  uint32_t pc = 0;  // address of the next instruction
  bool T = false, S = false, Q = false, M = false;
  unsigned I = 0xf;

  // configuration (match j2_cpu parameters)
  bool illegal_vec_fix = true;
  bool opcode_trap = true;

  // statistics / status
  uint64_t icount = 0;
  bool in_delay_slot() const { return delay_; }
  uint16_t last_opcode = 0;
  enum class Kind { NORMAL, GENERAL_ILLEGAL, SLOT_ILLEGAL };
  Kind last_kind = Kind::NORMAL;

  // side-effect callbacks
  std::function<void(int reg, uint32_t v)> on_reg;                       // R0-15, GBR, VBR, PR
  std::function<void(uint32_t a, unsigned sel, uint32_t d)> on_write;   // data writes
  std::function<void(uint32_t a, unsigned sel)> on_read;                 // data reads

  explicit Cpu(Bus &b) : bus_(b) {}

  // Power-on: SR.I = 15, then the reset sequence with vector 0.
  void power_on();
  // Next instruction's opcode (what the RTL will decode next).
  uint16_t peek_opcode() const { return bus_.fetch(pc); }
  // Execute one instruction (or take an illegal-instruction exception).
  void step();
  // Accept an external event before the next instruction.
  void event(int cmd, unsigned vec, unsigned lvl);

  uint32_t sr() const {
    return (M ? 1u << 9 : 0) | (Q ? 1u << 8 : 0) | (I & 0xf) << 4 | (S ? 2u : 0) | (T ? 1u : 0);
  }
  void set_sr(uint32_t v) {
    M = (v >> 9) & 1; Q = (v >> 8) & 1; I = (v >> 4) & 0xf; S = (v >> 1) & 1; T = v & 1;
  }

  static bool opcode_defined(uint16_t op);
  static bool pc_modifying(uint16_t op);  // illegal in a delay slot

 private:
  Bus &bus_;
  bool delay_ = false;
  uint32_t delay_target_ = 0;

  void wreg(int n, uint32_t v);
  uint32_t rd(uint32_t a, int size);           // sign-extended read
  void wr(uint32_t a, int size, uint32_t v);
  void exception(unsigned vec, uint32_t ret_pc);
  void execute(uint16_t op, uint32_t a, uint32_t &next_pc);
  void delayed(uint32_t target) { delay_ = true; delay_target_ = target; }
  void mac_w(uint32_t a, uint32_t b);
  void mac_l(uint32_t a, uint32_t b);
};

}  // namespace j2iss

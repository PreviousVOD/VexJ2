// J2 ALU functions.
//
// Ported 1:1 from reference/soc_top/components/cpu/core/components_pkg.vhd
// (package cpu2j0_components_pack). Widths are fixed at 32 bits, the only
// width the datapath uses.
package j2_alu_pkg;
  import j2_cpu_pkg::*;

  // Add/subtract with carry-in. Result bit 32 is carry out for ADD and
  // borrow for SUB.
  //   ADD: a + b + ci         SUB: a - b - ci
  function automatic logic [32:0] arith_unit(logic [31:0] a, logic [31:0] b,
                                             arith_func_t func, logic ci);
    logic        is_sub;
    logic [32:0] sum;
    is_sub = (func == ARITH_SUB);
    // a - b - ci = a + ~b + 1 - ci = a + ~b + (is_sub ^ ci)
    sum = {1'b0, a} + {1'b0, b ^ {32{is_sub}}} + {32'd0, is_sub ^ ci};
    sum[32] = sum[32] ^ is_sub;  // carry -> borrow on subtract
    return sum;
  endfunction

  // Bitwise AND/OR/XOR of a and b, or NOT b.
  function automatic logic [31:0] logic_unit(logic [31:0] a, logic [31:0] b,
                                             logic_func_t func);
    unique case (func)
      LOGIC_NOT: return ~b;
      LOGIC_AND: return a & b;
      LOGIC_OR : return a | b;
      default  : return a ^ b;  // LOGIC_XOR
    endcase
  endfunction

  // Update SR flags from the inputs/outputs of arith_unit.
  function automatic sr_t arith_update_sr(sr_t sr_in, logic a_msb, logic b_msb,
                                          logic [31:0] value, logic co_or_borrow,
                                          arith_func_t arithfunc, arith_sr_func_t func);
    sr_t  sr_out;
    logic v_msb, is_sub, value_zero;
    logic common_gr_eq, sign_gr_eq, unsign_gr_eq;
    sr_out     = sr_in;
    v_msb      = value[31];
    is_sub     = (arithfunc == ARITH_SUB);
    value_zero = (value == 32'd0);
    // common_gr_eq = 1 => a >= b (not the converse)
    common_gr_eq = (~a_msb & ~b_msb & ~v_msb) | (a_msb & b_msb & ~v_msb);
    sign_gr_eq   = common_gr_eq | (~a_msb & b_msb);
    unsign_gr_eq = common_gr_eq | (a_msb & ~b_msb);
    unique case (func)
      ASR_ZERO         : sr_out.t = value_zero;
      ASR_OVERUNDERFLOW: sr_out.t = (~a_msb & ~(b_msb ^ is_sub) & v_msb) |
                                    (a_msb & (b_msb ^ is_sub) & ~v_msb);
      ASR_UGRTER       : sr_out.t = unsign_gr_eq & ~value_zero;
      ASR_UGRTER_EQ    : sr_out.t = unsign_gr_eq;
      ASR_SGRTER       : sr_out.t = sign_gr_eq & ~value_zero;
      ASR_SGRTER_EQ    : sr_out.t = sign_gr_eq;
      ASR_DIV0S: begin
        sr_out.q = a_msb;
        sr_out.m = b_msb;
        sr_out.t = a_msb ^ b_msb;
      end
      default: begin  // ASR_DIV1
        sr_out.q = a_msb ^ sr_in.m ^ co_or_borrow;
        sr_out.t = ~(sr_out.q ^ sr_in.m);
      end
    endcase
    return sr_out;
  endfunction

  // Update SR flags from the output of logic_unit. BYTE_EQ assumes value = a ^ b
  // (CMP/STR: T = 1 if any byte of a equals the corresponding byte of b).
  function automatic sr_t logic_update_sr(sr_t sr_in, logic [31:0] value,
                                          logic_sr_func_t func);
    sr_t sr_out;
    sr_out = sr_in;
    if (func == LSR_ZERO)
      sr_out.t = (value == 32'd0);
    else
      sr_out.t = (value[31:24] == 8'd0) | (value[23:16] == 8'd0) |
                 (value[15:8]  == 8'd0) | (value[7:0]   == 8'd0);
    return sr_out;
  endfunction

  // Barrel shifter.
  //   b[5]   : 0 = shift left, 1 = shift right
  //   b[4:0] : rotate-left amount. For right shifts the caller passes the
  //            two's complement of the right shift count, so a magnitude of 0
  //            with b[5]=1 shifts right by 32 (SHAD/SHLD semantics).
  //   c      : T bit, shifted in for ROTC
  function automatic logic [31:0] bshifter(logic [31:0] a, logic [5:0] b, logic c,
                                           shiftfunc_t ops);
    logic        left, rot, s;
    logic [4:0]  mag;
    logic [31:0] f, p, y1, y;
    mag  = b[4:0];
    left = ~b[5];
    rot  = (ops == SHIFT_ROTATE);
    // y1 = rotate left a by mag (left_rotate)
    y1 = (a << mag) | (a >> ((6'd32 - {1'b0, mag}) & 6'h1f));
    // f(i) = 1 when i < mag (calf_fcn); p = keep mask (calp_fcn)
    for (int i = 0; i < 32; i++) begin
      f[i] = (i < int'(mag));
      p[i] = (f[i] ^ left) | rot;
    end
    // fill bits (caly_fcn)
    s = (ops == SHIFT_ARITH && !left) ? a[31] : 1'b0;
    for (int i = 1; i < 31; i++)
      y[i] = p[i] ? y1[i] : s;
    if (p[0])                           y[0] = y1[0];
    else if (left && ops == SHIFT_ROTC) y[0] = c;
    else                                y[0] = s;
    if (p[31])                           y[31] = y1[31];
    else if (!left && ops == SHIFT_ROTC) y[31] = c;
    else                                 y[31] = s;
    return y;
  endfunction

  // Byte manipulation: SWAP.B/W, EXTU/EXTS.B/W, XTRCT, TAS bit 7.
  function automatic logic [31:0] manip(logic [31:0] x, logic [31:0] y, alumanip_t func);
    logic [7:0] b0, b1, b2, b3, sign_byte;
    sign_byte = {8{(func == MANIP_EXTEND_SBYTE) ? y[7] : y[15]}};
    unique case (func)
      MANIP_SWAP_BYTE, MANIP_SET_BIT_7      : b3 = y[31:24];
      MANIP_EXTEND_UBYTE, MANIP_EXTEND_UWORD: b3 = 8'h00;
      MANIP_EXTEND_SBYTE, MANIP_EXTEND_SWORD: b3 = sign_byte;
      default                               : b3 = y[15:8];   // SWAP_WORD, EXTRACT
    endcase
    unique case (func)
      MANIP_SWAP_BYTE, MANIP_SET_BIT_7      : b2 = y[23:16];
      MANIP_EXTEND_UBYTE, MANIP_EXTEND_UWORD: b2 = 8'h00;
      MANIP_EXTEND_SBYTE, MANIP_EXTEND_SWORD: b2 = sign_byte;
      default                               : b2 = y[7:0];    // SWAP_WORD, EXTRACT
    endcase
    unique case (func)
      MANIP_SWAP_BYTE                                      : b1 = y[7:0];
      MANIP_SWAP_WORD                                      : b1 = y[31:24];
      MANIP_EXTEND_UBYTE                                   : b1 = 8'h00;
      MANIP_EXTEND_UWORD, MANIP_EXTEND_SWORD, MANIP_SET_BIT_7: b1 = y[15:8];
      MANIP_EXTEND_SBYTE                                   : b1 = sign_byte;
      default                                              : b1 = x[31:24]; // EXTRACT
    endcase
    unique case (func)
      MANIP_SWAP_BYTE: b0 = y[15:8];
      MANIP_SWAP_WORD: b0 = y[23:16];
      MANIP_EXTEND_UBYTE, MANIP_EXTEND_UWORD,
      MANIP_EXTEND_SBYTE, MANIP_EXTEND_SWORD: b0 = y[7:0];
      MANIP_SET_BIT_7: b0 = {1'b1, y[6:0]};
      default        : b0 = x[23:16];  // EXTRACT
    endcase
    return {b3, b2, b1, b0};
  endfunction

endpackage

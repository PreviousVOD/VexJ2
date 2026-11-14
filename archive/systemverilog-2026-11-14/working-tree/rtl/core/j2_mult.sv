// J2 multiply / multiply-accumulate unit.
//
// Ported from reference/soc_top/components/cpu/core/{mult.vhm,mult_pkg.vhd}.
//
// A 31x16 array multiplier plus sign-correction partial products (p23)
// accumulates into the 64-bit MACH:MACL. A small microcode table (MULT_CODE)
// steps every clock; only command/operand loading is gated by 'slot'.
//   MUL.L, DMULS.L, DMULU.L, MAC.L : 3 states    MULS.W, MULU.W, MAC.W : 2 states
// MAC.L with S=1 saturates to 48 bits, MAC.W with S=1 to 32 bits (and sets
// MACH bit 0 on overflow).
module j2_mult
  import j2_cpu_pkg::*;
(
  input  logic        clk,
  input  logic        rst,
  input  logic        slot,
  // mult_i_t
  input  logic        wr_m1,
  input  mult_state_t command,
  input  logic        s,
  input  logic        wr_mach,
  input  logic        wr_macl,
  input  logic [31:0] in1,
  input  logic [31:0] in2,
  // mult_o_t
  output logic [31:0] mach,
  output logic [31:0] macl,
  output logic        busy
);

  typedef struct packed {
    mult_state_t state;
    logic        busy;
    mult_sela_t  sela;
    logic        shift;
    logic        sign;
    mult_size_t  size;
    logic        mach_en;
    logic        macl_en;
    logic        use_h;
  } mult_codeline_t;

  function automatic mult_codeline_t mult_code(mult_state_t st);
    //                  state          busy  sela      shft  sign  size        h_en  l_en  use_h
    unique case (st)
      MULT_NOP    : return '{MULT_NOP,     1'b0, MSELA_M1, 1'b0, 1'b0, MSIZE_B16, 1'b0, 1'b0, 1'b1};
      MULT_DMULSL : return '{MULT_DMULSL1, 1'b1, MSELA_M1, 1'b0, 1'b1, MSIZE_B32, 1'b0, 1'b0, 1'b1};
      MULT_DMULSL1: return '{MULT_DMULSL2, 1'b1, MSELA_M1, 1'b1, 1'b1, MSIZE_B32, 1'b1, 1'b1, 1'b1};
      MULT_DMULSL2: return '{MULT_NOP,     1'b0, MSELA_M1, 1'b1, 1'b1, MSIZE_B32, 1'b1, 1'b1, 1'b1};
      MULT_DMULUL : return '{MULT_DMULUL1, 1'b1, MSELA_M1, 1'b0, 1'b0, MSIZE_B32, 1'b0, 1'b0, 1'b1};
      MULT_DMULUL1: return '{MULT_DMULUL2, 1'b1, MSELA_M1, 1'b1, 1'b0, MSIZE_B32, 1'b1, 1'b1, 1'b1};
      MULT_DMULUL2: return '{MULT_NOP,     1'b0, MSELA_M1, 1'b1, 1'b0, MSIZE_B32, 1'b1, 1'b1, 1'b1};
      MULT_MACL   : return '{MULT_MACL1,   1'b1, MSELA_MB, 1'b0, 1'b1, MSIZE_B32, 1'b0, 1'b0, 1'b1};
      MULT_MACL1  : return '{MULT_MACL2,   1'b1, MSELA_MB, 1'b1, 1'b1, MSIZE_B32, 1'b1, 1'b1, 1'b1};
      MULT_MACL2  : return '{MULT_NOP,     1'b0, MSELA_MB, 1'b1, 1'b1, MSIZE_B32, 1'b1, 1'b1, 1'b1};
      MULT_MACW   : return '{MULT_MACW1,   1'b1, MSELA_M1, 1'b0, 1'b1, MSIZE_B16, 1'b0, 1'b0, 1'b1};
      MULT_MACW1  : return '{MULT_NOP,     1'b0, MSELA_M1, 1'b0, 1'b1, MSIZE_B16, 1'b1, 1'b1, 1'b1};
      MULT_MACWS  : return '{MULT_MACWS1,  1'b1, MSELA_M1, 1'b0, 1'b1, MSIZE_B16, 1'b0, 1'b0, 1'b0};
      MULT_MACWS1 : return '{MULT_NOP,     1'b0, MSELA_M1, 1'b0, 1'b1, MSIZE_B16, 1'b0, 1'b1, 1'b0};
      MULT_MULL   : return '{MULT_MULL1,   1'b1, MSELA_M1, 1'b0, 1'b1, MSIZE_B32, 1'b0, 1'b0, 1'b0};
      MULT_MULL1  : return '{MULT_MULL2,   1'b1, MSELA_M1, 1'b1, 1'b1, MSIZE_B32, 1'b0, 1'b1, 1'b0};
      MULT_MULL2  : return '{MULT_NOP,     1'b0, MSELA_M1, 1'b1, 1'b1, MSIZE_B32, 1'b0, 1'b1, 1'b0};
      MULT_MULSW  : return '{MULT_MULSW1,  1'b1, MSELA_M1, 1'b0, 1'b1, MSIZE_B16, 1'b0, 1'b0, 1'b0};
      MULT_MULSW1 : return '{MULT_NOP,     1'b0, MSELA_M1, 1'b0, 1'b1, MSIZE_B16, 1'b0, 1'b1, 1'b0};
      MULT_MULUW  : return '{MULT_MULUW1,  1'b1, MSELA_M1, 1'b0, 1'b0, MSIZE_B16, 1'b0, 1'b0, 1'b0};
      MULT_MULUW1 : return '{MULT_NOP,     1'b0, MSELA_M1, 1'b0, 1'b0, MSIZE_B16, 1'b0, 1'b1, 1'b0};
      default     : return '{MULT_NOP,     1'b0, MSELA_M1, 1'b0, 1'b0, MSIZE_B16, 1'b0, 1'b0, 1'b1};
    endcase
  endfunction

  localparam logic [63:0] P48MAX = 64'h00007fffffffffff;
  localparam logic [63:0] N48MAX = 64'hffff800000000000;
  localparam logic [63:0] P32MAX = 64'h000000007fffffff;
  localparam logic [63:0] N32MAX = 64'hffffffff80000000;

  typedef struct packed {
    mult_state_t     state;
    mult_result_op_t result_op;
    logic [31:0]     m1, m2, mb;
    logic [31:0]     p23;
    logic [31:0]     mach, macl;
    logic            shift;
    logic [46:0]     abh;
  } mult_reg_t;

  mult_reg_t q, d;
  mult_codeline_t code;

  assign code = mult_code(q.state);
  assign busy = code.busy;
  assign mach = q.mach;
  assign macl = q.macl;

  always_comb begin
    logic [31:0] aa;
    logic [30:0] ah;
    logic [15:0] bh;
    logic [32:0] abh2;
    logic [31:0] p2, p3, sgn;
    logic [47:0] pm;
    logic [63:0] c, acc;
    logic [2:0]  region;
    logic        sat;

    d = q;

    // operand muxes: lower 31 bits of A, upper/lower 16 bits of B
    aa = (code.sela == MSELA_MB) ? q.mb : q.m1;
    ah = aa[30:0];
    if (code.size == MSIZE_B16) ah[30:15] = '0;
    bh = q.m2[15:0];
    if (code.size == MSIZE_B16) bh[15] = 1'b0;
    else if (code.shift)        bh = {1'b0, q.m2[30:16]};

    // partial product adder input mux
    if (code.size == MSIZE_B16) abh2 = {1'b0, 16'h0000, aa[15] & q.m2[15], q.abh[29:15]};
    else if (!q.shift)          abh2 = {1'b0, q.abh[46:15]};
    else                        abh2 = {1'b0, aa[31] & q.m2[31], q.abh[45:15]};

    // sign-correction partial products
    p2 = '0;
    if (aa[31] && code.shift)            p2 = {1'b0, q.m2[30:0]};
    if (aa[15] && code.size == MSIZE_B16) p2 = {16'h0000, 1'b0, q.m2[14:0]};
    p3 = '0;
    if (q.m2[31] && code.shift)            p3 = {1'b0, aa[30:0]};
    if (q.m2[15] && code.size == MSIZE_B16) p3 = {16'h0000, 1'b0, aa[14:0]};

    sgn = {32{code.sign}};
    pm  = {abh2 + {sgn[0], q.p23 ^ sgn} + {32'd0, code.sign}, q.abh[14:0]};
    d.p23 = p2 + p3;

    if (!q.shift) c = (pm[47] && code.size == MSIZE_B16) ? {16'hffff, pm} : {16'h0000, pm};
    else          c = {pm, 16'h0000};

    // accumulator
    acc = c + {q.mach & {32{code.use_h}}, q.macl};

    // saturation
    sat = 1'b1;
    region = '0;
    unique case (q.result_op)
      MRES_SATURATE64: begin
        if (!acc[63] && acc[62:47] != 16'h0000)     region[0] = 1'b1;
        else if (acc[63] && acc[62:47] != 16'hffff) region[0] = 1'b1;
        region[2:1] = {q.mach[31], acc[63]};
        if (!c[63]) begin
          unique case (region)
            3'b001, 3'b010, 3'b011, 3'b101: acc = P48MAX;
            3'b111:                         acc = N48MAX;
            default:                        sat = 1'b0;
          endcase
        end else begin
          unique case (region)
            3'b001:                         acc = P48MAX;
            3'b011, 3'b100, 3'b101, 3'b111: acc = N48MAX;
            default:                        sat = 1'b0;
          endcase
        end
      end
      MRES_SATURATE32: begin
        region = {q.macl[31], acc[31], 1'b0};
        if (!c[31]) begin
          if (region == 3'b010) acc = P32MAX; else sat = 1'b0;
        end else begin
          if (region == 3'b100) acc = N32MAX; else sat = 1'b0;
        end
      end
      default: sat = 1'b0;  // MRES_IDENTITY
    endcase

    // multiplier array
    d.abh = 47'(ah * bh);

    // load internal registers from the CPU (mb takes the OLD m1)
    if (slot) begin
      if (command != MULT_NOP) begin
        d.m2 = in2;
        if (command == MULT_MACL || command == MULT_MACW) d.mb = q.m1;
      end
      if (wr_m1) d.m1 = in1;
    end

    if (slot && wr_mach)                                          d.mach = in1;
    else if (slot && (command == MULT_DMULSL || command == MULT_DMULUL)) d.mach = 32'h0;
    else if (q.state == MULT_MACWS1 && sat)                       d.mach = q.mach | 32'h1;
    else if (code.mach_en)                                        d.mach = acc[63:32];

    if (slot && wr_macl)                                          d.macl = in2;
    else if (slot && command != MULT_NOP && command != MULT_MACL && command != MULT_MACW)
                                                                  d.macl = 32'h0;
    else if (code.macl_en)                                        d.macl = acc[31:0];

    // delayed control for the p23 pipeline register
    d.state = code.state;
    d.shift = code.shift;

    // accept the next command from the CPU
    if (!code.busy && slot) begin
      d.result_op = MRES_IDENTITY;
      d.state     = command;
      if (command == MULT_MACL) begin
        if (s) d.result_op = MRES_SATURATE64;
      end else if (command == MULT_MACW) begin
        // MAC.W with S=1 uses the MACWS sequence (different busy/mach_en)
        if (s) begin
          d.result_op = MRES_SATURATE32;
          d.state     = MULT_MACWS;
        end
      end
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= '{state: MULT_NOP, result_op: MRES_IDENTITY, default: '0};
    else     q <= d;
  end

endmodule

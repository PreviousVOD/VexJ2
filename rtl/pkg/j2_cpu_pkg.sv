// J2 CPU common types.
//
// Ported from reference/soc_top/components/cpu/{cpu2j0_pkg.vhd,
// core/components_pkg.vhd, core/mult_pkg.vhd}.
//
// Enum literal ORDER matches the VHDL declarations exactly, so the binary
// encodings equal GHDL's positional encoding (needed for equivalence checks
// against the converted reference). SV enum literals share the package scope,
// so every literal carries a type prefix (VHDL overloads e.g. ZERO, BREAK).
package j2_cpu_pkg;

  // ---------------------------------------------------------------- ALU
  typedef enum logic [0:0] {ARITH_ADD, ARITH_SUB} arith_func_t;

  typedef enum logic [2:0] {
    ASR_ZERO, ASR_OVERUNDERFLOW, ASR_UGRTER_EQ, ASR_SGRTER_EQ,
    ASR_UGRTER, ASR_SGRTER, ASR_DIV0S, ASR_DIV1
  } arith_sr_func_t;

  typedef enum logic [1:0] {LOGIC_NOT, LOGIC_AND, LOGIC_OR, LOGIC_XOR} logic_func_t;

  typedef enum logic [0:0] {LSR_ZERO, LSR_BYTE_EQ} logic_sr_func_t;

  typedef enum logic [1:0] {SHIFT_LOGIC, SHIFT_ARITH, SHIFT_ROTATE, SHIFT_ROTC} shiftfunc_t;

  typedef enum logic [2:0] {
    MANIP_SWAP_BYTE, MANIP_SWAP_WORD, MANIP_EXTEND_UBYTE, MANIP_EXTEND_UWORD,
    MANIP_EXTEND_SBYTE, MANIP_EXTEND_SWORD, MANIP_EXTRACT, MANIP_SET_BIT_7
  } alumanip_t;

  typedef enum logic [1:0] {SZ_BYTE, SZ_WORD, SZ_LONG} mem_size_t;

  typedef enum logic [1:0] {DS_RUN, DS_READY, DS_AWAIT_IF, DS_AWAIT_BREAK} debug_state_t;

  // VHDL: record t, s, q, m : std_logic; int_mask : slv(3 downto 0)
  typedef struct packed {
    logic       t;
    logic       s;
    logic       q;
    logic       m;
    logic [3:0] int_mask;
  } sr_t;

  // SR bit positions in the architectural 32-bit SR
  localparam int SR_T  = 0;
  localparam int SR_S  = 1;
  localparam int SR_I0 = 4;
  localparam int SR_I3 = 7;
  localparam int SR_Q  = 8;
  localparam int SR_M  = 9;

  typedef logic [4:0] regnum_t;
  // Register numbers above R15 (see decode/gen parser register-map)
  localparam regnum_t REG_GBR   = 5'd16;
  localparam regnum_t REG_VBR   = 5'd17;
  localparam regnum_t REG_PR    = 5'd18;
  localparam regnum_t REG_TEMP0 = 5'd19;
  localparam regnum_t REG_TEMP1 = 5'd20;

  // ---------------------------------------------------------- multiplier
  typedef enum logic [4:0] {
    MULT_NOP,
    MULT_DMULSL, MULT_DMULSL1, MULT_DMULSL2,
    MULT_DMULUL, MULT_DMULUL1, MULT_DMULUL2,
    MULT_MACL, MULT_MACL1, MULT_MACL2,
    MULT_MACW, MULT_MACW1, MULT_MACWS, MULT_MACWS1,
    MULT_MULL, MULT_MULL1, MULT_MULL2,
    MULT_MULSW, MULT_MULSW1,
    MULT_MULUW, MULT_MULUW1
  } mult_state_t;

  typedef enum logic [1:0] {MRES_IDENTITY, MRES_SATURATE32, MRES_SATURATE64} mult_result_op_t;
  typedef enum logic [0:0] {MSELA_M1, MSELA_MB} mult_sela_t;
  typedef enum logic [0:0] {MSIZE_B16, MSIZE_B32} mult_size_t;

  // ------------------------------------------------- debug / event ports
  typedef enum logic [1:0] {DBG_BREAK, DBG_STEP, DBG_INSERT, DBG_CONTINUE} cpu_debug_cmd_t;

  typedef struct packed {
    logic        ack;
    logic [31:0] d;
    logic        rdy;
  } cpu_debug_o_t;

  typedef struct packed {
    logic           en;
    cpu_debug_cmd_t cmd;
    logic [15:0]    ir;
    logic [31:0]    d;
    logic           d_en;
  } cpu_debug_i_t;

  localparam cpu_debug_i_t CPU_DEBUG_NOP = '{en: 1'b0, cmd: DBG_BREAK, ir: '0, d: '0, d_en: 1'b0};

  typedef enum logic [1:0] {EV_INTERRUPT, EV_ERROR, EV_BREAK, EV_RESET_CPU} cpu_event_cmd_t;

  typedef struct packed {
    logic           en;
    cpu_event_cmd_t cmd;
    logic [7:0]     vec;
    logic           msk;
    logic [3:0]     lvl;
  } cpu_event_i_t;

  localparam cpu_event_i_t NULL_CPU_EVENT_I =
    '{en: 1'b0, cmd: EV_INTERRUPT, vec: '0, msk: 1'b0, lvl: 4'hF};

  typedef struct packed {
    logic       ack;
    logic [3:0] lvl;
    logic       slp;
    logic       dbg;
  } cpu_event_o_t;

endpackage

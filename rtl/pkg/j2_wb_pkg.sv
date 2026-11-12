// Wishbone B4 (pipelined) types used across the J2 SoC.
//
// Conventions:
//   - 32-bit data, byte-addressed 'adr' (adr[1:0] are 0 for masters in this
//     design; kept full width so slaves can decode without shifting).
//   - Big-endian byte lanes: sel[3] = byte offset 0 = dat[31:24], matching
//     the native J-Core bus 'we' encoding.
//   - Reads also carry a size-accurate 'sel' (one-hot byte, 1100/0011 word,
//     1111 long) so registers with read side effects stay byte accurate.
//   - Pipelined handshake: a request is accepted in a cycle with stb & !stall;
//     the slave answers with ack (or err) in a later cycle.
//   - lock: the master keeps cyc asserted between the accesses of an atomic
//     read-modify-write (TAS.B, CAS.L).
//   - tgc: J2 instruction bus uses tgc[0] = 'jp' (fetch is a jump target).
package j2_wb_pkg;

  typedef struct packed {
    logic        cyc;
    logic        stb;
    logic        we;
    logic [31:0] adr;
    logic [3:0]  sel;
    logic [31:0] dat;
    logic        lock;
    logic [0:0]  tgc;
  } wb_m2s_t;

  typedef struct packed {
    logic        ack;
    logic        err;
    logic        stall;
    logic [31:0] dat;
  } wb_s2m_t;

  localparam wb_m2s_t WB_M2S_IDLE = '0;
  localparam wb_s2m_t WB_S2M_IDLE = '0;

  // Native J-Core bus (cpu2j0_pkg.vhd), used by j2_wb2native and testbenches.
  typedef struct packed {
    logic        en;
    logic [31:0] a;
    logic        rd;
    logic        wr;
    logic [3:0]  we;
    logic [31:0] d;
  } cpu_data_o_t;

  typedef struct packed {
    logic [31:0] d;
    logic        ack;
  } cpu_data_i_t;

  localparam cpu_data_o_t NULL_DATA_O = '0;

endpackage

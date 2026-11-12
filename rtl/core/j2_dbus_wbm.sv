// J2 data bus unit: Wishbone B4 pipelined master.
//
// Replaces the native db_o register of the original datapath.vhm
// (to_data_o / align_read_data and the m_dr / m_dr_next pipeline):
//   - At the end of a slot that issues an access (EX stage) the request is
//     latched; cyc/stb go high in the next cycle (like native 'en').
//   - stb stays high until accepted (!stall); cyc until ack/err.
//   - Read data is aligned / sign-extended into m_dr_next on ack and
//     presented on the W bus (m_dr) at the next slot boundary.
//   - 'lock' (TAS.B, CAS.L) is registered per slot and keeps cyc high between
//     the accesses of the atomic sequence.
// At most one access is outstanding. With a slave that acks k >= 1 cycles
// after accept and never stalls, timing equals the native bus with ack
// latency k.
module j2_dbus_wbm
  import j2_cpu_pkg::*;
  import j2_wb_pkg::*;
(
  input  logic        clk,
  input  logic        rst,
  input  logic        slot,       // combinational slot (from j2_datapath)
  // request from the EX stage (sampled when slot = 1)
  input  logic        issue,
  input  logic        wr,
  input  logic        lock,
  input  mem_size_t   size,
  input  logic [31:0] addr,
  input  logic [31:0] wdata,
  // status
  output logic        busy,       // request outstanding after this cycle's ack
  output logic [31:0] wbus,       // W bus: data of the last completed read
  // Wishbone
  output wb_m2s_t     wb_o,
  input  wb_s2m_t     wb_i
);

  typedef struct packed {
    logic        pending;
    logic        accepted;
    logic        wr;
    mem_size_t   size;
    logic [31:0] a;
    logic [3:0]  sel;
    logic [31:0] dat;
    logic        lock;
    logic [31:0] m_dr_next;
    logic        m_en;
    logic [31:0] m_dr;
  } dbus_reg_t;

  dbus_reg_t q, d;

  // big-endian byte enables for an access of 'size' at 'a'
  function automatic logic [3:0] be(mem_size_t sz, logic [1:0] a);
    unique case (sz)
      SZ_LONG: return 4'b1111;
      SZ_WORD: return a[1] ? 4'b0011 : 4'b1100;
      default: return 4'b1000 >> a;
    endcase
  endfunction

  function automatic logic [31:0] wdata_lanes(mem_size_t sz, logic [31:0] v);
    unique case (sz)
      SZ_LONG: return v;
      SZ_WORD: return {v[15:0], v[15:0]};
      default: return {4{v[7:0]}};
    endcase
  endfunction

  function automatic logic [31:0] align_read(logic [31:0] v, logic [1:0] a, mem_size_t sz);
    unique case (sz)
      SZ_BYTE: unique case (a)
        2'b00:   return {{24{v[31]}}, v[31:24]};
        2'b01:   return {{24{v[23]}}, v[23:16]};
        2'b10:   return {{24{v[15]}}, v[15:8]};
        default: return {{24{v[7]}},  v[7:0]};
      endcase
      SZ_WORD: return a[1] ? {{16{v[15]}}, v[15:0]} : {{16{v[31]}}, v[31:16]};
      default: return v;
    endcase
  endfunction

  logic done;
  assign done = q.pending && (wb_i.ack || wb_i.err);
  assign busy = q.pending && !done;

  always_comb begin
    d = q;
    // request accepted by the slave
    if (q.pending && !q.accepted && !wb_i.stall) d.accepted = 1'b1;
    // access completed
    if (done) begin
      d.m_dr_next = align_read(wb_i.err ? 32'h0 : wb_i.dat, q.a[1:0], q.size);
      d.m_en      = 1'b1;
      d.pending   = 1'b0;
    end
    if (slot) begin
      // present data of completed reads on the W bus
      if (d.m_en) begin
        d.m_dr = d.m_dr_next;
        d.m_en = 1'b0;
      end
      // start a new access
      if (issue && !d.pending) begin
        d.pending  = 1'b1;
        d.accepted = 1'b0;
        d.wr       = wr;
        d.size     = size;
        d.a        = addr;
        d.sel      = be(size, addr[1:0]);
        d.dat      = wr ? wdata_lanes(size, wdata) : 32'h0;
      end
      d.lock = lock;
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= '{size: SZ_BYTE, default: '0};
    else     q <= d;
  end

  assign wbus = q.m_dr;

  always_comb begin
    wb_o      = WB_M2S_IDLE;
    wb_o.cyc  = q.pending | q.lock;
    wb_o.stb  = q.pending & ~q.accepted;
    wb_o.we   = q.wr;
    wb_o.adr  = {q.a[31:2], 2'b00};
    wb_o.sel  = q.sel;
    wb_o.dat  = q.dat;
    wb_o.lock = q.lock;
  end

endmodule

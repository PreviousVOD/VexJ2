// J2 register file: 2 write ports (EX/Z and WB/W), 2 read ports + R0 port.
//
// Ported from reference/soc_top/components/cpu/core/register_file.vhd,
// architecture two_bank (the one selected by cpu_config.vhd).
//
// Both write ports write the same storage: EX-stage (Z bus) writes are delayed
// through a 2-entry pipe (ex_pipe[1], ex_pipe[2]) and committed in the WB
// stage. The decoder never schedules a Z and a W write that would commit in
// the same slot. Reads return the most recent value:
//   current W write  >  ex_pipe[1]  >  ex_pipe[2]  >  storage
// All state advances only when ce (the CPU 'slot') is high.
module j2_regfile #(
  parameter int ADDR_WIDTH = 5,
  parameter int NUM_REGS   = 21,
  parameter int REG_WIDTH  = 32
) (
  input  logic                  clk,
  input  logic                  rst,
  input  logic                  ce,

  input  logic [ADDR_WIDTH-1:0] addr_ra,
  output logic [REG_WIDTH-1:0]  dout_a,
  input  logic [ADDR_WIDTH-1:0] addr_rb,
  output logic [REG_WIDTH-1:0]  dout_b,
  output logic [REG_WIDTH-1:0]  dout_0,

  input  logic                  we_wb,
  input  logic [ADDR_WIDTH-1:0] w_addr_wb,
  input  logic [REG_WIDTH-1:0]  din_wb,

  input  logic                  we_ex,
  input  logic [ADDR_WIDTH-1:0] w_addr_ex,
  input  logic [REG_WIDTH-1:0]  din_ex,

  // data being written to storage this slot (0 when no write)
  output logic [REG_WIDTH-1:0]  wr_data_o
);

  typedef struct packed {
    logic                  en;
    logic [REG_WIDTH-1:0]  data;
    logic [ADDR_WIDTH-1:0] addr;
  } reg_pipe_t;

  localparam logic [ADDR_WIDTH-1:0] ZERO_ADDR = '0;

  // Storage. Not reset (the VHDL banks are not reset either); R0 has a
  // separate, reset copy that feeds dout_0.
  logic [REG_WIDTH-1:0] bank [NUM_REGS];
  logic [REG_WIDTH-1:0] reg0;

  reg_pipe_t wb_pipe, ex_pipe0, ex_pipe1, ex_pipe2;

  assign wb_pipe  = '{en: we_wb, data: din_wb, addr: w_addr_wb};
  assign ex_pipe0 = '{en: we_ex, data: din_ex, addr: w_addr_ex};

  // Out-of-range register numbers alias register 0 (VHDL to_reg_index).
  function automatic int unsigned reg_index(logic [ADDR_WIDTH-1:0] a);
    return (int'(a) < NUM_REGS) ? int'(a) : 0;
  endfunction

  function automatic logic [REG_WIDTH-1:0] read_fwd(logic [ADDR_WIDTH-1:0] a,
                                                    logic [REG_WIDTH-1:0] stored);
    if (wb_pipe.en && wb_pipe.addr == a)   return wb_pipe.data;
    if (ex_pipe1.en && ex_pipe1.addr == a) return ex_pipe1.data;
    if (ex_pipe2.en && ex_pipe2.addr == a) return ex_pipe2.data;
    return stored;
  endfunction

  assign dout_a = read_fwd(addr_ra, bank[reg_index(addr_ra)]);
  assign dout_b = read_fwd(addr_rb, bank[reg_index(addr_rb)]);
  assign dout_0 = read_fwd(ZERO_ADDR, reg0);

  // Commit: an EX write leaving the pipe has priority over a WB write (they
  // never coincide in correct operation).
  // Storage is not written while reset is asserted (as in the original).
  logic                  wr_en;
  logic [ADDR_WIDTH-1:0] wr_addr;
  logic [REG_WIDTH-1:0]  wr_data;
  int unsigned           wr_idx;
  always_comb begin
    wr_en   = wb_pipe.en | ex_pipe2.en;
    wr_addr = ex_pipe2.en ? ex_pipe2.addr : wb_pipe.addr;
    wr_data = ex_pipe2.en ? ex_pipe2.data : wb_pipe.data;
    wr_idx  = reg_index(wr_addr);
  end

  /* verilator lint_off SYNCASYNCNET */
  always_ff @(posedge clk) begin
    if (!rst && ce && wr_en)
      bank[wr_idx] <= wr_data;
  end
  /* verilator lint_on SYNCASYNCNET */

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_data_o <= '0;
      reg0      <= '0;
      ex_pipe1  <= '0;
      ex_pipe2  <= '0;
    end else if (ce) begin
      wr_data_o <= wr_en ? wr_data : '0;
      if (wr_en && wr_idx == 0)
        reg0 <= wr_data;
      ex_pipe2 <= ex_pipe1;
      ex_pipe1 <= ex_pipe0;
    end
  end

`ifndef SYNTHESIS
  // The decoder must never schedule Z and W writes that commit together.
  always_ff @(posedge clk)
    if (!rst && ce && wb_pipe.en && ex_pipe2.en)
      $warning("j2_regfile: write clash (W r%0d, Z r%0d)", wb_pipe.addr, ex_pipe2.addr);
`endif

endmodule

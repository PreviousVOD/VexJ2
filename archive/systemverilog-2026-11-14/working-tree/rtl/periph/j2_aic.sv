// J-Core AIC (interrupt/event, PIT, RTC and breakpoint control), ported from
// reference/soc_top/components/misc/aic.vhd.
//
// The register map below is expressed in adr[5:2], matching the original:
//   0: PIT/test controls, count and breakpoint enable
//   1: breakpoint address
//   2: interrupt priority levels, irq 7 in the high nibble
//   3: irq input/latched irq/debug status
//   4,5: PIT throttle/counter
//   6: bus clock period in ns
//   8,b: RTC seconds, 9/a: RTC ns + sec low
//
// irq_i(0) is the highest priority at equal programmed levels.
module j2_aic
  import j2_cpu_pkg::*;
  import j2_wb_pkg::*;
#(
  parameter int BUS_PERIOD_NS = 20,
  parameter logic [7:0] VECTOR_NUMBERS [8] = '{
    8'h00, 8'h12, 8'h00, 8'h14, 8'h15, 8'h00, 8'h00, 8'h00
  }
) (
  input  logic        clk,
  input  logic        rst,
  /* verilator lint_off UNUSEDSIGNAL */  // lock, tgc
  input  wb_m2s_t     wb_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t     wb_o,
  input  logic        bus_stb,
  input  logic        bus_ack,
  output logic [63:0] rtc_sec,
  output logic [31:0] rtc_nsec,
  input  logic [7:0]  irq_i,
  input  logic        enmi_i,
  /* verilator lint_off UNUSEDSIGNAL */  // only ack is used
  input  cpu_event_o_t event_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output cpu_event_i_t event_o
);
  localparam logic [2:0] EVENT_NMI  = 3'b001;
  localparam logic [2:0] EVENT_IRQ  = 3'b000;
  localparam logic [2:0] EVENT_CER  = 3'b010;
  localparam logic [2:0] EVENT_DER  = 3'b011;
  localparam logic [2:0] EVENT_MRES = 3'b110;
  localparam logic [2:0] EVENT_NEVT = 3'b111;

  typedef enum logic [1:0] {V_IDLE, V_INT, V_DLY_CHECK, V_CHECK} vstate_t;
  typedef enum logic {DB_INIT, DB_INT} dbstate_t;

  logic [7:0] q_irqs, edge_en, edge_clr;
  logic       reg0 [8], reg1 [8];

  logic [24:0] reg_event;
  logic [24:0] next_event;
  logic        ack_q;
  logic [31:0] rdata_q;
  logic        s_enmi, s_eirq, s_eirq2, s_cer, s_der, s_mrs, w_wctrl, w_enmi;
  logic        w_cer1, w_cer2, w_cer3;
  logic [11:0] testvect;
  logic        count_enable, pit_enable, brk_enable, pit_event;
  logic [11:0] count;
  logic [31:0] brkadr;
  logic        r_nmi, r_irq1, r_irq10, r_cpuerr, r_dmaerr, r_mrst;
  logic [31:0] w_debug, w_pitout, w_rtcout;
  logic [31:0] pit_cntr, pit_throttle;
  logic [63:0] reg_rtc_sec;
  logic [31:0] reg_rtc_nsec;
  logic [7:0]  es_irqs, ec_irqs;
  logic [3:0]  ilevel [8];
  logic        qq_irqs;
  logic        vnmi;
  logic [20:0] vcount;
  vstate_t     vstate;
  dbstate_t    db_state, da_state;
  logic [3:0]  db_count;
  logic [10:0] db_ackcount;
  logic        pit_flag;
  logic [2:0]  event_req;
  logic [11:0] event_info;
  logic        req;

  assign rtc_sec  = reg_rtc_sec;
  assign rtc_nsec = reg_rtc_nsec;
  assign req      = wb_i.cyc && wb_i.stb;

  // Interrupt edge detectors.
  generate
    for (genvar i = 0; i < 8; i++) begin : g_edge
      always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
          reg0[i] <= 1'b0;
          reg1[i] <= 1'b0;
          q_irqs[i] <= 1'b0;
        end else begin
          reg0[i] <= irq_i[i];
          reg1[i] <= reg0[i];
          if (reg1[i] == 1'b0 && reg0[i] == 1'b1)
            q_irqs[i] <= edge_en[i];
          else if (edge_clr[i])
            q_irqs[i] <= 1'b0;
        end
      end
    end
  endgenerate

  always_comb begin
    for (int i = 0; i < 8; i++)
      es_irqs[i] = |ilevel[i];
    qq_irqs = |q_irqs;
  end
  assign edge_en  = es_irqs;
  assign edge_clr = ec_irqs;

  // RTC.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      reg_rtc_sec  <= '0;
      reg_rtc_nsec <= '0;
    end else begin
      if (reg_rtc_nsec >= 32'd1_000_000_000) begin
        reg_rtc_nsec <= 32'd1_000_000_000 - 32'(1_000_000_000 - BUS_PERIOD_NS);
        reg_rtc_sec  <= reg_rtc_sec + 1'b1;
      end else begin
        reg_rtc_nsec <= reg_rtc_nsec + 32'(BUS_PERIOD_NS);
      end
      if (req && wb_i.we && wb_i.adr[5]) begin
        unique case (wb_i.adr[3:2])
          2'b00: reg_rtc_sec[63:32] <= wb_i.dat;
          2'b01: reg_rtc_sec[31:0]  <= wb_i.dat;
          2'b10: reg_rtc_nsec       <= wb_i.dat;
          default: ;
        endcase
      end
    end
  end

  // Debug state counters.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      db_count    <= '0;
      db_state    <= DB_INIT;
      da_state    <= DB_INIT;
      db_ackcount <= '0;
    end else begin
      db_ackcount <= '1;
      unique case (db_state)
        DB_INIT: if (q_irqs[6]) begin
          db_state <= DB_INT;
          db_count <= db_count + 1'b1;
        end
        default: if (!q_irqs[6]) db_state <= DB_INIT;
      endcase
      unique case (da_state)
        DB_INIT: if (event_i.ack) da_state <= DB_INT;
        default: if (!event_i.ack) da_state <= DB_INIT;
      endcase
    end
  end

  // Interrupt priority scan and event selection.
  always_comb begin
    int   high_i;
    logic [3:0] high_level;
    logic [7:0] irq_id;
    high_i     = 0;
    high_level = '0;
    for (int i = 0; i < 8; i++) begin
      if (q_irqs[i] && ilevel[i] > high_level) begin
        high_level = ilevel[i];
        high_i     = i;
      end
    end
    irq_id = 8'h01 << high_i;

    if (r_mrst)
      next_event = {8'h00, 2'b00, EVENT_MRES, 12'hf02};
    else if (r_dmaerr)
      next_event = {8'h00, 2'b00, EVENT_DER, 12'hf0a};
    else if (r_cpuerr)
      next_event = {8'h00, 2'b00, EVENT_CER, 12'hf09};
    else if (r_nmi)
      next_event = {10'h001, EVENT_NMI, 12'hf0b};
    else if (r_irq1)
      next_event = {10'h001, EVENT_IRQ, testvect};
    else if (qq_irqs)
      next_event = {1'b0, irq_id, 1'b0, EVENT_IRQ, ilevel[high_i],
                    VECTOR_NUMBERS[high_i]};
    else if (r_irq10)
      next_event = {10'h200, EVENT_IRQ, 12'h319};
    else
      next_event = {8'h00, 2'b00, EVENT_NEVT, 12'hf18};
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) reg_event <= {9'b0, 1'b0, 3'b111, 12'hf18};
    else     reg_event <= next_event;
  end

  assign event_req  = reg_event[14:12];
  assign event_info = reg_event[11:0];

  always_comb begin
    event_o.en  = event_req != EVENT_NEVT;
    unique case (event_req)
      EVENT_IRQ, EVENT_NMI: event_o.cmd = EV_INTERRUPT;
      EVENT_CER, EVENT_DER: event_o.cmd = EV_ERROR;
      3'b100:               event_o.cmd = EV_BREAK;
      default:              event_o.cmd = EV_RESET_CPU;
    endcase
    event_o.msk = event_req != EVENT_IRQ;
    event_o.lvl = event_info[11:8];
    event_o.vec = event_info[7:0];
  end

  // Read registers.
  always_comb begin
    w_debug = wb_i.adr[2] ?
      {irq_i, q_irqs, pit_flag, db_ackcount, db_count} :
      {ilevel[7], ilevel[6], ilevel[5], ilevel[4],
       ilevel[3], ilevel[2], ilevel[1], ilevel[0]};
    if (wb_i.adr[3:2] == 2'b11)
      w_pitout = '0;
    else if (wb_i.adr[3])
      w_pitout = 32'(BUS_PERIOD_NS);
    else
      w_pitout = wb_i.adr[2] ? pit_cntr : pit_throttle;
    unique case (wb_i.adr[3:2])
      2'b00: w_rtcout = reg_rtc_sec[63:32];
      2'b01: w_rtcout = reg_rtc_sec[31:0];
      2'b10: w_rtcout = reg_rtc_nsec;
      default: w_rtcout = '0;
    endcase
  end

  always_comb begin
    if (wb_i.adr[5])
      rdata_q = w_rtcout;
    else if (wb_i.adr[4])
      rdata_q = w_pitout;
    else if (wb_i.adr[3])
      rdata_q = w_debug;
    else if (!wb_i.adr[2])
      rdata_q = {5'b0, pit_enable, count_enable, brk_enable,
                 testvect, count};
    else
      rdata_q = brkadr;
  end

  assign pit_event = pit_cntr == pit_throttle;

  // Control/status write path.
  assign w_wctrl = req && wb_i.we && wb_i.adr[5:2] == 4'b0000 && wb_i.sel[3];
  assign s_mrs   = w_wctrl && wb_i.dat[27];
  assign s_der   = w_wctrl && wb_i.dat[28];
  assign w_cer1  = bus_stb && wb_i.sel == 4'b1100 && bus_ack && wb_i.adr[1];
  assign w_cer2  = bus_stb && wb_i.sel == 4'b0011 && bus_ack && !wb_i.adr[1];
  assign w_cer3  = bus_stb && &wb_i.sel && bus_ack &&
                   (wb_i.adr[0] || wb_i.adr[1]);
  assign s_cer   = (w_wctrl && wb_i.dat[29]) || w_cer1 || w_cer2 || w_cer3;
  assign s_eirq  = (w_wctrl && wb_i.dat[30]) || pit_event;
  assign s_eirq2 = count_enable && count == '0;
  assign w_enmi  = brk_enable && bus_stb && bus_ack && wb_i.adr == brkadr;
  assign s_enmi  = (w_wctrl && wb_i.dat[31]) || w_enmi || vnmi;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      brkadr        <= '0;
      pit_enable    <= 1'b0;
      pit_cntr      <= '0;
      pit_throttle  <= 32'(1_000_000_000 / 100 / BUS_PERIOD_NS);
      count_enable  <= 1'b0;
      count         <= '1;
      brk_enable    <= 1'b0;
      ack_q         <= 1'b0;
      r_nmi         <= 1'b0;
      r_irq1        <= 1'b0;
      r_irq10       <= 1'b0;
      r_cpuerr      <= 1'b0;
      r_dmaerr      <= 1'b0;
      r_mrst        <= 1'b0;
      testvect      <= '0;
      ec_irqs       <= '1;
      pit_flag      <= 1'b0;
      for (int i = 0; i < 8; i++) ilevel[i] <= '0;
    end else begin
      ack_q <= req;
      if (req && wb_i.we && !wb_i.adr[5]) begin
        if (!wb_i.adr[4]) begin
          if (!wb_i.adr[3]) begin
            if (!wb_i.adr[2]) begin
              if (!pit_enable) testvect <= wb_i.dat[23:12];
              brk_enable   <= wb_i.dat[24];
              count_enable <= wb_i.dat[25];
              pit_enable   <= wb_i.dat[26];
              count        <= wb_i.dat[11:0];
            end else begin
              brkadr <= wb_i.dat;
            end
          end else if (!wb_i.adr[2]) begin
            ilevel[7] <= wb_i.dat[31:28];
            ilevel[6] <= wb_i.dat[27:24];
            ilevel[5] <= wb_i.dat[23:20];
            ilevel[4] <= wb_i.dat[19:16];
            ilevel[3] <= wb_i.dat[15:12];
            ilevel[2] <= wb_i.dat[11:8];
            ilevel[1] <= wb_i.dat[7:4];
            ilevel[0] <= wb_i.dat[3:0];
          end
        end else if (wb_i.adr[3:2] == 2'b00 && !pit_enable) begin
          pit_throttle <= wb_i.dat;
        end
      end

      if (count_enable) count <= count - 1'b1;
      if (pit_enable) begin
        if (pit_event) begin
          pit_cntr <= '0;
          pit_flag <= ~pit_flag;
        end else begin
          pit_cntr <= pit_cntr + 1'b1;
        end
      end else begin
        pit_cntr <= '0;
      end

      if (s_mrs)  r_mrst   <= 1'b1;
      if (s_cer)  r_cpuerr <= 1'b1;
      if (s_der)  r_dmaerr <= 1'b1;
      if (s_eirq) r_irq1   <= 1'b1;
      if (s_eirq2) r_irq10 <= 1'b1;
      if (s_enmi) r_nmi    <= 1'b1;

      if (event_i.ack) begin
        ec_irqs <= '0;
        if (event_req == EVENT_MRES)
          r_mrst <= 1'b0;
        else if (event_req == EVENT_CER)
          r_cpuerr <= 1'b0;
        else if (event_req == EVENT_DER)
          r_dmaerr <= 1'b0;
        else if (event_req == EVENT_NMI)
          r_nmi <= 1'b0;
        else if (event_req == EVENT_IRQ) begin
          if (reg_event[15])
            r_irq1 <= 1'b0;
          else if (reg_event[24])
            r_irq10 <= 1'b0;
        end
        ec_irqs <= reg_event[23:16];
      end else begin
        ec_irqs <= '0;
      end
    end
  end

  // The original board drives enmi_i high.  This state machine retains the
  // Vlad NMI test hook: one low pulse generates NMI.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      vstate <= V_IDLE;
      vnmi   <= 1'b0;
      vcount <= '0;
    end else begin
      unique case (vstate)
        V_IDLE: if (!enmi_i) begin
          vstate <= V_INT;
          vnmi   <= 1'b1;
        end
        V_INT: begin
          vnmi   <= 1'b0;
          vstate <= V_DLY_CHECK;
          vcount <= '0;
        end
        V_DLY_CHECK: if (vcount > 21'h1312d0) vstate <= V_CHECK;
                     else                    vcount <= vcount + 1'b1;
        default: if (enmi_i) vstate <= V_IDLE;
                 else begin
                   vcount <= '0;
                   vstate <= V_DLY_CHECK;
                 end
      endcase
    end
  end

  assign wb_o = '{ack: ack_q, err: 1'b0, stall: 1'b0, dat: rdata_q};
endmodule

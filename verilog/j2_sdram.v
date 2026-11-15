`default_nettype none

module j2_sdram #(
  parameter CLK_HZ = 24000000,
  parameter BOOT_WAIT_CYCLES = 4800,
  parameter REFRESH_CYCLES = 360,
  parameter CAS_LATENCY = 3,
  parameter T_RCD = 1,
  parameter T_RP = 1,
  parameter T_RFC = 2,
  parameter T_MRD = 2,
  parameter T_WR = 2
) (
  input  wire        clk,
  input  wire        reset,

  input  wire        bus_cyc,
  input  wire        bus_stb,
  input  wire        bus_we,
  input  wire [3:0]  bus_sel,
  input  wire [22:0] bus_adr,
  input  wire [31:0] bus_dat_mosi,
  output wire        bus_ack,
  output wire [31:0] bus_dat_miso
);
  localparam [4:0] BOOT_WAIT = 5'd0;
  localparam [4:0] INIT_PRECHARGE = 5'd1;
  localparam [4:0] INIT_PRECHARGE_WAIT = 5'd2;
  localparam [4:0] INIT_REFRESH_1 = 5'd3;
  localparam [4:0] INIT_REFRESH_1_WAIT = 5'd4;
  localparam [4:0] INIT_REFRESH_2 = 5'd5;
  localparam [4:0] INIT_REFRESH_2_WAIT = 5'd6;
  localparam [4:0] MODE_SET = 5'd7;
  localparam [4:0] MODE_WAIT = 5'd8;
  localparam [4:0] IDLE = 5'd9;
  localparam [4:0] ACTIVATE = 5'd10;
  localparam [4:0] ACTIVATE_WAIT = 5'd11;
  localparam [4:0] READ = 5'd12;
  localparam [4:0] READ_WAIT = 5'd13;
  localparam [4:0] WRITE = 5'd14;
  localparam [4:0] WRITE_WAIT = 5'd15;
  localparam [4:0] RECOVER = 5'd16;
  localparam [4:0] ACKNOWLEDGE = 5'd17;
  localparam [4:0] REFRESH_PRECHARGE = 5'd18;
  localparam [4:0] REFRESH_PRECHARGE_WAIT = 5'd19;
  localparam [4:0] REFRESH = 5'd20;
  localparam [4:0] REFRESH_WAIT = 5'd21;

  localparam [2:0] CMD_MRS = 3'b000;
  localparam [2:0] CMD_REFRESH = 3'b001;
  localparam [2:0] CMD_PRECHARGE = 3'b010;
  localparam [2:0] CMD_ACTIVATE = 3'b011;
  localparam [2:0] CMD_WRITE = 3'b100;
  localparam [2:0] CMD_READ = 3'b101;
  localparam [2:0] CMD_NOP = 3'b111;

  reg [4:0] state;
  reg [12:0] timer;
  reg [8:0] refresh_timer;
  reg [22:0] request_address;
  reg [31:0] request_write_data;
  reg [3:0] request_write_mask;
  reg request_write;
  reg [31:0] read_data;

  reg [2:0] command;
  reg [10:0] memory_address;
  reg [1:0] memory_bank;
  reg [3:0] memory_mask;
  reg [31:0] write_data;
  reg write_enable;

  wire [31:0] memory_dq;
  wire request = bus_cyc && bus_stb;

  always @* begin
    command = CMD_NOP;
    memory_address = 11'b0;
    memory_bank = request_address[3:2];
    memory_mask = 4'b0;
    write_data = request_write_data;
    write_enable = 1'b0;
    case (state)
      INIT_PRECHARGE, REFRESH_PRECHARGE: begin
        command = CMD_PRECHARGE;
        memory_address[10] = 1'b1;
      end
      INIT_REFRESH_1, INIT_REFRESH_2, REFRESH: command = CMD_REFRESH;
      MODE_SET: begin
        command = CMD_MRS;
        memory_address = 11'h230;
      end
      ACTIVATE: begin
        command = CMD_ACTIVATE;
        memory_address = request_address[22:12];
      end
      READ: begin
        command = CMD_READ;
        memory_address = {1'b1, request_address[11:4]};
      end
      WRITE: begin
        command = CMD_WRITE;
        memory_address = {1'b1, request_address[11:4]};
        memory_mask = ~request_write_mask;
        write_enable = 1'b1;
      end
      default: begin
      end
    endcase
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= BOOT_WAIT;
      timer <= BOOT_WAIT_CYCLES;
      refresh_timer <= 0;
      request_address <= 0;
      request_write_data <= 0;
      request_write_mask <= 0;
      request_write <= 1'b0;
      read_data <= 0;
    end else begin
      if (refresh_timer != REFRESH_CYCLES - 1)
        refresh_timer <= refresh_timer + 1'b1;
      case (state)
        BOOT_WAIT: begin
          if (timer == 1) begin
            state <= INIT_PRECHARGE;
            timer <= 0;
          end else
            timer <= timer - 1'b1;
        end
        INIT_PRECHARGE: begin
          state <= INIT_PRECHARGE_WAIT;
          timer <= T_RP;
        end
        INIT_PRECHARGE_WAIT: begin
          if (timer == 1)
            state <= INIT_REFRESH_1;
          else
            timer <= timer - 1'b1;
        end
        INIT_REFRESH_1: begin
          state <= INIT_REFRESH_1_WAIT;
          timer <= T_RFC;
        end
        INIT_REFRESH_1_WAIT: begin
          if (timer == 1)
            state <= INIT_REFRESH_2;
          else
            timer <= timer - 1'b1;
        end
        INIT_REFRESH_2: begin
          state <= INIT_REFRESH_2_WAIT;
          timer <= T_RFC;
        end
        INIT_REFRESH_2_WAIT: begin
          if (timer == 1)
            state <= MODE_SET;
          else
            timer <= timer - 1'b1;
        end
        MODE_SET: begin
          state <= MODE_WAIT;
          timer <= T_MRD;
        end
        MODE_WAIT: begin
          if (timer == 1) begin
            state <= IDLE;
            refresh_timer <= 0;
          end else
            timer <= timer - 1'b1;
        end
        IDLE: begin
          if (refresh_timer == REFRESH_CYCLES - 1)
            state <= REFRESH_PRECHARGE;
          else if (request) begin
            request_address <= bus_adr;
            request_write_data <= bus_dat_mosi;
            request_write_mask <= bus_sel;
            request_write <= bus_we;
            state <= ACTIVATE;
          end
        end
        ACTIVATE: begin
          state <= ACTIVATE_WAIT;
          timer <= T_RCD;
        end
        ACTIVATE_WAIT: begin
          if (timer == 1)
            state <= request_write ? WRITE : READ;
          else
            timer <= timer - 1'b1;
        end
        READ: begin
          state <= READ_WAIT;
          timer <= CAS_LATENCY;
        end
        READ_WAIT: begin
          if (timer == 1) begin
            read_data <= memory_dq;
            state <= RECOVER;
            timer <= T_RP;
          end else
            timer <= timer - 1'b1;
        end
        WRITE: begin
          state <= WRITE_WAIT;
          timer <= T_WR;
        end
        WRITE_WAIT: begin
          if (timer == 1) begin
            state <= RECOVER;
            timer <= T_RP;
          end else
            timer <= timer - 1'b1;
        end
        RECOVER: begin
          if (timer == 1)
            state <= ACKNOWLEDGE;
          else
            timer <= timer - 1'b1;
        end
        ACKNOWLEDGE: state <= IDLE;
        REFRESH_PRECHARGE: begin
          state <= REFRESH_PRECHARGE_WAIT;
          timer <= T_RP;
        end
        REFRESH_PRECHARGE_WAIT: begin
          if (timer == 1)
            state <= REFRESH;
          else
            timer <= timer - 1'b1;
        end
        REFRESH: begin
          state <= REFRESH_WAIT;
          timer <= T_RFC;
          refresh_timer <= 0;
        end
        REFRESH_WAIT: begin
          if (timer == 1)
            state <= IDLE;
          else
            timer <= timer - 1'b1;
        end
        default: state <= BOOT_WAIT;
      endcase
    end
  end

  assign memory_dq = write_enable ? write_data : 32'bz;

  j2_sdram_phy phy (
    .clk(clk),
    .ras_n(command[2]),
    .cas_n(command[1]),
    .we_n(command[0]),
    .addr(memory_address),
    .ba(memory_bank),
    .dq(memory_dq),
    .cs_n(1'b0),
    .dm(memory_mask),
    .cke(1'b1)
  );

  assign bus_ack = state == ACKNOWLEDGE;
  assign bus_dat_miso = read_data;
endmodule

`default_nettype wire

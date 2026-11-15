`default_nettype none

module j2_spiflash (
  input  wire        clk,
  input  wire        reset,

  input  wire        ibus_cyc,
  input  wire        ibus_stb,
  input  wire [31:0] ibus_adr,
  output wire        ibus_ack,
  output wire [31:0] ibus_dat,

  input  wire        dbus_cyc,
  input  wire        dbus_stb,
  input  wire        dbus_we,
  input  wire        dbus_config,
  input  wire [31:0] dbus_adr,
  input  wire [31:0] dbus_dat_mosi,
  output wire        dbus_ack,
  output wire [31:0] dbus_dat_miso,

  output wire        spi_cs_n,
  output wire        spi_sck,
  output wire        spi_mosi,
  input  wire        spi_miso
);
  localparam IDLE = 3'd0;
  localparam COMMAND = 3'd1;
  localparam READ_DATA = 3'd2;
  localparam CONFIG_WRITE = 3'd3;
  localparam ACKNOWLEDGE = 3'd4;
  localparam COOLDOWN = 3'd5;

  reg [2:0] state;
  reg start;
  reg grant_data;
  reg grant_config;
  reg write_enable;
  reg [31:0] address;
  reg [31:0] write_data;
  reg [31:0] read_data;
  reg [7:0] config_data;
  reg cs_override;

  wire instruction_request = ibus_cyc && ibus_stb;
  wire data_request = dbus_cyc && dbus_stb;
  wire [31:0] flash_word;
  wire flash_valid;
  wire flash_busy;
  wire flash_cs_n;
  wire flash_sck;
  wire [1:0] flash_mode;
  wire [3:0] flash_out;
  wire [3:0] flash_in = {2'b11, spi_miso, 1'b0};

  wire [31:0] transfer_word = state == COMMAND ? {8'h03, address[23:2], 2'b00} :
                              state == CONFIG_WRITE ? {write_data[7:0], 24'b0} : 32'b0;
  wire [1:0] transfer_length = state == COMMAND ? 2'd3 :
                               state == READ_DATA ? 2'd3 : 2'd0;
  wire transfer_direction = state != READ_DATA;
  wire transfer_hold = state == COMMAND || (grant_config && !cs_override);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      start <= 1'b0;
      grant_data <= 1'b0;
      grant_config <= 1'b0;
      write_enable <= 1'b0;
      address <= 32'b0;
      write_data <= 32'b0;
      read_data <= 32'b0;
      config_data <= 32'b0;
      cs_override <= 1'b1;
    end else begin
      start <= 1'b0;
      case (state)
        IDLE: begin
          if (data_request) begin
            grant_data <= 1'b1;
            grant_config <= dbus_config;
            write_enable <= dbus_we;
            address <= dbus_config ? 32'b0 :
                       (dbus_adr - 32'h10000000) & 32'hfffffffc;
            write_data <= dbus_dat_mosi;
            if (!dbus_config) begin
              state <= COMMAND;
              start <= 1'b1;
              cs_override <= 1'b0;
            end else if (!dbus_we) begin
              state <= ACKNOWLEDGE;
            end else if (dbus_dat_mosi[8]) begin
              cs_override <= 1'b1;
              state <= ACKNOWLEDGE;
            end else begin
              state <= CONFIG_WRITE;
              start <= 1'b1;
              cs_override <= 1'b0;
            end
          end else if (instruction_request) begin
            grant_data <= 1'b0;
            grant_config <= 1'b0;
            write_enable <= 1'b0;
            address <= ibus_adr - 32'h10000000;
            write_data <= 32'b0;
            state <= COMMAND;
            start <= 1'b1;
            cs_override <= 1'b0;
          end
        end
        COMMAND: begin
          if (flash_valid) begin
            state <= READ_DATA;
            start <= 1'b1;
          end
        end
        READ_DATA: begin
          if (flash_valid) begin
            read_data <= flash_word;
            state <= ACKNOWLEDGE;
          end
        end
        CONFIG_WRITE: begin
          if (flash_valid) begin
            config_data <= flash_word[7:0];
            state <= ACKNOWLEDGE;
          end
        end
        ACKNOWLEDGE: state <= COOLDOWN;
        COOLDOWN: state <= IDLE;
        default: state <= IDLE;
      endcase
    end
  end

  llqspi flash (
    .i_clk(clk),
    .i_wr(start),
    .i_hold(transfer_hold),
    .i_word(transfer_word),
    .i_len(transfer_length),
    .i_spd(1'b0),
    .i_dir(transfer_direction),
    .o_word(flash_word),
    .o_valid(flash_valid),
    .o_busy(flash_busy),
    .o_sck(flash_sck),
    .o_cs_n(flash_cs_n),
    .o_mod(flash_mode),
    .o_dat(flash_out),
    .i_dat(flash_in)
  );

  wire [15:0] instruction_half = address[1] ? read_data[15:0] : read_data[31:16];
  assign spi_cs_n = cs_override ? 1'b1 : flash_cs_n;
  assign spi_sck = flash_sck;
  assign spi_mosi = flash_out[0];
  assign ibus_ack = state == ACKNOWLEDGE && !grant_data;
  assign ibus_dat = {16'b0, instruction_half};
  assign dbus_ack = state == ACKNOWLEDGE && grant_data;
  assign dbus_dat_miso = grant_config ? {24'b0, config_data} : read_data;
endmodule

`default_nettype wire

library ieee;
use ieee.std_logic_1164.all;

entity j2_microcode_rom is
  port (
    clk  : in  std_logic;
    addr : in  std_logic_vector(7 downto 0);
    dout : out std_logic_vector(71 downto 0)
  );
end entity;

architecture rtl of j2_microcode_rom is
  component EG_LOGIC_BRAM is
    generic (
      DATA_WIDTH_A : integer := 9;
      DATA_WIDTH_B : integer := 9;
      ADDR_WIDTH_A : integer := 10;
      ADDR_WIDTH_B : integer := 10;
      DATA_DEPTH_A : integer := 1024;
      DATA_DEPTH_B : integer := 1024;
      BYTE_ENABLE  : integer := 0;
      BYTE_A       : integer := 1;
      BYTE_B       : integer := 1;
      MODE         : string := "SP";
      REGMODE_A    : string := "NOREG";
      REGMODE_B    : string := "NOREG";
      WRITEMODE_A  : string := "NORMAL";
      WRITEMODE_B  : string := "NORMAL";
      RESETMODE    : string := "SYNC";
      DEBUGGABLE   : string := "NO";
      PACKABLE     : string := "NO";
      FORCE_KEEP   : string := "OFF";
      INIT_FILE    : string := "microcode.mif";
      FILL_ALL     : string := "NONE";
      IMPLEMENT    : string := "32K"
    );
    port (
      dia  : in  std_logic_vector(DATA_WIDTH_A-1 downto 0);
      addra: in  std_logic_vector(ADDR_WIDTH_A-1 downto 0);
      cea  : in  std_logic;
      ocea : in  std_logic;
      clka : in  std_logic;
      wea  : in  std_logic;
      rsta : in  std_logic;
      bea  : in  std_logic_vector(BYTE_A-1 downto 0);
      dib  : in  std_logic_vector(DATA_WIDTH_B-1 downto 0);
      addrb: in  std_logic_vector(ADDR_WIDTH_B-1 downto 0);
      ceb  : in  std_logic;
      oceb : in  std_logic;
      clkb : in  std_logic;
      web  : in  std_logic;
      rstb : in  std_logic;
      beb  : in  std_logic_vector(BYTE_B-1 downto 0);
      doa  : out std_logic_vector(DATA_WIDTH_A-1 downto 0);
      dob  : out std_logic_vector(DATA_WIDTH_B-1 downto 0)
    );
  end component;

  signal rom_clk : std_logic;
  signal unused_b : std_logic_vector(71 downto 0);
begin
  -- Preserve the reference decoder's falling-edge ROM timing.
  rom_clk <= not clk;

  rom : EG_LOGIC_BRAM
    generic map (
      DATA_WIDTH_A => 72,
      DATA_WIDTH_B => 72,
      ADDR_WIDTH_A => 8,
      ADDR_WIDTH_B => 8,
      DATA_DEPTH_A => 256,
      DATA_DEPTH_B => 256,
      MODE => "SP",
      REGMODE_A => "NOREG",
      REGMODE_B => "NOREG",
      WRITEMODE_A => "NORMAL",
      WRITEMODE_B => "NORMAL",
      INIT_FILE => "microcode.mif",
      IMPLEMENT => "32K"
    )
    port map (
      dia => (others => '0'),
      addra => addr,
      cea => '1',
      ocea => '0',
      clka => rom_clk,
      wea => '0',
      rsta => '0',
      bea => (others => '0'),
      dib => (others => '0'),
      addrb => (others => '0'),
      ceb => '0',
      oceb => '0',
      clkb => rom_clk,
      web => '0',
      rstb => '0',
      beb => (others => '0'),
      doa => dout,
      dob => unused_b
    );
end architecture;

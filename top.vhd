library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity top is
  port (
    clk : in std_logic;
    rst : in std_logic);
end entity;

architecture top_arch of top is
  signal reg1_out, reg2_out : std_logic_vector(15 downto 0);
  signal reg1_sel, reg2_sel : natural range 0 to 7;

  component pipeline is
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      reg1     : in  std_logic_vector(15 downto 0);
      reg2     : in  std_logic_vector(15 downto 0);
      reg1_sel : out natural range 0 to 7;
      reg2_sel : out natural range 0 to 7);
  end component;

  component reg_file is
    port (
      clk      : in  std_logic;
      rst      : in  std_logic_vector(7 downto 0);
      we       : in  std_logic;            -- do you want to write to anything
      we_sel   : in  natural range 0 to 7; -- what do you want to write to
      reg_sel1 : in  natural range 0 to 7;
      reg_sel2 : in  natural range 0 to 7;
      input    : in  std_logic_vector(15 downto 0);
      o1       : out std_logic_vector(15 downto 0);
      o2       : out std_logic_vector(15 downto 0)); -- select which registers to write to
  end component;
begin
  c_PIPELINE: pipeline
    port map (
      clk      => clk,
      rst      => rst,
      reg1     => reg1_out,
      reg2     => reg2_out,
      reg1_sel => reg1_sel,
      reg2_sel => reg2_sel
    );

  c_REG_FILE: reg_file
    port map (
      clk      => clk,
      rst      =>(others => rst),
      we       => '0',
      we_sel   => 0,
      reg_sel1 => reg1_sel,
      reg_sel2 => reg2_sel,
      input    =>(others => '0'),
      o1       => reg1_out,
      o2       => reg2_out
    );
end architecture;

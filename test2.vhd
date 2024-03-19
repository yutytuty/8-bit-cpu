library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity test2 is
  port (
    key0 : in  std_logic;
    key1 : in  std_logic;
    sw   : in  std_logic_vector(3 downto 0);
    led  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture behave of test2 is
  component IF_stage is
    port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      -- increment pc by 1.5 instead of 1. Set if previous was I-type instruction (by ID stage).
      previous_was_i_type : in  std_logic;
      inst                : out std_logic_vector(15 downto 0) := (others => '0');
      extra_8             : out std_logic_vector(7 downto 0)  := (others => '0');
      debug               : out std_logic_vector(7 downto 0));
  end component;
  signal clk, rst : std_logic;
  signal IR       : std_logic_vector(15 downto 0);
  signal extra_8  : std_logic_vector(7 downto 0);
  signal debug    : std_logic_vector(7 downto 0);
begin
  clk <= key1;
  rst <= not key0;

  c_IF_STAGE: IF_stage
    port map (
      clk                 => clk,
      rst                 => rst,
      previous_was_i_type => sw(0),
      inst                => IR,
      extra_8             => extra_8,
      debug               => debug
    );

  --led(3 downto 0) <= IR(3 downto 0);
  --led(7 downto 4) <= debug(3 downto 0);
  led <= IR(7 downto 0);
end architecture;

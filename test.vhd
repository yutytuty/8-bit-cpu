library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity test is
  port (
    key0 : in  std_logic;
    key1 : in  std_logic;
    sw   : in  std_logic_vector(3 downto 0);
    led  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture behave of test is
  component pcu is
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      inc_1andhalf : in  std_logic;
      o            : out std_logic_vector(15 downto 0);
      extra_8      : out std_logic_vector(7 downto 0);
      debug        : out std_logic_vector(15 downto 0));
  end component;

  signal clk, rst : std_logic;
  signal pcu_o    : std_logic_vector(15 downto 0);
  signal extra_8  : std_logic_vector(7 downto 0);
  signal debug    : std_logic_vector(15 downto 0);
begin
  clk <= key1;
  rst <= not key0;

  c_PCU: pcu
    port map (
      clk          => clk,
      rst          => rst,
      inc_1andhalf => sw(0),
      o            => pcu_o,
      extra_8      => extra_8,
      debug        => debug
    );

  led <= pcu_o(7 downto 0);
  --led <= debug(7 downto 0);
  --led <= (0 => debug, others => '0');
end architecture;

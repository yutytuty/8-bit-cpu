library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pcu_tb is
end entity;

architecture behavior of pcu_tb is
  signal clk          : std_logic := '0';
  signal rst          : std_logic := '0';
  signal inc_1andhalf : std_logic := '0';
  signal o            : std_logic_vector(15 downto 0);
  signal extra_8      : std_logic_vector(7 downto 0);

  component pcu
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      inc_1andhalf : in  std_logic;
      o            : out std_logic_vector(15 downto 0);
      extra_8      : out std_logic_vector(7 downto 0)
    );
  end component;
begin
  uut: pcu
    port map (
      clk          => clk,
      rst          => rst,
      inc_1andhalf => inc_1andhalf,
      o            => o,
      extra_8      => extra_8
    );

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;

  process
  begin
    rst <= '1';
    wait for 2 ns;
    rst <= '0';
    wait for 4 ns;
    inc_1andhalf <= '1';
    wait for 4 ns;
    inc_1andhalf <= '0';
    wait for 4 ns;
    wait;
  end process;
end architecture;

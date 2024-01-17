library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity top_tb is
end entity;

architecture top_tb_arch of top_tb is
  component top is
    port (
      clk : in std_logic;
      rst : in std_logic);
  end component;
  signal clk : std_logic;
  signal rst : std_logic;
begin
  uut: top
    port map (
      clk => clk,
      rst => rst
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
    wait;
  end process;
end architecture;

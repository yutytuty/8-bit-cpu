library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity counter_tb is
end entity;

architecture counter_tb_arch of counter_tb is
  component counter is
    port (clk : in  std_logic;
          rst : in  std_logic;
          o   : out std_logic_vector(1 downto 0));
  end component;
  signal clk : std_logic;
  signal rst : std_logic;
  signal o   : std_logic_vector(1 downto 0);
begin
  uut: counter
    port map (
      clk => clk,
      rst => rst,
      o   => o
    );

  process
  begin
    clk <= '0';
    wait for 1 ps;
    clk <= '1';
    wait for 1 ps;
  end process;

  process
  begin
    rst <= '1';
    wait for 5 ps;
    rst <= '0';
    wait for 15 ps;
  end process;
end architecture;

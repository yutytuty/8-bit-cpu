library ieee;
  use ieee.std_logic_1164.all;

entity cpu_tb is
end entity;

architecture cpu_tb_arch of cpu_tb is
  signal clk, rst : std_logic := '0';
begin
  uut: entity work.cpu
    port map (
      clk           => clk,
      rst           => rst,
      ps2_in        => '0',
      ps2_clk       => '0',
      debug_reg_sel => 0,
      word_selector => '0',
      debug_o       => open
    );

  clk_process: process
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

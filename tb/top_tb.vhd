library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity top_tb is
end entity;

architecture top_tb_arch of top_tb is
  component top is
    port (
      clk  : in std_logic;
      rst  : in std_logic;
      inst : in std_logic_Vector(10 downto 0));
  end component;
  signal clk  : std_logic;
  signal rst  : std_logic;
  signal inst : std_logic_vector(10 downto 0);
begin
  uut: top
    port map (
      clk, rst, inst
    );

  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;

  process
  begin
    rst <= '0';
    wait for 2 ns;
    rst <= '0';
    inst <= "00010000001"; -- add ra, rb
    wait for 4 ns;
    inst <= "00000001000"; -- mov rb, ra 
    wait for 4 ns;
    inst <= "00000000000"; -- mov ra, ra
    wait;
  end process;
end architecture;

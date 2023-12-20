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
    -- Fibonacci sequence
    -- add ar, br  :  00010000001
    -- mov cr, br  :  00000010001
    -- mov br, ar  :  00000001000
    -- mov ar, cr  :  00000000010
    rst <= '0';
    wait for 4 ns;
    -- inst <= "00010000001";
    -- wait for 6 ns;
    -- inst <= "00000010001";
    -- wait for 4 ns;
    -- inst <= "00000001000";
    -- wait for 4 ns;
    -- inst <= "00000000010";
    -- wait for 4 ns;
    -- inst <= "00010000001";
    -- wait for 6 ns;
    -- inst <= "00000010001";
    -- wait for 4 ns;
    -- inst <= "00000001000";
    -- wait for 4 ns;
    -- inst <= "00000000010";
    -- wait for 4 ns;
    -- inst <= "00010000001";
    -- wait for 6 ns;
    -- inst <= "00000010001";
    -- wait for 4 ns;
    -- inst <= "00000001000";
    -- wait for 4 ns;
    -- inst <= "00000000010";
    -- wait for 4 ns;
    -- inst <= "00010000001";
    -- wait for 6 ns;
    -- inst <= "00000010001";
    -- wait for 4 ns;
    -- inst <= "00000001000";
    -- wait for 4 ns;
    -- inst <= "00000000010";
    -- wait for 4 ns;
    -- inst <= "00010000001";
    -- wait for 6 ns;
    -- inst <= "00000010001";
    -- wait for 4 ns;
    -- inst <= "00000001000";
    -- wait for 4 ns;
    -- inst <= "00000000010";
    -- wait for 4 ns;
    inst <= "01100000000";
    wait;
  end process;
end architecture;

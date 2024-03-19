library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity top is
  port
  (
    clk_50 : in std_logic;
    key0   : in std_logic;
    key1   : in std_logic;
    sw     : in std_logic_vector(3 downto 0);
    led    : out std_logic_vector(7 downto 0));
end entity;

architecture top_arch of top is
  component cpu is
    port
    (
      clk           : in std_logic;
      rst           : in std_logic;
      debug_reg_sel : in natural range 0 to 7;
      debug_o       : out std_logic_vector(7 downto 0));
  end component;

  signal rst : std_logic;

  -- frequency splitter
  constant COUNT_MAX : natural                      := 50000000 / 10; -- 10hz
  signal counter     : natural range 0 to COUNT_MAX := 0;
  signal clk         : std_logic                    := '1';
begin
  rst <= not key0;

  p_frequency_splitter : process (clk_50, rst)
  begin
    if rst = '1' then
      counter <= 0;
      clk     <= '1';
    elsif rising_edge(clk_50) then
      if counter = COUNT_MAX - 1 then
        counter <= 0;
        clk     <= not clk;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  c_CPU : cpu
  port map
  (
    clk           => clk,
    rst           => rst,
    debug_reg_sel => to_integer(unsigned(sw(2 downto 0))),
    debug_o       => led
  );
end architecture;
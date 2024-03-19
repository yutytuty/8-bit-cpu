library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.STD_LOGIC_ARITH.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;
  use ieee.numeric_std.all;

entity reg_file_tb is
end entity;

architecture testbench of reg_file_tb is
  signal clk         : std_logic                    := '0';
  signal rst         : std_logic_vector(7 downto 0) := (others => '0');
  signal we          : natural range 0 to 7         := 0;
  signal oe          : natural range 0 to 7         := 0;
  signal input_data  : std_logic_vector(7 downto 0) := "00000000";
  signal output_data : std_logic_vector(7 downto 0);

  component reg_file
    port (
      clk   : in  std_logic;
      rst   : in  std_logic_vector(7 downto 0);
      we    : in  natural range 0 to 7;
      oe    : in  natural range 0 to 7;
      input : in  std_logic_vector(7 downto 0);
      o     : out std_logic_vector(7 downto 0)
    );
  end component;

begin
  uut: reg_file
    port map (
      clk   => clk,
      rst   => rst,
      we    => we,
      oe    => oe,
      input => input_data,
      o     => output_data
    );

  process
  begin
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
    wait for 1 ns;
  end process;

  stimulus: process
  begin
    rst <= "11111111";
    wait for 2 ns;
    rst <= "00000000";

    for i in 0 to 7 loop
      we <= i;
      oe <= i;
      input_data <= std_logic_vector(to_unsigned(i * 2, 8));
      wait for 2 ns;
    end loop;

    wait;
  end process;

end architecture;

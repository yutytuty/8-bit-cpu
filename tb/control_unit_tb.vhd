library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity control_unit_tb is
end entity;

architecture behave of control_unit_tb is
  component control_unit is
    port (
      inst                                   : in  std_logic_vector(10 downto 0);
      counter                                : in  std_logic_vector(1 downto 0);
      ar_load, br_load, counter_rst, add_sub : out std_logic;
      data_bus_selector_sel                  : out std_logic_vector(2 downto 0));
  end component;

  signal inst                       : std_logic_vector(10 downto 0);
  signal counter                    : std_logic_vector(1 downto 0);
  signal ar_l, br_l, c_rst, add_sub : std_logic;
  signal data_bus_selector_sel      : std_logic_vector(2 downto 0);
begin
  uut: control_unit port map (inst, counter, ar_l, br_l, c_rst, add_sub, data_bus_selector_sel);

  process
  begin
    inst <= "00000000001"; -- mov ar, br;
    counter <= "00";
    wait for 10 ns;
    counter <= "01";
    wait for 10 ns;
  end process;
end architecture;

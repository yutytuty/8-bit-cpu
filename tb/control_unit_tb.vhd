library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity control_unit_tb is
end entity;

architecture behave of control_unit_tb is
  component control_unit is
    port (
      inst                  : in  std_logic_vector(10 downto 0);
      counter               : in  std_logic_vector(1 downto 0);
      no_reg                : out std_logic; -- means no register is getting input
      reg_decoder_sel       : out std_logic_vector(2 downto 0);
      add_sub               : out std_logic;
      data_bus_selector_sel : out std_logic_vector(2 downto 0);
      done                  : out std_logic);
  end component;

  signal inst                  : std_logic_vector(10 downto 0);
  signal counter               : std_logic_vector(1 downto 0);
  signal no_reg                : std_logic;
  signal reg_decoder_sel       : std_logic_vector(2 downto 0);
  signal add_sub               : std_logic;
  signal data_bus_selector_sel : std_logic_Vector(2 downto 0);
  signal done                  : std_logic;
begin
  uut: control_unit
    port map (
      inst, counter, no_reg, reg_decoder_sel, add_sub, data_bus_selector_sel, done
    );

  process
  begin
    inst <= "00010000001"; -- add ar, br;
    counter <= "00";
    wait for 10 ns;
    counter <= "01";
    wait for 10 ns;
    wait;
  end process;
end architecture;

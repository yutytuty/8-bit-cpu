library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity top is
  port (clk : in std_logic);
end entity;

architecture top_arch of top is
  component reg8 is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      load  : in  std_logic;
      input : in  std_logic_vector(7 downto 0);
      o     : out std_logic_vector(7 downto 0)
    );
  end component;

  component data_bus_selector is
    port (
      ar, br, alu : in  std_logic_vector(7 downto 0);
      sel         : in  std_logic_vector(2 downto 0);
      o           : out std_logic_vector(7 downto 0));
  end component;

  component control_unit is
    port (
      inst                                   : in  std_logic_vector(10 downto 0);
      counter                                : in  std_logic_vector(1 downto 0);
      ar_load, br_load, counter_rst, add_sub : out std_logic;
      data_bus_selector_sel                  : out std_logic_vector(2 downto 0));
  end component;
  signal ar_rst, ar_load  : std_logic;
  signal ar_input, ar_out : std_logic_vector(7 downto 0);

begin
  c_AR: reg8
    port map (
      clk   => clk,
      rst   => ar_rst,
      load  => ar_load,
      input => ar_input,
      o     => ar_out
    );
end architecture;

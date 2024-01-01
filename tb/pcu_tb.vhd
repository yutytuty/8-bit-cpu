library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pcu_tb is
end entity;

architecture pcu_tb_arch of pcu_tb is
  component pcu
    port (
      clk       : in  std_logic;
      input     : in  std_logic_vector(7 downto 0);
      rst       : in  std_logic;
      load_h    : in  std_logic;
      load_l    : in  std_logic;
      inc       : in  std_logic;
      inst_type : in  std_logic_vector(1 downto 0);
      o         : out std_logic_vector(15 downto 0));
  end component;
  signal clk            : std_logic;
  signal data_bus       : std_logic_vector(7 downto 0);
  signal rst            : std_logic;
  signal load_h, load_l : std_logic;
  signal inc            : std_logic;
  signal inst_type      : std_logic_vector(1 downto 0);
  signal o              : std_logic_vector(15 downto 0);
begin
  uut: pcu
    port map (
      clk       => clk,
      input     => data_bus,
      rst       => rst,
      load_h    => load_h,
      load_l    => load_l,
      inc       => inc,
      inst_type => inst_type,
      o         => o
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
    rst <= '1';
    wait for 2 ns;
  end process;
end architecture;

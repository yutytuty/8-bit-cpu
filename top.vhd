library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity top is
  port (
    clk  : in std_logic;
    rst  : in std_logic;
    inst : in std_logic_Vector(10 downto 0));
end entity;

architecture top_arch of top is
  component reg8 is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      load  : in  std_logic;
      input : in  std_logic_vector(7 downto 0);
      o     : out std_logic_vector(7 downto 0));
  end component;

  component data_bus_selector is
    port (
      ar, br, cr, dr, ha, la, alu : in  std_logic_vector(7 downto 0);
      sel                         : in  std_logic_vector(2 downto 0);
      o                           : out std_logic_vector(7 downto 0));
  end component;

  component alu is
    port (
      a       : in  std_logic_vector(7 downto 0);
      b       : in  std_logic_vector(7 downto 0);
      add_sub : in  std_logic; -- add = 0 sub = 1
      o       : out std_logic_vector(7 downto 0));
  end component;

  component counter is
    port (clk : in  std_logic;
          rst : in  std_logic;
          o   : out std_logic_vector(1 downto 0));
  end component;

  component reg_decoder is
    port (
      no_out : in  std_logic;
      sel    : in  std_logic_vector(2 downto 0);
      o      : out std_logic_vector(7 downto 0));
  end component;

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

  -- register decoder
  signal no_reg          : std_logic;
  signal reg_decoder_sel : std_logic_vector(2 downto 0);

  -- AR
  signal ar_load : std_logic;
  signal ar_out  : std_logic_vector(7 downto 0);

  -- BR
  signal br_load : std_logic;
  signal br_out  : std_logic_vector(7 downto 0);

  -- CR
  signal cr_load : std_logic;
  signal cr_out  : std_logic_vector(7 downto 0);

  -- DR
  signal dr_load : std_logic;
  signal dr_out  : std_logic_vector(7 downto 0);

  -- HA
  signal ha_load : std_logic;
  signal ha_out  : std_logic_vector(7 downto 0);

  -- LA
  signal la_load : std_logic;
  signal la_out  : std_logic_vector(7 downto 0);

  -- tmp registers
  signal tmp1_load : std_logic;
  signal tmp2_load : std_logic;

  -- Counter
  signal counter_rst : std_logic;
  signal counter_o   : std_logic_vector(1 downto 0);

  -- data bus selector
  signal data_bus_selector_sel : std_logic_vector(2 downto 0);

  -- alu
  signal add_sub : std_logic;
  signal alu_o   : std_logic_vector(7 downto 0);

  -- ACC (alu)
  signal acc_out : std_logic_vector(7 downto 0);

  -- data bus
  signal data_bus : std_logic_vector(7 downto 0);
begin
  c_REG_DECODER: reg_decoder
    port map (
      no_out => no_reg,
      sel    => reg_decoder_sel,
      o(0)   => ar_load,
      o(1)   => br_load,
      o(2)   => cr_load,
      o(3)   => dr_load,
      o(4)   => ha_load,
      o(5)   => la_load,
      o(6)   => tmp1_load, -- tmp
      o(7)   => tmp2_load -- tmp
    );

  c_AR: reg8
    port map (
      clk   => clk,
      rst   => rst,
      load  => ar_load,
      input => data_bus,
      o     => ar_out
    );

  c_BR: reg8
    port map (
      clk   => clk,
      rst   => rst,
      load  => br_load,
      input => data_bus,
      o     => br_out
    );

  c_CR: reg8
    port map (
      clk   => clk,
      rst   => rst,
      load  => cr_load,
      input => data_bus,
      o     => cr_out
    );

  c_DR: reg8
    port map (
      clk   => clk,
      rst   => rst,
      load  => dr_load,
      input => data_bus,
      o     => dr_out
    );

  c_HA: reg8
    port map (
      clk   => clk,
      rst   => rst,
      load  => ha_load,
      input => data_bus,
      o     => ha_out
    );

  c_LA: reg8
    port map (
      clk   => clk,
      rst   => rst,
      load  => la_load,
      input => data_bus,
      o     => la_out
    );

  c_ALU: alu
    port map (
      a       => ar_out,
      b       => data_bus,
      add_sub => add_sub,
      o       => alu_o
    );

  c_ACC: reg8
    port map (
      clk   => clk,
      rst   => rst,
      load  => '1',
      input => alu_o,
      o     => acc_out
    );

  c_DATA_BUS_SELECTOR: data_bus_selector
    port map (
      ar  => ar_out,
      br  => br_out,
      cr  => cr_out,
      dr  => dr_out,
      ha  => ha_out,
      la  => la_out,
      alu => acc_out,
      sel => data_bus_selector_sel,
      o   => data_bus
    );

  c_COUNTER: counter
    port map (
      clk => clk,
      rst => counter_rst,
      o   => counter_o
    );

  c_CONTROL_UNIT: control_unit
    port map (
      inst                  => inst,
      counter               => counter_o,
      no_reg                => no_reg,
      reg_decoder_sel       => reg_decoder_sel,
      add_sub               => add_sub,
      data_bus_selector_sel => data_bus_selector_sel,
      done                  => counter_rst
    );

end architecture;

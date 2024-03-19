library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity id_stage_test is
  port (
    key0 : in  std_logic;
    key1 : in  std_logic;
    sw   : in  std_logic_vector(3 downto 0);
    led  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture behave of id_stage_test is

  component IF_stage is
    port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      -- increment pc by 1.5 instead of 1. Set if previous was I-type instruction (by ID stage).
      previous_was_i_type : in  std_logic;
      inst                : out std_logic_vector(15 downto 0) := (others => '0');
      extra_8             : out std_logic_vector(7 downto 0)  := (others => '0');
      debug               : out std_logic_vector(7 downto 0));
  end component;

  component ID_stage is
    port (
      clk              : in     std_logic;
      ir               : in     std_logic_vector(15 downto 0);
      extra_8          : in     std_logic_vector(7 downto 0);
      reg1             : in     std_logic_vector(15 downto 0);
      reg2             : in     std_logic_vector(15 downto 0);
      -- outputs for reg file
      reg1_sel         : buffer natural range 0 to 7;
      reg2_sel         : buffer natural range 0 to 7;
      -- outputs that go back into IF stage
      inst_was_I_type  : out    std_logic := '0';
      -- outputs for EX stage
      operand1         : out    std_logic_vector(15 downto 0);
      operand2         : out    std_logic_vector(15 downto 0);
      operand_forward1 : out    std_logic;
      operand_forward2 : out    std_logic;
      alu_func         : out    natural range 0 to 15;
      -- outputs for WB stage
      wb_reg           : buffer natural range 0 to 7;
      wb_we            : buffer std_logic := '0');
  end component;

  component reg_file is
    port (
      clk      : in  std_logic;
      rst      : in  std_logic_vector(7 downto 0);
      we       : in  std_logic;            -- do you want to write to anything
      we_sel   : in  natural range 0 to 7; -- what do you want to write to
      reg_sel1 : in  natural range 0 to 7;
      reg_sel2 : in  natural range 0 to 7;
      input    : in  std_logic_vector(15 downto 0);
      o1       : out std_logic_vector(15 downto 0);
      o2       : out std_logic_vector(15 downto 0)); -- select which registers to write to
  end component;

  signal clk, rst : std_logic;

  signal inst : std_logic_vector(15 downto 0);
  signal extra_8 : std_logic_vector(7 downto 0);

  signal reg_sel1, reg_sel2 : natural range 0 to 7;
  signal reg1_o, reg2_o : std_logic_vector(15 downto 0);
  signal previous_was_i_type : std_logic;

  signal op1, op2 : std_logic_vector(15 downto 0);
  signal op_forward1, op_forward2 : std_logic;
  signal alu_func : natural range 0 to 15;
begin
  clk <= key1;
  rst <= not key0;

  c_REG_FILE: reg_file port map (
    clk => clk,
    rst => (others => rst),
    we => '0',
    we_sel => 0,
    reg_sel1 => reg_sel1,
    reg_sel2 => reg_sel2,
    input => (others => '0'),
    o1 => reg1_o,
    o2 => reg2_o
  );

  c_IF_STAGE: IF_stage port map (
    clk => clk,
    rst => rst,
    previous_was_i_type => previous_was_i_type,
    inst => inst,
    extra_8 => extra_8,
    debug => open
  );

  c_ID_stage: ID_stage port map (
    clk => clk,
    ir => inst,
    extra_8 => extra_8,
    reg1 => reg1_o,
    reg2 => reg2_o,
    reg1_sel => reg_sel1,
    reg2_sel => reg_sel2,
    inst_was_i_type => previous_was_i_type,
    operand1 => op1,
    operand2 => op2,
    operand_forward1 => op_forward1,
    operand_forward2 => op_forward2,
    alu_func => alu_func,
    wb_reg => open,
    wb_we => open
  );

  --led <= std_logic_vector(to_unsigned(alu_func, led'length));
  --led <= inst(15 downto 8);
  --led <= std_logic_vector(to_unsigned(reg_sel2, led'length));
  --led <= op2(7 downto 0);
  led <= (
    0 => op_forward1,
    1 => op_forward2,
    others => '0'
  );
end architecture;

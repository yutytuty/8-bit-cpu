library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pipeline is
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    reg1     : in  std_logic_vector(15 downto 0);
    reg2     : in  std_logic_vector(15 downto 0);
    reg1_sel : out natural range 0 to 7;
    reg2_sel : out natural range 0 to 7);
end entity;

architecture pipeline_arch of pipeline is

  component IF_stage is
    port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      -- increment pc by 1.5 instead of 1. Set if previous was I-type instruction (by ID stage).
      previous_was_i_type : in  std_logic;
      inst                : out std_logic_vector(15 downto 0);
      extra_8             : out std_logic_vector(7 downto 0));
  end component;

  component ID_stage is
    port (
      clk              : in  std_logic;
      ir               : in  std_logic_vector(15 downto 0);
      extra_8          : in  std_logic_vector(7 downto 0);
      reg1             : in  std_logic_vector(15 downto 0);
      reg2             : in  std_logic_vector(15 downto 0);
      -- outputs for reg file
      reg1_sel         : out natural range 0 to 7;
      reg2_sel         : out natural range 0 to 7;
      -- outputs that go back into IF stage
      inst_was_I_type  : out std_logic;
      -- outputs for EX stage
      operand1         : out std_logic_vector(15 downto 0);
      operand2         : out std_logic_vector(15 downto 0);
      operand_forward1 : out std_logic;
      operand_forward2 : out std_logic;
      alu_func         : out natural range 0 to 15);
  end component;
  signal if_inst_out              : std_logic_vector(15 downto 0);
  signal if_extra_8               : std_logic_vector(7 downto 0);
  signal id_prev_was_i_type       : std_logic := '0';
  signal id_operand1, id_operand2 : std_logic_vector(15 downto 0);
  signal id_alu_func              : natural range 0 to 15;
begin
  c_IF_stage: IF_stage
    port map (
      clk                 => clk,
      rst                 => rst,
      previous_was_i_type => id_prev_was_i_type,
      inst                => if_inst_out,
      extra_8             => if_extra_8
    );

  c_ID_stage: ID_stage
    port map (
      clk              => clk,
      ir               => if_inst_out,
      extra_8          => if_extra_8,
      reg1             => reg1,
      reg2             => reg2,
      reg1_sel         => reg1_sel,
      reg2_sel         => reg2_sel,
      inst_was_I_type  => id_prev_was_i_type,
      operand1         => id_operand1,
      operand2         => id_operand2,
      operand_forward1 => open,
      operand_forward2 => open,
      alu_func         => id_alu_func
    );
end architecture;

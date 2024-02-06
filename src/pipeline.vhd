library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pipeline is
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    reg1          : in  std_logic_vector(15 downto 0);
    reg2          : in  std_logic_vector(15 downto 0);
    reg1_sel      : out natural range 0 to 7;
    reg2_sel      : out natural range 0 to 7;
    reg_write_sel : out natural range 0 to 7;
    reg_we        : out std_logic;
    reg_input     : out std_logic_vector(15 downto 0));
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
      operand_forward1 : out std_logic := '0';
      operand_forward2 : out std_logic := '0';
      alu_func         : out natural range 0 to 15;
      wb_reg           : out natural range 0 to 7;
      wb_we            : out std_logic);
  end component;

  component EX_stage is
    port (
      clk                : in  std_logic;
      op1                : in  std_logic_vector(15 downto 0);
      op2                : in  std_logic_vector(15 downto 0);
      operand_forward_in : in  std_logic_vector(15 downto 0);
      operand_forward1   : in  std_logic;
      operand_forward2   : in  std_logic;
      func               : in  natural range 0 to 15;
      wb_reg             : in  natural range 0 to 7;
      wb_we              : in  std_logic;
      o                  : out std_logic_vector(15 downto 0);
      wb_reg_o           : out natural range 0 to 7;
      wb_we_o            : out std_logic);
  end component;

  component WB_stage is
    port (
      clk                : in  std_logic;
      reg_write_sel      : in  natural range 0 to 7;
      we                 : in  std_logic;
      input              : in  std_logic_vector(15 downto 0);
      reg_file_write_sel : out natural range 0 to 7;
      reg_file_we        : out std_logic;
      reg_file_input     : out std_logic_vector(15 downto 0));
  end component;

  signal if_inst_out : std_logic_vector(15 downto 0);
  signal if_extra_8  : std_logic_vector(7 downto 0);

  signal id_prev_was_i_type                       : std_logic := '0';
  signal id_operand1, id_operand2                 : std_logic_vector(15 downto 0);
  signal id_alu_func                              : natural range 0 to 15;
  signal id_wb_reg                                : natural range 0 to 7;
  signal id_wb_we                                 : std_logic;
  signal id_operand_forward1, id_operand_forward2 : std_logic;

  signal ex_out    : std_logic_vector(15 downto 0);
  signal ex_wb_reg : natural range 0 to 7;
  signal ex_wb_we  : std_logic;
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
      operand_forward1 => id_operand_forward1,
      operand_forward2 => id_operand_forward2,
      alu_func         => id_alu_func,
      wb_reg           => id_wb_reg,
      wb_we            => id_wb_we
    );

  c_EX_stage: EX_stage
    port map (
      clk                => clk,
      op1                => id_operand1,
      op2                => id_operand2,
      operand_forward_in => ex_out,
      operand_forward1   => id_operand_forward1,
      operand_forward2   => id_operand_forward2,
      func               => id_alu_func,
      wb_reg             => id_wb_reg,
      wb_we              => id_wb_we,
      o                  => ex_out,
      wb_reg_o           => ex_wb_reg,
      wb_we_o            => ex_wb_we
    );

  c_WB_stage: WB_stage
    port map (
      clk                => clk,
      reg_write_sel      => ex_wb_reg,
      we                 => ex_wb_we,
      input              => ex_out,
      reg_file_write_sel => reg_write_sel,
      reg_file_we        => reg_we,
      reg_file_input     => reg_input
    );
end architecture;

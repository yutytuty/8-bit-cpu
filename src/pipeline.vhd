library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
library work;
  use work.types.all;

entity pipeline is
  port (
    clk           : in  std_logic;
    pc            : in  std_logic_vector(15 downto 0);
    reg1          : in  std_logic_vector(15 downto 0);
    reg2          : in  std_logic_vector(15 downto 0);
    reg1_sel      : out natural range 0 to 7          := 0;
    reg2_sel      : out natural range 0 to 7          := 0;
    reg_write_sel : out natural range 0 to 7          := 0;
    reg_we        : out std_logic                     := '0';
    reg_input     : out std_logic_vector(15 downto 0) := (others => '0');
    next_pc       : out std_logic_vector(15 downto 0) := (others => '0'));
end entity;

architecture pipeline_arch of pipeline is
  signal if_inst_out : std_logic_vector(15 downto 0) := (others => '0');
  signal if_next_16  : std_logic_vector(15 downto 0) := (others => '0');
  signal if_next_pc  : std_logic_vector(15 downto 0);

  signal id_prev_was_i_type                       : std_logic                     := '0';
  signal id_operand1, id_operand2                 : std_logic_vector(15 downto 0) := (others => '0');
  signal id_alu_func                              : natural range 0 to 6          := 0;
  signal id_wb_reg                                : natural range 0 to 7          := 0;
  signal id_wb_we                                 : std_logic                     := '0';
  signal id_operand_forward1, id_operand_forward2 : std_logic                     := '0';
  signal id_inst_is_j_type                        : std_logic;
  signal id_prev_pc                               : std_logic_vector(15 downto 0);
  signal id_jmp_type                              : natural range 0 to 7          := 0;
  signal id_jmp_invert_flags                      : std_logic                     := '0';
  signal id_mem_instruction                       : std_logic                     := '0';
  signal id_op1_use_reg, id_op2_use_reg           : std_logic                     := '0';

  signal ex_out             : std_logic_vector(15 downto 0) := (others => '0');
  signal ex_wb_reg          : natural range 0 to 7          := 0;
  signal ex_wb_we           : std_logic                     := '0';
  signal ex_pc_load         : std_logic                     := '0';
  signal ex_mem_instruction : std_logic                     := '0';
  signal ex_mem_data_in     : std_logic_vector(15 downto 0) := (others => '0');

  signal mem_wb_reg : natural range 0 to 7          := 0;
  signal mem_wb_we  : std_logic                     := '0';
  signal mem_out    : std_logic_vector(15 downto 0) := (others => '0');
begin
  c_IF_stage: entity work.IF_stage
    port map (
      clk                 => clk,
      pc                  => pc,
      previous_was_i_type => id_prev_was_i_type,
      inst                => if_inst_out,
      next_16             => if_next_16,
      next_pc             => if_next_pc,
      ex_pc               => id_prev_pc
    );

  c_ID_stage: entity work.ID_stage
    port map (
      clk                => clk,
      ir                 => if_inst_out,
      next_16            => if_next_16,
      reg1_sel_o         => reg1_sel,
      reg2_sel_o         => reg2_sel,
      inst_was_I_type    => id_prev_was_i_type,
      op1_use_reg        => id_op1_use_reg,
      op2_use_reg        => id_op2_use_reg,
      operand1           => id_operand1,
      operand2           => id_operand2,
      operand_forward1   => id_operand_forward1,
      operand_forward2   => id_operand_forward2,
      alu_func           => id_alu_func,
      mem_instruction_o  => id_mem_instruction,
      wb_reg             => id_wb_reg,
      wb_we              => id_wb_we,
      prev_pc            => id_prev_pc,
      inst_is_j_type     => id_inst_is_j_type,
      jmp_type_o         => id_jmp_type,
      jmp_invert_flags_o => id_jmp_invert_flags
    );

  c_EX_stage: entity work.EX_stage
    port map (
      clk                => clk,
      op1                => id_operand1,
      op2                => id_operand2,
      op1_use_reg        => id_op1_use_reg,
      op2_use_reg        => id_op2_use_reg,
      operand_forward_in => ex_out,
      operand_forward1   => id_operand_forward1,
      operand_forward2   => id_operand_forward2,
      func               => id_alu_func,
      mem_instruction    => id_mem_instruction,
      wb_reg             => id_wb_reg,
      wb_we              => id_wb_we,
      o                  => ex_out,
      reg1               => reg1,
      reg2               => reg2,
      mem_instruction_o  => ex_mem_instruction,
      mem_data_in        => ex_mem_data_in,
      wb_reg_o           => ex_wb_reg,
      wb_we_o            => ex_wb_we,
      jmp_type           => id_jmp_type,
      invert_flags       => id_jmp_invert_flags,
      inst_is_j_type     => id_inst_is_j_type,
      pc_load            => ex_pc_load
    );

  c_MEM_stage: entity work.MEM_stage
    port map (
      clk             => clk,
      mem_instruction => ex_mem_instruction,
      we              => ex_wb_we,
      data_in         => ex_mem_data_in,
      address         => ex_out,
      wb_reg          => ex_wb_reg,
      wb_we           => ex_wb_we,
      wb_reg_o        => mem_wb_reg,
      wb_we_o         => mem_wb_we,
      o               => mem_out
    );

  c_WB_stage: entity work.WB_stage
    port map (
      -- clk => clk,
      reg_write_sel      => mem_wb_reg,
      we                 => mem_wb_we,
      input              => mem_out,
      reg_file_write_sel => reg_write_sel,
      reg_file_we        => reg_we,
      reg_file_input     => reg_input
    );

  next_pc <= ex_out when ex_pc_load = '1' else
             if_next_pc;
end architecture;

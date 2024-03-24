
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity cpu is
  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    debug_reg_sel : in  natural range 0 to 7;
    debug_o       : out std_logic_vector(7 downto 0));
end entity;

architecture cpu_arch of cpu is
  signal reg1_out, reg2_out : std_logic_vector(15 downto 0);
  signal reg1_sel, reg2_sel : natural range 0 to 7;
  signal pipeline_we        : std_logic;
  signal pipeline_reg_sel   : natural range 0 to 7;
  signal pipeline_reg_input : std_logic_vector(15 downto 0);
  signal reg_debug_o        : std_logic_vector(15 downto 0);
  signal pc, next_pc        : std_logic_vector(15 downto 0);
begin
  c_PIPELINE: entity work.pipeline
    port map (
      clk           => clk,
      pc            => pc,
      reg1          => reg1_out,
      reg2          => reg2_out,
      reg1_sel      => reg1_sel,
      reg2_sel      => reg2_sel,
      reg_write_sel => pipeline_reg_sel,
      reg_we        => pipeline_we,
      reg_input     => pipeline_reg_input,
      next_pc       => next_pc
    );

  c_REG_FILE: entity work.reg_file
    port map (
      clk       => not clk,
      rst       => (others => rst),
      we        => pipeline_we,
      we_sel    => pipeline_reg_sel,
      reg_sel1  => reg1_sel,
      reg_sel2  => reg2_sel,
      debug_sel => debug_reg_sel,
      input     => pipeline_reg_input,
      pc_input  => next_pc,
      o1        => reg1_out,
      o2        => reg2_out,
      pc_o      => pc,
      debug_o   => reg_debug_o
    );

  debug_o <= reg_debug_o(7 downto 0);
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pipeline_tb is
end entity;

architecture pipeline_tb_arch of pipeline_tb is
  signal clk                            : std_logic;
  signal reg1, reg2                     : std_logic_vector(15 downto 0);
  signal reg1_sel, reg2_sel, reg_we_sel : natural range 0 to 7;
  signal reg_we                         : std_logic;
  signal reg_input                      : std_logic_vector(15 downto 0);
  signal pc_input                       : std_logic_vector(15 downto 0);
  signal pc_o                           : std_logic_vector(15 downto 0);

  signal reg_file_clk : std_logic;

  signal pc_we : std_logic;

begin
  reg_file_clk <= not clk;

  reg_file: entity work.reg_file
    port map (
      clk       => reg_file_clk,
      rst       => (others => '0'),
      we        => reg_we,
      we_sel    => reg_we_sel,
      pc_we     => pc_we,
      reg_sel1  => reg1_sel,
      reg_sel2  => reg2_sel,
      debug_sel => 0,
      input     => reg_input,
      pc_input  => pc_input,
      o1        => reg1,
      o2        => reg2,
      pc_o      => pc_o,
      debug_o   => open
    );

  uut: entity work.pipeline
    port map (
      clk           => clk,
      pc            => pc_o,
      reg1          => reg1,
      reg2          => reg2,
      reg1_sel      => reg1_sel,
      reg2_sel      => reg2_sel,
      reg_write_sel => reg_we_sel,
      reg_we        => reg_we,
      reg_input     => reg_input,
      next_pc       => pc_input
    );

  process
  begin
    clk <= '1';
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
  end process;
end architecture;

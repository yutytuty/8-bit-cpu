library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pcu is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    o   : out std_logic_vector(15 downto 0));
end entity;

architecture pcu_arch of pcu is
  component program_mem is
    port (
      clk   : in  std_logic;
      addr  : in  std_logic_vector(10 downto 0); -- for now address is 10 bits wide
      we    : in  std_logic;
      input : in  std_logic_vector(15 downto 0);
      o     : out std_logic_vector(15 downto 0));
  end component;

  component pc_reg is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      input : in  std_logic_vector(15 downto 0);
      o     : out std_logic_vector(15 downto 0));
  end component;

  component pc_adder is
    port (
      input : in  std_logic_vector(15 downto 0);
      o     : out std_logic_vector(15 downto 0));
  end component;

  signal pc_out, pc_addr_out : std_logic_vector(15 downto 0);
begin
  c_PC: pc_reg
    port map (
      clk => clk,
      rst => rst,
      input => pc_addr_out,
      o => pc_out
    );

  c_PC_ADDER: pc_adder
    port map(
      input => pc_out,
      o => pc_addr_out
    );

  c_PROGRAM_MEMORY: program_mem
    port map (
      clk => clk,
      addr => pc_out(10 downto 0),
      we => '0',
      input => (others => '0'),
      o => o
    );
end architecture;

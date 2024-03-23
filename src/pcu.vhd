library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pcu is
  port (
    clk      : in  std_logic;
    inc_2    : in  std_logic;
    pc       : in  std_logic_vector(15 downto 0);
    o        : out std_logic_vector(15 downto 0);
    next_16  : out std_logic_vector(15 downto 0);
    next_pc  : out std_logic_vector(15 downto 0) := (others => '0'));
end entity;

architecture pcu_arch of pcu is
  signal addr1, addr2        : std_logic_vector(9 downto 0);
  signal program_mem_plus1_o : std_logic_vector(15 downto 0) := (others => '0');
  signal program_mem_o       : std_logic_vector(15 downto 0) := (others => '0');
begin
  next_pc <= pc     when inc_2 = 'Z' else
             pc + 2 when inc_2 = '1' else
             pc + 1;
  addr1 <= pc(9 downto 0);
  addr2 <= addr1 + 1;

  c_PROGRAM_MEMORY: entity work.program_mem
    port map (
      clk   => clk,
      addr1 => addr1,
      addr2 => addr2,
      we    => '0',
      input => (others => '0'),
      o1    => program_mem_o,
      o2    => program_mem_plus1_o
    );

  o(15 downto 0)       <= program_mem_o;
  next_16(15 downto 0) <= program_mem_plus1_o;
end architecture;

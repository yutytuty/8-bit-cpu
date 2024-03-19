library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pcu is
  port
  (
    clk          : in std_logic;
    rst          : in std_logic;
    inc_1andhalf : in std_logic;
    o            : out std_logic_vector(15 downto 0);
    extra_8      : out std_logic_vector(7 downto 0);
    debug        : out std_logic_vector(7 downto 0));
end entity;

architecture pcu_arch of pcu is
  component program_mem is
    port
    (
      clk   : in std_logic;
      addr1 : in std_logic_vector(9 downto 0); -- for now address is 10 bits wide
      addr2 : in std_logic_vector(9 downto 0);
      we    : in std_logic;
      input : in std_logic_vector(15 downto 0);
      o1    : out std_logic_vector(15 downto 0);
      o2    : out std_logic_vector(15 downto 0));
  end component;

  component pc_reg is
    port
    (
      clk   : in std_logic;
      rst   : in std_logic;
      input : in std_logic_vector(15 downto 0);
      o     : out std_logic_vector(15 downto 0));
  end component;

  component pc_adder is
    port
    (
      input : in std_logic_vector(15 downto 0);
      inc_2 : in std_logic;
      o     : out std_logic_vector(15 downto 0));
  end component;

  signal pc_out, pc_adder_out : std_logic_vector(15 downto 0) := (others => '0');
  --signal pc_out_plus1         : std_logic_vector(15 downto 0) := (others => '0');
  --signal pc_out_plus2         : std_logic_vector(15 downto 0) := (others => '0');
  signal addr1, addr2 : std_logic_vector(9 downto 0);
  -- meaning it is pointing at the end part of the previous instruction.
  signal backward_pointer    : std_logic := '0';
  signal program_mem_plus1_o : std_logic_vector(15 downto 0);
  signal program_mem_o       : std_logic_vector(15 downto 0);
  signal adder_inc_2         : std_logic;
begin
  addr1 <= pc_out(9 downto 0) when adder_inc_2 = '0' else
    pc_out(9 downto 0) + 1 when adder_inc_2 = '1' else
    pc_out(9 downto 0);

  addr2 <= pc_out(9 downto 0) + 1 when adder_inc_2 = '0' else
    pc_out(9 downto 0) + 2 when adder_inc_2 = '1' else
    pc_out(9 downto 0) + 1;

  process (clk)
  begin
    if rst = '1' then
      adder_inc_2 <= '0';
    elsif falling_edge(clk) then
      adder_inc_2 <= backward_pointer and inc_1andhalf;
    end if;
  end process;

  process (clk, inc_1andhalf)
  begin
    if rst = '1' then
      backward_pointer <= '0';
    elsif falling_edge(clk) then
      backward_pointer <= backward_pointer xor inc_1andhalf;
    end if;
  end process;

  c_PC : pc_reg
  port map
  (
    clk   => clk,
    rst   => rst,
    input => pc_adder_out,
    o     => pc_out
  );

  c_PC_ADDER : pc_adder
  port
  map (
  input => pc_out,
  inc_2 => adder_inc_2,
  o     => pc_adder_out
  );

  c_PROGRAM_MEMORY : program_mem
  port
  map (
  clk   => clk,
  addr1 => addr1,
  addr2 => addr2,
  we    => '0',
  input => (others => '0'),
  o1    => program_mem_o,
  o2    => program_mem_plus1_o
  );
  o(15 downto 8) <= program_mem_o(15 downto 8) when backward_pointer = '0' else
  program_mem_o(7 downto 0) when backward_pointer = '1' else
  program_mem_o(15 downto 8);

  o(7 downto 0) <= program_mem_o(7 downto 0) when backward_pointer = '0' else
  program_mem_plus1_o(15 downto 8) when backward_pointer = '1' else
  program_mem_o(7 downto 0);

  extra_8 <= program_mem_plus1_o(15 downto 8) when backward_pointer = '0' else
    program_mem_plus1_o(7 downto 0) when backward_pointer = '1' else
    program_mem_plus1_o(15 downto 8);

  debug <= pc_out(7 downto 0);
  --debug <= (
  --  0 => backward_pointer,
  --  1 => inc_1andhalf,
  --  2 => adder_inc_2,
  --  others => '0'
  --);
end architecture;
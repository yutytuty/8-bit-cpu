library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity program_mem is
  port (
    clk   : in  std_logic;
    addr1 : in  std_logic_vector(9 downto 0); -- for now address is 10 bits wide
    addr2 : in  std_logic_vector(9 downto 0);
    we    : in  std_logic;
    input : in  std_logic_vector(15 downto 0);
    o1    : out std_logic_vector(15 downto 0);
    o2    : out std_logic_vector(15 downto 0));
end entity;

architecture program_mem_arch of program_mem is
  subtype word_t is std_logic_vector(15 downto 0);
  type mem_t is array (0 to 1023) of word_t;

  -- MOVI AR, 1
  -- MOVI BR, 1
  -- ADD AR, BR
  -- MOV CR, BR
  -- MOV BR, AR
  -- MOV AR, CR
  signal mem : mem_t := (
    0      => "0001000100000000",
    1      => "0000000100000000",
    2      => "0001001100000000",
    3      => "0000000100000000",
    4      => "0000000001000110",
    5      => "0000010001000010",
    6      => "0000001000000010",
    7      => "0000000010000010",
    8      => "0000000001000110",
    9      => "0000010001000010",
    10     => "0000001000000010",
    11     => "0000000010000010",
    12     => "0000000001000110",
    13     => "0000010001000010",
    14     => "0000001000000010",
    15     => "0000000010000010",
    16     => "0000000001000110",
    17     => "0000010001000010",
    18     => "0000001000000010",
    19     => "0000000010000010",
    20     => "0000000001000110",
    21     => "0000010001000010",
    22     => "0000001000000010",
    23     => "0000000010000010",
    24     => "0000000001000110",
    25     => "0000010001000010",
    26     => "0000001000000010",
    27     => "0000000010000010",
    others => x"0000"
  );

begin
  process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        mem(to_integer(unsigned(addr1))) <= input;
      end if;
    end if;
  end process;

  o1 <= mem(to_integer(unsigned(addr1)));
  o2 <= mem(to_integer(unsigned(addr2)));
end architecture;

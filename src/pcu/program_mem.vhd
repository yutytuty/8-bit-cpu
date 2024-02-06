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
    1      => "0000000100010011",
    2      => "0000000000000001",
    3      => "0000000001000110",
    4      => "0000010001000010",
    5      => "0000001000000010",
    6      => "0000000010000010",
    7      => "0000000001000110",
    8      => "0000010001000010",
    9      => "0000001000000010",
    10     => "0000000010000010",
    11     => "0000000001000110",
    12     => "0000010001000010",
    13     => "0000001000000010",
    14     => "0000000010000010",
    15     => "0000000001000110",
    16     => "0000010001000010",
    17     => "0000001000000010",
    18     => "0000000010000010",
    19     => "0000000001000110",
    20     => "0000010001000010",
    21     => "0000001000000010",
    22     => "0000000010000010",
    23     => "0000000001000110",
    24     => "0000010001000010",
    25     => "0000001000000010",
    26     => "0000000010000010",
    27     => "0000000001000110",
    28     => "0000010001000010",
    29     => "0000001000000010",
    30     => "0000000010000010",
    31     => "0000000001000110",
    32     => "0000010001000010",
    33     => "0000001000000010",
    34     => "0000000010000010",
    35     => "0000000001000110",
    36     => "0000010001000010",
    37     => "0000001000000010",
    38     => "0000000010000010",
    39     => "0000000001000110",
    40     => "0000010001000010",
    41     => "0000001000000010",
    42     => "0000000010000010",
    43     => "0000000001000110",
    44     => "0000010001000010",
    45     => "0000001000000010",
    46     => "0000000010000010",
    47     => "0000000001000110",
    48     => "0000010001000010",
    49     => "0000001000000010",
    50     => "0000000010000010",
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

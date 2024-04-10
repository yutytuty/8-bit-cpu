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

  -- MOVI AR, 5
  -- CMPI AR, 3
  -- JA 10
  -- MOVI AR, 1
  -- JMP 6
  -- MOVI AR, 2
  signal mem : mem_t := (
    0      => "0001000100000000",
    1      => "0000010100000000",
    2      => "0011000000000000",
    3      => "0000001100000000",
    4      => "1100000000001010",
    5      => "0000000000000000",
    6      => "0000000000000000",
    7      => "0000000000000000",
    8      => "0001000100000000",
    9      => "0000000100000000",
    10     => "0111000000000110",
    11     => "0000000000000000",
    12     => "0000000000000000",
    13     => "0000000000000000",
    14     => "0001000100000000",
    15     => "0000001000000000",
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

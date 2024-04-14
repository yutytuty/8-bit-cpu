library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity program_mem is
  port (
    clk   : in  std_logic;
    addr1 : in  std_logic_vector(13 downto 0); -- for now address is 10 bits wide
    addr2 : in  std_logic_vector(13 downto 0);
    we    : in  std_logic;
    input : in  std_logic_vector(15 downto 0);
    o1    : out std_logic_vector(15 downto 0);
    o2    : out std_logic_vector(15 downto 0));
end entity;

architecture program_mem_arch of program_mem is
  subtype word_t is std_logic_vector(15 downto 0);
  type mem_t is array (0 to 16383) of word_t;

  -- 0:  MOVI CR, 10
  -- 2:  MOVI AR, 1
  -- 4:  MOVI BR, 1
  -- 6:  ADD AR, BR
  -- 7:  MOV DR, BR
  -- 8:  MOV BR, AR
  -- 9:  MOV AR, DR
  -- 10: ST [CR], BR
  -- 11: SUB CR, 1
  -- 13: JNZ -7
  -- 17: MOVI AR, 5
  -- 19: LD BR, [AR-3]
  signal mem : mem_t := (
    0      => "0001010000000001",
    1      => "0000000000001010",
    2      => "0001000000000001",
    3      => "0000000000000001",
    4      => "0001001000000001",
    5      => "0000000000000001",
    6      => "0000000001000101",
    7      => "0000011001000001",
    8      => "0000001000000001",
    9      => "0000000011000001",
    10     => "1010001010000001",
    11     => "0001010001000001",
    12     => "0000000000000001",
    13     => "0011111111111001",
    14     => "0000000000000000",
    15     => "0000000000000000",
    16     => "0000000000000000",
    17     => "0001000000000001",
    18     => "0000000000000101",
    19     => "1010001000111010",
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

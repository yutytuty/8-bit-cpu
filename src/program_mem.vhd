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

  signal mem : mem_t;
  attribute ram_init_file : string;
  attribute ram_init_file of mem : signal is "sort.mif";

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

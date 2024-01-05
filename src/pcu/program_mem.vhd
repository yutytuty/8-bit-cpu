library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity program_mem is
  port (
    clk   : in  std_logic;
    addr  : in  std_logic_vector(10 downto 0); -- for now address is 10 bits wide
    we    : in  std_logic;
    input : in  std_logic_vector(15 downto 0);
    o     : out std_logic_vector(15 downto 0));
end entity;

architecture program_mem_arch of program_mem is
  subtype word_t is std_logic_vector(15 downto 0);
  type mem_t is array (0 to 1024) of word_t;

  signal mem : mem_t := (
    others => x"0000"
  );
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        mem(to_integer(unsigned(addr))) <= input;
      end if;
    end if;
  end process;

  o <= mem(to_integer(unsigned(addr)));
end architecture;

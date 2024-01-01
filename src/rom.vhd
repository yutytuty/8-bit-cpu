library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity rom is
  port (
    addr_bus : in  std_logic_vector(15 downto 0);
    o        : out std_logic_vector(7 downto 0));
end entity;

architecture rom_arch of rom is
  type rom_array is array (0 to 32767) of std_logic;

  signal mem : std_logic_vector(32767 downto 0);
begin
  mem(7 downto 0)  <= "00000101";
  mem(15 downto 8) <= "00000010";

  process (addr_bus)
  begin
    o <= mem(to_integer(unsigned(addr_bus)) + 7 downto to_integer(unsigned(addr_bus)));
  end process;
end architecture;

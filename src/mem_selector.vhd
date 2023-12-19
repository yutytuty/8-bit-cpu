library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mem_selector is
  port (
    rom      : in  std_logic_vector(7 downto 0);
    ram      : in  std_logic_vector(7 downto 0);
    addr_bus : in  std_logic_vector(15 downto 0);
    o        : out std_Logic_vector(7 downto 0));
end entity;

architecture mem_selector_arch of mem_selector is
begin
  process (rom, ram, ram, addr_bus)
  begin
    if to_integer(unsigned(addr_bus)) < 128 then
      o <= rom;
    elsif to_integer(unsigned(addr_bus)) > 128 then
      o <= ram;
    else
      o <= rom;
    end if;
  end process;
end architecture;

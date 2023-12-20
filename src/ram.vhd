library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity ram is
  port (
    addr_bus : in  std_logic_vector(15 downto 0);
    load     : in  std_logic;
    input    : in  std_logic_vector(7 downto 0);
    o        : out std_logic_vector(7 downto 0));
end entity;

architecture ram_arch of ram is
  type ram_array is array (0 to 32767) of std_logic_vector(7 downto 0);

  signal mem : ram_array;
begin
  process (addr_bus, load, input)
  begin
    if (to_integer(unsigned(addr_bus)) > 127) then
      o <= mem(to_integer(unsigned(addr_bus)) - 128); -- in code, ram comes after rom.
    end if;

    if load = '1' then
      mem(to_integer(unsigned(addr_bus) - 128)) <= input; -- same as above
    end if;
  end process;
end architecture;

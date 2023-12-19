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
  type rom_array is array (0 to 127) of std_logic_vector(7 downto 0);

  signal mem : rom_array := (
    x"55", x"66", x"77", x"67", -- 0x00: 
    x"99", x"00", x"00", x"11", -- 0x04: 
    x"00", x"00", x"00", x"00", -- 0x08: 
    x"00", x"00", x"00", x"00", -- 0x0C: 
    x"00", x"00", x"00", x"00", -- 0x10: 
    x"00", x"00", x"00", x"00", -- 0x14: 
    x"00", x"00", x"00", x"00", -- 0x18: 
    x"00", x"00", x"00", x"00", -- 0x1C: 
    x"00", x"00", x"00", x"00", -- 0x20: 
    x"00", x"00", x"00", x"00", -- 0x24: 
    x"00", x"00", x"00", x"00", -- 0x28: 
    x"00", x"00", x"00", x"00", -- 0x2C: 
    x"00", x"00", x"00", x"00", -- 0x30: 
    x"00", x"00", x"00", x"00", -- 0x34: 
    x"00", x"00", x"00", x"00", -- 0x38: 
    x"00", x"00", x"00", x"00", -- 0x3C: 
    x"00", x"00", x"00", x"00", -- 0x40: 
    x"00", x"00", x"00", x"00", -- 0x44: 
    x"00", x"00", x"00", x"00", -- 0x48: 
    x"00", x"00", x"00", x"00", -- 0x4C: 
    x"00", x"00", x"00", x"00", -- 0x50: 
    x"00", x"00", x"00", x"00", -- 0x54: 
    x"00", x"00", x"00", x"00", -- 0x58: 
    x"00", x"00", x"00", x"00", -- 0x5C: 
    x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00",
    x"00", x"00", x"00", x"00"
  );
begin
  process (addr_bus)
  begin
    o <= mem(to_integer(unsigned(addr_bus)));
  end process;
end architecture;

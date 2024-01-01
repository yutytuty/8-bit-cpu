library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity rom is
  port (
    clk      : in  std_logic;
    addr_bus : in  std_logic_vector(15 downto 0);
    o        : out std_logic_vector(7 downto 0));
end entity;

architecture rom_arch of rom is
  type rom_array is array (0 to 32767) of std_logic_vector(7 downto 0);

  signal en : std_logic := '0';

  constant rom : rom_array := (
    0 => x"01",
    1 => x"02",
    2 => x"03",
    others => (Others => '0')
  );
begin

  p_enable: process (addr_bus)
  begin
    if addr_bus < 32768 and addr_bus >= 0 then
      en <= '1';
    else
      en <= '0';
    end if;
  end process;

  p_read: process (clk)
  begin
    if rising_edge(clk) then
      if en = '1' then
        o <= rom(to_integer(unsigned(addr_bus)));
      end if;
    end if;
  end process;
end architecture;

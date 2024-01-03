library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity ram is
  port (
    clk      : in  std_logic;
    addr_bus : in  std_logic_vector(15 downto 0);
    load     : in  std_logic;
    input    : in  std_logic_vector(7 downto 0);
    o        : out std_logic_vector(7 downto 0));
end entity;

architecture ram_arch of ram is
  type ram_array is array (0 to 32767) of std_logic_vector(7 downto 0);

  signal en  : std_logic := '0';
  signal ram : ram_array := (others => x"00");
  -- signal addr_reg : std_logic_vector(15 downto 0) := x"0000";
begin

  p_enable: process (addr_bus)
  begin
    if addr_bus >= 32768 and addr_bus < 65536 then
      en <= '1';
    else
      en <= '0';
    end if;
  end process;

  p_read_write: process (clk, load)
  begin
    if rising_edge(clk) then
      if en = '1' then
        if load = '1' then
          ram(to_integer(unsigned(addr_bus)) - 32768) <= input;
        end if;
      end if;
      o <= ram(to_integer(unsigned(addr_bus)) - 32768);
    end if;
  end process;
end architecture;

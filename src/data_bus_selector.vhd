library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity data_bus_selector is
  port (
    reg, alu, mem : in  std_logic_vector(7 downto 0);
    sel           : in  natural range 0 to 2;
    o             : out std_logic_vector(7 downto 0));
end entity;

architecture data_bus_selector_arch of data_bus_selector is
begin
  process (reg, alu, mem, sel)
  begin
    case sel is
      when 0 => o <= reg;
      when 1 => o <= alu;
      when 2 => o <= mem;
      when others => o <= "00000000";
    end case;
  end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity data_bus_selector is
  port (
    reg, alu, mem : in  std_logic_vector(7 downto 0);
    sel           : in  std_logic_vector(1 downto 0);
    o             : out std_logic_vector(7 downto 0));
end entity;

architecture data_bus_selector_arch of data_bus_selector is
begin
  process (reg, alu, mem, sel)
  begin
    case sel is
      when "00" => o <= reg;
      when "01" => o <= alu;
      when "10" => o <= mem;
      when others => o <= "00000000";
    end case;
  end process;
end architecture;

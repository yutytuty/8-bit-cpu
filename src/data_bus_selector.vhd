library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity data_bus_selector is
  port (
    ar, br, alu : in  std_logic_vector(7 downto 0);
    sel         : in  std_logic_vector(2 downto 0);
    o           : out std_logic_vector(7 downto 0));
end entity;

architecture data_bus_selector_arch of data_bus_selector is
begin
  process (ar, br, alu, sel)
  begin
    case sel is
      when "00" => o <= ar;
      when "01" => o <= br;
      when "10" => o <= alu;
      when others => o <= "00000000";
    end case;
  end process;
end architecture;

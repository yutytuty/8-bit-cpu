library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity data_bus_selector is
  port (
    ar, br, cr, dr, ha, la, alu : in  std_logic_vector(7 downto 0);
    sel                         : in  std_logic_vector(2 downto 0);
    o                           : out std_logic_vector(7 downto 0));
end entity;

architecture data_bus_selector_arch of data_bus_selector is
begin
  process (ar, br, cr, dr, ha, la, alu, sel)
  begin
    case sel is
      when "000" => o <= ar;
      when "001" => o <= br;
      when "011" => o <= cr;
      when "100" => o <= dr;
      when "101" => o <= ha;
      when "110" => o <= la;
      when "111" => o <= alu;
      when others => o <= "00000000";
    end case;
  end process;
end architecture;

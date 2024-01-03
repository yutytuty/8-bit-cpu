library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity reg_selector is
  port (
    ar, br, cr, dr, ha, la : in  std_logic_vector(7 downto 0);
    sel                    : in  std_logic_vector(2 downto 0);
    o                      : out std_logic_vector(7 downto 0));
end entity;

architecture reg_selector_arch of reg_selector is
begin
  process (ar, br, cr, dr, ha, la, sel)
  begin
    case sel is
      when "000" => o <= ar;
      when "001" => o <= br;
      when "010" => o <= cr;
      when "011" => o <= dr;
      when "100" => o <= ha;
      when "101" => o <= la;
      when others => o <= "00000000";
    end case;
  end process;
end architecture;

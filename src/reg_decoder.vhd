library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity reg_decoder is
  port (
    no_out : in  std_logic;
    sel    : in  std_logic_vector(2 downto 0);
    o      : out std_logic_vector(7 downto 0));
end entity;

architecture reg_decoder_arch of reg_decoder is
begin
  process (sel, no_out)
  begin
    if no_out = '1' then
      o <= "00000000";
    else
      case sel is
        when "000" => o <= "00000001";
        when "001" => o <= "00000010";
        when "010" => o <= "00000100";
        when "011" => o <= "00001000";
        when "100" => o <= "00010000";
        when "101" => o <= "00100000";
        when "110" => o <= "01000000";
        when "111" => o <= "10000000";
        when others => o <= "00000000";
      end case;
    end if;
  end process;
end architecture;

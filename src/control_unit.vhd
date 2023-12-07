library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity control_unit is
  port (
    inst                                   : in  std_logic_vector(10 downto 0);
    counter                                : in  std_logic_vector(1 downto 0);
    ar_load, br_load, counter_rst, add_sub : out std_logic;
    data_bus_selector_sel                  : out std_logic_vector(2 downto 0));
end entity;

architecture data_bus_selector_arch of control_unit is
begin
  process (inst, counter)
  begin
    case inst(10 downto 7) is
      when "0000" =>
        if counter = "00" then
          data_bus_selector_sel <= inst(2 downto 0);
          ar_load <= '0';
          br_load <= '0';
        elsif counter = "01" then
          if inst(5 downto 3) = "000" then
            ar_load <= '1';
            br_load <= '0';
          elsif inst(5 downto 3) = "001" then
            ar_load <= '0';
            br_load <= '1';
          end if;
        end if;
      when "0001" =>
        -- ar <= reg_a, add_sub <= '0'
        -- data_bus <= reg_b, data_bus_selector_sel <= '1'
        -- 
        if counter = "00" then

        end if;
      when others =>
        ar_load <= '0';
        br_load <= '0';
        data_bus_selector_sel <= "000";
    end case;
  end process;
end architecture;

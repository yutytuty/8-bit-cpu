library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity addr_bus_selector is
  port (
    reg : in  std_logic_vector(15 downto 0);
    pc  : in  std_logic_vector(15 downto 0);
    sel : in  std_logic;
    o   : out std_logic_vector(15 downto 0));
end entity;

architecture addr_bus_selector_arch of addr_bus_selector is
begin
  process (reg, pc, sel)
  begin
    case sel is
      when '0' => o <= reg;
      when '1' => o <= pc;
      when others => o <= (others => '0');
    end case;
  end process;
end architecture;

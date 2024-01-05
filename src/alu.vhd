library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity alu is
  port (
    a    : in  std_logic_vector(15 downto 0);
    b    : in  std_logic_vector(15 downto 0);
    func : in  natural range 0 to 10;
    o    : out std_logic_vector(15 downto 0));
end entity;

architecture alu_arch of alu is
begin
  o <= a + b   when func = 0 else
       a - b   when func = 1 else
       a and b when func = 2 else
       a or b  when func = 3 else
       not a   when func = 4 else
       a;
end architecture;

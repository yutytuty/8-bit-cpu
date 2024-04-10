library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity alu is
  port (
    a    : in  std_logic_vector(15 downto 0);
    b    : in  std_logic_vector(15 downto 0);
    func : in  natural range 0 to 15;
    o    : out std_logic_vector(15 downto 0);
    ZF   : out std_logic;
    CF   : out std_logic;
    SF   : out std_logic;
    VF   : out std_logic);
end entity;

architecture alu_arch of alu is
  signal result : std_logic_vector(15 downto 0);
begin
  result <= b       when func = 0 else
            a + b   when func = 1 else
            a - b   when func = 2 else
            a and b when func = 3 else
            a or b  when func = 4 else
            a xor b when func = 5 else
            not a   when func = 6 else
            a;

  ZF <= '1' when result = x"00000000" else '0';
  CF <= '1' when ((a(15) and b(15)) = '1' or ((a(15) xor b(15)) and not result(15)) = '1') and func = 1 else
        '1' when to_integer(unsigned(a)) < to_integer(unsigned(b)) and func = 2 else
        '0';
  SF <= result(15);
  VF <= '1' when ((a(15) xnor b(15)) = '1' and result(15) /= a(15)) and func = 1 else
        '1' when ((a(15) xor b(15)) = '1' and result(15) /= a(15)) and func = 2 else
        '0';
  o <= result;
end architecture;

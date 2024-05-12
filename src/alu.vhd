library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;
library work;
  use work.types.all;

entity alu is
  port (
    a    : in  std_logic_vector(15 downto 0);
    b    : in  std_logic_vector(15 downto 0);
    func : in  alu_func_t;
    o    : out std_logic_vector(15 downto 0);
    ZF   : out std_logic;
    CF   : out std_logic;
    SF   : out std_logic;
    VF   : out std_logic);
end entity;

architecture alu_arch of alu is
  signal result      : std_logic_vector(15 downto 0);
  signal mult_result : std_logic_vector(31 downto 0);
begin
  mult_result <= a * b;
  result      <= b                        when func = T_MOV else
                 a + b                    when func = T_ADD else
                 a - b                    when func = T_SUB else
                 a and b                  when func = T_AND else
                 a or b                   when func = T_OR else
                 a xor b                  when func = T_XOR else
                 not a                    when func = T_NOT else
                 mult_result(15 downto 0) when func = T_NONE else
                 std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b)))) when func = T_SHL else
                 std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b)))) when func = T_SHR else
                 a;

  ZF <= '1' when result = x"00000000" else '0';
  CF <= '1' when ((a(15) and b(15)) = '1' or ((a(15) xor b(15)) and not result(15)) = '1') and func = T_ADD else
        '1' when to_integer(unsigned(a)) < to_integer(unsigned(b)) and func = T_SUB else
        '0';
  SF <= result(15);
  VF <= '1' when ((a(15) xnor b(15)) = '1' and result(15) /= a(15)) and func = T_ADD else
        '1' when ((a(15) xor b(15)) = '1' and result(15) /= a(15)) and func = T_SUB else
        '0';
  o <= result;
end architecture;

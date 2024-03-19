library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pc_adder is
  port
  (
    input : in std_logic_vector(15 downto 0);
    inc_2 : in std_logic;
    o     : out std_logic_vector(15 downto 0));
end entity;

architecture pc_adder_arch of pc_adder is
begin
  o <= input + 1 when inc_2 = '0' else
    input + 2 when inc_2 = '1' else
    input + 1;
end architecture;
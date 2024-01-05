library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pc_adder is
  port (
    input            : in  std_logic_vector(15 downto 0);
    o                : out std_logic_vector(15 downto 0));
end entity;

architecture pc_adder_arch of pc_adder is
  constant INSTRUCTION_SIZE : natural := 16;
begin
  o <= input + INSTRUCTION_SIZE;
end architecture;

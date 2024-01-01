library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pc_adder is
  port (
    input            : in  std_logic_vector(15 downto 0);
    instruction_type : in  std_logic_vector(1 downto 0); -- r-type=0, i1-type=1, i2-type=3, j-type=2
    o                : out std_logic_vector(15 downto 0));
end entity;

architecture pc_adder_arch of pc_adder is
  constant r_type_size  : integer := 10;
  constant i1_type_size : integer := 10;
  constant i2_type_size : integer := 10;
  constant j_type_size  : integer := 10;
begin
  process (input, instruction_type)
  begin
    case instruction_type is
      when "00" => o <= input + r_type_size;
      when "01" => o <= input + i1_type_size;
      when "10" => o <= input + i2_type_size;
      when "11" => o <= input + j_type_size;
      when others => o <= input;
    end case;
  end process;
end architecture;

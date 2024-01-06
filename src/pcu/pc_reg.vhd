library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pc_reg is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    input : in  std_logic_vector(15 downto 0);
    o     : out std_logic_vector(15 downto 0));
end entity;

architecture pc_reg_arch of pc_reg is
  signal data : std_logic_vector(15 downto 0) := (others => '0');
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        data <= (others => '0');
      else
        data <= input;
      end if;
    end if;
  end process;

  o <= data;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity reg8 is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    load  : in  std_logic;
    input : in  std_logic_vector(7 downto 0);
    o     : out std_logic_vector(7 downto 0)
  );
end entity;

architecture reg8_arch of reg8 is
  signal data : std_logic_vector(7 downto 0) := "00000001";
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        data <= (others => '0');
      elsif load = '1' then
        data <= input;
      end if;
    end if;

    o <= data;
  end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity counter is
  port (clk : in  std_logic;
        rst : in  std_logic;
        o   : out std_logic_vector(1 downto 0));
end entity;

architecture counter_arch of counter is
  signal value : std_logic_vector(1 downto 0);
begin
  process (clk)
  begin
    if rst = '1' then
      value <= "00";
    else
      if rising_edge(clk) then
        value <= value + 1;
      end if;
    end if;
    o <= value;
  end process;
end architecture;

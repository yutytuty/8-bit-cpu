library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pc_reg is
  port (
    clk  : in  std_logic;
    in_h : in  std_logic_vector(7 downto 0);
    in_l : in  std_logic_vector(7 downto 0);
    load : in  std_logic;
    rst  : in  std_logic;
    o    : out std_logic_vector(15 downto 0));
end entity;

architecture pc_reg_arch of pc_reg is
  signal h : std_logic_vector(7 downto 0);
  signal l : std_logic_vector(7 downto 0);
begin
  process (in_h, in_l, load)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        h <= (others => '0');
        l <= (others => '0');
      elsif load = '1' then
        h <= in_h;
        l <= in_l;
      end if;
      o(15 downto 8) <= h;
      o(7 downto 0) <= l;
    end if;
  end process;
end architecture;

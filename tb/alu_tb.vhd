library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_tb is
end entity;

architecture behave of alu_tb is
  component alu is
    port
    (
      a       : in std_logic_vector(7 downto 0);
      b       : in std_logic_vector(7 downto 0);
      add_sub : in std_logic; -- add = 0 sub = 1
      o       : out std_logic_vector(7 downto 0));
  end component;
  -- component reg8 is
  --   port (
  --     clk : in std_logic;
  --     rst : in std_logic;
  --     load : in std_logic;
  --     input : in std_logic_vector (7 downto 0);
  --     o : out std_logic_vector (7 downto 0));
  -- end component;
  signal a, b, o : std_logic_vector(7 downto 0);
  signal add_sub : std_logic;
begin
  uut : alu port map
    (a, b, add_sub, o);

  process
  begin
    a       <= "00001010"; -- 10
    b       <= "00000010"; -- 2
    add_sub <= '0';

    wait for 1 ns;
    add_sub <= '1';

    wait for 1 ns;
    a <= "00000001";
    wait for 1 ns;

    wait;
  end process;
end architecture;
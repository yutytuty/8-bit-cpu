library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity IF_stage is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    o   : out std_logic_vector(15 downto 0));
end entity;

architecture IF_stage_arch of IF_Stage is
  component pcu is
    port (
      clk : in  std_logic;
      rst : in  std_logic;
      o   : out std_logic_vector(15 downto 0));
  end component;

  signal IR : std_logic_vector(15 downto 0);
begin
  c_PCU: pcu
    port map (
      clk => clk,
      rst => rst,
      o   => IR
    );

  process (clk)
  begin
    if rising_edge(clk) then
      o <= IR;
    end if;
  end process;
end architecture;

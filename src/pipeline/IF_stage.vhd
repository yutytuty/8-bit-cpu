library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity IF_stage is
  port (
    clk                 : in  std_logic;
    pc                  : in  std_logic_vector(15 downto 0);
    previous_was_i_type : in  std_logic;
    inst                : out std_logic_vector(15 downto 0) := (others => '0');
    next_16             : out std_logic_vector(15 downto 0)  := (others => '0');
    next_pc             : out std_logic_vector(15 downto 0) := (others => '0'));
end entity;

architecture IF_stage_arch of IF_Stage is
  signal IR          : std_logic_vector(15 downto 0);
  signal pcu_next_16 : std_logic_vector(15 downto 0);
begin
  c_PCU: entity work.pcu
    port map (
      clk     => clk,
      inc_2   => previous_was_i_type,
      pc      => pc,
      next_16 => pcu_next_16,
      next_pc => next_pc,
      o       => IR
    );

  process (clk)
  begin
    if rising_edge(clk) then
      inst <= IR;
      next_16 <= pcu_next_16;
    end if;
  end process;
end architecture;

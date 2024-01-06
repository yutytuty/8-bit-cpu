library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity IF_stage is
  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    -- increment pc by 1.5 instead of 1. Set if previous was I-type instruction (by ID stage).
    previous_was_i_type : in  std_logic;
    inst                : out std_logic_vector(15 downto 0);
    extra_8             : out std_logic_vector(7 downto 0));
end entity;

architecture IF_stage_arch of IF_Stage is
  component pcu is
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;
      inc_1andhalf : in  std_logic;
      o            : out std_logic_vector(15 downto 0);
      extra_8      : out std_logic_vector(7 downto 0));
  end component;

  signal IR     : std_logic_vector(15 downto 0);
  signal next_8 : std_logic_vector(7 downto 0);
begin
  c_PCU: pcu
    port map (
      clk          => clk,
      rst          => rst,
      inc_1andhalf => previous_was_i_type,
      o            => IR,
      extra_8      => next_8
    );

  process (clk)
  begin
    if rising_edge(clk) then
      inst <= IR;
      extra_8 <= next_8;
    end if;
  end process;
end architecture;

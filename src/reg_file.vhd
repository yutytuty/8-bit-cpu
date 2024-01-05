library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity reg_file is
  port (
    clk      : in  std_logic;
    rst      : in  std_logic_vector(7 downto 0);
    we       : in  std_logic;            -- do you want to write to anything
    we_sel   : in  natural range 0 to 7; -- what do you want to write to
    reg_sel1 : in  natural range 0 to 7;
    reg_sel2 : in  natural range 0 to 7;
    input    : in  std_logic_vector(15 downto 0);
    o1       : out std_logic_vector(15 downto 0);
    o2       : out std_logic_vector(15 downto 0)); -- select which registers to write to
end entity;

architecture reg_file_arch of reg_file is
  component reg is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      we  : in  std_logic; -- write enabled
      input : in  std_logic_vector(15 downto 0);
      o     : out std_logic_vector(15 downto 0)
    );
  end component;
  signal internal_we                              : std_logic_vector(7 downto 0) := (others => '0');
  signal ar_o1, br_o1, cr_o1, dr_o1, ha_o1, la_o1 : std_logic_vector(15 downto 0);
  signal ar_o2, br_o2, cr_o2, dr_o2, ha_o2, la_o2 : std_logic_vector(15 downto 0);
begin
  ar_o2 <= ar_o1;
  br_o2 <= br_o1;
  cr_o2 <= cr_o1;
  dr_o2 <= dr_o1;
  ha_o2 <= ha_o1;
  la_o2 <= la_o1;

  c_AR: reg
    port map (
      clk   => clk,
      rst   => rst(0),
      we  => internal_we(0),
      input => input,
      o     => ar_o1
    );
  c_BR: reg
    port map (
      clk   => clk,
      rst   => rst(1),
      we  => internal_we(1),
      input => input,
      o     => br_o1
    );
  c_CR: reg
    port map (
      clk   => clk,
      rst   => rst(2),
      we  => internal_we(2),
      input => input,
      o     => cr_o1
    );
  c_DR: reg
    port map (
      clk   => clk,
      rst   => rst(3),
      we  => internal_we(3),
      input => input,
      o     => dr_o1
    );
  c_HA: reg
    port map (
      clk   => clk,
      rst   => rst(4),
      we  => internal_we(4),
      input => input,
      o     => ha_o1
    );
  c_LA: reg
    port map (
      clk   => clk,
      rst   => rst(5),
      we  => internal_we(5),
      input => input,
      o     => la_o1
    );

  process (reg_sel1, ar_o1, br_o1, cr_o1, dr_o1, ha_o1, la_o1)
  begin
    case reg_sel1 is
      when 0 => o1 <= ar_o1;
      when 1 => o1 <= br_o1;
      when 2 => o1 <= cr_o1;
      when 3 => o1 <= dr_o1;
      when 4 => o1 <= ha_o1;
      when 5 => o1 <= la_o1;
      when others => o1 <= (others => '0');
    end case;
  end process;

  process (reg_sel2, ar_o2, br_o2, cr_o2, dr_o2, ha_o2, la_o2)
  begin
    case reg_sel2 is
      when 0 => o2 <= ar_o2;
      when 1 => o2 <= br_o2;
      when 2 => o2 <= cr_o2;
      when 3 => o2 <= dr_o2;
      when 4 => o2 <= ha_o2;
      when 5 => o2 <= la_o2;
      when others => o2 <= (others => '0');
    end case;
  end process;

  process (we_sel, we)
  begin
    internal_we <= (others => '0');
    if we = '1' then
      internal_we(we_sel) <= '1';
    end if;
  end process;
end architecture;

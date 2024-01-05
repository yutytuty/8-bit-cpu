library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity reg_file is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic_vector(7 downto 0);
    we      : in  std_logic;            -- do you want to write to anything
    we_sel  : in  natural range 0 to 7; -- what do you want to write to
    reg_sel : in  natural range 0 to 7;
    input   : in  std_logic_vector(15 downto 0);
    o       : out std_logic_vector(15 downto 0));
end entity;

architecture reg_file_arch of reg_file is
  component reg is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      we    : in  std_logic; -- write enabled
      input : in  std_logic_vector(15 downto 0);
      o     : out std_logic_vector(15 downto 0)
    );
  end component;
  signal internal_we                              : std_logic_vector(7 downto 0) := (others => '0');
  signal ar_o, br_o, cr_o, dr_o, ha_o, la_o : std_logic_vector(15 downto 0);
begin
  c_AR: reg
    port map (
      clk   => clk,
      rst   => rst(0),
      we    => internal_we(0),
      input => input,
      o     => ar_o
    );
  c_BR: reg
    port map (
      clk   => clk,
      rst   => rst(1),
      we    => internal_we(1),
      input => input,
      o     => br_o
    );
  c_CR: reg
    port map (
      clk   => clk,
      rst   => rst(2),
      we    => internal_we(2),
      input => input,
      o     => cr_o
    );
  c_DR: reg
    port map (
      clk   => clk,
      rst   => rst(3),
      we    => internal_we(3),
      input => input,
      o     => dr_o
    );
  c_HA: reg
    port map (
      clk   => clk,
      rst   => rst(4),
      we    => internal_we(4),
      input => input,
      o     => ha_o
    );
  c_LA: reg
    port map (
      clk   => clk,
      rst   => rst(5),
      we    => internal_we(5),
      input => input,
      o     => la_o
    );

  process (reg_sel, ar_o, br_o, cr_o, dr_o, ha_o, la_o)
  begin
    case reg_sel is
      when 0 => o <= ar_o;
      when 1 => o <= br_o;
      when 2 => o <= cr_o;
      when 3 => o <= dr_o;
      when 4 => o <= ha_o;
      when 5 => o <= la_o;
      when others => o <= (others => '0');
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

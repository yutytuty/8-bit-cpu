library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity reg_file is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic_vector(7 downto 0);
    we        : in  std_logic;            -- do you want to write to anything
    we_sel    : in  natural range 0 to 7; -- what do you want to write to
    reg_sel1  : in  natural range 0 to 7;
    reg_sel2  : in  natural range 0 to 7;
    debug_sel : in  natural range 0 to 7;
    input     : in  std_logic_vector(15 downto 0);
    pc_input  : in  std_logic_vector(15 downto 0);
    o1        : out std_logic_vector(15 downto 0);
    o2        : out std_logic_vector(15 downto 0);
    pc_o      : out std_logic_vector(15 downto 0);
    debug_o   : out std_logic_vector(15 downto 0)); -- select which registers to write to
end entity;

architecture reg_file_arch of reg_file is
  signal internal_we                                                            : std_logic_vector(7 downto 0)  := (others => '0');
  signal ar_o1, br_o1, cr_o1, dr_o1, sp_o1, bp_o1, ds_o1                        : std_logic_vector(15 downto 0) := (others => '0');
  signal ar_o2, br_o2, cr_o2, dr_o2, sp_o2, bp_o2, ds_o2                        : std_logic_vector(15 downto 0) := (others => '0');
  signal debug_ar_o, debug_br_o, debug_cr_o, debug_dr_o, debug_ha_o, debug_la_o : std_logic_vector(15 downto 0) := (others => '0');
  signal pc_enable                                                              : std_logic                     := '0';
begin
  ar_o2 <= ar_o1;
  br_o2 <= br_o1;
  cr_o2 <= cr_o1;
  dr_o2 <= dr_o1;
  sp_o2 <= sp_o1;
  bp_o2 <= bp_o1;
  ds_o2 <= ds_o1;

  debug_ar_o <= ar_o1;
  debug_br_o <= br_o1;
  debug_cr_o <= cr_o1;
  debug_dr_o <= dr_o1;
  debug_ha_o <= sp_o1;
  debug_la_o <= bp_o1;

  c_AR: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(0),
      we    => internal_we(0),
      input => input,
      o     => ar_o1
    );
  c_BR: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(1),
      we    => internal_we(1),
      input => input,
      o     => br_o1
    );
  c_CR: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(2),
      we    => internal_we(2),
      input => input,
      o     => cr_o1
    );
  c_DR: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(3),
      we    => internal_we(3),
      input => input,
      o     => dr_o1
    );
  c_SP: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(4),
      we    => internal_we(4),
      input => input,
      o     => sp_o1
    );
  c_BP: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(5),
      we    => internal_we(5),
      input => input,
      o     => bp_o1
    );

  -- enable pc only after one cycle
  c_PC: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(6),
      we    => pc_enable,
      input => pc_input,
      o     => pc_o
    );

  c_DS: entity work.reg
    port map (
      clk   => clk,
      rst   => rst(7),
      we    => internal_we(7),
      input => input,
      o     => ds_o1
    );
    process (reg_sel1, ar_o1, br_o1, cr_o1, dr_o1, sp_o1, bp_o1, ds_o1)
    begin
      case reg_sel1 is
        when 0 => o1 <= ar_o1;
        when 1 => o1 <= br_o1;
        when 2 => o1 <= cr_o1;
        when 3 => o1 <= dr_o1;
        when 4 => o1 <= sp_o1;
        when 5 => o1 <= bp_o1;
        when 7 => o1 <= ds_o1;
        when others => o1 <= (others => '0');
      end case;
    end process;

  process (reg_sel2, ar_o2, br_o2, cr_o2, dr_o2, sp_o2, bp_o2)
  begin
    case reg_sel2 is
      when 0 => o2 <= ar_o2;
      when 1 => o2 <= br_o2;
      when 2 => o2 <= cr_o2;
      when 3 => o2 <= dr_o2;
      when 4 => o2 <= sp_o2;
      when 5 => o2 <= bp_o2;
      when 7 => o2 <= ds_o2;
      when others => o2 <= (others => '0');
    end case;
  end process;

  process (debug_sel, debug_ar_o, debug_br_o, debug_cr_o, debug_dr_o, debug_ha_o, debug_la_o)
  begin
    case debug_sel is
      when 0 => debug_o <= debug_ar_o;
      when 1 => debug_o <= debug_br_o;
      when 2 => debug_o <= debug_cr_o;
      when 3 => debug_o <= debug_dr_o;
      when 4 => debug_o <= debug_ha_o;
      when 5 => debug_o <= debug_la_o;
      when others => debug_o <= (others => '0');
    end case;
  end process;

  process (we_sel, we)
  begin
    internal_we <= (others => '0');
    if we = '1' then
      internal_we(we_sel) <= '1';
    end if;
  end process;

  process (clk)
  begin
    if falling_edge(clk) then
      if pc_enable = '0' then
        pc_enable <= '1';
      end if;
    end if;
  end process;
end architecture;

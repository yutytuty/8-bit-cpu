library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity pcu is
  port (
    clk       : in  std_logic;
    input     : in  std_logic_vector(7 downto 0);
    rst       : in  std_logic;
    load_h    : in  std_logic;
    load_l    : in  std_logic;
    inc       : in  std_logic;
    inst_type : in  std_logic_vector(1 downto 0);
    o         : out std_logic_vector(15 downto 0));
end entity;

architecture pcu_arch of pcu is
  component pcu_reg is
    port (
      clk  : in  std_logic;
      in_h : in  std_logic_vector(7 downto 0);
      in_l : in  std_logic_vector(7 downto 0);
      load : in  std_logic;
      rst  : in  std_logic;
      o    : out std_logic_vector(15 downto 0));
  end component;

  component pcu_adder is
    port (
      input            : in  std_logic_vector(15 downto 0);
      instruction_type : in  std_logic_vector(1 downto 0); -- r-type=0, i1-type=1, i2-type=3, j-type=2
      o                : out std_logic_vector(15 downto 0));
  end component;

  signal h_latch, l_latch  : std_logic_vector(7 downto 0);
  signal reg_load          : std_logic;
  signal reg_out, addr_out : std_logic_vector(15 downto 0);
begin
  c_REG: pcu_reg
    port map (
      clk  => clk,
      in_h => h_latch,
      in_l => l_latch,
      load => reg_load,
      rst  => rst,
      o    => reg_out
    );

  c_ADDER: pcu_adder
    port map (
      input            => reg_out,
      instruction_type => inst_type,
      o                => addr_out
    );

  process (clk)
  begin
    if rising_edge(clk) then
      reg_load <= load_h nor load_l;
      if not inc then
        if load_h then
          h_latch <= input;
        end if;
        if load_l then
          l_latch <= input;
        end if;
      else
        h_latch <= addr_out(15 downto 8);
        l_latch <= addr_out(7 downto 0);
      end if;
      o <= reg_out;
    end if;
  end process;
end architecture;

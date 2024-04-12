library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;
library work;
  use work.types.all;

entity EX_stage is
  port (
    clk                : in  std_logic;
    op1                : in  std_logic_vector(15 downto 0);
    op2                : in  std_logic_vector(15 downto 0);
    operand_forward_in : in  std_logic_vector(15 downto 0);
    operand_forward1   : in  std_logic;
    operand_forward2   : in  std_logic;
    func               : in  alu_func_t;
    wb_reg             : in  natural range 0 to 7;
    wb_we              : in  std_logic;
    o                  : out std_logic_vector(15 downto 0);
    wb_reg_o           : out natural range 0 to 7;
    wb_we_o            : out std_logic;
    -- for jumps
    jmp_type           : in  jmp_type_t;
    invert_flags       : in  std_logic;
    inst_is_j_type     : in  std_logic;
    pc_load            : out std_logic);
end entity;

architecture EX_stage_arch of EX_stage is
  signal alu_a, alu_b : std_logic_vector(15 downto 0) := (others => '0');
  signal alu_o        : std_logic_vector(15 downto 0) := (others => '0');

  signal alu_zf, alu_cf, alu_sf, alu_vf : std_logic := '0';
  signal flags                          : std_logic_vector(15 downto 0);
begin
  alu_a <= op1                when operand_forward1 = '0' else
           operand_forward_in when operand_forward1 = '1' else
           op1;
  alu_b <= op2                when operand_forward2 = '0' else
           operand_forward_in when operand_forward2 = '1' else
           op2;

  c_ALU: entity work.alu
    port map (
      a    => alu_a,
      b    => alu_b,
      func => func,
      o    => alu_o,
      ZF   => alu_zf,
      CF   => alu_cf,
      SF   => alu_sf,
      VF   => alu_vf
    );

  p_flags: process (clk)
  begin
    if rising_edge(clk) then
      flags <= (
        0      => alu_zf,
        1      => alu_cf,
        2      => alu_sf,
        4      => alu_vf,
        others => '0'
      );
    end if;
  end process;

  process (clk)
    variable condition : boolean := false;
  begin
    if rising_edge(clk) then
      condition := false;

      o <= alu_o;
      wb_reg_o <= wb_reg;
      wb_we_o <= wb_we;
      pc_load <= '0';
      if inst_is_j_type = '1' then
        pc_load <= '0';
        case jmp_type is
          when T_JMP => condition := true;
          when T_JZ => condition := flags(0) = '1';
          when T_JC => condition := flags(1) = '1';
          when T_JS => condition := flags(2) = '1';
          when T_JO => condition := flags(3) = '1';
          when T_JA => condition := flags(1) = '0' and flags(0) = '0';
          when T_JG => condition := flags(0) = '0' and flags(2) = flags(3);
          when T_JGE => condition := flags(2) = flags(3);
        end case;

        if invert_flags = '0' and condition then
          pc_load <= '1';
        elsif invert_flags = '1' and not condition then
          pc_load <= '1';
        else
          pc_load <= '0';
        end if;
      end if;
    end if;
  end process;
end architecture;

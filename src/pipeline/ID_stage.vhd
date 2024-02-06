library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity ID_stage is
  port (
    clk              : in  std_logic;
    ir               : in  std_logic_vector(15 downto 0);
    extra_8          : in  std_logic_vector(7 downto 0);
    reg1             : in  std_logic_vector(15 downto 0);
    reg2             : in  std_logic_vector(15 downto 0);
    -- outputs for reg file
    reg1_sel         : out natural range 0 to 7;
    reg2_sel         : out natural range 0 to 7;
    -- outputs that go back into IF stage
    inst_was_I_type  : out std_logic := '0';
    -- outputs for EX stage
    operand1         : out std_logic_vector(15 downto 0);
    operand2         : out std_logic_vector(15 downto 0);
    operand_forward1 : out std_logic;
    operand_forward2 : out std_logic;
    alu_func         : out natural range 0 to 15;
    -- outputs for WB stage
    wb_reg           : out natural range 0 to 7;
    wb_we            : out std_logic := '0');
end entity;

architecture ID_stage_arch of ID_stage is
  type inst_type_t is (T_R_TYPE, T_I_TYPE, T_UNKNOWN);

  signal inst_type : inst_type_t := T_UNKNOWN;
begin
  p_decode: process (ir)
    variable opcode : integer := 0;
  begin
    opcode := to_integer(unsigned(ir(15 downto 12)));
    if opcode = 0 then
      inst_type <= T_R_TYPE;
    elsif opcode >= 1 and opcode < 7 then
      inst_type <= T_I_TYPE;
    else
      inst_type <= T_UNKNOWN;
    end if;
  end process;

  -- This needs to be sequential because it is not part of the sequential part of the pipeline
  process (inst_type)
  begin
    if inst_type = T_I_TYPE then
      inst_was_I_type <= '1';
    else
      inst_was_I_type <= '0';
    end if;
  end process;

  p_reg_sel_decode: process (inst_type, ir)
  begin
    case inst_type is
      when T_R_TYPE =>
        reg1_sel <= to_integer(unsigned(ir(11 downto 9)));
        reg2_sel <= to_integer(unsigned(ir(8 downto 6)));
      when T_I_TYPE =>
        reg1_sel <= to_integer(unsigned(ir(11 downto 9)));
      when others =>
        reg1_sel <= 0;
        reg2_sel <= 0;
    end case;
  end process;

  p_operand_fetch: process (clk)
  begin
    if rising_edge(clk) then
      operand1 <= (others => '0');
      operand2 <= (others => '0');
      case inst_type is
        when T_R_TYPE =>
          operand1 <= reg1;
          operand2 <= reg2;
        when T_I_TYPE =>
          operand1 <= reg1;
          operand2(15 downto 8) <= ir(7 downto 0);
          operand2(7 downto 0) <= extra_8;
        when others =>
      end case;
    end if;
  end process;

  p_alu_func: process (clk)
  begin
    if rising_edge(clk) then
      alu_func <= 0;
      case inst_type is
        when T_R_TYPE =>
          alu_func <= to_integer(unsigned(ir(5 downto 2)));
        when T_I_TYPE =>
          alu_func <= to_integer(unsigned(ir(15 downto 12))) - 1;
        when others =>
      end case;
    end if;
  end process;

  p_operad_forwarding: process (clk)
  begin
    if rising_edge(clk) then
      operand_forward1 <= '0';
      operand_forward2 <= '0';
      if wb_reg = reg1_sel then
        operand_forward1 <= '1';
      elsif wb_reg = reg2_sel and inst_type /= T_I_TYPE then
        operand_forward2 <= '1';
      end if;
    end if;
  end process;

  p_wb_reg: process (clk)
  begin
    if rising_edge(clk) then
      wb_reg <= to_integer(unsigned(ir(11 downto 9)));
      case inst_type is
        when T_R_TYPE =>
          wb_we <= ir(1);
        when T_I_TYPE =>
          wb_we <= ir(8);
        when others =>
          wb_we <= '0';
      end case;
    end if;
  end process;
end architecture;

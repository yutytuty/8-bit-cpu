library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

library work;
  use work.types.all;

entity ID_stage is
  port (
    clk              : in     std_logic;
    ir               : in     std_logic_vector(15 downto 0);
    next_16          : in     std_logic_vector(15 downto 0);
    reg1             : in     std_logic_vector(15 downto 0);
    reg2             : in     std_logic_vector(15 downto 0);
    -- outputs for reg file
    reg1_sel         : buffer natural range 0 to 7;
    reg2_sel         : buffer natural range 0 to 7;
    -- outputs that go back into IF stage
    inst_was_I_type  : out    std_logic := 'Z';
    -- outputs for EX stage
    operand1         : out    std_logic_vector(15 downto 0);
    operand2         : out    std_logic_vector(15 downto 0);
    operand_forward1 : out    std_logic;
    operand_forward2 : out    std_logic;
    alu_func         : out    natural range 0 to 6;
    -- outputs for WB stage
    wb_reg           : buffer natural range 0 to 7;
    wb_we            : buffer std_logic := '0';
    -- outputs for jumps
    prev_pc          : in     std_logic_vector(15 downto 0);
    inst_is_j_type   : out    std_logic;
    jmp_type_o       : out    natural range 0 to 7;
    jmp_invert_flags : out    std_logic);
end entity;

architecture ID_stage_arch of ID_stage is
  signal inst_type : inst_type_t := T_UNKNOWN;
  signal jmp_type  : jmp_type_t  := T_JMP;
begin
  p_decode: process (ir)
    variable opcode : integer := 0;
  begin
    opcode := to_integer(unsigned(ir(15 downto 12)));
    if opcode = 0 then
      inst_type <= T_R_TYPE;
    elsif opcode = 1 then
      inst_type <= T_I_TYPE;
    elsif opcode >= 2 and opcode < 10 then
      inst_type <= T_J_TYPE;
    else
      inst_type <= T_UNKNOWN;
    end if;
  end process;

  -- This needs to be not sequential because it is not part of the pipeline
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
        reg2_sel <= 0;
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
          operand2 <= next_16;
        when T_J_TYPE =>
          operand1 <= prev_pc;
          operand2(10 downto 0) <= ir(10 downto 0);
          if ir(10) = '1' then
            operand2(15 downto 11) <= (others => '1');
          else
            operand2(15 downto 11) <= (others => '0');
          end if;
        when others =>
      end case;
    end if;
  end process;

  p_alu_func: process (clk)
  begin
    if rising_edge(clk) then
      alu_func <= AluFuncToNum(T_MOV);
      case inst_type is
        when T_R_TYPE =>
          alu_func <= to_integer(unsigned(ir(5 downto 2)));
        when T_I_TYPE =>
          alu_func <= to_integer(unsigned(ir(7 downto 4)));
        when T_J_TYPE =>
          alu_func <= AluFuncToNum(T_ADD);
        when others =>
      end case;
    end if;
  end process;

  p_operad_forwarding: process (clk)
  begin
    if rising_edge(clk) then
      if inst_type = T_J_TYPE then
        operand_forward1 <= '0';
        operand_forward2 <= '0';
      else
        operand_forward1 <= '0';
        operand_forward2 <= '0';
        if wb_reg = reg1_sel then
          operand_forward1 <= '1';
        elsif wb_reg = reg2_sel and inst_type /= T_I_TYPE then
          operand_forward2 <= '1';
        end if;
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

  p_inst_is_j_type: process (clk)
  begin
    if rising_edge(clk) then
      if inst_type = T_J_TYPE then
        inst_is_j_type <= '1';
        jmp_type_o <= JmpTypeToNum(jmp_type);
      else
        jmp_type_o <= JmpTypeToNum(T_JMP);
        inst_is_j_type <= '0';
      end if;
    end if;
  end process;

  p_jmp_type: process (inst_type, ir)
    variable opcode : integer := 0;
  begin
    opcode := to_integer(unsigned(ir(15 downto 12)));
    jmp_type <= T_JMP;
    jmp_invert_flags <= '0';
    if inst_type = T_J_TYPE then
      case opcode is
        when 2 => jmp_type <= T_JMP;
        when 3 => jmp_type <= T_JZ;
        when 4 => jmp_type <= T_JC;
        when 5 => jmp_type <= T_JS;
        when 6 => jmp_type <= T_JO;
        when 7 => jmp_type <= T_JA;
        when 8 => jmp_type <= T_JG;
        when 9 => jmp_type <= T_JGE;
        when others => jmp_type <= T_JMP;
      end case;
      jmp_invert_flags <= ir(11);
    end if;
  end process;
end architecture;

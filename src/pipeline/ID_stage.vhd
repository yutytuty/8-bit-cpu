library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

library work;
  use work.types.all;

entity ID_stage is
  port (
    clk                      : in     std_logic;
    ir                       : in     std_logic_vector(15 downto 0);
    next_16                  : in     std_logic_vector(15 downto 0);
    -- outputs that go back into IF stage
    inst_was_I_type          : out    std_logic := 'Z';
    -- outputs for EX stage
    operand1, operand2       : out    std_logic_vector(15 downto 0); -- EX can use this or value in register
    op1_use_reg, op2_use_reg : out    std_logic;
    reg1_sel_o               : out    natural range 0 to 7;
    reg2_sel_o               : out    natural range 0 to 7;
    operand_forward1         : out    std_logic;
    operand_forward2         : out    std_logic;
    alu_func                 : out    natural range 0 to 7;
    -- outputs for MEM stage
    mem_instruction_o        : out    std_logic;
    mem_read                 : out    std_logic;
    -- outputs for WB stage
    wb_reg                   : buffer natural range 0 to 7;
    wb_we                    : buffer std_logic := '0';
    -- outputs for jumps
    prev_pc                  : in     std_logic_vector(15 downto 0);
    inst_is_j_type           : out    std_logic;
    jmp_type_o               : out    natural range 0 to 7;
    jmp_invert_flags_o       : out    std_logic);
end entity;

architecture ID_stage_arch of ID_stage is
  signal inst_type          : inst_type_t := T_UNKNOWN;
  signal jmp_type           : jmp_type_t  := T_JMP;
  signal reg1_sel, reg2_sel : natural range 0 to 7;
  signal jmp_invert_flags   : std_logic   := '0';
  signal mem_instruction    : std_logic   := '0';
begin
  p_decode: process (ir)
    variable opcode : integer := 0;
  begin
    opcode := to_integer(unsigned(ir(15 downto 12)));
    mem_instruction <= '0';
    mem_read <= '0';
    if opcode = 0 then
      inst_type <= T_R_TYPE;
    elsif opcode = 1 then
      inst_type <= T_I_TYPE;
    elsif opcode >= 2 and opcode < 10 then
      inst_type <= T_J_TYPE;
    elsif opcode = 10 then
      inst_type <= T_R_TYPE;
      mem_instruction <= '1';
    elsif opcode = 11 then
      inst_type <= T_I_TYPE;
      mem_instruction <= '1';
    else
      inst_type <= T_UNKNOWN;
    end if;
  end process;

  process (clk)
  begin
    if rising_edge(clk) then
      mem_instruction_o <= mem_instruction;
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

  p_reg_sel_decode: process (clk)
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

  p_ex_reg_sel: process (clk)
  begin
    if rising_edge(clk) then
      reg1_sel_o <= reg1_sel;
      reg2_sel_o <= reg2_sel;
    end if;
  end process;

  process (clk)
  begin
    if rising_edge(clk) then
      op1_use_reg <= '0';
      op2_use_reg <= '0';
      case inst_type is
        when T_R_TYPE =>
          op1_use_reg <= '1';
          op2_use_reg <= '1';
        when T_I_TYPE =>
          op1_use_reg <= '1';
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
        jmp_invert_flags_o <= jmp_invert_flags;
      else
        jmp_type_o <= JmpTypeToNum(T_JMP);
        inst_is_j_type <= '0';
        jmp_invert_flags_o <= '0';
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

package types is
  type jmp_type_t is (T_JMP, T_JZ, T_JC, T_JS, T_JO, T_JA, T_JG, T_JGE);
  type alu_func_t is (T_MOV, T_ADD, T_SUB, T_AND, T_OR, T_XOR, T_NOT, T_NONE, T_UNKNOWN);
  type inst_type_t is (T_R_TYPE, T_I_TYPE, T_J_TYPE, T_UNKNOWN);

  function NumToAluFunc(num : natural range 0 to 7) return alu_func_t;
  function AluFuncToNum(func : alu_func_t) return natural;

  function NumToJmpType(num : natural range 0 to 7) return jmp_type_t;
  function JmpTypeToNum(jmp_type : jmp_type_t) return natural;
end package;

package body types is
  function NumToAluFunc(num : natural range 0 to 7) return alu_func_t is
  begin
    case num is
      when 0 => return T_MOV;
      when 1 => return T_ADD;
      when 2 => return T_SUB;
      when 3 => return T_AND;
      when 4 => return T_OR;
      when 5 => return T_XOR;
      when 6 => return T_NOT;
      when 7 => return T_NONE;
      when others => return T_UNKNOWN;
    end case;
  end function;

  function AluFuncToNum(func : alu_func_t) return natural is
  begin
    case func is
      when T_MOV => return 0;
      when T_ADD => return 1;
      when T_SUB => return 2;
      when T_AND => return 3;
      when T_OR => return 4;
      when T_XOR => return 5;
      when T_NOT => return 6;
      when T_NONE => return 7;
      when others => return 0;
    end case;
  end function;

  function NumToJmpType(num : natural range 0 to 7) return jmp_type_t is
  begin
    case num is
      when 0 => return T_JMP;
      when 1 => return T_JZ;
      when 2 => return T_JC;
      when 3 => return T_JS;
      when 4 => return T_JO;
      when 5 => return T_JA;
      when 6 => return T_JG;
      when 7 => return T_JGE;
    end case;
  end function;

  function JmpTypeToNum(jmp_type : jmp_type_t) return natural is
  begin
    case jmp_type is
      when T_JMP => return 0;
      when T_JZ => return 1;
      when T_JC => return 2;
      when T_JS => return 3;
      when T_JO => return 4;
      when T_JA => return 5;
      when T_JG => return 6;
      when T_JGE => return 7;
      when others => return 0;
    end case;
  end function;
end package body;

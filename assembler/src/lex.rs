#![allow(dead_code)]

use std::collections::HashMap;

use crate::error::Error;

pub type Result<T> = core::result::Result<T, Error>;

pub const RESERVED_CHARACTERS: &[char] = &[',', '+', '-', '*', '/', ';', '.', '%', '$'];
pub const BREAK_CHARACTERS: &[char] = &[',', '+', '-', '*', '/'];
const OFFSET_OPERATORS: &[char] = &['+', '-'];
const NOP: Instruction = Instruction::Mov(
    Operand::Register(Register::AR),
    Operand::Register(Register::AR),
);

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Register {
    AR,
    BR,
    CR,
    DR,
    SP,
    BP,
    PC,
    DS,
}

impl Register {
    pub fn from_string(s: &str) -> Result<Self> {
        match s.to_uppercase().as_str() {
            "AR" => Ok(Register::AR),
            "BR" => Ok(Register::BR),
            "CR" => Ok(Register::CR),
            "DR" => Ok(Register::DR),
            "SP" => Ok(Register::SP),
            "BP" => Ok(Register::BP),
            "PC" => Ok(Register::PC),
            "DS" => Ok(Register::DS),
            _ => Err(Error::UnknownRegister(None, s.to_string())),
        }
    }

    fn to_word(self) -> u16 {
        match self {
            Register::AR => 0,
            Register::BR => 1,
            Register::CR => 2,
            Register::DR => 3,
            Register::SP => 4,
            Register::BP => 5,
            Register::PC => 6,
            Register::DS => 7,
        }
    }
}

pub type Offset = i16;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Operand {
    Register(Register),
    RegisterAndOffset(Register, Offset),
    Imm(i16),
}

impl Operand {
    pub fn from_string(s: &str) -> Result<Self> {
        match s.chars().next() {
            Some('%') => {
                if s.chars().any(|c| OFFSET_OPERATORS.contains(&c)) {
                    Self::parse_register_and_offset(s)
                } else {
                    Self::parse_register(s)
                }
            }
            Some('$') => Self::parse_imm(s),
            Some(_) | None => Err(Error::ExpectedConstantOrRegister(None)),
        }
    }

    fn parse_register(s: &str) -> Result<Self> {
        match Register::from_string(s[1..].trim()) {
            Ok(reg) => Ok(Self::Register(reg)),
            Err(e) => Err(Error::CouldNotParseRegister(Some(Box::new(e)))),
        }
    }

    fn parse_imm(s: &str) -> Result<Self> {
        match Self::evaluate_expression(s.trim()) {
            Ok(imm) => Ok(Self::Imm(imm)),
            Err(e) => Err(Error::CouldNotParseConstant(
                Some(Box::new(e)),
                s.to_string(),
            )),
        }
    }

    fn parse_register_and_offset(s: &str) -> Result<Self> {
        let break_char = if let Some(c) = s.chars().find(|c| OFFSET_OPERATORS.contains(c)) {
            c
        } else {
            return Err(Error::ExpectedOffsetOperator(None));
        };
        if let Some((reg, imm)) = s.split_once(break_char) {
            match reg.chars().next() {
                Some('%') => Ok(Self::RegisterAndOffset(
                    match Register::from_string(reg[1..].trim()) {
                        Ok(reg) => reg,
                        Err(e) => return Err(Error::ExpectedAddress(Some(Box::new(e)))),
                    },
                    match Self::evaluate_expression(format!("${}", imm.trim()).as_str()) {
                        Ok(imm) => imm,
                        Err(e) => return Err(Error::ExpectedAddress(Some(Box::new(e)))),
                    },
                )),
                Some(_) | None => Err(Error::ExpectedRegister(None)),
            }
        } else {
            Err(Error::CouldNotParseOperand(None))
        }
    }

    const SUPPORTED_OPERATORS: [char; 4] = ['+', '-', '*', '/'];

    fn evaluate_expression(s: &str) -> Result<i16> {
        if s.starts_with('(') {
            todo!()
        } else {
            match s[1..].parse() {
                Ok(num) => Ok(num),
                Err(_) => Err(Error::CouldNotParseConstant(None, s.to_string())),
            }
        }
    }

    fn to_byte(self) -> u16 {
        match self {
            Self::Register(reg) => reg.to_word(),
            Self::Imm(imm) => imm as u16,
            Self::RegisterAndOffset(..) => todo!(),
        }
    }
}

pub type InvertFlags = bool;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Instruction {
    Mov(Operand, Operand),
    Add(Operand, Operand),
    Sub(Operand, Operand),
    And(Operand, Operand),
    Or(Operand, Operand),
    Xor(Operand, Operand),
    Mul(Operand, Operand),
    Not(Operand),
    Cmp(Operand, Operand),
    Ld(Operand, Operand),
    Sto(Operand, Operand),
    Jmp(i16, InvertFlags),
    Jz(i16, InvertFlags),
    Jc(i16, InvertFlags),
    Js(i16, InvertFlags),
    Jv(i16, InvertFlags),
    Ja(i16, InvertFlags),
    Jg(i16, InvertFlags),
    Jge(i16, InvertFlags),
}

macro_rules! parse_one_operand {
    ($instruction:expr, $op_str:expr) => {
        match Operand::from_string($op_str.trim()) {
            Ok(op) => match op {
                Operand::Register(_) | Operand::RegisterAndOffset(_, _) => Ok($instruction(op)),
                Operand::Imm(_) => Err(Error::ExpectedRegister(None)),
            },
            Err(e) => Err(Error::CouldNotParseOperand(Some(Box::new(e)))),
        }
    };
}

macro_rules! parse_two_operands {
    ($instruction:expr, $op_str:expr) => {
        if let Some((op1_str, op2_str)) = $op_str.split_once(',') {
            match Operand::from_string(op1_str.trim()) {
                Ok(op1) => match Operand::from_string(op2_str.trim()) {
                    Ok(op2) => Ok($instruction(op1, op2)),
                    Err(e) => Err(Error::CouldNotParseOperand(Some(Box::new(e)))),
                },
                Err(e) => Err(Error::CouldNotParseOperand(Some(Box::new(e)))),
            }
        } else {
            Err(Error::ExpectedOperands(None))
        }
    };
}

macro_rules! parse_jmp_operand {
    ($instruction:expr, $offset_str:expr, $params:expr) => {
        match Operand::from_string($offset_str.trim()) {
            Ok(op) => match op {
                Operand::Register(_) | Operand::RegisterAndOffset(_, _) => {
                    Err(Error::JumpMustHaveConstantAsOperand(None))
                }
                Operand::Imm(imm) => Ok($instruction(imm, $params)),
            },
            Err(e) => Err(Error::CouldNotParseOperand(Some(Box::new(e)))),
        }
    };
}

impl Instruction {
    pub fn parse(line: &str) -> Result<Self> {
        if let Some((instruction, operands)) = line.split_once(char::is_whitespace) {
            match instruction.to_uppercase().as_str().trim() {
                "MOV" => parse_two_operands!(Instruction::Mov, operands),
                "ADD" => parse_two_operands!(Instruction::Add, operands),
                "SUB" => parse_two_operands!(Instruction::Sub, operands),
                "AND" => parse_two_operands!(Instruction::Add, operands),
                "OR" => parse_two_operands!(Instruction::Or, operands),
                "NOT" => parse_one_operand!(Instruction::Not, operands),
                "XOR" => parse_two_operands!(Instruction::Xor, operands),
                "MUL" => parse_two_operands!(Instruction::Mul, operands),
                "CMP" => parse_two_operands!(Instruction::Cmp, operands),
                "LD" => parse_two_operands!(Instruction::Ld, operands),
                "STO" => parse_two_operands!(Instruction::Sto, operands),
                "JMP" => parse_jmp_operand!(Instruction::Jmp, operands, false),
                "JZ" => parse_jmp_operand!(Instruction::Jz, operands, false),
                "JNZ" => parse_jmp_operand!(Instruction::Jz, operands, true),
                "JC" => parse_jmp_operand!(Instruction::Jc, operands, false),
                "JNC" => parse_jmp_operand!(Instruction::Jc, operands, true),
                "JS" => parse_jmp_operand!(Instruction::Js, operands, false),
                "JNS" => parse_jmp_operand!(Instruction::Js, operands, true),
                "JV" => parse_jmp_operand!(Instruction::Jv, operands, false),
                "JNV" => parse_jmp_operand!(Instruction::Jv, operands, true),
                "JA" => parse_jmp_operand!(Instruction::Ja, operands, false),
                "JAE" => parse_jmp_operand!(Instruction::Jc, operands, true),
                "JB" => parse_jmp_operand!(Instruction::Jc, operands, false),
                "JBE" => parse_jmp_operand!(Instruction::Ja, operands, true),
                "JG" => parse_jmp_operand!(Instruction::Jg, operands, false),
                "JLE" => parse_jmp_operand!(Instruction::Jg, operands, true),
                "JGE" => parse_jmp_operand!(Instruction::Jge, operands, false),
                "JL" => parse_jmp_operand!(Instruction::Jge, operands, true),
                _ => Err(Error::UnknownInstruction(None, instruction.to_string())),
            }
        } else {
            todo!("Implement handling for no whitespace")
        }
    }

    const SEPERATORS: [char; 1] = [','];

    // Size of types of instructions in bytes
    const R_TYPE_SIZE: u16 = 1;
    const J_TYPE_SIZE: u16 = 4;
    const I_TYPE_SIZE: u16 = 2;

    pub fn size(&self) -> u16 {
        match self {
            Self::Not(..) => Self::R_TYPE_SIZE,
            Self::Mov(_, op2)
            | Self::Add(_, op2)
            | Self::Sub(_, op2)
            | Self::And(_, op2)
            | Self::Or(_, op2)
            | Self::Xor(_, op2)
            | Self::Mul(_, op2)
            | Self::Cmp(_, op2)
            | Self::Ld(_, op2)
            | Self::Sto(_, op2) => match op2 {
                Operand::Register(_) => Self::R_TYPE_SIZE,
                Operand::RegisterAndOffset(_, _) => Self::R_TYPE_SIZE,
                Operand::Imm(_) => Self::I_TYPE_SIZE,
            },
            Self::Jmp(_, _)
            | Self::Jz(_, _)
            | Self::Js(_, _)
            | Self::Jv(_, _)
            | Self::Jc(_, _)
            | Self::Ja(_, _)
            | Self::Jg(_, _)
            | Self::Jge(_, _) => Self::J_TYPE_SIZE,
        }
    }

    fn opcode(&self) -> u16 {
        match self {
            Self::Not(..) => 0,
            Self::Mov(_, op2)
            | Self::Add(_, op2)
            | Self::Sub(_, op2)
            | Self::And(_, op2)
            | Self::Or(_, op2)
            | Self::Xor(_, op2)
            | Self::Mul(_, op2)
            | Self::Cmp(_, op2) => match op2 {
                Operand::Register(_) => 0,
                Operand::Imm(_) => 1,
                Operand::RegisterAndOffset(_, _) => unreachable!(),
            },
            Self::Jmp(..) => 2,
            Self::Jz(..) => 3,
            Self::Jc(..) => 4,
            Self::Js(..) => 5,
            Self::Jv(..) => 6,
            Self::Ja(..) => 7,
            Self::Jg(..) => 8,
            Self::Jge(..) => 9,
            Self::Ld(_, address) | Self::Sto(_, address) => match address {
                Operand::Register(_) => 10,
                Operand::RegisterAndOffset(_, _) => 10,
                Operand::Imm(_) => 11,
            },
        }
    }

    fn alu_func(&self) -> u16 {
        match self {
            Self::Mov(..) => 0,
            Self::Add(..) => 1,
            Self::Sub(..) | Self::Cmp(..) => 2,
            Self::And(..) => 3,
            Self::Or(..) => 4,
            Self::Xor(..) => 5,
            Self::Not(..) => 6,
            Self::Mul(..) => 7,
            _ => panic!("Called alu_func on non alu function"), // Should not happen
        }
    }

    fn is_write_enabled(&self) -> bool {
        match self {
            Self::Mov(..)
            | Self::Add(..)
            | Self::Sub(..)
            | Self::And(..)
            | Self::Or(..)
            | Self::Not(..)
            | Self::Xor(..)
            | Self::Mul(..) => true,
            Self::Ld(..) => false,
            Self::Sto(..) => true,
            Self::Cmp(..) => false,
            Self::Jmp(..)
            | Self::Jz(..)
            | Self::Jc(..)
            | Self::Js(..)
            | Self::Jv(..)
            | Self::Ja(..)
            | Self::Jg(..)
            | Self::Jge(..) => panic!("Called is_write_enabled on jmp function"), // Does not matter for this type of function
        }
    }

    pub fn to_words(self) -> Result<Vec<u16>> {
        match self {
            Self::Mov(op1, op2)
            | Self::Add(op1, op2)
            | Self::Sub(op1, op2)
            | Self::Cmp(op1, op2)
            | Self::And(op1, op2)
            | Self::Or(op1, op2)
            | Self::Xor(op1, op2)
            | Self::Mul(op1, op2) => match op1 {
                Operand::Register(rd) => match op2 {
                    Operand::Register(rs) => Ok(vec![
                        self.is_write_enabled() as u16
                            | (self.alu_func() << 2)
                            | (rs.to_word() << 6)
                            | (rd.to_word() << 9)
                            | (self.opcode() << 12),
                    ]),
                    Operand::Imm(imm) => Ok(vec![
                        self.is_write_enabled() as u16
                            | (self.alu_func() << 5)
                            | (rd.to_word() << 9)
                            | (self.opcode() << 12),
                        imm as u16,
                    ]),
                    Operand::RegisterAndOffset(..) => Err(Error::ExpectedConstantOrRegister(None)),
                },
                Operand::Imm(..) | Operand::RegisterAndOffset(..) => {
                    Err(Error::ExpectedRegister(None))
                }
            },
            Self::Not(op) => match op {
                Operand::Register(reg) => Ok(vec![
                    self.is_write_enabled() as u16
                        | (self.alu_func() << 2)
                        | (reg.to_word() << 9)
                        | (self.opcode() << 12),
                ]),
                Operand::Imm(..) | Operand::RegisterAndOffset(..) => {
                    Err(Error::ExpectedRegister(None))
                }
            },
            Self::Jmp(offset, invert_flags)
            | Self::Jz(offset, invert_flags)
            | Self::Jc(offset, invert_flags)
            | Self::Js(offset, invert_flags)
            | Self::Jv(offset, invert_flags)
            | Self::Ja(offset, invert_flags)
            | Self::Jg(offset, invert_flags)
            | Self::Jge(offset, invert_flags) => Ok(vec![
                (offset as u16 & 0x7FF) | ((invert_flags as u16) << 11) | (self.opcode() << 12),
            ]),
            Self::Ld(data_op, addr_op) | Self::Sto(data_op, addr_op) => match data_op {
                Operand::Register(data_reg) => match addr_op {
                    Operand::Register(addr_reg) => Ok(vec![
                        self.is_write_enabled() as u16
                            | (addr_reg.to_word() << 6)
                            | (data_reg.to_word() << 9)
                            | (self.opcode() << 12),
                    ]),
                    Operand::RegisterAndOffset(addr_reg, addr_offset) => Ok(vec![
                        self.is_write_enabled() as u16
                            | ((addr_offset as u16) << 1)
                            | (addr_reg.to_word() << 6)
                            | (data_reg.to_word() << 9)
                            | (self.opcode() << 12),
                    ]),
                    Operand::Imm(addr) => Ok(vec![
                        self.is_write_enabled() as u16
                            | (data_reg.to_word() << 9)
                            | (self.opcode() << 12),
                        addr as u16,
                    ]),
                },
                Operand::RegisterAndOffset(..) | Operand::Imm(..) => {
                    Err(Error::ExpectedRegister(None))
                }
            },
        }
    }
}

pub type Name = String;
pub type Address = i16;

#[derive(Debug)]
pub struct SymbolTable {
    map: HashMap<Name, Address>,
}

impl SymbolTable {
    pub fn new() -> Self {
        Self {
            map: HashMap::new(),
        }
    }

    pub fn insert(&mut self, name: Name, address: Address) -> Result<()> {
        if self.label_exists(&name) {
            Err(Error::LabelAlreadyExists(None, name))
        } else {
            self.map.insert(name, address);
            Ok(())
        }
    }

    pub fn get(&self, name: &Name) -> Option<&Address> {
        self.map.get(name)
    }

    pub fn label_exists(&self, name: &Name) -> bool {
        self.map.contains_key(name)
    }
}

#[derive(Debug)]
pub struct Context {
    instructions: Vec<Instruction>,
    symbols: SymbolTable,
    size: u16,
}

impl Context {
    pub fn new() -> Self {
        Self {
            instructions: Vec::new(),
            symbols: SymbolTable::new(),
            size: 0,
        }
    }

    fn replace_labels_with_zero(&self, line: &str, label_start: char) -> Result<String> {
        let mut line = line.to_string();
        let mut label_search = line.to_string();
        while let Some((_, label_and_remaining)) = label_search.clone().split_once(label_start) {
            label_search = label_and_remaining.to_string();
            let break_index_option = label_and_remaining
                .chars()
                .enumerate()
                .find(|(_, c)| BREAK_CHARACTERS.contains(c))
                .map(|(i, _)| i);
            let label = if let Some(break_index) = break_index_option {
                label_and_remaining.split_at(break_index).0
            } else {
                label_and_remaining
            };
            line = line
                .clone()
                .replace(format!("{label_start}{label}").as_str(), "$0");
        }
        Ok(line)
    }

    fn solve_ld_data_hazard(&mut self, inst: &Instruction) -> Result<()> {
        if let Some(Instruction::Ld(Operand::Register(prev_reg), _)) = self.instructions.last() {
            match inst {
                Instruction::Mov(op1, op2)
                | Instruction::Add(op1, op2)
                | Instruction::Sub(op1, op2)
                | Instruction::And(op1, op2)
                | Instruction::Or(op1, op2)
                | Instruction::Xor(op1, op2)
                | Instruction::Mul(op1, op2)
                | Instruction::Cmp(op1, op2) => {
                    if let Operand::Register(reg1) = op1 {
                        if reg1 == prev_reg {
                            self.size += NOP.size();
                            self.instructions.push(NOP);
                            return Ok(());
                        }
                    } else {
                        return Err(Error::ExpectedRegister(None));
                    }
                    if let Operand::Register(reg2) = op2 {
                        if reg2 == prev_reg {
                            self.size += NOP.size();
                            self.instructions.push(NOP);
                            return Ok(());
                        }
                    }
                    if let Operand::RegisterAndOffset(reg2, _) = op2 {
                        if reg2 == prev_reg {
                            self.size += NOP.size();
                            self.instructions.push(NOP);
                            return Ok(());
                        }
                    }
                    return Ok(());
                }
                Instruction::Not(op1) => {
                    if let Operand::Register(reg1) = op1 {
                        if reg1 == prev_reg {
                            self.size += NOP.size();
                            self.instructions.push(NOP);
                            return Ok(());
                        }
                    } else {
                        return Err(Error::ExpectedRegister(None));
                    }
                }
                Instruction::Ld(op1, op2) | Instruction::Sto(op1, op2) => {
                    if let Operand::Register(reg1) = op1 {
                        if reg1 == prev_reg {
                            self.size += NOP.size();
                            self.instructions.push(NOP);
                            return Ok(());
                        }
                    } else {
                        return Err(Error::ExpectedRegister(None));
                    }
                    if let Operand::Register(reg2) = op2 {
                        if reg2 == prev_reg {
                            self.size += NOP.size();
                            self.instructions.push(NOP);
                            return Ok(());
                        }
                    }
                    if let Operand::RegisterAndOffset(reg2, _) = op2 {
                        if reg2 == prev_reg {
                            self.size += NOP.size();
                            self.instructions.push(NOP);
                            return Ok(());
                        }
                    }
                    return Ok(());
                }
                Instruction::Jmp(..)
                | Instruction::Jz(..)
                | Instruction::Jc(..)
                | Instruction::Js(..)
                | Instruction::Jv(..)
                | Instruction::Ja(..)
                | Instruction::Jg(..)
                | Instruction::Jge(..) => return Ok(()),
            }
        }
        Ok(())
    }

    fn solve_sto_data_hazard(&mut self, inst: &Instruction) -> Result<()> {
        if let Instruction::Sto(Operand::Register(reg1), op2) = inst {
            if let Some(inst) = self.instructions.last() {
                match inst {
                    Instruction::Mov(prev_op1, _)
                    | Instruction::Add(prev_op1, _)
                    | Instruction::Sub(prev_op1, _)
                    | Instruction::And(prev_op1, _)
                    | Instruction::Or(prev_op1, _)
                    | Instruction::Xor(prev_op1, _)
                    | Instruction::Not(prev_op1)
                    | Instruction::Mul(prev_op1, _)
                    | Instruction::Ld(prev_op1, _) => {
                        if let Operand::Register(prev_reg1) = prev_op1 {
                            if prev_reg1 == reg1 {
                                self.size += NOP.size();
                                self.instructions.push(NOP);
                                return Ok(());
                            }
                            match op2 {
                                Operand::Register(reg2) | Operand::RegisterAndOffset(reg2, _) => {
                                    if prev_reg1 == reg2 {
                                        self.size += NOP.size();
                                        self.instructions.push(NOP);
                                        return Ok(());
                                    }
                                }
                                Operand::Imm(..) => (),
                            }
                        } else {
                            return Err(Error::ExpectedRegister(None));
                        }
                    }
                    Instruction::Jmp(..)
                    | Instruction::Jz(..)
                    | Instruction::Jc(..)
                    | Instruction::Js(..)
                    | Instruction::Jv(..)
                    | Instruction::Ja(..)
                    | Instruction::Jg(..)
                    | Instruction::Jge(..)
                    | Instruction::Cmp(..)
                    | Instruction::Sto(..) => return Ok(()),
                }
            }
        }
        Ok(())
    }

    // TODO: add support for labels in expressions
    pub fn parse_ignore_labels(&mut self, instruction_line: &str) -> Result<()> {
        let mut line_trimmed = instruction_line.trim().to_string();
        if let Some((remaining, _)) = line_trimmed.split_once(';') {
            line_trimmed = remaining.trim().to_string();
        }
        while let Some((label, remaining)) = line_trimmed.clone().split_once(':') {
            line_trimmed = remaining.trim().to_string();
            if label.trim().contains(char::is_whitespace) {
                return Err(Error::LabelCannotContainWhitespace(None));
            }
            if label
                .trim()
                .chars()
                .any(|c| RESERVED_CHARACTERS.contains(&c))
            {
                return Err(Error::LabelIncludesReservedCharacter(None));
            }
            self.symbols.insert(label.to_string(), self.size as i16)?
        }
        if line_trimmed.trim().is_empty() {
            return Ok(());
        }
        line_trimmed = self.replace_labels_with_zero(line_trimmed.as_str(), '.')?;
        line_trimmed = self.replace_labels_with_zero(line_trimmed.as_str(), '@')?;
        let inst = Instruction::parse(line_trimmed.as_str())?;
        self.solve_ld_data_hazard(&inst)?;
        self.solve_sto_data_hazard(&inst)?;
        self.size += inst.size();
        self.instructions.push(inst);
        Ok(())
    }

    fn replace_lables<F: Fn(&i16) -> i16>(
        &self,
        line: &str,
        label_start: char,
        replace_calculation: F,
    ) -> Result<String> {
        let mut line = line.to_string();
        let mut label_search = line.to_string();
        while let Some((_, label_and_remaining)) = label_search.clone().split_once(label_start) {
            label_search = label_and_remaining.to_string();
            let break_index_option = label_and_remaining
                .chars()
                .enumerate()
                .find(|(_, c)| BREAK_CHARACTERS.contains(c))
                .map(|(i, _)| i);
            let label = if let Some(break_index) = break_index_option {
                label_and_remaining.split_at(break_index).0
            } else {
                label_and_remaining
            };

            let label_address = match self.symbols.get(&label.trim().to_string()) {
                Some(address) => address,
                None => return Err(Error::UnknownLabel(None, label.trim().to_string())),
            };
            line = line
                .replace(
                    format!("{label_start}{label}").as_str(),
                    format!("${}", replace_calculation(label_address)).as_str(),
                )
                .to_string();
        }
        Ok(line)
    }

    pub fn parse_line(&mut self, instruction_line: &str) -> Result<()> {
        let mut line = instruction_line.to_string();
        // Ignore comments
        if let Some((remaining, _)) = line.split_once(';') {
            line = remaining.to_string();
        }
        // Parse lables at start of line
        while let Some((label, remaining)) = line.split_once(':') {
            // ignore the error if it occures, parse_line should be used for the second run, after
            // all the symbols are parsed
            if let Ok(()) = self
                .symbols
                .insert(label.trim().to_string(), self.size as i16)
            {}
            line = remaining.to_string();
        }
        line = self.replace_lables(line.as_str(), '.', |label_address| *label_address)?;
        line = self.replace_lables(line.as_str(), '@', |label_address| {
            label_address - self.size as i16
        })?;
        // Replace lables that start with @ with the offset to them
        if line.trim().is_empty() {
            return Ok(());
        }
        match Instruction::parse(line.trim()) {
            Ok(inst) => {
                self.solve_ld_data_hazard(&inst)?;
                self.solve_sto_data_hazard(&inst)?;
                self.size += inst.size();
                self.instructions.push(inst);
                match inst {
                    Instruction::Jmp(..)
                    | Instruction::Jz(..)
                    | Instruction::Jc(..)
                    | Instruction::Js(..)
                    | Instruction::Jv(..)
                    | Instruction::Ja(..)
                    | Instruction::Jg(..)
                    | Instruction::Jge(..) => {
                        for _ in 0..3 {
                            self.instructions.push(NOP);
                        }
                    }
                    _ => (),
                }
                Ok(())
            }
            Err(e) => Err(e),
        }
    }

    pub fn prepare_second_run(&mut self) {
        self.size = 0;
        self.instructions.clear();
    }

    pub fn dump_image(&self) -> Vec<u16> {
        self.instructions
            .iter()
            .flat_map(|inst| inst.to_words().unwrap())
            .collect()
    }
}

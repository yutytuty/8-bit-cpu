#![allow(dead_code)]

use std::collections::HashMap;

use crate::error::Error;

pub type Result<T> = core::result::Result<T, Error>;

pub const RESERVED_CHARACTERS: &[char] = &[',', '+', '-', '*', '/', ';', '.', '%', '$'];
pub const BREAK_CHARACTERS: &[char] = &[',', '+', '-', '*', '/'];

#[derive(Debug)]
pub enum Register {
    AR,
    BR,
    CR,
    DR,
    SP,
    BP,
    PC,
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
            _ => Err(Error::UnknownRegister(None)),
        }
    }
}

#[derive(Debug)]
pub enum Operand {
    Register(Register),
    Imm(i16),
}

impl Operand {
    pub fn from_string(s: &str) -> Result<Self> {
        match s.chars().next() {
            Some('%') => match Register::from_string(s[1..].trim()).map(Operand::Register) {
                Ok(reg) => Ok(reg),
                Err(e) => Err(Error::CouldNotParseOperand(Some(Box::new(e)))),
            },
            Some('$') => match Self::evaluate_expression(s.trim()).map(Operand::Imm) {
                Ok(imm) => Ok(imm),
                Err(e) => Err(Error::CouldNotParseOperand(Some(Box::new(e)))),
            },
            Some(_) | None => Err(Error::ExpectedConstantOrRegister(None)),
        }
    }

    const SUPPORTED_OPERATORS: [char; 4] = ['+', '-', '*', '/'];

    fn evaluate_expression(s: &str) -> Result<i16> {
        if s.starts_with('(') {
            Err(Error::NotImplemented(
                "Evaluating mathematical expressions not implemented".to_string(),
            ))
        } else {
            Ok(s[1..].parse().unwrap())
        }
    }
}

pub type InvertFlags = bool;

#[derive(Debug)]
pub enum Instruction {
    Mov(Operand, Operand),
    Add(Operand, Operand),
    Sub(Operand, Operand),
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

macro_rules! parse_two_operands {
    ($instruction:expr, $op_str:expr) => {
        if let Some((op1_str, op2_str)) = $op_str.split_once(',') {
            match Operand::from_string(op1_str.trim()) {
                Ok(op1) => match Operand::from_string(op2_str.trim()) {
                    Ok(op2) => Ok($instruction(op1, op2)),
                    Err(e) => Err(Error::InvalidNumberOfOperands(Some(Box::new(e)))),
                },
                Err(e) => Err(Error::InvalidNumberOfOperands(Some(Box::new(e)))),
            }
        } else {
            Err(Error::ExpectedOperands(None))
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
                "LD" => parse_two_operands!(Instruction::Ld, operands),
                "STO" => parse_two_operands!(Instruction::Sto, operands),
                _ => Err(Error::UnknownInstruction(None)),
            }
        } else {
            todo!("Implement handling for no whitespace")
        }
    }

    const SEPERATORS: [char; 1] = [','];

    // Size of types of instructions in bytes
    const R_TYPE_SIZE: u16 = 1;
    const J_TYPE_SIZE: u16 = 1;
    const I_TYPE_SIZE: u16 = 2;

    pub fn size(&self) -> u16 {
        match self {
            Self::Mov(_, op2)
            | Self::Add(_, op2)
            | Self::Sub(_, op2)
            | Self::Ld(_, op2)
            | Self::Sto(_, op2) => match op2 {
                Operand::Register(_) => Self::R_TYPE_SIZE,
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
        let mut label_search = line_trimmed.clone();
        // replace label with name
        while let Some((_, label_and_remaining)) = label_search.clone().split_once('.') {
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
            line_trimmed = line_trimmed
                .clone()
                .replace(format!(".{label}").as_str(), "$0");
        }
        let inst = Instruction::parse(line_trimmed.as_str())?;
        self.size += inst.size();
        self.instructions.push(inst);
        Ok(())
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
        let mut label_search = line.clone();
        // Replace lables with offset to them
        while let Some((_, label_and_remaining)) = label_search.clone().split_once('.') {
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
            line = line.replace(
                format!(".{label}").as_str(),
                format!("${}", label_address - self.size as i16).as_str(),
            );
        }
        if line.trim().is_empty() {
            return Ok(());
        }
        match Instruction::parse(line.trim()) {
            Ok(inst) => {
                self.size += inst.size();
                self.instructions.push(inst);
                Ok(())
            }
            Err(e) => Err(e),
        }
    }

    pub fn prepare_second_run(&mut self) {
        self.size = 0;
        self.instructions.clear();
    }
}

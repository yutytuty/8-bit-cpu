#![allow(dead_code)]

use std::collections::HashMap;

use crate::error::Error;

pub type Result<T> = core::result::Result<T, Error>;

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
            Err(Error::NotImplemented("TODO".to_string()))
        }
    }

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

#[derive(Debug)]
pub struct Context {
    instructions: Vec<Instruction>,
    lables: HashMap<String, u16>,
    size: u16,
}

impl Context {
    pub fn new() -> Self {
        Self {
            instructions: Vec::new(),
            lables: HashMap::new(),
            size: 0,
        }
    }

    pub fn parse_line(&mut self, instruction_line: &str) -> Result<()> {
        let mut line = instruction_line;
        // Parse lables
        if let Some((label, remaining)) = instruction_line.split_once(':') {
            self.lables.insert(label.trim().to_string(), self.size);
            line = remaining;
        }
        // Ignore comments
        if let Some((remaining, _)) = line.split_once(';') {
            line = remaining;
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
}

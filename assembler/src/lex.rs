#![allow(dead_code)]

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

#[derive(Debug)]
pub enum Operand {
    Register(Register),
    Imm(i16),
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
            // let mut chars = s.chars();

            // let mut num_str = String::new();
            // while let Some(c) = chars.next() {
            //   if c.is_whitespace() {
            //     break;
            //   } else if c.is_digit(10) {
            //     num_str.push(c);
            //   } else if Self::SUPPORTED_OPERATORS.contains(&c) {
            //     break;
            //   } else {
            //     return Err(Error::InvalidTokenInConstant);
            //   }
            // }
        } else {
            Ok(s[1..].parse().unwrap())
        }
    }
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
}

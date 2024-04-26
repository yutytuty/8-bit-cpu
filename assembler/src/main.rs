use std::{
    fs::File,
    io::{BufRead, BufReader},
};

use crate::error::Error;
use crate::lex::Instruction;

mod error;
mod lex;

pub type Result<T> = core::result::Result<T, Error>;

const FILE_PATH: &str = "code.y";

fn main() -> Result<()> {
    let file = match File::open(FILE_PATH) {
        Ok(f) => f,
        Err(e) => return Err(Error::IO(e)),
    };
    let reader = BufReader::new(file);

    for line_result in reader.lines() {
        let line = match line_result {
            Ok(l) => l,
            Err(e) => return Err(Error::IO(e)),
        };
        // Skip empty lines
        if line.trim().is_empty() {
            continue;
        }
        println!("{:?}", Instruction::parse(line.as_str()));
    }
    Ok(())
}

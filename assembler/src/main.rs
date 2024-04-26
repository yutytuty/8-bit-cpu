use std::{
    fs::File,
    io::{BufRead, BufReader},
};

use lex::Context;

use crate::error::Error;

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
    let mut ctx = Context::new();

    for line_result in reader.lines() {
        let line = match line_result {
            Ok(l) => l,
            Err(e) => return Err(Error::IO(e)),
        };
        ctx.parse_line(line.as_str())?;
    }
    println!("Context: {ctx:?}");
    Ok(())
}

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
    let mut code = String::new();
    for line_result in reader.lines() {
        match line_result {
            Ok(line) => code.push_str(format!("{line}\n").as_str()),
            Err(e) => return Err(Error::IO(e)),
        }
    }

    // First pass to get symbols
    println!("Starting first run");
    let mut ctx = Context::new();
    for line in code.lines() {
        ctx.parse_ignore_labels(line)?;
    }
    // Second pass to parse all instructions
    println!("Starting second run");
    ctx.prepare_second_run();
    for line in code.lines() {
        ctx.parse_line(line)?;
    }
    dbg!(ctx);

    Ok(())
}

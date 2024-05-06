use std::{
    fs::File,
    io::{BufRead, BufReader},
};

use lex::Context;

use crate::{error::Error, file_format::to_modelsim_hex};

mod error;
mod file_format;
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
    let mut ctx = Context::new();
    for (i, line) in code.lines().enumerate() {
        match ctx.parse_ignore_labels(line) {
            Ok(_) => (),
            Err(e) => {
                println!("Error at line {}: {e:?}", i + 1);
                return Err(e);
            }
        }
    }
    // Second pass to parse all instructions
    ctx.prepare_second_run();
    for (i, line) in code.lines().enumerate() {
        match ctx.parse_line(line) {
            Ok(_) => (),
            Err(e) => {
                println!("Error at line {}: {e:?}", i + 1);
                return Err(e);
            }
        }
    }
    dbg!(&ctx);
    let img = ctx.dump_image();
    // to_mif(img, 0x4000, "sort.mif")?;
    to_modelsim_hex(img, 0x4000, "sort.mem")?;

    Ok(())
}

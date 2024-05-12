use std::{
    fs::File,
    io::{BufRead, BufReader},
    path::PathBuf,
};

use clap::value_parser;
use clap::{command, Arg};
use file_format::to_mif;
use lex::Context;

use crate::{error::Error, file_format::to_modelsim_hex};

mod error;
mod file_format;
mod lex;

pub type Result<T> = core::result::Result<T, Error>;

fn main() -> Result<()> {
    let results = command!()
        .about("Assembler for my custom 16 bit CPU")
        .arg(
            Arg::new("path")
                .required(true)
                .help("Path to program file")
                .value_parser(value_parser!(PathBuf)),
        )
        .arg(
            Arg::new("output_file")
                .help("Path to output file")
                .short('o')
                .long("output"),
        )
        .arg(
            Arg::new("format")
                .short('f')
                .long("format")
                .help("Output format, mif or hex")
                .default_value("mif"),
        )
        .get_matches();
    if let Some(path) = results.get_one::<PathBuf>("path") {
        let file = match File::open(path) {
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
        let img = ctx.dump_image();
        if let Some(format) = results.get_one::<String>("format") {
            match format.to_lowercase().as_str() {
                "mif" => {
                    if let Some(output_path) = results.get_one::<String>("output_file") {
                        to_mif(img, 0x4000, output_path)?;
                    } else {
                        to_mif(img, 0x4000, "prog.mif")?;
                    }
                }
                "hex" => {
                    if let Some(output_path) = results.get_one::<String>("output_file") {
                        to_modelsim_hex(img, 0x4000, output_path)?;
                    } else {
                        to_modelsim_hex(img, 0x4000, "prog.hex")?;
                    }
                }
                _ => return Err(Error::UnknownFormat),
            }
        }
    }

    Ok(())
}

#![allow(dead_code)]

use std::{fs::File, io::Write};

use crate::error::Error;

pub type Result<T> = core::result::Result<T, Error>;

/// Assumes word size is 16 bits
pub fn to_mif(img: Vec<u16>, depth: usize, path: &str) -> Result<()> {
    let mut file = match File::create(path) {
        Ok(f) => f,
        Err(e) => return Err(Error::IO(e)),
    };
    let header = format!("WIDTH=16;\nDEPTH={depth};\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n\n");
    let mut content = String::new();
    content.push_str("CONTENT BEGIN\n");
    for (i, word) in img.iter().enumerate() {
        content.push_str(format!("	{i}    :   {word};\n").as_str());
    }
    content.push_str(format!("	[{}..{}]  :   0;\n", img.len(), depth - 1).as_str());
    content.push_str("END;\n");
    let final_str = format!("{header}{content}");
    match file.write_all(final_str.as_bytes()) {
        Ok(_) => (),
        Err(e) => return Err(Error::IO(e)),
    };
    Ok(())
}

pub fn to_modelsim_hex(img: Vec<u16>, depth: usize, path: &str) -> Result<()> {
    let mut file = match File::create(path) {
        Ok(f) => f,
        Err(e) => return Err(Error::IO(e)),
    };
    let mut content = String::new();
    for (i, word) in img.iter().enumerate() {
        if i % 16 == 0 && i != 0 {
            content.push('\n');
        }
        content.push_str(format!("{word:04X}").as_str());
        if i % 16 != 15 {
            content.push(' ');
        }
    }
    for i in img.len()..depth {
        if i % 16 == 0 && i != 0 {
            content.push('\n');
        }
        content.push_str(r#"0000"#);
        if i % 16 != 15 {
            content.push(' ');
        }
    }
    file.write_all(content.as_bytes()).unwrap();
    Ok(())
}

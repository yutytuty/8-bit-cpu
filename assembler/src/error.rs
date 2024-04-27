#[derive(Debug)]
pub enum Error {
    UnknownRegister(Option<Box<Error>>),
    ExpectedConstantOrRegister(Option<Box<Error>>),
    #[allow(dead_code)]
    InvalidTokenInConstant(Option<Box<Error>>),
    InvalidNumberOfOperands(Option<Box<Error>>),
    UnknownInstruction(Option<Box<Error>>),
    ExpectedOperands(Option<Box<Error>>),
    CouldNotParseOperand(Option<Box<Error>>),
    LabelCannotContainWhitespace(Option<Box<Error>>),
    LabelIncludesReservedCharacter(Option<Box<Error>>),
    LabelAlreadyExists(Option<Box<Error>>, String),
    UnknownLabel(Option<Box<Error>>, String),

    IO(std::io::Error),

    NotImplemented(String),
}

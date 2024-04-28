#[derive(Debug)]
pub enum Error {
    UnknownRegister(Option<Box<Error>>, String),
    ExpectedConstantOrRegister(Option<Box<Error>>),
    ExpectedRegister(Option<Box<Error>>),
    ExpectedOffsetOperator(Option<Box<Error>>),
    ExpectedAddress(Option<Box<Error>>),
    #[allow(dead_code)]
    InvalidTokenInConstant(Option<Box<Error>>),
    UnknownInstruction(Option<Box<Error>>, String),
    ExpectedOperands(Option<Box<Error>>),
    CouldNotParseOperand(Option<Box<Error>>),
    CouldNotParseRegister(Option<Box<Error>>),
    CouldNotParseConstant(Option<Box<Error>>, String),
    LabelCannotContainWhitespace(Option<Box<Error>>),
    LabelIncludesReservedCharacter(Option<Box<Error>>),
    LabelAlreadyExists(Option<Box<Error>>, String),
    UnknownLabel(Option<Box<Error>>, String),
    JumpMustHaveConstantAsOperand(Option<Box<Error>>),

    IO(std::io::Error),

    NotImplemented(String),
}

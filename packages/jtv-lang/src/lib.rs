// Julia the Viper - Core Language Implementation
// Harvard Architecture: Control (Turing-complete) + Data (Total)

pub mod ast;
pub mod parser;
pub mod interpreter;
pub mod number;
pub mod error;
pub mod wasm;

pub use ast::*;
pub use parser::*;
pub use interpreter::*;
pub use number::*;
pub use error::*;

#[cfg(target_arch = "wasm32")]
pub use wasm::*;

import gleam/bool
import lenient_parse/internal/base_constants.{base_0, base_10}
import lenient_parse/internal/parser
import lenient_parse/internal/tokenizer
import parse_error.{type ParseError, InvalidBaseValue}

/// Converts a string to a float using a more lenient parsing method than
/// gleam's `float.parse()`. It behaves similarly to Python's `float()` built-in
/// function.
pub fn to_float(text text: String) -> Result(Float, ParseError) {
  text |> tokenizer.tokenize_float |> parser.parse_float_tokens
}

/// Converts a string to an integer using a more lenient parsing method than
/// gleam's `int.parse()`. It behaves similarly to Python's `int()` built-in
/// function, using a default base of 10.
pub fn to_int(text text: String) -> Result(Int, ParseError) {
  text |> to_int_with_base(base: base_10)
}

/// Converts a string to an integer using a more lenient parsing method than
/// gleam's `int.parse()`, allowing for a specified base. It behaves similarly
/// to Python's `int()` built-in function with a base parameter.
pub fn to_int_with_base(
  text text: String,
  base base: Int,
) -> Result(Int, ParseError) {
  let is_valid_base = base == base_0 || { base >= 2 && base <= 36 }
  use <- bool.guard(!is_valid_base, Error(InvalidBaseValue(base)))

  text
  |> tokenizer.tokenize_int
  |> parser.parse_int_tokens(base: base)
}

import gleam/bool
import lenient_parse/internal/base_constants.{base_0, base_10}
import lenient_parse/internal/parser
import lenient_parse/internal/tokenizer
import parse_error.{type ParseError, InvalidBaseValue}

/// Converts a string to a float.
pub fn to_float(text text: String) -> Result(Float, ParseError) {
  text |> tokenizer.tokenize_float |> parser.parse_float_tokens
}

/// Converts a string to an integer using a default base of 10.
pub fn to_int(text text: String) -> Result(Int, ParseError) {
  text |> to_int_with_base(base: base_10)
}

/// Converts a string to an integer with a specified base.
///
/// The base must be between 2 and 36 (inclusive), or 0. When the base is set to
/// 0, the base is inferred from the prefix specifier, if one is present. If no
/// prefix specifier is present, base 10 is used.
pub fn to_int_with_base(
  text text: String,
  base base: Int,
) -> Result(Int, ParseError) {
  let is_valid_base = base == base_0 || { base >= 2 && base <= 36 }
  use <- bool.guard(!is_valid_base, Error(InvalidBaseValue(base)))

  text
  |> tokenizer.tokenize_int
  |> parser.parse_int_tokens(base)
}

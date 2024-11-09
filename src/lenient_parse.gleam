import lenient_parse/internal/parse
import parse_error.{type ParseError}

/// Converts a string to a float using a more lenient parsing method than
/// gleam's `float.parse()`. It behaves similarly to Python's `float()` built-in
/// function.
pub fn to_float(text text: String) -> Result(Float, ParseError) {
  text |> parse.parse_float
}

/// Converts a string to an integer using a more lenient parsing method than
/// gleam's `int.parse()`. It behaves similarly to Python's `int()` built-in
/// function, using a default base of 10.
pub fn to_int(text text: String) -> Result(Int, ParseError) {
  text |> parse.parse_int(base: 10)
}

/// Converts a string to an integer using a more lenient parsing method than
/// gleam's `int.parse()`, allowing for a specified base. It behaves similarly
/// to Python's `int()` built-in function with a base parameter.
pub fn to_int_with_base(
  text text: String,
  base base: Int,
) -> Result(Int, ParseError) {
  text |> parse.parse_int(base: base)
}

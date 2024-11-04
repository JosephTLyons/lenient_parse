import gleam/float
import gleam/int
import gleam/result
import lenient_parse/internal/parse
import parse_error.{type ParseError, GleamFloatParseError, GleamIntParseError}

/// Converts a string to a float using a more lenient parsing method than gleam's `float.parse()`. It behaves similarly to Python's `float()` built-in function.
///
/// ## Examples
///
/// ```gleam
/// lenient_parse.to_float("1.001")    // -> Ok(1.001)
/// lenient_parse.to_float("1")        // -> Ok(1.0)
/// lenient_parse.to_float("1.")       // -> Ok(1.0)
/// lenient_parse.to_float("1.0")      // -> Ok(1.0)
/// lenient_parse.to_float(".1")       // -> Ok(0.1)
/// lenient_parse.to_float("0.1")      // -> Ok(0.1)
/// lenient_parse.to_float("+123.321") // -> Ok(123.321)
/// lenient_parse.to_float("-123.321") // -> Ok(-123.321)
/// lenient_parse.to_float(" 1.0 ")    // -> Ok(1.0)
/// lenient_parse.to_float("1_000.0")  // -> Ok(1.0e3)
/// lenient_parse.to_float("")         // -> Error(EmptyString)
/// lenient_parse.to_float(" ")        // -> Error(WhitespaceOnlyString)
/// lenient_parse.to_float("abc")      // -> Error(InvalidCharacter("a", 0))
/// ```
pub fn to_float(text: String) -> Result(Float, ParseError) {
  let text = text |> parse.parse_float
  use text <- result.try(text)
  let res = text |> float.parse |> result.replace_error(GleamFloatParseError)
  use <- result.lazy_or(res)

  text
  |> int.parse
  |> result.map(int.to_float)
  |> result.replace_error(GleamIntParseError)
}

/// Converts a string to an integer using a more lenient parsing method than gleam's `int.parse()`.
/// It behaves similarly to Python's `int()` built-in function.
///
/// ## Examples
///
/// ```gleam
/// lenient_parse.to_int("123")   // -> Ok(123)
/// lenient_parse.to_int("+123")  // -> Ok(123)
/// lenient_parse.to_int("-123")  // -> Ok(-123)
/// lenient_parse.to_int("0123")  // -> Ok(123)
/// lenient_parse.to_int(" 123 ") // -> Ok(123)
/// lenient_parse.to_int("1_000") // -> Ok(1000)
/// lenient_parse.to_int("")      // -> Error(EmptyString)
/// lenient_parse.to_int("1.0")   // -> Error(InvalidDecimalPosition(1))
/// lenient_parse.to_int("abc")   // -> Error(InvalidCharacter("a", 0))
/// ```
pub fn to_int(text: String) -> Result(Int, ParseError) {
  use text <- result.try(text |> parse.parse_int)
  text |> int.parse |> result.replace_error(GleamIntParseError)
}

import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import gleam/set
import gleam/string

pub const digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

pub const valid_characters = [
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "_", "+", "-",
]

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
/// lenient_parse.to_float("1_000.0")  // -> Ok(1000.0)
/// lenient_parse.to_float(" ")        // -> Error(Nil)
/// lenient_parse.to_float("")         // -> Error(Nil)
/// lenient_parse.to_float("abc")      // -> Error(Nil)
/// ```
pub fn to_float(text: String) -> Result(Float, Nil) {
  use text <- result.try(text |> common_sanitize)
  use _ <- result.try_recover(text |> float.parse)
  use _ <- result.try_recover(text |> int.parse |> result.map(int.to_float))

  let res = case string.first(text) {
    Ok(".") -> float.parse("0" <> text)
    _ -> Error(Nil)
  }

  use <- result.lazy_or(res)

  case string.last(text) {
    Ok(".") -> float.parse(text <> "0")
    _ -> Error(Nil)
  }
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
/// lenient_parse.to_int("")      // -> Error(Nil)
/// lenient_parse.to_int("1.0")   // -> Error(Nil)
/// lenient_parse.to_int("abc")   // -> Error(Nil)
/// ```
pub fn to_int(text: String) -> Result(Int, Nil) {
  text |> common_sanitize |> result.try(int.parse)
}

pub type ParseError {
  InvalidCharacter(String)
  WhitespaceOnlyOrEmptyString
  LeadingUnderscore
  TrailingUnderscore
  UnderscoreNextToDecimal
  AdjacentUnderscores
}

@internal
pub fn coerce_into_valid_number_string(
  text: String,
) -> Result(String, ParseError) {
  let text = text |> string.trim
  use <- bool.guard(text |> string.is_empty, Error(WhitespaceOnlyOrEmptyString))
  use _ <- result.try(text |> has_valid_characters)
  use _ <- result.try(text |> check_for_valid_underscore_position)
  Ok(text)
}

@internal
pub fn check_for_valid_underscore_position(
  text: String,
) -> Result(Nil, ParseError) {
  text
  |> string.to_graphemes
  |> do_check_for_valid_underscore_position(previous: None)
}

// fn do_check_for_valid_underscore_position(
//   characters: List(String),
//   previous previous: Option(String),
// ) -> Result(Nil, ParseError) {
//   case characters {
//     [] ->
//       case previous {
//         Some("_") -> Error(TrailingUnderscore)
//         _ -> Ok(Nil)
//       }
//     [first, ..rest] -> {
//       case first, previous {
//         "_", None -> Error(LeadingUnderscore)
//         "_", Some("_") -> Error(AdjacentUnderscores)
//         ".", Some("_") | "_", Some(".") -> Error(UnderscoreNextToDecimal)
//         _, _ ->
//           do_check_for_valid_underscore_position(rest, previous: Some(first))
//       }
//     }
//   }
// }

fn do_check_for_valid_underscore_position(
  characters: List(String),
  previous previous: Option(String),
) -> Result(Nil, ParseError) {
  case characters {
    [] ->
      case previous {
        Some("_") -> Error(TrailingUnderscore)
        _ -> Ok(Nil)
      }
    [first, ..rest] -> {
      case first, previous {
        "_", None -> Error(LeadingUnderscore)
        "_", Some("_") -> Error(AdjacentUnderscores)
        ".", Some("_") | "_", Some(".") -> Error(UnderscoreNextToDecimal)
        _, _ ->
          do_check_for_valid_underscore_position(rest, previous: Some(first))
      }
    }
  }
}

pub fn is_digit(text: String) -> Bool {
  let digits = digits |> set.from_list
  digits |> set.contains(text)
}

@internal
pub fn has_valid_characters(text: String) -> Result(Nil, ParseError) {
  let graphemes = text |> string.to_graphemes
  let valid_characters = valid_characters |> set.from_list
  list.try_map(graphemes, fn(grapheme) {
    case valid_characters |> set.contains(grapheme) {
      True -> Ok(Nil)
      False -> Error(InvalidCharacter(grapheme))
    }
  })
  |> result.map(fn(_) { Nil })
}

fn common_sanitize(text: String) -> Result(String, Nil) {
  use <- bool.guard(!is_valid_number_string(text), Error(Nil))
  let text = text |> string.trim |> string.replace("_", "")
  use <- bool.guard(text |> string.is_empty, Error(Nil))
  text |> Ok
}

@internal
pub fn is_valid_number_string(text: String) -> Bool {
  // ^        - Start of string
  // \s*      - Optional whitespace at the beginning
  // [+-]?    - Optional plus or minus sign
  // (?!.*__) - Negative lookahead to prevent double underscores
  // (?!_)    - Negative lookahead to prevent leading underscore
  // (?!^\s*[+-]?_\s*$) - Negative lookahead to prevent just an underscore
  // [0-9_]*  - Zero or more digits or underscores
  // (?<!_)   - Negative lookbehind to prevent trailing underscore before decimal point
  // \.?      - Optional decimal point
  // (?!_)    - Negative lookahead to prevent underscore immediately after decimal point
  // [0-9_]*  - Zero or more digits or underscores after decimal point
  // (?<!_)   - Negative lookbehind to prevent trailing underscore
  // \s*      - Optional whitespace at the end
  // $        - End of string
  let pattern =
    "^\\s*[+-]?(?!_)(?!.*__)(?!^\\s*[+-]?_\\s*$)[0-9_]*(?<!_)\\.?(?!_)[0-9_]*(?<!_)\\s*$"

  case regex.from_string(pattern) {
    Ok(re) -> regex.check(with: re, content: text)
    Error(_) -> False
  }
}

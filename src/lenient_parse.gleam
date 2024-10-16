import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
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
/// lenient_parse.to_float("1_000.0")  // -> Ok(1.0e3)
/// lenient_parse.to_float(" ")        // -> Error(WhitespaceOnlyOrEmptyString)
/// lenient_parse.to_float("")         // -> Error(WhitespaceOnlyOrEmptyString)
/// lenient_parse.to_float("abc")      // -> Error(InvalidCharacter("a"))
/// ```
pub fn to_float(text: String) -> Result(Float, ParseError) {
  let text = text |> coerce_into_valid_number_string
  use text <- result.try(text)
  let res = text |> float.parse |> result.replace_error(GleamFloatParseError)
  use _ <- result.try_recover(res)
  text
  |> int.parse
  |> result.replace_error(GleamIntParseError)
  |> result.map(int.to_float)
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
/// lenient_parse.to_int("")      // -> Error(WhitespaceOnlyOrEmptyString)
/// lenient_parse.to_int("1.0")   // -> Error(GleamIntParseError)
/// lenient_parse.to_int("abc")   // -> Error(InvalidCharacter("a"))
/// ```
pub fn to_int(text: String) -> Result(Int, ParseError) {
  use text <- result.try(text |> coerce_into_valid_number_string)
  text |> int.parse |> result.replace_error(GleamIntParseError)
}

pub type ParseError {
  /// Represents an error when an invalid character is encountered during
  /// parsing. The `String` parameter contains the invalid character.
  InvalidCharacter(String)

  /// Represents an error when the input string is empty or contains only
  /// whitespace.
  WhitespaceOnlyOrEmptyString

  /// Represents an error when an underscore is in an invalid position within
  /// the number string.
  InvalidUnderscorePosition

  /// Represents an error when a decimal point is in an invalid position within
  /// the number string.
  InvalidDecimalPosition

  /// Represents an error when Gleam's `float.parse` fails after custom parsing
  /// and coercion. Indicates the string couldn't be converted to a float even
  /// with more permissive rules.
  GleamFloatParseError

  /// Represents an error when Gleam's `int.parse` fails after custom parsing
  /// and coercion. Indicates the string couldn't be converted to a float even
  /// with more permissive rules.
  GleamIntParseError
}

@internal
pub fn coerce_into_valid_number_string(
  text: String,
) -> Result(String, ParseError) {
  let text = text |> string.trim
  use <- bool.guard(text |> string.is_empty, Error(WhitespaceOnlyOrEmptyString))
  use _ <- result.try(
    text |> has_valid_characters(valid_characters |> set.from_list),
  )
  use text <- result.try(text |> coerce_into_valid_underscore_string)
  text |> coerce_into_valid_decimal_string
}

@internal
pub fn coerce_into_valid_underscore_string(
  text: String,
) -> Result(String, ParseError) {
  text
  |> string.to_graphemes
  |> do_coerce_into_valid_underscore_string(
    previous: None,
    digits: digits |> set.from_list,
    acc: "",
  )
}

fn do_coerce_into_valid_underscore_string(
  characters: List(String),
  previous previous: Option(String),
  digits digits: Set(String),
  acc acc: String,
) -> Result(String, ParseError) {
  case characters {
    [] -> {
      use <- bool.guard(previous == Some("_"), Error(InvalidUnderscorePosition))
      Ok(acc |> string.reverse)
    }
    [first, ..rest] -> {
      case first, previous {
        "_", None -> Error(InvalidUnderscorePosition)
        a, Some("_") ->
          case digits |> set.contains(a) {
            True ->
              do_coerce_into_valid_underscore_string(
                rest,
                previous: Some(first),
                digits: digits,
                acc: first <> acc,
              )
            False -> Error(InvalidUnderscorePosition)
          }
        "_", Some(a) ->
          case digits |> set.contains(a) {
            True ->
              do_coerce_into_valid_underscore_string(
                rest,
                previous: Some(first),
                digits: digits,
                acc: acc,
              )
            False -> Error(InvalidUnderscorePosition)
          }
        _, _ ->
          do_coerce_into_valid_underscore_string(
            rest,
            previous: Some(first),
            digits: digits,
            acc: first <> acc,
          )
      }
    }
  }
}

@internal
pub fn has_valid_characters(
  text: String,
  valid_characters: Set(String),
) -> Result(Nil, ParseError) {
  let graphemes = text |> string.to_graphemes
  list.try_map(graphemes, fn(grapheme) {
    case valid_characters |> set.contains(grapheme) {
      True -> Ok(Nil)
      False -> Error(InvalidCharacter(grapheme))
    }
  })
  |> result.replace(Nil)
}

@internal
pub fn coerce_into_valid_decimal_string(
  text: String,
) -> Result(String, ParseError) {
  let text_length = text |> string.length

  text
  |> string.to_graphemes
  |> do_coerce_into_valid_decimal_string(
    text_length: text_length,
    previous: None,
    seen_decimal: False,
    acc: "",
  )
}

fn do_coerce_into_valid_decimal_string(
  characters: List(String),
  text_length text_length: Int,
  previous previous: Option(String),
  seen_decimal seen_decimal: Bool,
  acc acc: String,
) -> Result(String, ParseError) {
  case characters {
    [] -> {
      case previous {
        Some(".") -> Ok("0" <> acc)
        _ -> Ok(acc)
      }
      |> result.map(string.reverse)
    }
    [first, ..rest] -> {
      case first, previous {
        ".", None ->
          case text_length == 1 {
            True -> Error(InvalidDecimalPosition)
            False ->
              rest
              |> do_coerce_into_valid_decimal_string(
                text_length: text_length,
                previous: Some(first),
                seen_decimal: True,
                acc: acc <> ".0",
              )
          }
        ".", Some(_) if seen_decimal -> Error(InvalidDecimalPosition)
        a, _ -> {
          rest
          |> do_coerce_into_valid_decimal_string(
            text_length: text_length,
            previous: Some(first),
            seen_decimal: a == "." || seen_decimal,
            acc: first <> acc,
          )
        }
      }
    }
  }
}

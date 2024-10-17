import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string

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

  /// Represents an error when a sign (+ or -) is in an invalid position within
  /// the number string. The `String` parameter contains the sign that caused
  /// the error.
  SignAtInvalidPosition(String)

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
pub fn parse_error_to_string(error: ParseError) -> String {
  case error {
    GleamIntParseError -> "GleamIntParseError"
    InvalidCharacter(character) -> "InvalidCharacter(\"" <> character <> "\")"
    InvalidUnderscorePosition -> "InvalidUnderscorePosition"
    WhitespaceOnlyOrEmptyString -> "WhitespaceOnlyOrEmptyString"
    GleamFloatParseError -> "GleamFloatParseError"
    InvalidDecimalPosition -> "InvalidDecimalPosition"
    SignAtInvalidPosition(character) ->
      "SignAtInvalidPosition(\"" <> character <> "\")"
  }
}

@internal
pub fn coerce_into_valid_number_string(
  text: String,
) -> Result(String, ParseError) {
  let text = text |> string.trim
  use <- bool.guard(text |> string.is_empty, Error(WhitespaceOnlyOrEmptyString))
  use _ <- result.try(text |> has_valid_sign_position())
  use _ <- result.try(text |> has_valid_characters())
  use text <- result.try(text |> coerce_into_valid_underscore_string)
  text |> coerce_into_valid_decimal_string
}

fn digit_set() -> Set(String) {
  ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] |> set.from_list
}

fn sign_set() -> Set(String) {
  ["+", "-"] |> set.from_list
}

fn separator_set() -> Set(String) {
  [".", "_"] |> set.from_list
}

fn valid_character_set() -> Set(String) {
  let digits = digit_set()
  let signs = sign_set()
  let separators = separator_set()

  digits |> set.union(signs) |> set.union(separators)
}

@internal
pub fn coerce_into_valid_underscore_string(
  text: String,
) -> Result(String, ParseError) {
  text
  |> string.to_graphemes
  |> do_coerce_into_valid_underscore_string(
    previous: None,
    digits: digit_set(),
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
pub fn has_valid_characters(text: String) -> Result(Nil, ParseError) {
  let graphemes = text |> string.to_graphemes
  list.try_map(graphemes, fn(grapheme) {
    case valid_character_set() |> set.contains(grapheme) {
      True -> Ok(Nil)
      False -> Error(InvalidCharacter(grapheme))
    }
  })
  |> result.replace(Nil)
}

@internal
pub fn has_valid_sign_position(text: String) -> Result(Nil, ParseError) {
  do_has_valid_sign_position(text |> string.to_graphemes, 0)
}

fn do_has_valid_sign_position(
  characters: List(String),
  index index: Int,
) -> Result(Nil, ParseError) {
  case characters {
    [] -> Ok(Nil)
    [first, ..rest] -> {
      case first {
        "+" | "-" if index != 0 -> Error(SignAtInvalidPosition(first))
        _ -> do_has_valid_sign_position(rest, index + 1)
      }
    }
  }
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

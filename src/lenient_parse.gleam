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
/// lenient_parse.to_float("1_000.0")  // -> Ok(1000.0)
/// lenient_parse.to_float(" ")        // -> Error(Nil)
/// lenient_parse.to_float("")         // -> Error(Nil)
/// lenient_parse.to_float("abc")      // -> Error(Nil)
/// ```
pub fn to_float(text: String) -> Result(Float, Nil) {
  let text = text |> coerce_into_valid_number_string |> result.nil_error
  use text <- result.try(text)
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
  text
  |> coerce_into_valid_number_string
  |> result.nil_error
  |> result.try(int.parse)
}

pub type ParseError {
  InvalidCharacter(String)
  WhitespaceOnlyOrEmptyString
  InvalidUnderscorePosition
  InvalidDecimalPosition
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
  use _ <- result.try(text |> check_for_valid_underscore_positions)
  Ok(text)
}

@internal
pub fn check_for_valid_underscore_positions(
  text: String,
) -> Result(Nil, ParseError) {
  text
  |> string.to_graphemes
  |> do_check_for_valid_underscore_positions(
    previous: None,
    digits: digits |> set.from_list,
  )
}

fn do_check_for_valid_underscore_positions(
  characters: List(String),
  previous previous: Option(String),
  digits digits: Set(String),
) -> Result(Nil, ParseError) {
  case characters {
    [] -> {
      use <- bool.guard(previous == Some("_"), Error(InvalidUnderscorePosition))
      Ok(Nil)
    }
    [first, ..rest] -> {
      case first, previous {
        "_", None -> Error(InvalidUnderscorePosition)
        a, Some("_") | "_", Some(a) ->
          case digits |> set.contains(a) {
            True ->
              do_check_for_valid_underscore_positions(
                rest,
                previous: Some(first),
                digits: digits,
              )
            False -> Error(InvalidUnderscorePosition)
          }
        _, _ ->
          do_check_for_valid_underscore_positions(
            rest,
            previous: Some(first),
            digits: digits,
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
  |> result.map(fn(_) { Nil })
}

@internal
pub fn check_for_valid_decimal_positions(
  text: String,
) -> Result(Nil, ParseError) {
  text
  |> string.to_graphemes
  |> do_check_for_valid_decimal_positions(previous: None, seen_decimal: False)
}

fn do_check_for_valid_decimal_positions(
  characters: List(String),
  previous previous: Option(String),
  seen_decimal seen_decimal: Bool,
) -> Result(Nil, ParseError) {
  case characters {
    [] -> Ok(Nil)
    [first, ..rest] -> {
      case first, previous {
        ".", None -> Error(InvalidDecimalPosition)
        a, _ -> {
          case a {
            "." -> {
              use <- bool.guard(seen_decimal, Error(InvalidDecimalPosition))

              rest
              |> do_check_for_valid_decimal_positions(Some(first), True)
            }
            _ ->
              rest
              |> do_check_for_valid_decimal_positions(Some(first), seen_decimal)
          }
        }
      }
    }
  }
}
// @internal
// pub fn pad_with_leading_or_trailing_zeros(
//   characters: List(String),
//   previous previous: Option(String),
// ) -> String {
//   case characters {
//     [] -> {
//       use <- bool.guard(previous == Some("_"), Error(InvalidUnderscorePosition))
//       Ok(Nil)
//     }
//     [first, ..rest] -> {
//       case first, previous {
//         "_", None -> Error(InvalidUnderscorePosition)
//         a, Some("_") | "_", Some(a) ->
//           case digits |> set.contains(a) {
//             True ->
//               do_check_for_valid_underscore_positions(
//                 rest,
//                 previous: Some(first),
//                 digits: digits,
//               )
//             False -> Error(InvalidUnderscorePosition)
//           }
//         _, _ ->
//           do_check_for_valid_underscore_positions(
//             rest,
//             previous: Some(first),
//             digits: digits,
//           )
//       }
//     }
//   }
// }

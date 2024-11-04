import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import lenient_parse/internal/tokenizer.{
  type Token, DecimalPoint, Digit, Sign, Underscore, Unknown, Whitespace,
}
import parse_error.{
  type ParseError, EmptyString, InvalidDecimalPosition,
  InvalidUnderscorePosition, UnknownCharacter, WhitespaceOnlyString,
}

pub fn parse_float(input: String) -> Result(Float, ParseError) {
  let tokens = input |> tokenizer.tokenize
  let index = 0
  let empty_string = ""

  let pre_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(leading_whitespace, tokens, index) <- result.try(pre_whitespace_result)

  let sign_result = parse_sign(tokens, index)
  use #(is_positive, tokens, index) <- result.try(sign_result)

  let whole_digit_result = parse_digit(tokens, 0, index, index, 0)
  use #(whole_digit, _, tokens, index) <- result.try(whole_digit_result)

  let decimal_result = parse_decimal_point(tokens, index)
  use #(decimal_specified, tokens, index) <- result.try(decimal_result)

  let fractional_digit_result = parse_digit(tokens, 0, index, index, 0)
  use #(fractional_digit, fractional_digit_length, tokens, index) <- result.try(
    fractional_digit_result,
  )

  let post_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(_, tokens, index) <- result.try(post_whitespace_result)

  case tokens |> list.first {
    Ok(token) -> Error(tokenizer.to_error(token, index))
    _ -> {
      case whole_digit, fractional_digit {
        Some(whole), Some(fractional) ->
          Ok(form_float(is_positive, whole, fractional, fractional_digit_length))
        Some(whole), None ->
          Ok(form_float(is_positive, whole, 0, fractional_digit_length))
        None, Some(fractional) ->
          Ok(form_float(is_positive, 0, fractional, fractional_digit_length))
        _, _ -> {
          // TODO: This sucks - hardcoded to take care of one specific test case during the rewrite: "."
          // There is likely a better way to handle this.
          use <- bool.guard(
            decimal_specified,
            Error(InvalidDecimalPosition(index - 1)),
          )

          case leading_whitespace {
            Some(_) -> Error(WhitespaceOnlyString)
            _ -> Error(EmptyString)
          }
        }
      }
    }
  }
}

pub fn parse_int(input: String) -> Result(Int, ParseError) {
  let tokens = input |> tokenizer.tokenize
  let index = 0
  let empty_string = ""

  let pre_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(leading_whitespace, tokens, index) <- result.try(pre_whitespace_result)

  let sign_result = parse_sign(tokens, index)
  use #(is_positive, tokens, index) <- result.try(sign_result)

  let digit_result = parse_digit(tokens, 0, index, index, 0)
  use #(digit, _, tokens, index) <- result.try(digit_result)

  let post_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(_, tokens, index) <- result.try(post_whitespace_result)

  case tokens |> list.first {
    Ok(token) -> Error(tokenizer.to_error(token, index))
    _ -> {
      case leading_whitespace, digit {
        Some(_), Some(digit) | None, Some(digit) ->
          case is_positive {
            True -> Ok(digit)
            False -> Ok(-digit)
          }
        Some(_), None -> Error(WhitespaceOnlyString)
        _, _ -> Error(EmptyString)
      }
    }
  }
}

fn parse_whitespace(
  tokens: List(Token),
  acc: String,
  index: Int,
) -> Result(#(Option(String), List(Token), Int), ParseError) {
  case tokens {
    [] ->
      case acc {
        "" -> Ok(#(None, tokens, index))
        _ -> Ok(#(Some(acc), tokens, index))
      }
    [first, ..rest] -> {
      case first {
        Unknown(character) -> Error(UnknownCharacter(character, index))
        Whitespace(whitespace) ->
          parse_whitespace(rest, acc <> whitespace, index + 1)
        _ -> {
          case acc {
            "" -> Ok(#(None, tokens, index))
            _ -> Ok(#(Some(acc), tokens, index))
          }
        }
      }
    }
  }
}

fn parse_sign(
  tokens: List(Token),
  index: Int,
) -> Result(#(Bool, List(Token), Int), ParseError) {
  case tokens {
    [] -> Ok(#(True, tokens, index))
    [first, ..rest] -> {
      case first {
        Unknown(character) -> Error(UnknownCharacter(character, index))
        Sign(is_positive) -> Ok(#(is_positive, rest, index + 1))
        _ -> Ok(#(True, tokens, index))
      }
    }
  }
}

fn parse_decimal_point(
  tokens: List(Token),
  index: Int,
) -> Result(#(Bool, List(Token), Int), ParseError) {
  case tokens {
    [] -> Ok(#(False, tokens, index))
    [first, ..rest] -> {
      case first {
        Unknown(character) -> Error(UnknownCharacter(character, index))
        DecimalPoint -> Ok(#(True, rest, index + 1))
        _ -> Ok(#(False, rest, index))
      }
    }
  }
}

fn parse_digit(
  tokens: List(Token),
  acc: Int,
  index: Int,
  beginning_index: Int,
  digit_length: Int,
) -> Result(#(Option(Int), Int, List(Token), Int), ParseError) {
  let at_beginning = index == beginning_index

  case tokens {
    [] ->
      case digit_length > 0 {
        True -> Ok(#(Some(acc), digit_length, tokens, index))
        False -> Ok(#(None, digit_length, tokens, index))
      }
    [first, ..rest] -> {
      let lookahead = rest |> list.first
      let is_end = case lookahead {
        Ok(Digit(_)) -> False
        _ -> True
      }
      let next_is_underscore = case lookahead {
        Ok(Underscore) -> True
        _ -> False
      }

      case first {
        Digit(digit) -> {
          let acc = acc * 10 + digit
          parse_digit(rest, acc, index + 1, beginning_index, digit_length + 1)
        }
        Underscore if next_is_underscore ->
          Error(InvalidUnderscorePosition(index + 1))
        Underscore if at_beginning || is_end ->
          Error(InvalidUnderscorePosition(index))
        Underscore -> {
          parse_digit(rest, acc, index + 1, beginning_index, digit_length)
        }
        Whitespace(whitespace) if at_beginning ->
          Error(UnknownCharacter(whitespace, index))
        Unknown(character) -> Error(UnknownCharacter(character, index))
        _ -> {
          case digit_length > 0 {
            True -> Ok(#(Some(acc), digit_length, tokens, index))
            False -> Ok(#(None, digit_length, tokens, index))
          }
        }
      }
    }
  }
}

fn form_float(
  is_positive: Bool,
  whole_digit: Int,
  fractional_digit: Int,
  fractional_length: Int,
) -> Float {
  let whole_float = whole_digit |> int.to_float
  let fractional_float =
    fractional_digit
    |> int.to_float
    |> normalize_fractional_part(fractional_length)
  let float_value = whole_float +. fractional_float
  case is_positive {
    True -> float_value
    False -> float_value *. -1.0
  }
}

fn normalize_fractional_part(value: Float, fractional_length: Int) -> Float {
  case fractional_length <= 0 {
    True -> value
    False -> normalize_fractional_part(value /. 10.0, fractional_length - 1)
  }
}

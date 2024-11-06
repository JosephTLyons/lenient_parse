import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import lenient_parse/internal/token.{
  type Token, DecimalPoint, Digit, Exponent, Sign, Underscore, Unknown,
  Whitespace,
}

import lenient_parse/internal/tokenizer
import parse_error.{
  type ParseError, EmptyString, InvalidDecimalPosition, InvalidExponentPosition,
  InvalidUnderscorePosition, UnknownCharacter, WhitespaceOnlyString,
}

pub fn parse_float(input: String) -> Result(Float, ParseError) {
  let tokens = input |> tokenizer.tokenize
  let index = 0

  let leading_whitespace_result = parse_whitespace(tokens, index)
  use #(leading_whitespace, tokens, index) <- result.try(
    leading_whitespace_result,
  )

  let sign_result = parse_sign(tokens, index)
  use #(is_positive, tokens, index) <- result.try(sign_result)

  let whole_digit_result = parse_digit(tokens, index)
  use #(whole_digit, _, tokens, index) <- result.try(whole_digit_result)

  let decimal_result = parse_decimal_point(tokens, index)
  use #(decimal_specified, tokens, index) <- result.try(decimal_result)

  let fractional_digit_result = case decimal_specified {
    True -> parse_digit(tokens, index)
    False -> Ok(#(None, 0, tokens, index))
  }
  use #(fractional_digit, fractional_length, tokens, index) <- result.try(
    fractional_digit_result,
  )

  let exponent_symbol_result = parse_exponent_symbol(tokens, index)
  use #(exponent_symbol, tokens, index) <- result.try(exponent_symbol_result)

  let exponent_sign_result = case exponent_symbol {
    Some(exponent_symbol) -> {
      use <- bool.guard(
        option.is_none(whole_digit) && option.is_none(fractional_digit),
        Error(InvalidExponentPosition(exponent_symbol, index - 1)),
      )
      parse_sign(tokens, index)
    }
    None -> Ok(#(False, tokens, index))
  }
  use #(exponent_digit_is_positive, tokens, index) <- result.try(
    exponent_sign_result,
  )

  // Feels a bit hacky :( - Improve this
  let exponent_digit_result = case exponent_symbol {
    Some(exponent_symbol) -> {
      case parse_digit(tokens, index) {
        Ok(#(Some(digit), digit_length, tokens, index)) ->
          Ok(#(digit, digit_length, tokens, index))
        _ -> Error(InvalidExponentPosition(exponent_symbol, index - 1))
      }
    }
    None -> Ok(#(0, 1, tokens, index))
  }
  use #(exponent_digit, _, tokens, index) <- result.try(exponent_digit_result)

  let trailing_whitespace_result = parse_whitespace(tokens, index)
  use #(_, tokens, index) <- result.try(trailing_whitespace_result)

  case tokens |> list.first {
    Ok(token) -> Error(token.to_error(token, index))
    _ -> {
      case whole_digit, fractional_digit {
        Some(whole_digit), Some(fractional_digit) ->
          Ok(form_float(
            is_positive: is_positive,
            whole_digit: whole_digit,
            fractional_digit: fractional_digit,
            fractional_length: fractional_length,
            exponent_digit_is_positive: exponent_digit_is_positive,
            exponent_digit: exponent_digit,
          ))
        Some(whole_digit), None ->
          Ok(form_float(
            is_positive: is_positive,
            whole_digit: whole_digit,
            fractional_digit: 0,
            fractional_length: fractional_length,
            exponent_digit_is_positive: exponent_digit_is_positive,
            exponent_digit: exponent_digit,
          ))
        None, Some(fractional_digit) ->
          Ok(form_float(
            is_positive: is_positive,
            whole_digit: 0,
            fractional_digit: fractional_digit,
            fractional_length: fractional_length,
            exponent_digit_is_positive: exponent_digit_is_positive,
            exponent_digit: exponent_digit,
          ))
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

  let leading_whitespace_result = parse_whitespace(tokens, index)
  use #(leading_whitespace, tokens, index) <- result.try(
    leading_whitespace_result,
  )

  let sign_result = parse_sign(tokens, index)
  use #(is_positive, tokens, index) <- result.try(sign_result)

  let digit_result = parse_digit(tokens, index)
  use #(digit, _, tokens, index) <- result.try(digit_result)

  let trailing_whitespace_result = parse_whitespace(tokens, index)
  use #(_, tokens, index) <- result.try(trailing_whitespace_result)

  case tokens |> list.first {
    Ok(token) -> Error(token.to_error(token, index))
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
  index: Int,
) -> Result(#(Option(String), List(Token), Int), ParseError) {
  do_parse_whitespace(tokens: tokens, index: index, acc: "")
}

fn do_parse_whitespace(
  tokens tokens: List(Token),
  index index: Int,
  acc acc: String,
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
          do_parse_whitespace(
            tokens: rest,
            index: index + 1,
            acc: acc <> whitespace,
          )
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
        Sign(_, is_positive) -> Ok(#(is_positive, rest, index + 1))
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
        _ -> Ok(#(False, tokens, index))
      }
    }
  }
}

fn parse_exponent_symbol(
  tokens: List(Token),
  index: Int,
) -> Result(#(Option(String), List(Token), Int), ParseError) {
  case tokens {
    [] -> Ok(#(None, tokens, index))
    [first, ..rest] -> {
      case first {
        Unknown(character) -> Error(UnknownCharacter(character, index))
        Exponent(exponent) -> Ok(#(Some(exponent), rest, index + 1))
        _ -> Ok(#(None, tokens, index))
      }
    }
  }
}

fn parse_digit(
  tokens: List(Token),
  index: Int,
) -> Result(#(Option(Int), Int, List(Token), Int), ParseError) {
  do_parse_digit(
    tokens: tokens,
    index: index,
    acc: 0,
    at_beginning: True,
    digit_length: 0,
  )
}

fn do_parse_digit(
  tokens tokens: List(Token),
  index index: Int,
  acc acc: Int,
  at_beginning at_beginning: Bool,
  digit_length digit_length: Int,
) -> Result(#(Option(Int), Int, List(Token), Int), ParseError) {
  case tokens {
    [] ->
      case digit_length > 0 {
        True -> Ok(#(Some(acc), digit_length, tokens, index))
        False -> Ok(#(None, digit_length, tokens, index))
      }
    [first, ..rest] -> {
      let lookahead = rest |> list.first
      let at_end = case lookahead {
        Ok(Digit(_)) -> False
        _ -> True
      }
      let next_is_underscore = case lookahead {
        Ok(Underscore) -> True
        _ -> False
      }

      case first {
        Unknown(character) -> Error(UnknownCharacter(character, index))
        Digit(digit) -> {
          do_parse_digit(
            tokens: rest,
            index: index + 1,
            acc: acc * 10 + digit,
            at_beginning: False,
            digit_length: digit_length + 1,
          )
        }
        Underscore if next_is_underscore ->
          Error(InvalidUnderscorePosition(index + 1))
        Underscore if at_beginning || at_end ->
          Error(InvalidUnderscorePosition(index))
        Underscore -> {
          do_parse_digit(
            tokens: rest,
            index: index + 1,
            acc: acc,
            at_beginning: False,
            digit_length: digit_length,
          )
        }
        Whitespace(whitespace) if at_beginning ->
          Error(UnknownCharacter(whitespace, index))
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
  is_positive is_positive: Bool,
  whole_digit whole_digit: Int,
  fractional_digit fractional_digit: Int,
  fractional_length fractional_length: Int,
  exponent_digit_is_positive exponent_digit_is_positive: Bool,
  exponent_digit exponent_digit: Int,
) -> Float {
  let whole_float = whole_digit |> int.to_float
  let fractional_float =
    fractional_digit
    |> int.to_float
    |> normalize_fractional(fractional_length)
  let float_value = whole_float +. fractional_float
  let float_value = case is_positive {
    True -> float_value
    False -> float_value *. -1.0
  }

  let exponent_digit = case exponent_digit_is_positive {
    True -> exponent_digit
    False -> exponent_digit * -1
  }

  power(float_value, exponent_digit)
}

fn normalize_fractional(fractional: Float, fractional_length: Int) -> Float {
  case fractional_length <= 0 {
    True -> fractional
    False -> normalize_fractional(fractional /. 10.0, fractional_length - 1)
  }
}

fn power(base: Float, exponent: Int) {
  do_power(
    base: base,
    exponent: exponent,
    scale_factor: 1,
    exponent_is_positive: exponent >= 0,
  )
}

fn do_power(
  base base: Float,
  exponent exponent: Int,
  scale_factor scale_factor: Int,
  exponent_is_positive exponent_is_positive,
) -> Float {
  case int.compare(exponent, 0) {
    order.Eq -> {
      let scale_factor_float = scale_factor |> int.to_float
      case exponent_is_positive {
        True -> base *. scale_factor_float
        False -> base /. scale_factor_float
      }
    }
    order.Gt ->
      do_power(base, exponent - 1, scale_factor * 10, exponent_is_positive)
    order.Lt ->
      do_power(base, exponent + 1, scale_factor * 10, exponent_is_positive)
  }
}

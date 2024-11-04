import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import lenient_parse/internal/tokenizer.{
  type Token, DecimalPoint, Digit, Sign, Underscore, Unknown, Whitespace,
}
import parse_error.{
  type ParseError, EmptyString, InvalidCharacter, InvalidDecimalPosition,
  InvalidDigitPosition, InvalidSignPosition, InvalidUnderscorePosition,
  WhitespaceOnlyString,
}

pub fn parse_float(input: String) -> Result(String, ParseError) {
  let tokens = input |> tokenizer.tokenize
  let index = 0
  let empty_string = ""

  let pre_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(leading_whitespace, tokens, index) <- result.try(pre_whitespace_result)

  let sign_result = parse_sign(tokens, index)
  use #(sign, tokens, index) <- result.try(sign_result)

  let digit_pre_decimal = parse_digit(tokens, empty_string, index, index)
  use #(digit_pre_decimal, tokens, index) <- result.try(digit_pre_decimal)

  let decimal_point_result = parse_decimal_point(tokens, index)
  use #(decimal_specified, tokens, index) <- result.try(decimal_point_result)

  let digit_post_decimal = parse_digit(tokens, empty_string, index, index)
  use #(digit_post_decimal, tokens, index) <- result.try(digit_post_decimal)

  let post_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(_, tokens, index) <- result.try(post_whitespace_result)

  case tokens |> list.first {
    Ok(token) -> Error(extraneous_token_error(token, index))
    _ -> {
      case digit_pre_decimal, digit_post_decimal {
        Some(pre), Some(post) -> Ok(sign <> pre <> "." <> post)
        Some(pre), None -> Ok(sign <> pre <> ".0")
        None, Some(post) -> Ok(sign <> "0." <> post)
        _, _ -> {
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

pub fn parse_int(input: String) -> Result(String, ParseError) {
  let tokens = input |> tokenizer.tokenize
  let index = 0
  let empty_string = ""

  let pre_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(leading_whitespace, tokens, index) <- result.try(pre_whitespace_result)

  let sign_result = parse_sign(tokens, index)
  use #(sign, tokens, index) <- result.try(sign_result)

  let digit_result = parse_digit(tokens, empty_string, index, index)
  use #(digit, tokens, index) <- result.try(digit_result)

  let post_whitespace_result = parse_whitespace(tokens, empty_string, index)
  use #(_, tokens, index) <- result.try(post_whitespace_result)

  case tokens |> list.first {
    Ok(token) -> Error(extraneous_token_error(token, index))
    _ -> {
      case leading_whitespace, digit {
        Some(_), Some(digit) | None, Some(digit) -> Ok(sign <> digit)
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
        Unknown(character) -> Error(InvalidCharacter(character, index))
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
) -> Result(#(String, List(Token), Int), ParseError) {
  case tokens {
    [] -> Ok(#("+", tokens, index))
    [first, ..rest] -> {
      case first {
        Unknown(character) -> Error(InvalidCharacter(character, index))
        Sign(a) -> Ok(#(a, rest, index + 1))
        _ -> Ok(#("+", tokens, index))
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
        Unknown(character) -> Error(InvalidCharacter(character, index))
        DecimalPoint -> Ok(#(True, rest, index + 1))
        _ -> Ok(#(False, rest, index))
      }
    }
  }
}

fn parse_digit(
  tokens: List(Token),
  acc: String,
  index: Int,
  beginning_index: Int,
) -> Result(#(Option(String), List(Token), Int), ParseError) {
  let at_beginning = index == beginning_index

  case tokens {
    [] ->
      case acc {
        "" -> Ok(#(None, tokens, index))
        _ -> Ok(#(Some(acc), tokens, index))
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
        Digit(digit) ->
          parse_digit(rest, acc <> digit, index + 1, beginning_index)
        Underscore if next_is_underscore ->
          Error(parse_error.InvalidUnderscorePosition(index + 1))
        Underscore if at_beginning || is_end ->
          Error(parse_error.InvalidUnderscorePosition(index))
        Underscore -> parse_digit(rest, acc, index + 1, beginning_index)
        Whitespace(whitespace) if at_beginning ->
          Error(InvalidCharacter(whitespace, index))
        Unknown(character) -> Error(InvalidCharacter(character, index))
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

fn extraneous_token_error(token: Token, index) -> ParseError {
  case token {
    Digit(digit) -> InvalidDigitPosition(digit, index)
    Sign(sign) -> InvalidSignPosition(sign, index)
    Underscore -> InvalidUnderscorePosition(index)
    Unknown(character) -> InvalidCharacter(character, index)
    Whitespace(whitespace) -> InvalidCharacter(whitespace, index)
    DecimalPoint -> InvalidDecimalPosition(index)
  }
}

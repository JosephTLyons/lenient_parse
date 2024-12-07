import gleam/bool
import gleam/deque.{type Deque}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import lenient_parse/internal/base_constants.{
  base_0, base_10, base_16, base_2, base_8,
}
import lenient_parse/internal/build
import lenient_parse/internal/convert.{digits_to_int}
import lenient_parse/internal/token.{
  type Token, DecimalPoint, Digit, ExponentSymbol, Sign, Underscore, Unknown,
  Whitespace,
}
import parse_error.{
  type ParseError, BasePrefixOnly, EmptyString, InvalidDecimalPosition,
  InvalidExponentSymbolPosition, InvalidUnderscorePosition, OutOfBaseRange,
  UnknownCharacter, WhitespaceOnlyString,
}

type ParseData(t) {
  ParseData(data: t, next_index: Int, tokens: List(Token))
}

pub fn parse_float_tokens(
  tokens tokens: List(Token),
) -> Result(Float, ParseError) {
  let parse_data = parse_whitespace(tokens, 0)
  use ParseData(leading_whitespace, next_index, tokens) <- result.try(
    parse_data,
  )

  let parse_data = parse_sign(tokens, next_index)
  use ParseData(is_positive, next_index, tokens) <- result.try(parse_data)

  let parse_data = parse_digits(tokens, next_index, base_10, False)
  use ParseData(whole_digits, next_index, tokens) <- result.try(parse_data)

  let parse_data = parse_decimal_point(tokens, next_index)
  use ParseData(decimal_specified, next_index, tokens) <- result.try(parse_data)

  let parse_data = case decimal_specified {
    True -> parse_digits(tokens, next_index, base_10, False)
    False -> Ok(ParseData(deque.new(), next_index, tokens))
  }
  use ParseData(fractional_digits, next_index, tokens) <- result.try(parse_data)

  let missing_digit_parts =
    deque.is_empty(whole_digits) && deque.is_empty(fractional_digits)
  use <- bool.guard(
    missing_digit_parts && decimal_specified,
    Error(InvalidDecimalPosition(next_index - 1)),
  )

  let parse_data = parse_exponent_symbol(tokens, next_index)
  use ParseData(exponent_symbol, next_index, tokens) <- result.try(parse_data)

  let parse_data = case missing_digit_parts, exponent_symbol {
    True, Some(exponent_symbol) ->
      Error(InvalidExponentSymbolPosition(next_index - 1, exponent_symbol))
    _, None -> Ok(ParseData(0, next_index, tokens))
    _, Some(exponent_symbol) -> {
      let parse_data = parse_sign(tokens, next_index)
      use ParseData(exponent_digit_is_positive, next_index, tokens) <- result.try(
        parse_data,
      )

      let parse_data = parse_digits(tokens, next_index, base_10, False)
      use ParseData(exponent_digits, next_index, tokens) <- result.try(
        parse_data,
      )

      let parse_data = case exponent_digits |> deque.is_empty {
        True ->
          Error(InvalidExponentSymbolPosition(next_index - 1, exponent_symbol))
        False -> Ok(ParseData(exponent_digits, next_index, tokens))
      }
      use ParseData(exponent_digits, next_index, tokens) <- result.try(
        parse_data,
      )

      let exponent_digit = exponent_digits |> digits_to_int
      let exponent = case exponent_digit_is_positive {
        True -> exponent_digit
        False -> -exponent_digit
      }

      Ok(ParseData(exponent, next_index, tokens))
    }
  }
  use ParseData(exponent, next_index, tokens) <- result.try(parse_data)

  let parse_data = parse_whitespace(tokens, next_index)
  use ParseData(_, _, tokens) <- result.try(parse_data)

  let remaining_token_result = case tokens {
    [] -> Ok(Nil)
    [token, ..] -> Error(token.to_error(token, base_10))
  }
  use _ <- result.try(remaining_token_result)

  case leading_whitespace, missing_digit_parts {
    None, True -> Error(EmptyString)
    Some(_), True -> Error(WhitespaceOnlyString)
    _, _ ->
      build.float_value(
        is_positive:,
        whole_digits:,
        fractional_digits:,
        scale_factor: exponent,
      )
  }
}

pub fn parse_int_tokens(
  tokens tokens: List(Token),
  base base: Int,
) -> Result(Int, ParseError) {
  let parse_data = parse_whitespace(tokens, 0)
  use ParseData(leading_whitespace, next_index, tokens) <- result.try(
    parse_data,
  )

  let parse_data = parse_sign(tokens, next_index)
  use ParseData(is_positive, next_index, tokens) <- result.try(parse_data)

  let parse_data = case base {
    base
      if base == base_0 || base == base_2 || base == base_8 || base == base_16
    -> {
      let parse_data = parse_base_prefix(tokens, next_index, base)
      use ParseData(base_data, next_index, tokens) <- result.try(parse_data)

      let #(base, prefix_data) = case base_data {
        Some(#(index_range, prefix, base)) -> #(
          base,
          Some(#(index_range, prefix)),
        )
        None -> {
          let default_base = case base {
            0 -> base_10
            _ -> base
          }

          #(default_base, None)
        }
      }

      Ok(ParseData(#(base, prefix_data), next_index, tokens))
    }
    _ -> Ok(ParseData(#(base, None), next_index, tokens))
  }
  use ParseData(#(base, prefix_data), next_index, tokens) <- result.try(
    parse_data,
  )

  let parse_data =
    parse_digits(tokens, next_index, base, prefix_data |> option.is_some)
  use ParseData(digits, next_index, tokens) <- result.try(parse_data)

  let parse_data = parse_whitespace(tokens, next_index)
  use ParseData(_, _, tokens) <- result.try(parse_data)

  let remaining_token_result = case tokens {
    [] -> Ok(Nil)
    [token, ..] -> Error(token.to_error(token, base))
  }
  use _ <- result.try(remaining_token_result)

  case leading_whitespace, prefix_data, digits |> deque.is_empty {
    None, None, True -> Error(EmptyString)
    _, Some(#(index_range, prefix)), True ->
      Error(BasePrefixOnly(index_range, prefix))
    Some(_), _, True -> Error(WhitespaceOnlyString)
    _, _, _ -> {
      build.integer_value(digits:, base:, is_positive:)
    }
  }
}

fn parse_whitespace(
  tokens tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Option(String)), ParseError) {
  do_parse_whitespace(tokens:, index:, acc: "")
}

fn do_parse_whitespace(
  tokens tokens: List(Token),
  index index: Int,
  acc acc: String,
) -> Result(ParseData(Option(String)), ParseError) {
  case tokens {
    [Unknown(index, character), ..] -> Error(UnknownCharacter(index, character))
    [Whitespace(index, data), ..rest] -> {
      do_parse_whitespace(
        tokens: rest,
        index: index + 1,
        acc: acc <> data.character,
      )
    }
    _ -> {
      let data = case acc {
        "" -> None
        _ -> Some(acc)
      }

      Ok(ParseData(data:, next_index: index, tokens:))
    }
  }
}

fn parse_sign(
  tokens tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Bool), ParseError) {
  case tokens {
    [Unknown(index, character), ..] -> Error(UnknownCharacter(index, character))
    [Sign(index, _, is_positive), ..rest] ->
      Ok(ParseData(data: is_positive, next_index: index + 1, tokens: rest))
    _ -> {
      Ok(ParseData(data: True, next_index: index, tokens:))
    }
  }
}

fn parse_base_prefix(
  tokens tokens: List(Token),
  index index: Int,
  base base: Int,
) -> Result(ParseData(Option(#(#(Int, Int), String, Int))), ParseError) {
  case tokens {
    [Unknown(index, character), ..] -> Error(UnknownCharacter(index, character))
    [Digit(index, "0", _), ..rest] -> {
      let lookahead = rest |> list.first

      case lookahead {
        Ok(Digit(_, specifier, _))
          if { base == base_0 || base == base_2 }
          && { specifier == "b" || specifier == "B" }
        -> Ok(base_prefix_data(tokens: rest, index:, specifier:, base: base_2))
        Ok(Digit(_, specifier, _))
          if { base == base_0 || base == base_8 }
          && { specifier == "o" || specifier == "O" }
        -> Ok(base_prefix_data(tokens: rest, index:, specifier:, base: base_8))
        Ok(Digit(_, specifier, _))
          if { base == base_0 || base == base_16 }
          && { specifier == "x" || specifier == "X" }
        -> Ok(base_prefix_data(tokens: rest, index:, specifier:, base: base_16))
        Ok(Digit(index, character, _)) if base == base_0 -> {
          Error(UnknownCharacter(index, character))
        }
        _ -> Ok(ParseData(data: None, next_index: index, tokens:))
      }
    }
    _ -> Ok(ParseData(data: None, next_index: index, tokens:))
  }
}

fn base_prefix_data(
  tokens tokens: List(Token),
  index index: Int,
  specifier specifier: String,
  base base: Int,
) -> ParseData(Option(#(#(Int, Int), String, Int))) {
  ParseData(
    data: Some(#(#(index, index + 2), "0" <> specifier, base)),
    next_index: index + 2,
    tokens: tokens |> list.drop(1),
  )
}

fn parse_decimal_point(
  tokens tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Bool), ParseError) {
  case tokens {
    [Unknown(index, character), ..] -> Error(UnknownCharacter(index, character))
    [DecimalPoint(index), ..rest] ->
      Ok(ParseData(data: True, next_index: index + 1, tokens: rest))
    _ -> Ok(ParseData(data: False, next_index: index, tokens:))
  }
}

fn parse_exponent_symbol(
  tokens tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Option(String)), ParseError) {
  case tokens {
    [Unknown(index, character), ..] -> Error(UnknownCharacter(index, character))
    [ExponentSymbol(index, exponent_symbol), ..rest] ->
      Ok(ParseData(
        data: Some(exponent_symbol),
        next_index: index + 1,
        tokens: rest,
      ))
    _ -> Ok(ParseData(data: None, next_index: index, tokens:))
  }
}

fn parse_digits(
  tokens tokens: List(Token),
  index index: Int,
  base base: Int,
  has_base_prefix has_base_prefix: Bool,
) -> Result(ParseData(Deque(Int)), ParseError) {
  do_parse_digits(
    tokens:,
    index:,
    base:,
    acc: deque.new(),
    at_beginning: True,
    has_base_prefix:,
  )
}

fn do_parse_digits(
  tokens tokens: List(Token),
  index index: Int,
  base base: Int,
  acc acc: Deque(Int),
  at_beginning at_beginning: Bool,
  has_base_prefix has_base_prefix: Bool,
) -> Result(ParseData(Deque(Int)), ParseError) {
  case tokens {
    [Unknown(index, character), ..] -> Error(UnknownCharacter(index, character))
    [Whitespace(index, data), ..] if at_beginning ->
      Error(UnknownCharacter(index, data.character))
    [Underscore(index), ..rest] -> {
      let lookahead = rest |> list.first
      let at_end = case lookahead {
        Ok(Digit(_, _, _)) -> False
        _ -> True
      }
      let next_is_underscore = case lookahead {
        Ok(Underscore(_)) -> True
        _ -> False
      }

      use <- bool.guard(
        next_is_underscore,
        Error(InvalidUnderscorePosition(index + 1)),
      )

      use <- bool.guard(
        { at_beginning && !has_base_prefix } || at_end,
        Error(InvalidUnderscorePosition(index)),
      )

      do_parse_digits(
        tokens: rest,
        index: index + 1,
        base:,
        acc:,
        at_beginning: False,
        has_base_prefix:,
      )
    }
    [Digit(index, character, _), ..] if base == base_0 -> {
      Error(UnknownCharacter(index, character))
    }
    [Digit(index, _, value), ..rest] if value < base -> {
      do_parse_digits(
        tokens: rest,
        index:,
        base:,
        acc: acc |> deque.push_back(value),
        at_beginning: False,
        has_base_prefix:,
      )
    }
    [Digit(index, character, value), ..] ->
      Error(OutOfBaseRange(index, character, value, base))
    _ -> Ok(ParseData(data: acc, next_index: index, tokens:))
  }
}

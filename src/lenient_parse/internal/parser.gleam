import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/queue.{type Queue}
import gleam/result
import lenient_parse/internal/scale
import lenient_parse/internal/token.{
  type Token, DecimalPoint, Digit, ExponentSymbol, Sign, Underscore, Unknown,
  Whitespace,
}
import parse_error.{
  type ParseError, EmptyString, InvalidDecimalPosition,
  InvalidExponentSymbolPosition, InvalidUnderscorePosition, OutOfBaseRange,
  UnknownCharacter, WhitespaceOnlyString,
}

type ParseData(t) {
  ParseData(data: t, next_index: Int, tokens: List(Token))
}

pub fn parse_float(tokens tokens: List(Token)) -> Result(Float, ParseError) {
  let parse_data = parse_whitespace(tokens, 0)
  use ParseData(leading_whitespace, next_index, tokens) <- result.try(
    parse_data,
  )

  let parse_data = parse_sign(tokens, next_index)
  use ParseData(is_positive, next_index, tokens) <- result.try(parse_data)

  let parse_data = parse_digits(tokens, next_index)
  use ParseData(whole_digits, next_index, tokens) <- result.try(parse_data)

  let parse_data = parse_decimal_point(tokens, next_index)
  use ParseData(decimal_specified, next_index, tokens) <- result.try(parse_data)

  let parse_data = case decimal_specified {
    True -> parse_digits(tokens, next_index)
    False -> Ok(ParseData(queue.new(), next_index, tokens))
  }
  use ParseData(fractional_digits, next_index, tokens) <- result.try(parse_data)

  let missing_digit_parts =
    queue.is_empty(whole_digits) && queue.is_empty(fractional_digits)
  use <- bool.guard(
    missing_digit_parts && decimal_specified,
    Error(InvalidDecimalPosition(next_index - 1)),
  )

  let parse_data = parse_exponent_symbol(tokens, next_index)
  use ParseData(exponent_symbol, next_index, tokens) <- result.try(parse_data)

  let parse_data = case missing_digit_parts, exponent_symbol {
    True, Some(exponent_symbol) ->
      Error(InvalidExponentSymbolPosition(exponent_symbol, next_index - 1))
    _, None -> Ok(ParseData(0, next_index, tokens))
    _, Some(exponent_symbol) -> {
      let parse_data = parse_sign(tokens, next_index)
      use ParseData(exponent_digit_is_positive, next_index, tokens) <- result.try(
        parse_data,
      )

      let parse_data = parse_digits(tokens, next_index)
      use ParseData(exponent_digits, next_index, tokens) <- result.try(
        parse_data,
      )

      let parse_data = case exponent_digits |> queue.is_empty {
        True ->
          Error(InvalidExponentSymbolPosition(exponent_symbol, next_index - 1))
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
    [token, ..] -> Error(token.to_error(token))
  }
  use _ <- result.try(remaining_token_result)

  case leading_whitespace, missing_digit_parts {
    None, True -> Error(EmptyString)
    Some(_), True -> Error(WhitespaceOnlyString)
    _, _ ->
      Ok(form_float(
        is_positive: is_positive,
        whole_digits: whole_digits,
        fractional_digits: fractional_digits,
        exponent: exponent,
      ))
  }
}

pub fn parse_int(
  tokens tokens: List(Token),
  base base: Int,
) -> Result(Int, ParseError) {
  let parse_data = parse_whitespace(tokens, 0)
  use ParseData(leading_whitespace, index_range, tokens) <- result.try(
    parse_data,
  )

  let parse_data = parse_sign(tokens, index_range)
  use ParseData(is_positive, index_range, tokens) <- result.try(parse_data)

  let parse_data = parse_digits(tokens, index_range)
  use ParseData(digits, index_range, tokens) <- result.try(parse_data)

  let parse_data = parse_whitespace(tokens, index_range)
  use ParseData(_, _, tokens) <- result.try(parse_data)

  let remaining_token_result = case tokens {
    [] -> Ok(Nil)
    [token, ..] -> Error(token.to_error(token))
  }
  use _ <- result.try(remaining_token_result)

  case leading_whitespace, digits |> queue.is_empty {
    None, True -> Error(EmptyString)
    Some(_), True -> Error(WhitespaceOnlyString)
    _, False -> {
      let value = digits |> digits_to_int_with_base(base: base)
      let value = case is_positive {
        True -> value
        False -> -value
      }
      Ok(value)
    }
  }
}

fn parse_whitespace(
  tokens tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Option(String)), ParseError) {
  do_parse_whitespace(tokens: tokens, index: index, acc: "")
}

fn do_parse_whitespace(
  tokens tokens: List(Token),
  index index: Int,
  acc acc: String,
) -> Result(ParseData(Option(String)), ParseError) {
  case tokens {
    [Unknown(#(start_index, _), character), ..] ->
      Error(UnknownCharacter(character, start_index))
    [Whitespace(#(_, end_index), whitespace), ..rest] -> {
      do_parse_whitespace(
        tokens: rest,
        index: end_index,
        acc: acc <> whitespace,
      )
    }
    _ -> {
      let data = case acc {
        "" -> None
        _ -> Some(acc)
      }

      Ok(ParseData(data: data, next_index: index, tokens: tokens))
    }
  }
}

fn parse_sign(
  tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Bool), ParseError) {
  case tokens {
    [Unknown(#(start_index, _), character), ..] ->
      Error(UnknownCharacter(character, start_index))
    [Sign(#(_, end_index), _, is_positive), ..rest] ->
      Ok(ParseData(data: is_positive, next_index: end_index, tokens: rest))
    _ -> {
      Ok(ParseData(data: True, next_index: index, tokens: tokens))
    }
  }
}

fn parse_decimal_point(
  tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Bool), ParseError) {
  case tokens {
    [Unknown(#(start_index, _), character), ..] ->
      Error(UnknownCharacter(character, start_index))
    [DecimalPoint(#(_, end_index)), ..rest] ->
      Ok(ParseData(data: True, next_index: end_index, tokens: rest))
    _ -> Ok(ParseData(data: False, next_index: index, tokens: tokens))
  }
}

fn parse_exponent_symbol(
  tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Option(String)), ParseError) {
  case tokens {
    [Unknown(#(start_index, _), character), ..] ->
      Error(UnknownCharacter(character, start_index))
    [ExponentSymbol(#(_, end_index), exponent_symbol), ..rest] ->
      Ok(ParseData(
        data: Some(exponent_symbol),
        next_index: end_index,
        tokens: rest,
      ))
    _ -> Ok(ParseData(data: None, next_index: index, tokens: tokens))
  }
}

fn parse_digits(
  tokens: List(Token),
  index index: Int,
) -> Result(ParseData(Queue(Int)), ParseError) {
  do_parse_digits(
    tokens: tokens,
    index: index,
    acc: queue.new(),
    at_beginning: True,
  )
}

fn do_parse_digits(
  tokens tokens: List(Token),
  index index: Int,
  acc acc: Queue(Int),
  at_beginning at_beginning: Bool,
) -> Result(ParseData(Queue(Int)), ParseError) {
  case tokens {
    [Unknown(#(start_index, _), character), ..] ->
      Error(UnknownCharacter(character, start_index))
    [Whitespace(#(start_index, _), whitespace), ..] if at_beginning ->
      Error(UnknownCharacter(whitespace, start_index))
    [Underscore(#(start_index, end_index)), ..rest] -> {
      let lookahead = rest |> list.first
      let at_end = case lookahead {
        Ok(Digit(_, _, _, _)) -> False
        _ -> True
      }
      let next_is_underscore = case lookahead {
        Ok(Underscore(_)) -> True
        _ -> False
      }

      use <- bool.guard(
        next_is_underscore,
        Error(InvalidUnderscorePosition(start_index + 1)),
      )

      use <- bool.guard(
        at_beginning || at_end,
        Error(InvalidUnderscorePosition(start_index)),
      )

      do_parse_digits(
        tokens: rest,
        index: end_index,
        acc: acc,
        at_beginning: False,
      )
    }
    [Digit(#(_, end_index), _, value, base), ..rest] if value < base -> {
      do_parse_digits(
        tokens: rest,
        index: end_index,
        acc: acc |> queue.push_back(value),
        at_beginning: False,
      )
    }
    [Digit(#(start_index, _), character, value, base), ..] ->
      Error(OutOfBaseRange(character, value, base, start_index))
    _ -> Ok(ParseData(data: acc, next_index: index, tokens: tokens))
  }
}

fn form_float(
  is_positive is_positive: Bool,
  whole_digits whole_digits: Queue(Int),
  fractional_digits fractional_digits: Queue(Int),
  exponent exponent: Int,
) -> Float {
  let #(whole_digits, fractional_digits) =
    scale.by_10(whole_digits, fractional_digits, exponent)

  let whole_float = whole_digits |> digits_to_int |> int.to_float

  let fractional_digits_length = fractional_digits |> queue.length
  let fractional_float =
    fractional_digits
    |> digits_to_int
    |> int.to_float
    |> power(-fractional_digits_length)

  case is_positive {
    True -> whole_float +. fractional_float
    False -> { whole_float +. fractional_float } *. -1.0
  }
}

fn digits_to_int(digits digits: Queue(Int)) -> Int {
  digits_to_int_with_base(digits: digits, base: 10)
}

fn digits_to_int_with_base(digits digits: Queue(Int), base base: Int) -> Int {
  digits |> queue.to_list |> list.fold(0, fn(acc, digit) { acc * base + digit })
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

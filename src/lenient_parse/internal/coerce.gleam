import gleam/bool
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lenient_parse/internal/tokenizer.{
  type Token, DecimalPoint, Digit, Sign, Underscore, Whitespace,
}
import parse_error.{
  type ParseError, EmptyString, InvalidCharacter, InvalidDecimalPosition,
  InvalidSignPosition, InvalidUnderscorePosition, WhitespaceOnlyString,
}

pub type ParseState {
  State(
    tokens: List(Token),
    index: Int,
    previous: Option(Token),
    text_length: Int,
    seen_decimal: Bool,
    seen_digit: Bool,
    acc: String,
  )
}

pub fn coerce_into_valid_number_string(
  text: String,
) -> Result(String, ParseError) {
  State(
    tokens: text |> tokenizer.tokenize_number_string,
    index: 0,
    previous: None,
    text_length: text |> string.length,
    seen_decimal: False,
    seen_digit: False,
    acc: "",
  )
  |> do_coerce_into_valid_number_string
}

fn do_coerce_into_valid_number_string(
  state: ParseState,
) -> Result(String, ParseError) {
  let at_beginning_of_string = state.index == 0
  let acc_is_empty = state.acc |> string.is_empty

  case state.tokens {
    [] if at_beginning_of_string -> Error(EmptyString)
    [] if acc_is_empty -> Error(WhitespaceOnlyString)
    [] -> Ok(state.acc)
    [first, ..rest] -> {
      let at_end_of_string = state.index == state.text_length - 1
      let is_digit = first |> tokenizer.is_digit
      let seen_digit = state.seen_digit || is_digit

      let res = case first {
        Sign(sign) if seen_digit ->
          Error(InvalidSignPosition(sign, state.index))
        first if state.previous == Some(Underscore) -> {
          case first {
            Digit(digit) -> Ok(State(..state, acc: state.acc <> digit))
            Underscore -> Error(InvalidUnderscorePosition(state.index))
            _ -> Error(InvalidUnderscorePosition(state.index - 1))
          }
        }
        Underscore -> {
          use <- bool.guard(
            at_beginning_of_string || at_end_of_string,
            Error(InvalidUnderscorePosition(state.index)),
          )

          let next_to_valid_character =
            state.previous
            |> option.map(tokenizer.is_digit)
            |> option.unwrap(False)

          use <- bool.guard(
            !next_to_valid_character,
            Error(InvalidUnderscorePosition(state.index)),
          )

          Ok(state)
        }
        DecimalPoint -> {
          let is_invalid_decimal_position_error =
            state.text_length == 1 || state.seen_decimal

          use <- bool.guard(
            is_invalid_decimal_position_error,
            Error(InvalidDecimalPosition(state.index)),
          )

          let acc = case at_beginning_of_string, at_end_of_string {
            True, False -> "0" <> "." <> state.acc
            False, True -> state.acc <> "." <> "0"
            _, _ -> state.acc <> "."
          }

          Ok(State(..state, seen_decimal: True, acc: acc))
        }
        Whitespace(_) -> Ok(state)
        _ -> {
          first
          |> tokenizer.to_result
          |> result.map(fn(a) {
            State(..state, seen_digit: seen_digit, acc: state.acc <> a)
          })
          |> result.map_error(fn(a) { InvalidCharacter(a, state.index) })
        }
      }

      use state <- result.try(res)

      State(
        ..state,
        tokens: rest,
        previous: Some(first),
        index: state.index + 1,
      )
      |> do_coerce_into_valid_number_string
    }
  }
}

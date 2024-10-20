import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lenient_parse/internal/tokenizer.{
  type Token, DecimalPoint, Digit, Sign, Underscore, Whitespace,
}
import lenient_parse/internal/whitespace_block_tracker.{
  type WhitespaceBlockTracker,
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
    tracker: WhitespaceBlockTracker,
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
    tracker: whitespace_block_tracker.new(),
    seen_decimal: False,
    seen_digit: False,
    acc: "",
  )
  |> do_coerce_into_valid_number_string
}

fn do_coerce_into_valid_number_string(
  state: ParseState,
) -> Result(String, ParseError) {
  let at_beginning = state.index == 0
  let acc_is_empty = state.acc |> string.is_empty

  case state.tokens {
    [] if at_beginning -> Error(EmptyString)
    [] if acc_is_empty -> Error(WhitespaceOnlyString)
    [] -> Ok(state.acc)
    [first, ..rest] -> {
      let at_end = state.index == state.text_length - 1
      let seen_digit = state.seen_digit || { first |> tokenizer.is_digit }
      let previous_is_underscore = state.previous == Some(Underscore)
      let previous_is_digit =
        state.previous
        |> option.map(tokenizer.is_digit)
        |> option.unwrap(False)

      let parse_result = case first {
        Sign(sign) if seen_digit ->
          Error(InvalidSignPosition(sign, state.index))
        Digit(digit) if previous_is_underscore ->
          Ok(State(..state, acc: state.acc <> digit))
        Underscore if at_beginning || at_end || !previous_is_digit ->
          Error(InvalidUnderscorePosition(state.index))
        _ if previous_is_underscore ->
          Error(InvalidUnderscorePosition(state.index - 1))
        Underscore -> Ok(state)
        DecimalPoint if state.text_length == 1 || state.seen_decimal ->
          Error(InvalidDecimalPosition(state.index))
        DecimalPoint if at_beginning ->
          Ok(State(..state, seen_decimal: True, acc: "0" <> "." <> state.acc))
        DecimalPoint if at_end ->
          Ok(State(..state, seen_decimal: True, acc: state.acc <> "." <> "0"))
        DecimalPoint ->
          Ok(State(..state, seen_decimal: True, acc: state.acc <> "."))
        Whitespace(_) -> Ok(state)
        _ -> {
          first
          |> tokenizer.to_result
          |> result.map(fn(a) {
            State(..state, seen_digit: seen_digit, acc: state.acc <> a)
          })
          |> result.map_error(InvalidCharacter(_, state.index))
        }
      }

      let tracker = state.tracker |> whitespace_block_tracker.mark(first)

      case state.previous {
        Some(previous) if tracker == 0b101 -> {
          let previous = previous |> tokenizer.to_result |> result.unwrap_both
          Error(InvalidCharacter(previous, state.index - 1))
        }
        _ -> {
          use state <- result.try(parse_result)

          State(
            ..state,
            tokens: rest,
            previous: Some(first),
            index: state.index + 1,
            tracker: tracker,
          )
          |> do_coerce_into_valid_number_string
        }
      }
    }
  }
}

import gleam/dict.{type Dict}
import gleam/int
import gleam/string
import lenient_parse/internal/whitespace.{type WhitespaceData}
import parse_error.{
  type ParseError, BasePrefixOnly, EmptyString, InvalidBaseValue,
  InvalidDecimalPosition, InvalidDigitPosition, InvalidExponentSymbolPosition,
  InvalidSignPosition, InvalidUnderscorePosition, OutOfBaseRange,
  OutOfFloatRange, OutOfIntRange, UnknownCharacter, WhitespaceOnlyString,
}

pub fn to_printable_text(text: String) -> String {
  do_to_printable_text(
    characters: text |> string.to_graphemes,
    whitespace_character_dict: whitespace.character_dict(),
    acc: "",
  )
}

fn do_to_printable_text(
  characters characters: List(String),
  whitespace_character_dict whitespace_character_dict: Dict(
    String,
    WhitespaceData,
  ),
  acc acc: String,
) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case whitespace_character_dict |> dict.get(first) {
        Ok(whitespace_data) -> whitespace_data.printable
        Error(_) -> first
      }

      do_to_printable_text(
        characters: rest,
        whitespace_character_dict:,
        acc: acc <> printable,
      )
    }
  }
}

pub fn error_to_string(error: ParseError) -> String {
  case error {
    EmptyString -> "empty string"
    WhitespaceOnlyString -> "whitespace only string"
    InvalidUnderscorePosition(index) ->
      "underscore at invalid position: " <> index |> int.to_string
    InvalidDecimalPosition(index) ->
      "decimal at invalid position: " <> index |> int.to_string
    InvalidSignPosition(index, sign) ->
      "sign \"" <> sign <> "\" at invalid position: " <> index |> int.to_string
    InvalidDigitPosition(index, digit) ->
      "digit \""
      <> digit
      <> "\" at invalid position: "
      <> index |> int.to_string
    BasePrefixOnly(#(start_index, end_index), prefix) ->
      "inferred base prefix only: "
      <> prefix
      <> " at index range: "
      <> start_index |> int.to_string
      <> ".."
      <> end_index |> int.to_string
    OutOfBaseRange(index, character, value, base) ->
      "digit character \""
      <> character
      <> "\" ("
      <> value |> int.to_string
      <> ") at position "
      <> index |> int.to_string
      <> " is out of range for base: "
      <> base |> int.to_string
    InvalidExponentSymbolPosition(index, exponent_symbol) ->
      "exponent symbol \""
      <> exponent_symbol
      <> "\" at invalid position: "
      <> index |> int.to_string
    UnknownCharacter(index, character) ->
      "unknown character \""
      <> character
      <> "\" at index: "
      <> index |> int.to_string
    InvalidBaseValue(base) -> "invalid base value: " <> base |> int.to_string
    OutOfIntRange(integer_string) ->
      "integer value \""
      <> integer_string
      <> "\" cannot safely be represented on the JavaScript target"
    OutOfFloatRange(float_string) ->
      "float value \"" <> float_string <> "\" cannot safely be represented"
  }
}

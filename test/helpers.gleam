import gleam/dict.{type Dict}
import gleam/int
import gleam/string
import lenient_parse/internal/whitespace.{type WhitespaceData}
import lenient_parse/parse_error.{
  type ParseError, BasePrefixOnly, EmptyString, InvalidBaseValue,
  InvalidDecimalPosition, InvalidDigitPosition, InvalidExponentSymbolPosition,
  InvalidSignPosition, InvalidUnderscorePosition, OutOfBaseRange,
  OutOfFloatRange, OutOfIntRange, UnknownCharacter, WhitespaceOnlyString,
}

pub fn to_printable_text(text: String) -> String {
  to_printable_text_loop(
    characters: string.to_graphemes(text),
    whitespace_character_dict: whitespace.character_dict(),
    acc: "",
  )
}

fn to_printable_text_loop(
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
      let printable = case dict.get(whitespace_character_dict, first) {
        Ok(whitespace_data) -> whitespace_data.printable
        Error(_) -> first
      }

      to_printable_text_loop(
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
      "underscore at invalid position: " <> int.to_string(index)
    InvalidDecimalPosition(index) ->
      "decimal at invalid position: " <> int.to_string(index)
    InvalidSignPosition(index, sign) ->
      "sign \"" <> sign <> "\" at invalid position: " <> int.to_string(index)
    InvalidDigitPosition(index, digit) ->
      "digit \"" <> digit <> "\" at invalid position: " <> int.to_string(index)
    BasePrefixOnly(#(start_index, end_index), prefix) ->
      "inferred base prefix only: "
      <> prefix
      <> " at index range: "
      <> int.to_string(start_index)
      <> ".."
      <> int.to_string(end_index)
    OutOfBaseRange(index, character, value, base) ->
      "digit character \""
      <> character
      <> "\" ("
      <> int.to_string(value)
      <> ") at position "
      <> int.to_string(value)
      <> " is out of range for base: "
      <> int.to_string(base)
    InvalidExponentSymbolPosition(index, exponent_symbol) ->
      "exponent symbol \""
      <> exponent_symbol
      <> "\" at invalid position: "
      <> int.to_string(index)
    UnknownCharacter(index, character) ->
      "unknown character \""
      <> character
      <> "\" at index: "
      <> int.to_string(index)
    InvalidBaseValue(base) -> "invalid base value: " <> int.to_string(base)
    OutOfIntRange(integer_string) ->
      "integer value \""
      <> integer_string
      <> "\" cannot safely be represented on the JavaScript target"
    OutOfFloatRange(float_string) ->
      "float value \"" <> float_string <> "\" cannot safely be represented"
  }
}

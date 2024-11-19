import gleam/dict
import gleam/list
import gleam/string
import helpers
import lenient_parse/internal/whitespace
import parse_error.{
  type ParseError, EmptyString, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentSymbolPosition, InvalidUnderscorePosition, UnknownCharacter,
  WhitespaceOnlyString,
}
import python/python_error.{type PythonError, ValueError}
import test_data.{type FloatTestData, FloatTestData}

fn could_not_convert_string_to_float_error(input: String) -> PythonError {
  let message = "could not convert string to float: '" <> input <> "'"
  ValueError(message)
}

fn float_test_data(
  input input: String,
  expected_program_output expected_program_output: Result(Float, ParseError),
  python_error_function python_error_function: fn(String) -> PythonError,
) -> FloatTestData {
  let printable_text = input |> helpers.to_printable_text

  FloatTestData(
    input: input,
    expected_program_output: expected_program_output,
    expected_python_output: Error(python_error_function(printable_text)),
  )
}

fn invalid_empty_or_whitespace() -> List(FloatTestData) {
  let all_whitespace_characters_string =
    whitespace.character_dict() |> dict.keys |> string.join("")

  [
    float_test_data(
      input: "",
      expected_program_output: Error(EmptyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: " ",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "\t",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "\n",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "\r",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "\f",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "\r\n",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: " \t\n\r\f ",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "  \t  ",
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: all_whitespace_characters_string,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: could_not_convert_string_to_float_error,
    ),
  ]
}

fn invalid_decimal_position() -> List(FloatTestData) {
  [
    float_test_data(
      input: "..1",
      expected_program_output: Error(InvalidDecimalPosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1..",
      expected_program_output: Error(InvalidDecimalPosition(2)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: ".1.",
      expected_program_output: Error(InvalidDecimalPosition(2)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: ".",
      expected_program_output: Error(InvalidDecimalPosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "..",
      expected_program_output: Error(InvalidDecimalPosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: " .",
      expected_program_output: Error(InvalidDecimalPosition(1)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1.2.3",
      expected_program_output: Error(InvalidDecimalPosition(3)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: ".1.2",
      expected_program_output: Error(InvalidDecimalPosition(2)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
  ]
}

fn invalid_underscore_position() -> List(FloatTestData) {
  [
    float_test_data(
      input: "_.",
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "._",
      expected_program_output: Error(InvalidUnderscorePosition(1)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1_.000",
      expected_program_output: Error(InvalidUnderscorePosition(1)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1._000",
      expected_program_output: Error(InvalidUnderscorePosition(2)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "_1000.0",
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1000.0_",
      expected_program_output: Error(InvalidUnderscorePosition(6)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1000._0",
      expected_program_output: Error(InvalidUnderscorePosition(5)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1000_.0",
      expected_program_output: Error(InvalidUnderscorePosition(4)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1000_.",
      expected_program_output: Error(InvalidUnderscorePosition(4)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1_000__000.0",
      expected_program_output: Error(InvalidUnderscorePosition(6)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "_1_000.0",
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1_000.0_",
      expected_program_output: Error(InvalidUnderscorePosition(7)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
  ]
}

fn unknown_character() -> List(FloatTestData) {
  [
    float_test_data(
      input: ". ",
      expected_program_output: Error(UnknownCharacter(1, " ")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "abc",
      expected_program_output: Error(UnknownCharacter(0, "a")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "100.00c01",
      expected_program_output: Error(UnknownCharacter(6, "c")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "3.14f",
      expected_program_output: Error(UnknownCharacter(4, "f")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "$100.00",
      expected_program_output: Error(UnknownCharacter(0, "$")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1." <> whitespace.four_per_em_space.character <> "0",
      expected_program_output: Error(UnknownCharacter(
        2,
        whitespace.four_per_em_space.character,
      )),
      python_error_function: could_not_convert_string_to_float_error,
    ),
  ]
}

fn invalid_exponent_symbol_position() -> List(FloatTestData) {
  [
    float_test_data(
      input: "e",
      expected_program_output: Error(InvalidExponentSymbolPosition(0, "e")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "E",
      expected_program_output: Error(InvalidExponentSymbolPosition(0, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "e4",
      expected_program_output: Error(InvalidExponentSymbolPosition(0, "e")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "E4",
      expected_program_output: Error(InvalidExponentSymbolPosition(0, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4e",
      expected_program_output: Error(InvalidExponentSymbolPosition(1, "e")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4E",
      expected_program_output: Error(InvalidExponentSymbolPosition(1, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4.e",
      expected_program_output: Error(InvalidExponentSymbolPosition(2, "e")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4.E",
      expected_program_output: Error(InvalidExponentSymbolPosition(2, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4e.",
      expected_program_output: Error(InvalidExponentSymbolPosition(1, "e")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4E.",
      expected_program_output: Error(InvalidExponentSymbolPosition(1, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "E4.0",
      expected_program_output: Error(InvalidExponentSymbolPosition(0, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4.0E",
      expected_program_output: Error(InvalidExponentSymbolPosition(3, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1_234.e-4e",
      expected_program_output: Error(InvalidExponentSymbolPosition(9, "e")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1e2e3",
      expected_program_output: Error(InvalidExponentSymbolPosition(3, "e")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1E2E3",
      expected_program_output: Error(InvalidExponentSymbolPosition(3, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
  ]
}

fn invalid_digit_position() {
  [
    float_test_data(
      input: "1" <> whitespace.four_per_em_space.character <> "0",
      expected_program_output: Error(InvalidDigitPosition(2, "0")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
  ]
}

fn invalid_mixed() -> List(FloatTestData) {
  [
    float_test_data(
      input: "4.0E_2",
      expected_program_output: Error(InvalidUnderscorePosition(4)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1.2e_3",
      expected_program_output: Error(InvalidUnderscorePosition(4)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4.0_E2",
      expected_program_output: Error(InvalidUnderscorePosition(3)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1_234.e-4.3",
      expected_program_output: Error(InvalidDecimalPosition(9)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "_1.2e3",
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "1.2e3_",
      expected_program_output: Error(InvalidUnderscorePosition(5)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: ".e",
      expected_program_output: Error(InvalidDecimalPosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: ".E",
      expected_program_output: Error(InvalidDecimalPosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: ".e4",
      expected_program_output: Error(InvalidDecimalPosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: ".E4",
      expected_program_output: Error(InvalidDecimalPosition(0)),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: " 4.0E",
      expected_program_output: Error(InvalidExponentSymbolPosition(4, "E")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: "4.0E ",
      expected_program_output: Error(UnknownCharacter(4, " ")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
    float_test_data(
      input: " 4.0E ",
      expected_program_output: Error(UnknownCharacter(5, " ")),
      python_error_function: could_not_convert_string_to_float_error,
    ),
  ]
}

pub fn data() -> List(FloatTestData) {
  [
    invalid_empty_or_whitespace(),
    invalid_decimal_position(),
    invalid_underscore_position(),
    unknown_character(),
    invalid_exponent_symbol_position(),
    invalid_digit_position(),
    invalid_mixed(),
  ]
  |> list.flatten
}

import gleam/list
import parse_error.{
  EmptyString, InvalidDecimalPosition, InvalidExponentSymbolPosition,
  InvalidUnderscorePosition, UnknownCharacter, WhitespaceOnlyString,
}
import test_data.{type FloatTestData, FloatTestData}

const invalid_empty_or_whitespace: List(FloatTestData) = [
  FloatTestData(
    input: "",
    expected_program_output: Error(EmptyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: " ",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\t",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\n",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\r",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\f",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\r\n",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: " \t\n\r\f ",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "  \t  ",
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
]

const invalid_decimal_position: List(FloatTestData) = [
  FloatTestData(
    input: "..1",
    expected_program_output: Error(InvalidDecimalPosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1..",
    expected_program_output: Error(InvalidDecimalPosition(2)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".1.",
    expected_program_output: Error(InvalidDecimalPosition(2)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".",
    expected_program_output: Error(InvalidDecimalPosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "..",
    expected_program_output: Error(InvalidDecimalPosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: " .",
    expected_program_output: Error(InvalidDecimalPosition(1)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1.2.3",
    expected_program_output: Error(InvalidDecimalPosition(3)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".1.2",
    expected_program_output: Error(InvalidDecimalPosition(2)),
    expected_python_output: Error(Nil),
  ),
]

const invalid_underscore_position: List(FloatTestData) = [
  FloatTestData(
    input: "_.",
    expected_program_output: Error(InvalidUnderscorePosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "._",
    expected_program_output: Error(InvalidUnderscorePosition(1)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1_.000",
    expected_program_output: Error(InvalidUnderscorePosition(1)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1._000",
    expected_program_output: Error(InvalidUnderscorePosition(2)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "_1000.0",
    expected_program_output: Error(InvalidUnderscorePosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000.0_",
    expected_program_output: Error(InvalidUnderscorePosition(6)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000._0",
    expected_program_output: Error(InvalidUnderscorePosition(5)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000_.0",
    expected_program_output: Error(InvalidUnderscorePosition(4)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000_.",
    expected_program_output: Error(InvalidUnderscorePosition(4)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1_000__000.0",
    expected_program_output: Error(InvalidUnderscorePosition(6)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "_1_000.0",
    expected_program_output: Error(InvalidUnderscorePosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1_000.0_",
    expected_program_output: Error(InvalidUnderscorePosition(7)),
    expected_python_output: Error(Nil),
  ),
]

const unknown_character: List(FloatTestData) = [
  FloatTestData(
    input: ". ",
    expected_program_output: Error(UnknownCharacter(1, " ")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "abc",
    expected_program_output: Error(UnknownCharacter(0, "a")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "100.00c01",
    expected_program_output: Error(UnknownCharacter(6, "c")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "3.14f",
    expected_program_output: Error(UnknownCharacter(4, "f")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "$100.00",
    expected_program_output: Error(UnknownCharacter(0, "$")),
    expected_python_output: Error(Nil),
  ),
]

const invalid_exponent_symbol_position: List(FloatTestData) = [
  FloatTestData(
    input: "e",
    expected_program_output: Error(InvalidExponentSymbolPosition(0, "e")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "E",
    expected_program_output: Error(InvalidExponentSymbolPosition(0, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "e4",
    expected_program_output: Error(InvalidExponentSymbolPosition(0, "e")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "E4",
    expected_program_output: Error(InvalidExponentSymbolPosition(0, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4e",
    expected_program_output: Error(InvalidExponentSymbolPosition(1, "e")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4E",
    expected_program_output: Error(InvalidExponentSymbolPosition(1, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4.e",
    expected_program_output: Error(InvalidExponentSymbolPosition(2, "e")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4.E",
    expected_program_output: Error(InvalidExponentSymbolPosition(2, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4e.",
    expected_program_output: Error(InvalidExponentSymbolPosition(1, "e")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4E.",
    expected_program_output: Error(InvalidExponentSymbolPosition(1, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "E4.0",
    expected_program_output: Error(InvalidExponentSymbolPosition(0, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4.0E",
    expected_program_output: Error(InvalidExponentSymbolPosition(3, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1_234.e-4e",
    expected_program_output: Error(InvalidExponentSymbolPosition(9, "e")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1e2e3",
    expected_program_output: Error(InvalidExponentSymbolPosition(3, "e")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1E2E3",
    expected_program_output: Error(InvalidExponentSymbolPosition(3, "E")),
    expected_python_output: Error(Nil),
  ),
]

const invalid_mixed: List(FloatTestData) = [
  FloatTestData(
    input: "4.0E_2",
    expected_program_output: Error(InvalidUnderscorePosition(4)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1.2e_3",
    expected_program_output: Error(InvalidUnderscorePosition(4)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4.0_E2",
    expected_program_output: Error(InvalidUnderscorePosition(3)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1_234.e-4.3",
    expected_program_output: Error(InvalidDecimalPosition(9)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "_1.2e3",
    expected_program_output: Error(InvalidUnderscorePosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1.2e3_",
    expected_program_output: Error(InvalidUnderscorePosition(5)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".e",
    expected_program_output: Error(InvalidDecimalPosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".E",
    expected_program_output: Error(InvalidDecimalPosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".e4",
    expected_program_output: Error(InvalidDecimalPosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".E4",
    expected_program_output: Error(InvalidDecimalPosition(0)),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: " 4.0E",
    expected_program_output: Error(InvalidExponentSymbolPosition(4, "E")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: "4.0E ",
    expected_program_output: Error(UnknownCharacter(4, " ")),
    expected_python_output: Error(Nil),
  ),
  FloatTestData(
    input: " 4.0E ",
    expected_program_output: Error(UnknownCharacter(5, " ")),
    expected_python_output: Error(Nil),
  ),
]

pub fn data() -> List(FloatTestData) {
  [
    invalid_empty_or_whitespace,
    invalid_decimal_position,
    invalid_underscore_position,
    unknown_character,
    invalid_exponent_symbol_position,
    invalid_mixed,
  ]
  |> list.flatten
}

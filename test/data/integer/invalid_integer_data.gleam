import gleam/list
import parse_error.{
  EmptyString, InvalidDecimalPosition, InvalidDigitPosition,
  InvalidExponentPosition, InvalidSignPosition, InvalidUnderscorePosition,
  UnknownCharacter, WhitespaceOnlyString,
}
import types.{type IntegerTestData, IntegerTestData}

const invalid_empty_or_whitespace: List(IntegerTestData) = [
  IntegerTestData(
    input: "",
    output: Error(EmptyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " ",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\t",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\n",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\r",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\f",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\r\n",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " \t\n\r\f\r\n ",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
]

const invalid_underscore_positions: List(IntegerTestData) = [
  IntegerTestData(
    input: "_",
    output: Error(InvalidUnderscorePosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "_1000",
    output: Error(InvalidUnderscorePosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1000_",
    output: Error(InvalidUnderscorePosition(4)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " _1000",
    output: Error(InvalidUnderscorePosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1000_ ",
    output: Error(InvalidUnderscorePosition(4)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "+_1000",
    output: Error(InvalidUnderscorePosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "-_1000",
    output: Error(InvalidUnderscorePosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1__000",
    output: Error(InvalidUnderscorePosition(2)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1_000__000",
    output: Error(InvalidUnderscorePosition(6)),
    python_output: Error(Nil),
  ),
]

const invalid_characters: List(IntegerTestData) = [
  IntegerTestData(
    input: "a",
    output: Error(UnknownCharacter("a", 0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1b1",
    output: Error(UnknownCharacter("b", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "+ 1",
    output: Error(UnknownCharacter(" ", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "abc",
    output: Error(UnknownCharacter("a", 0)),
    python_output: Error(Nil),
  ),
]

const invalid_digit_positions: List(IntegerTestData) = [
  IntegerTestData(
    input: "1 1",
    output: Error(InvalidDigitPosition("1", 2)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " 12 34 ",
    output: Error(InvalidDigitPosition("3", 4)),
    python_output: Error(Nil),
  ),
]

const invalid_sign_positions: List(IntegerTestData) = [
  IntegerTestData(
    input: "1+",
    output: Error(InvalidSignPosition("+", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1-",
    output: Error(InvalidSignPosition("-", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1+1",
    output: Error(InvalidSignPosition("+", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1-1",
    output: Error(InvalidSignPosition("-", 1)),
    python_output: Error(Nil),
  ),
]

const invalid_decimal_positions: List(IntegerTestData) = [
  IntegerTestData(
    input: ".",
    output: Error(InvalidDecimalPosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "..",
    output: Error(InvalidDecimalPosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "0.0.",
    output: Error(InvalidDecimalPosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: ".0.0",
    output: Error(InvalidDecimalPosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1.",
    output: Error(InvalidDecimalPosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1.0",
    output: Error(InvalidDecimalPosition(1)),
    python_output: Error(Nil),
  ),
]

const invalid_exponent_positions: List(IntegerTestData) = [
  IntegerTestData(
    input: "e",
    output: Error(InvalidExponentPosition("e", 0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "E",
    output: Error(InvalidExponentPosition("E", 0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "e13",
    output: Error(InvalidExponentPosition("e", 0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1e3",
    output: Error(InvalidExponentPosition("e", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "13e",
    output: Error(InvalidExponentPosition("e", 2)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "E13",
    output: Error(InvalidExponentPosition("E", 0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1E3",
    output: Error(InvalidExponentPosition("E", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "13E",
    output: Error(InvalidExponentPosition("E", 2)),
    python_output: Error(Nil),
  ),
]

pub fn data() -> List(IntegerTestData) {
  [
    invalid_empty_or_whitespace,
    invalid_underscore_positions,
    invalid_characters,
    invalid_digit_positions,
    invalid_sign_positions,
    invalid_decimal_positions,
    invalid_exponent_positions,
  ]
  |> list.flatten
}

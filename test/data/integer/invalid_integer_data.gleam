import gleam/list
import parse_error.{
  BasePrefixOnly, EmptyString, InvalidBaseValue, InvalidDigitPosition,
  InvalidSignPosition, InvalidUnderscorePosition, OutOfBaseRange,
  UnknownCharacter, WhitespaceOnlyString,
}
import test_data.{type IntegerTestData, IntegerTestData}

const invalid_empty_or_whitespace: List(IntegerTestData) = [
  IntegerTestData(
    input: "",
    base: 10,
    expected_program_output: Error(EmptyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " ",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\t",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\n",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\r",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\f",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\r\n",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " \t\n\r\f\r\n ",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "   ",
    base: 10,
    expected_program_output: Error(WhitespaceOnlyString),
    expected_python_output: Error(Nil),
  ),
]

const invalid_underscore_position: List(IntegerTestData) = [
  IntegerTestData(
    input: "_",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(0)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "_1000",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(0)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1000_",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(4)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " _1000",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(1)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1000_ ",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(4)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "+_1000",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(1)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "-_1000",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(1)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1__000",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(2)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1_000__000",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(6)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "_1_000",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(0)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1_000_",
    base: 10,
    expected_program_output: Error(InvalidUnderscorePosition(5)),
    expected_python_output: Error(Nil),
  ),
]

const unknown_character: List(IntegerTestData) = [
  IntegerTestData(
    input: "+ 1",
    base: 10,
    expected_program_output: Error(UnknownCharacter(1, " ")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: ".",
    base: 10,
    expected_program_output: Error(UnknownCharacter(0, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "..",
    base: 10,
    expected_program_output: Error(UnknownCharacter(0, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "0.0.",
    base: 10,
    expected_program_output: Error(UnknownCharacter(1, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: ".0.0",
    base: 10,
    expected_program_output: Error(UnknownCharacter(0, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1.",
    base: 10,
    expected_program_output: Error(UnknownCharacter(1, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1.0",
    base: 10,
    expected_program_output: Error(UnknownCharacter(1, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1$",
    base: 10,
    expected_program_output: Error(UnknownCharacter(1, "$")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "#123",
    base: 10,
    expected_program_output: Error(UnknownCharacter(0, "#")),
    expected_python_output: Error(Nil),
  ),
]

const out_of_base_range: List(IntegerTestData) = [
  IntegerTestData(
    input: "a",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "a", 10, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1b1",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(1, "b", 11, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "abc",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "a", 10, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "e",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "e", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "E",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "E", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "e13",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "e", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1e3",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(1, "e", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "13e",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(2, "e", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "E13",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "E", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1E3",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(1, "E", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "13E",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(2, "E", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "151",
    base: 2,
    expected_program_output: Error(OutOfBaseRange(1, "5", 5, 2)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "DEAD_BEEF",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "D", 13, 10)),
    expected_python_output: Error(Nil),
  ),
]

const invalid_digit_position: List(IntegerTestData) = [
  IntegerTestData(
    input: "1 1",
    base: 10,
    expected_program_output: Error(InvalidDigitPosition(2, "1")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " 12 34 ",
    base: 10,
    expected_program_output: Error(InvalidDigitPosition(4, "3")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1 2 3",
    base: 10,
    expected_program_output: Error(InvalidDigitPosition(2, "2")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "123 456",
    base: 10,
    expected_program_output: Error(InvalidDigitPosition(4, "4")),
    expected_python_output: Error(Nil),
  ),
]

const invalid_sign_position: List(IntegerTestData) = [
  IntegerTestData(
    input: "1+",
    base: 10,
    expected_program_output: Error(InvalidSignPosition(1, "+")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1-",
    base: 10,
    expected_program_output: Error(InvalidSignPosition(1, "-")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1+1",
    base: 10,
    expected_program_output: Error(InvalidSignPosition(1, "+")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1-1",
    base: 10,
    expected_program_output: Error(InvalidSignPosition(1, "-")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "++1",
    base: 10,
    expected_program_output: Error(InvalidSignPosition(1, "+")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "--1",
    base: 10,
    expected_program_output: Error(InvalidSignPosition(1, "-")),
    expected_python_output: Error(Nil),
  ),
]

const invalid_base_value: List(IntegerTestData) = [
  IntegerTestData(
    input: "151",
    base: 1,
    expected_program_output: Error(InvalidBaseValue(1)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "151",
    base: 37,
    expected_program_output: Error(InvalidBaseValue(37)),
    expected_python_output: Error(Nil),
  ),
]

const base_prefix_only: List(IntegerTestData) = [
  IntegerTestData(
    input: "  0b",
    base: 0,
    expected_program_output: Error(BasePrefixOnly(#(2, 4), "0b")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "  0b  ",
    base: 0,
    expected_program_output: Error(UnknownCharacter(4, " ")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "0b100b",
    base: 0,
    expected_program_output: Error(OutOfBaseRange(5, "b", 11, 2)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "0b1001",
    base: 8,
    expected_program_output: Error(OutOfBaseRange(1, "b", 11, 8)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "0XABCD",
    base: 2,
    expected_program_output: Error(OutOfBaseRange(1, "X", 33, 2)),
    expected_python_output: Error(Nil),
  ),
]

const invalid_mixed: List(IntegerTestData) = [
  IntegerTestData(
    input: "e_1_3",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(0, "e", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1_3_e",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(4, "e", 14, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1._3_e",
    base: 10,
    expected_program_output: Error(UnknownCharacter(1, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1+._3_e",
    base: 10,
    expected_program_output: Error(InvalidSignPosition(1, "+")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1 1+._3_e",
    base: 10,
    expected_program_output: Error(InvalidDigitPosition(2, "1")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1_a_2",
    base: 10,
    expected_program_output: Error(OutOfBaseRange(2, "a", 10, 10)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "+1.2_3",
    base: 10,
    expected_program_output: Error(UnknownCharacter(2, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "  1_f_1  ",
    base: 2,
    expected_program_output: Error(OutOfBaseRange(4, "f", 15, 2)),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "  1._5_1  ",
    base: 2,
    expected_program_output: Error(UnknownCharacter(3, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "  1_1__1  ",
    base: 2,
    expected_program_output: Error(InvalidUnderscorePosition(6)),
    expected_python_output: Error(Nil),
  ),
  // Base 0, has no prefix, default to decimal, but error because of UnknownCharacter
  IntegerTestData(
    input: " \n6_666.",
    base: 0,
    expected_program_output: Error(UnknownCharacter(7, ".")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " \n0x ABC.",
    base: 0,
    expected_program_output: Error(UnknownCharacter(4, " ")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " \n0xA BC.",
    base: 0,
    expected_program_output: Error(InvalidDigitPosition(6, "B")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " \n0b101 1",
    base: 0,
    expected_program_output: Error(InvalidDigitPosition(8, "1")),
    expected_python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "0xDEAD_BEEF_",
    base: 0,
    expected_program_output: Error(InvalidUnderscorePosition(11)),
    expected_python_output: Error(Nil),
  ),
]

pub fn data() -> List(IntegerTestData) {
  [
    invalid_empty_or_whitespace,
    invalid_underscore_position,
    unknown_character,
    out_of_base_range,
    invalid_digit_position,
    invalid_sign_position,
    invalid_base_value,
    base_prefix_only,
    invalid_mixed,
  ]
  |> list.flatten
}

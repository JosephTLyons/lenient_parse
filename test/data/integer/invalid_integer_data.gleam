import gleam/int
import gleam/list
import helpers
import parse_error.{
  type ParseError, BasePrefixOnly, EmptyString, InvalidBaseValue,
  InvalidDigitPosition, InvalidSignPosition, InvalidUnderscorePosition,
  OutOfBaseRange, UnknownCharacter, WhitespaceOnlyString,
}
import python/python_error.{type PythonError, ValueError}
import test_data.{type IntegerTestData, IntegerTestData}

fn invalid_literal_for_int_error(input: String, base: Int) -> PythonError {
  let message =
    "invalid literal for int() with base "
    <> base |> int.to_string
    <> ": '"
    <> input
    <> "'"

  ValueError(message)
}

fn invalid_base_value_error(_: String, _: Int) -> PythonError {
  ValueError("int() base must be >= 2 and <= 36, or 0")
}

fn integer_test_data(
  input input: String,
  base base: Int,
  expected_program_output expected_program_output: Result(Int, ParseError),
  python_error_function python_error_function: fn(String, Int) -> PythonError,
) -> IntegerTestData {
  let printable_text = input |> helpers.to_printable_text(True)

  IntegerTestData(
    input: input,
    base: base,
    expected_program_output: expected_program_output,
    expected_python_output: Error(python_error_function(printable_text, base)),
  )
}

fn invalid_empty_or_whitespace() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "",
      base: 10,
      expected_program_output: Error(EmptyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: " ",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "\t",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "\n",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "\r",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "\f",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "\r\n",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: " \t\n\r\f\r\n ",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "   ",
      base: 10,
      expected_program_output: Error(WhitespaceOnlyString),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

fn invalid_underscore_position() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "_",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "_1000",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1000_",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(4)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: " _1000",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(1)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1000_ ",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(4)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "+_1000",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(1)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "-_1000",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(1)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1__000",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(2)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1_000__000",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(6)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "_1_000",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1_000_",
      base: 10,
      expected_program_output: Error(InvalidUnderscorePosition(5)),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

fn unknown_characters() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "+ 1",
      base: 10,
      expected_program_output: Error(UnknownCharacter(1, " ")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: ".",
      base: 10,
      expected_program_output: Error(UnknownCharacter(0, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "..",
      base: 10,
      expected_program_output: Error(UnknownCharacter(0, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "0.0.",
      base: 10,
      expected_program_output: Error(UnknownCharacter(1, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: ".0.0",
      base: 10,
      expected_program_output: Error(UnknownCharacter(0, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1.",
      base: 10,
      expected_program_output: Error(UnknownCharacter(1, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1.0",
      base: 10,
      expected_program_output: Error(UnknownCharacter(1, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1$",
      base: 10,
      expected_program_output: Error(UnknownCharacter(1, "$")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "#123",
      base: 10,
      expected_program_output: Error(UnknownCharacter(0, "#")),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

fn out_of_base_range() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "a",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "a", 10, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1b1",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(1, "b", 11, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "abc",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "a", 10, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "e",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "e", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "E",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "E", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "e13",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "e", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1e3",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(1, "e", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "13e",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(2, "e", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "E13",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "E", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1E3",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(1, "E", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "13E",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(2, "E", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "151",
      base: 2,
      expected_program_output: Error(OutOfBaseRange(1, "5", 5, 2)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "DEAD_BEEF",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "D", 13, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

fn invalid_digit_position() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "1 1",
      base: 10,
      expected_program_output: Error(InvalidDigitPosition(2, "1")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: " 12 34 ",
      base: 10,
      expected_program_output: Error(InvalidDigitPosition(4, "3")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1 2 3",
      base: 10,
      expected_program_output: Error(InvalidDigitPosition(2, "2")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "123 456",
      base: 10,
      expected_program_output: Error(InvalidDigitPosition(4, "4")),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

fn invalid_sign_position() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "1+",
      base: 10,
      expected_program_output: Error(InvalidSignPosition(1, "+")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1-",
      base: 10,
      expected_program_output: Error(InvalidSignPosition(1, "-")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1+1",
      base: 10,
      expected_program_output: Error(InvalidSignPosition(1, "+")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1-1",
      base: 10,
      expected_program_output: Error(InvalidSignPosition(1, "-")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "++1",
      base: 10,
      expected_program_output: Error(InvalidSignPosition(1, "+")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "--1",
      base: 10,
      expected_program_output: Error(InvalidSignPosition(1, "-")),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

fn invalid_base_value() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "151",
      base: 1,
      expected_program_output: Error(InvalidBaseValue(1)),
      python_error_function: invalid_base_value_error,
    ),
    integer_test_data(
      input: "151",
      base: 37,
      expected_program_output: Error(InvalidBaseValue(37)),
      python_error_function: invalid_base_value_error,
    ),
  ]
}

fn base_prefix_only() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "  0b",
      base: 0,
      expected_program_output: Error(BasePrefixOnly(#(2, 4), "0b")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "  0b  ",
      base: 0,
      expected_program_output: Error(UnknownCharacter(4, " ")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "0b100b",
      base: 0,
      expected_program_output: Error(OutOfBaseRange(5, "b", 11, 2)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "0b1001",
      base: 8,
      expected_program_output: Error(OutOfBaseRange(1, "b", 11, 8)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "0XABCD",
      base: 2,
      expected_program_output: Error(OutOfBaseRange(1, "X", 33, 2)),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

fn invalid_mixed() -> List(IntegerTestData) {
  [
    integer_test_data(
      input: "e_1_3",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(0, "e", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1_3_e",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(4, "e", 14, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1._3_e",
      base: 10,
      expected_program_output: Error(UnknownCharacter(1, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1+._3_e",
      base: 10,
      expected_program_output: Error(InvalidSignPosition(1, "+")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1 1+._3_e",
      base: 10,
      expected_program_output: Error(InvalidDigitPosition(2, "1")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "1_a_2",
      base: 10,
      expected_program_output: Error(OutOfBaseRange(2, "a", 10, 10)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "+1.2_3",
      base: 10,
      expected_program_output: Error(UnknownCharacter(2, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "  1_f_1  ",
      base: 2,
      expected_program_output: Error(OutOfBaseRange(4, "f", 15, 2)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "  1._5_1  ",
      base: 2,
      expected_program_output: Error(UnknownCharacter(3, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "  1_1__1  ",
      base: 2,
      expected_program_output: Error(InvalidUnderscorePosition(6)),
      python_error_function: invalid_literal_for_int_error,
    ),
    // Base 0, has no prefix, default to decimal, but error because of UnknownCharacter
    integer_test_data(
      input: " \n6_666.",
      base: 0,
      expected_program_output: Error(UnknownCharacter(7, ".")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: " \n0x ABC.",
      base: 0,
      expected_program_output: Error(UnknownCharacter(4, " ")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: " \n0xA BC.",
      base: 0,
      expected_program_output: Error(InvalidDigitPosition(6, "B")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: " \n0b101 1",
      base: 0,
      expected_program_output: Error(InvalidDigitPosition(8, "1")),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "0xDEAD_BEEF_",
      base: 0,
      expected_program_output: Error(InvalidUnderscorePosition(11)),
      python_error_function: invalid_literal_for_int_error,
    ),
    integer_test_data(
      input: "_0xDEAD_BEEF",
      base: 0,
      expected_program_output: Error(InvalidUnderscorePosition(0)),
      python_error_function: invalid_literal_for_int_error,
    ),
  ]
}

pub fn data() -> List(IntegerTestData) {
  [
    invalid_empty_or_whitespace(),
    invalid_underscore_position(),
    unknown_characters(),
    out_of_base_range(),
    invalid_digit_position(),
    invalid_sign_position(),
    invalid_base_value(),
    base_prefix_only(),
    invalid_mixed(),
  ]
  |> list.flatten
}

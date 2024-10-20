import gleam/int
import gleam/list
import helpers
import lenient_parse
import parse_error.{
  EmptyString, GleamIntParseError, InvalidCharacter, InvalidDecimalPosition,
  InvalidSignPosition, InvalidUnderscorePosition, WhitespaceOnlyString,
}

import startest.{describe, it}
import startest/expect

pub fn coerce_into_valid_number_string_tests() {
  describe("int_test", [
    describe(
      "should_coerce",
      [
        #("1", 1),
        #("+123", 123),
        #(" +123 ", 123),
        #(" -123 ", -123),
        #("0123", 123),
        #(" 0123", 123),
        #("-123", -123),
        #("1_000", 1000),
        #("1_000_000", 1_000_000),
        #(" 1 ", 1),
      ]
        |> list.map(fn(tuple) {
          let #(input, output) = tuple
          let output_string = output |> int.to_string
          use <- it("\"" <> input <> "\" -> " <> output_string)

          input
          |> lenient_parse.to_int
          |> expect.to_equal(Ok(output))
        }),
    ),
    describe(
      "should_not_coerce",
      [
        [
          #("", EmptyString),
          #(" ", WhitespaceOnlyString),
          #("\t", WhitespaceOnlyString),
          #("\n", WhitespaceOnlyString),
          #("\r", WhitespaceOnlyString),
          #("\f", WhitespaceOnlyString),
          #(" \t\n\r\f ", WhitespaceOnlyString),
          #("1_000__000", InvalidUnderscorePosition(6)),
          #("1.", GleamIntParseError),
          #("1.0", GleamIntParseError),
          #("", EmptyString),
          #(" ", WhitespaceOnlyString),
          #("abc", InvalidCharacter("a", 0)),
        ],
        [
          #("_", 0),
          #("_1000", 0),
          #("1000_", 4),
          #(" _1000", 1),
          #("1000_ ", 4),
          #("+_1000", 1),
          #("-_1000", 1),
          #("1__000", 2),
        ]
          |> list.map(fn(tuple) {
            let #(input, index) = tuple
            #(input, InvalidUnderscorePosition(index))
          }),
        [
          #("a", "a", 0),
          #("1b1", "b", 1),
          #("+ 1", " ", 1),
          #("1 1", " ", 1),
          #(" 12 34 ", " ", 3),
        ]
          |> list.map(fn(tuple) {
            let #(input, invalid_character, index) = tuple
            #(input, InvalidCharacter(invalid_character, index))
          }),
        [#("1+", "+", 1), #("1-", "-", 1), #("1+1", "+", 1), #("1-1", "-", 1)]
          |> list.map(fn(tuple) {
            let #(input, invalid_sign, index) = tuple
            #(input, InvalidSignPosition(invalid_sign, index))
          }),
        [#(".", 0), #("..", 1), #("0.0.", 3), #(".0.0", 2)]
          |> list.map(fn(tuple) {
            let #(input, index) = tuple
            #(input, InvalidDecimalPosition(index))
          }),
      ]
        |> list.flatten
        |> list.map(fn(tuple) {
          let #(input, error) = tuple
          let printable_text = input |> helpers.to_printable_text
          let error_text = error |> parse_error.to_string
          use <- it("\"" <> printable_text <> "\" -> " <> error_text)

          input
          |> lenient_parse.to_int
          |> expect.to_equal(Error(error))
        }),
    ),
  ])
}

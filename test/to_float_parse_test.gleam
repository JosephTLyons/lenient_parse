import gleam/float
import gleam/list
import helpers
import lenient_parse
import parse_error.{
  EmptyString, InvalidCharacter, InvalidDecimalPosition,
  InvalidUnderscorePosition, WhitespaceOnlyString,
}
import startest.{describe, it}
import startest/expect

pub fn coerce_into_valid_number_string_tests() {
  describe("float_test", [
    describe(
      "should_coerce",
      [
        #("1.001", 1.001),
        #("1.00", 1.0),
        #("1.0", 1.0),
        #("0.1", 0.1),
        #("+1.0", 1.0),
        #("-1.0", -1.0),
        #("+123.321", 123.321),
        #("-123.321", -123.321),
        #("1", 1.0),
        #("1.", 1.0),
        #(".1", 0.1),
        #("1_000_000.0", 1_000_000.0),
        #("1_000_000.000_1", 1_000_000.0001),
        #("1000.000_000", 1000.0),
        #(" 1 ", 1.0),
        #(" 1.0 ", 1.0),
        #(" 1000 ", 1000.0),
      ]
        |> list.map(fn(tuple) {
          let #(input, output) = tuple
          let output_string = output |> float.to_string
          use <- it("\"" <> input <> "\" -> " <> output_string)

          input
          |> lenient_parse.to_float
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
          #("1_000__000.0", InvalidUnderscorePosition(6)),
          #("..1", InvalidDecimalPosition(1)),
          #("1..", InvalidDecimalPosition(2)),
          #(".1.", InvalidDecimalPosition(2)),
          #(".", InvalidDecimalPosition(0)),
          #("", EmptyString),
          #(" ", WhitespaceOnlyString),
          #("abc", InvalidCharacter("a", 0)),
        ],
        [
          #("1_.000", 1),
          #("1._000", 2),
          #("_1000.0", 0),
          #("1000.0_", 6),
          #("1000._0", 5),
          #("1000_.0", 4),
          #("1000_.", 4),
        ]
          |> list.map(fn(tuple) {
            let #(input, index) = tuple
            #(input, InvalidUnderscorePosition(index))
          }),
        [#("100.00c01", "c", 6)]
          |> list.map(fn(tuple) {
            let #(input, invalid_character, index) = tuple
            #(input, InvalidCharacter(invalid_character, index))
          }),
      ]
        |> list.flatten
        |> list.map(fn(tuple) {
          let #(input, error) = tuple
          let printable_text = input |> helpers.to_printable_text
          let error_text = error |> parse_error.to_string
          use <- it("\"" <> printable_text <> "\" -> " <> error_text)

          input
          |> lenient_parse.to_float
          |> expect.to_equal(Error(error))
        }),
    ),
  ])
}

import gleam/float
import gleam/list
import lenient_parse
import parse_error.{
  InvalidCharacter, InvalidDecimalPosition, InvalidUnderscorePosition,
  WhitespaceOnlyOrEmptyString,
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
        #("+123.321", 123.321),
        #("-123.321", -123.321),
        #("1", 1.0),
        #("1.", 1.0),
        #(".1", 0.1),
        #("1_000_000.0", 1_000_000.0),
        #(" 1 ", 1.0),
        #(" 1.0 ", 1.0),
      ]
        |> list.map(fn(pair) {
          let #(input, output) = pair
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
        #("1_000__000.0", InvalidUnderscorePosition),
        #("..1", InvalidDecimalPosition),
        #("1..", InvalidDecimalPosition),
        #(".1.", InvalidDecimalPosition),
        #(".", InvalidDecimalPosition),
        #("", WhitespaceOnlyOrEmptyString),
        #(" ", WhitespaceOnlyOrEmptyString),
        #("abc", InvalidCharacter("a")),
      ]
        |> list.map(fn(pair) {
          let #(input, error) = pair
          let error_text = error |> parse_error.to_string

          use <- it("\"" <> input <> "\" -> " <> error_text)

          input
          |> lenient_parse.to_float
          |> expect.to_equal(Error(error))
        }),
    ),
  ])
}

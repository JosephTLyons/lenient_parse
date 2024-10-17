import coerce.{
  GleamIntParseError, InvalidCharacter, InvalidUnderscorePosition,
  WhitespaceOnlyOrEmptyString,
}
import gleam/int
import gleam/list
import lenient_parse
import startest.{describe, it}
import startest/expect

pub fn coerce_into_valid_number_string_tests() {
  describe("int_test", [
    describe(
      "should_coerce_to_int",
      [
        [
          #("1", 1),
          #("+123", 123),
          #("0123", 123),
          #("-123", -123),
          #("1_000_000", 1_000_000),
          #(" 1 ", 1),
        ]
        |> list.map(fn(pair) {
          let #(input, output) = pair
          let output_string = output |> int.to_string
          use <- it("\"" <> input <> "\" -> " <> output_string)

          input
          |> lenient_parse.to_int
          |> expect.to_equal(Ok(output))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "should_not_coerce_to_int",
      [
        [
          #("1_000__000", InvalidUnderscorePosition),
          #("1.", GleamIntParseError),
          #("1.0", GleamIntParseError),
          #("", WhitespaceOnlyOrEmptyString),
          #(" ", WhitespaceOnlyOrEmptyString),
          #("abc", InvalidCharacter("a")),
        ]
        |> list.map(fn(pair) {
          let #(input, error) = pair
          let error_text = error |> coerce.parse_error_to_string

          use <- it("\"" <> input <> "\" -> " <> error_text)

          input
          |> lenient_parse.to_int
          |> expect.to_equal(Error(error))
        }),
      ]
        |> list.concat,
    ),
  ])
}

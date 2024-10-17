import coerce.{
  InvalidCharacter, InvalidDecimalPosition, InvalidUnderscorePosition,
  SignAtInvalidPosition, WhitespaceOnlyOrEmptyString,
  coerce_into_valid_number_string,
}

import gleam/list
import helpers.{into_printable_text}
import startest.{describe, it}
import startest/expect

pub fn coerce_into_valid_number_string_tests() {
  describe("coerce_into_valid_number_string_test", [
    describe(
      "whitespace_only_or_empty_string",
      [
        ["", " ", "\t", "\n", "\r", "\f", " \t\n\r\f "]
        |> list.map(fn(text) {
          let printable_text = text |> into_printable_text

          use <- it("\"" <> printable_text <> "\"")

          text
          |> coerce_into_valid_number_string
          |> expect.to_equal(Error(WhitespaceOnlyOrEmptyString))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_invalid_character",
      [
        [#("a", "a"), #("1b1", "b"), #("100.00c01", "c"), #("1 1", " ")]
        |> list.map(fn(pair) {
          let #(input, invalid_character) = pair
          use <- it("\"" <> invalid_character <> "\" in \"" <> input <> "\"")

          input
          |> coerce_into_valid_number_string
          |> expect.to_equal(Error(InvalidCharacter(invalid_character)))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_valid_sign_position",
      [
        [#("+1", "+1"), #("-1", "-1"), #("+1.0", "+1.0"), #("-1.0", "-1.0")]
        |> list.map(fn(pair) {
          let #(input, output) = pair
          use <- it("\"" <> output <> "\" in \"" <> input <> "\"")

          input
          |> coerce_into_valid_number_string
          |> expect.to_equal(Ok(output))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_invalid_sign_position",
      [
        [#("1+", "+"), #("1-", "-"), #("1+1", "+"), #("1-1", "-")]
        |> list.map(fn(pair) {
          let #(input, sign_at_invalid_position) = pair
          use <- it(
            "\"" <> sign_at_invalid_position <> "\" in \"" <> input <> "\"",
          )

          input
          |> coerce_into_valid_number_string
          |> expect.to_equal(
            Error(SignAtInvalidPosition(sign_at_invalid_position)),
          )
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_valid_decimal_position",
      [
        [#(".1", "0.1"), #("1.", "1.0")]
        |> list.map(fn(pair) {
          let #(input, output) = pair
          use <- it("\"" <> input <> "\"")
          input
          |> coerce_into_valid_number_string
          |> expect.to_equal(Ok(output))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_invalid_decimal_position",
      [
        [".", "..", "0.0.", ".0.0"]
        |> list.map(fn(text) {
          use <- it("\"" <> text <> "\"")
          text
          |> coerce_into_valid_number_string
          |> expect.to_equal(Error(InvalidDecimalPosition))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_valid_underscore_position",
      [
        [
          #("0", "0"),
          #("0.0", "0.0"),
          #("+1000", "+1000"),
          #("-1000", "-1000"),
          #(" 1000 ", "1000"),
          #(" -1000 ", "-1000"),
          #("1_000", "1000"),
          #("1_000_000", "1000000"),
          #("1_000_000.0", "1000000.0"),
          #("1_000_000.000_1", "1000000.0001"),
          #("1000.000_000", "1000.000000"),
        ]
        |> list.map(fn(pair) {
          let #(input, output) = pair
          use <- it("\"" <> input <> "\" -> \"" <> output <> "\"")

          input
          |> coerce_into_valid_number_string
          |> expect.to_equal(Ok(output))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_invalid_underscore_position",
      [
        [
          "_", "_1000", "1000_", "+_1000", "-_1000", "1__000", "1_.000",
          "1._000", "_1000.0", "1000.0_", "1000._0", "1000_.0", "1000_.",
        ]
        |> list.map(fn(text) {
          use <- it("\"" <> text <> "\"")

          text
          |> coerce_into_valid_number_string
          |> expect.to_equal(Error(InvalidUnderscorePosition))
        }),
      ]
        |> list.concat,
    ),
  ])
}

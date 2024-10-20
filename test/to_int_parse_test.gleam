import gleam/int
import gleam/list
import helpers
import lenient_parse
import parse_error.{
  InvalidCharacter, InvalidDecimalPosition, InvalidSignPosition,
  InvalidUnderscorePosition,
}
import startest.{describe, it}
import startest/expect
import test_data

pub fn coerce_into_valid_number_string_tests() {
  describe("int_test", [
    describe(
      "should_coerce",
      test_data.valid_ints
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
        test_data.invalid_int_assortment,
        test_data.invalid_underscore_position_ints
          |> list.map(fn(tuple) {
            let #(input, index) = tuple
            #(input, InvalidUnderscorePosition(index))
          }),
        test_data.invalid_character_ints
          |> list.map(fn(tuple) {
            let #(input, invalid_character, index) = tuple
            #(input, InvalidCharacter(invalid_character, index))
          }),
        test_data.invalid_sign_position_ints
          |> list.map(fn(tuple) {
            let #(input, invalid_sign, index) = tuple
            #(input, InvalidSignPosition(invalid_sign, index))
          }),
        test_data.invalid_decimal_position_ints
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

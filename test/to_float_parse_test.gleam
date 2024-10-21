import gleam/float
import gleam/list
import helpers
import lenient_parse
import parse_error.{InvalidCharacter, InvalidUnderscorePosition}
import shared_test_data
import startest.{describe, it}
import startest/expect

pub fn coerce_into_valid_number_string_tests() {
  describe("float_test", [
    describe(
      "should_coerce",
      shared_test_data.valid_floats
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
        shared_test_data.invalid_float_assortment,
        shared_test_data.invalid_underscore_position_floats
          |> list.map(fn(tuple) {
            let #(input, index) = tuple
            #(input, InvalidUnderscorePosition(index))
          }),
        shared_test_data.invalid_character_position_floats
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

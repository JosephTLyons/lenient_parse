import gleam/list
import helpers
import python/python_parse
import shared_test_data
import startest.{describe, it}
import startest/expect

pub fn check_against_python_tests() {
  describe("check_against_python_tests", [
    describe(
      "expect_float_to_parse",
      shared_test_data.valid_float_strings()
        |> list.map(fn(input) {
          let printable_text = input |> helpers.to_printable_text
          use <- it("\"" <> printable_text <> "\"")

          input |> python_parse.to_float |> expect.to_be_ok
        }),
    ),
    describe(
      "expect_float_to_not_parse",
      shared_test_data.invalid_float_strings()
        |> list.map(fn(input) {
          let printable_text = input |> helpers.to_printable_text
          use <- it("\"" <> printable_text <> "\"")

          input |> python_parse.to_float |> expect.to_be_error
        }),
    ),
    describe(
      "expect_int_to_parse",
      shared_test_data.valid_int_strings()
        |> list.map(fn(input) {
          let printable_text = input |> helpers.to_printable_text
          use <- it("\"" <> printable_text <> "\"")

          input |> python_parse.to_int |> expect.to_be_ok
        }),
    ),
    describe(
      "expect_int_to_not_parse",
      shared_test_data.invalid_int_strings()
        |> list.map(fn(input) {
          let printable_text = input |> helpers.to_printable_text
          use <- it("\"" <> printable_text <> "\"")

          input |> python_parse.to_int |> expect.to_be_error
        }),
    ),
  ])
}

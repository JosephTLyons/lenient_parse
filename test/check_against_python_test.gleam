import gleam/list
import python/python_parse
import startest.{describe, it}
import startest/expect
import test_data

pub fn check_against_python_tests() {
  describe("check_against_python_tests", [
    describe(
      "expect_float_to_parse",
      test_data.valid_float_strings()
        |> list.map(fn(input) {
          use <- it("\"" <> input <> "\"")

          input |> python_parse.to_float |> expect.to_be_ok
        }),
    ),
    describe(
      "expect_float_to_not_parse",
      test_data.invalid_float_strings()
        |> list.map(fn(input) {
          use <- it("\"" <> input <> "\"")

          input |> python_parse.to_float |> expect.to_be_error
        }),
    ),
    describe(
      "expect_int_to_parse",
      test_data.valid_int_strings()
        |> list.map(fn(input) {
          use <- it("\"" <> input <> "\"")

          input |> python_parse.to_int |> expect.to_be_ok
        }),
    ),
    describe(
      "expect_int_to_not_parse",
      test_data.invalid_int_strings()
        |> list.map(fn(input) {
          use <- it("\"" <> input <> "\"")

          input |> python_parse.to_int |> expect.to_be_error
        }),
    ),
  ])
}

import gleam/list
import helpers
import python/python_parse
import shared_test_data
import startest.{describe, it}
import startest/expect

// TODO: Refactor body and panic message
// TODO: Panic message should explain the issue
pub fn check_against_python_tests() {
  describe("check_against_python_tests", [
    describe(
      "python_float_test",
      shared_test_data.float_data
        |> list.map(fn(test_data) {
          let input = test_data.input
          let input_printable_text = input |> helpers.to_printable_text
          let output = test_data.output
          let python_output = test_data.python_output

          let message = case output, python_output {
            Ok(_), Ok(python_output) -> {
              "should_coerce: \""
              <> input_printable_text
              <> "\" -> \""
              <> python_output
              <> "\""
            }
            Error(_), Error(_) -> {
              "should_not_coerce: \""
              <> input_printable_text
              <> "\" -> \"Error\""
            }
            _, _ -> {
              panic as "Invalid test data configuration - our coerce method and python's coerces method should both succeed or both fail for the same input."
            }
          }

          use <- it(message)

          input
          |> python_parse.to_float
          |> expect.to_equal(python_output)
        }),
    ),
    describe(
      "python_int_test",
      shared_test_data.int_data
        |> list.map(fn(test_data) {
          let input = test_data.input
          let input_printable_text = input |> helpers.to_printable_text
          let output = test_data.output
          let python_output = test_data.python_output

          let message = case output, python_output {
            Ok(_), Ok(python_output) -> {
              "should_coerce: \""
              <> input_printable_text
              <> "\" -> \""
              <> python_output
              <> "\""
            }
            Error(_), Error(_) -> {
              "should_not_coerce: \""
              <> input_printable_text
              <> "\" -> \"Error\""
            }
            _, _ -> {
              panic as "Invalid test data configuration - our coerce method and python's coerces method should both succeed or both fail for the same input."
            }
          }

          use <- it(message)

          input
          |> python_parse.to_int
          |> expect.to_equal(python_output)
        }),
    ),
  ])
}

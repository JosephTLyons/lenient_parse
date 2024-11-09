import data
import gleam/float
import gleam/int
import gleam/list
import helpers
import parse_error
import python/python_parse
import startest.{describe, it}
import startest/expect

pub fn check_against_python_tests() {
  describe("check_against_python_tests", [
    describe(
      "python_float_test",
      data.float_data()
        |> list.map(fn(data) {
          let input = data.input
          let input_printable_text = input |> helpers.to_printable_text
          let output = data.output
          let python_output = data.python_output

          let message = case output, python_output {
            Ok(_), Ok(python_output) -> {
              "should_parse: \""
              <> input_printable_text
              <> "\" -> \""
              <> python_output
              <> "\""
            }
            Error(_), Error(_) -> {
              "should_not_parse: \""
              <> input_printable_text
              <> "\" -> \"Error\""
            }
            Ok(output), Error(_) -> {
              panic as form_panic_message(
                input_printable_text,
                output |> float.to_string,
                "Error",
              )
            }
            Error(output), Ok(python_output) -> {
              panic as form_panic_message(
                input_printable_text,
                output |> parse_error.to_string,
                python_output,
              )
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
      data.integer_data()
        |> list.map(fn(data) {
          let input = data.input
          let input_printable_text = input |> helpers.to_printable_text
          let output = data.output
          let python_output = data.python_output
          let base = data.base

          let base_text = case base {
            10 -> ""
            _ -> "(base: " <> base |> int.to_string <> ")"
          }

          let message = case output, python_output {
            Ok(_), Ok(python_output) -> {
              "should_parse: \""
              <> input_printable_text
              <> "\" "
              <> base_text
              <> " -> \""
              <> python_output
              <> "\""
            }
            Error(_), Error(_) -> {
              "should_not_parse: \""
              <> input_printable_text
              <> "\" "
              <> base_text
              <> " -> \"Error\""
            }
            Ok(output), Error(_) -> {
              panic as form_panic_message(
                input_printable_text,
                output |> int.to_string,
                "Error",
              )
            }
            Error(output), Ok(python_output) -> {
              panic as form_panic_message(
                input_printable_text,
                output |> parse_error.to_string,
                python_output,
              )
            }
          }

          use <- it(message)

          input
          |> python_parse.to_int(base: base)
          |> expect.to_equal(python_output)
        }),
    ),
  ])
}

fn form_panic_message(
  input: String,
  output: String,
  python_output: String,
) -> String {
  "Invalid test data configuration."
  <> " Test data for both our's and Python's parse methods should both expect"
  <> " to either succeed or fail for the same input.\n"
  <> "Input: "
  <> input
  <> ", Output: "
  <> output
  <> ", Python Output: "
  <> python_output
}

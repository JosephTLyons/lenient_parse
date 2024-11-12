import data
import gleam/float
import gleam/int
import gleam/list
import helpers
import parse_error
import startest.{describe, it}
import startest/expect

pub fn check_against_python_tests() {
  describe("check_against_python_tests", [
    describe(
      "python_float_test",
      data.python_processed_float_data()
        |> list.map(fn(data) {
          let input = { data.0 }.input
          let expected_program_output = { data.0 }.expected_program_output
          let expected_python_output = { data.0 }.expected_python_output
          let actual_python_output = data.1

          let input_printable_text = input |> helpers.to_printable_text(False)

          let message = case expected_program_output, expected_python_output {
            Ok(_), Ok(python_output) -> {
              "should_parse: \""
              <> input_printable_text
              <> "\" -> \""
              <> python_output
              <> "\""
            }
            Error(_), Error(python_error) -> {
              "should_not_parse: \""
              <> input_printable_text
              <> "\" -> \""
              <> python_error.message
              <> "\""
            }
            Ok(output), Error(python_error) -> {
              panic as form_panic_message(
                input_printable_text,
                output |> float.to_string,
                python_error.message,
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

          expected_python_output
          |> expect.to_equal(actual_python_output)
        }),
    ),
    describe(
      "python_int_test",
      data.python_processed_integer_data()
        |> list.map(fn(data) {
          let input = { data.0 }.input
          let base = { data.0 }.base
          let expected_program_output = { data.0 }.expected_program_output
          let expected_python_output = { data.0 }.expected_python_output
          let actual_python_output = data.1

          let input_printable_text = input |> helpers.to_printable_text(False)

          let base_text = case base {
            10 -> ""
            _ -> "(base: " <> base |> int.to_string <> ") "
          }

          let message = case expected_program_output, expected_python_output {
            Ok(_), Ok(python_output) -> {
              "should_parse: \""
              <> input_printable_text
              <> "\" "
              <> base_text
              <> "-> \""
              <> python_output
              <> "\""
            }
            Error(_), Error(python_error) -> {
              "should_not_parse: \""
              <> input_printable_text
              <> "\" "
              <> base_text
              <> "-> \""
              <> python_error.message
              <> "\""
            }
            Ok(output), Error(python_error) -> {
              panic as form_panic_message(
                input_printable_text,
                output |> int.to_string,
                python_error.message,
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

          expected_python_output
          |> expect.to_equal(actual_python_output)
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

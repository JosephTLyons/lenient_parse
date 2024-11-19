import data
import gleam/int
import gleam/list
import helpers
import lenient_parse
import parse_error
import startest.{describe, it}
import startest/expect

pub fn to_int_tests() {
  describe(
    "int_test",
    data.integer_test_data()
      |> list.map(fn(data) {
        let input = data.input
        let input_printable_text = input |> helpers.to_printable_text
        let expected_program_output = data.expected_program_output
        let base = data.base

        let base_text = case base {
          10 -> ""
          _ -> "(base: " <> base |> int.to_string <> ") "
        }

        let message = case expected_program_output {
          Ok(output) -> {
            "should_parse: \""
            <> input_printable_text
            <> "\" "
            <> base_text
            <> "-> "
            <> output |> int.to_string
          }
          Error(error) -> {
            let error_string = error |> parse_error.to_string
            "should_not_parse: \""
            <> input_printable_text
            <> "\" -> "
            <> error_string
            <> "\""
          }
        }

        use <- it(message)

        input
        |> lenient_parse.to_int_with_base(base: base)
        |> expect.to_equal(expected_program_output)
      }),
  )
}

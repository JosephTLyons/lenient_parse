import data
import gleam/float
import gleam/list
import helpers
import lenient_parse
import parse_error
import startest.{describe, it}
import startest/expect

pub fn to_float_tests() {
  describe(
    "float_test",
    data.float_test_data()
      |> list.map(fn(data) {
        let input = data.input
        let input_printable_text = input |> helpers.to_printable_text
        let expected_program_output = data.expected_program_output

        let message = case expected_program_output {
          Ok(output) -> {
            "should_parse: \""
            <> input_printable_text
            <> "\" -> "
            <> output |> float.to_string
          }
          Error(error) -> {
            let error_string = error |> parse_error.to_string
            "should_not_parse: \""
            <> input_printable_text
            <> "\" -> \""
            <> error_string
            <> "\""
          }
        }

        use <- it(message)

        input
        |> lenient_parse.to_float
        |> expect.to_equal(expected_program_output)
      }),
  )
}

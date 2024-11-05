import data
import gleam/float
import gleam/list
import helpers
import lenient_parse
import parse_error
import startest.{describe, it}
import startest/expect

pub fn parse_into_valid_number_string_tests() {
  describe(
    "float_test",
    data.float_data()
      |> list.map(fn(data) {
        let input = data.input
        let input_printable_text = input |> helpers.to_printable_text
        let output = data.output

        let message = case output {
          Ok(output) -> {
            "should_parse: \""
            <> input_printable_text
            <> "\" -> \""
            <> output |> float.to_string
            <> "\""
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
        |> expect.to_equal(output)
      }),
  )
}

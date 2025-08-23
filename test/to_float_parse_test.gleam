import data
import gleam/float
import gleam/list
import helpers
import lenient_parse
import startest.{describe, it}
import startest/expect

pub fn to_float_tests() {
  describe(
    "float_test",
    data.float_test_data()
      |> list.map(fn(data) {
        let input = data.input
        let input_printable_text = helpers.to_printable_text(input)
        let expected_program_output = data.expected_program_output

        let message = case expected_program_output {
          Ok(output) -> {
            "should_parse: \""
            <> input_printable_text
            <> "\" -> "
            <> float.to_string(output)
          }
          Error(error) -> {
            let error_string = helpers.error_to_string(error)
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

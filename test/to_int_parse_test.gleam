import data
import gleam/int
import gleam/list
import helpers
import lenient_parse
import startest.{describe, it}

pub fn to_int_tests() {
  describe(
    "int_test",
    data.integer_test_data()
      |> list.map(fn(data) {
        let input = data.input
        let input_printable_text = helpers.to_printable_text(input)
        let expected_program_output = data.expected_program_output
        let base = data.base

        let base_text = case base {
          10 -> ""
          _ -> "(base: " <> int.to_string(base) <> ") "
        }

        let message = case expected_program_output {
          Ok(output) -> {
            "should_parse: \""
            <> input_printable_text
            <> "\" "
            <> base_text
            <> "-> "
            <> int.to_string(output)
          }
          Error(error) -> {
            let error_string = helpers.error_to_string(error)
            "should_not_parse: \""
            <> input_printable_text
            <> "\" -> "
            <> error_string
            <> "\""
          }
        }

        use <- it(message)

        assert lenient_parse.to_int_with_base(input, base)
          == expected_program_output
      }),
  )
}

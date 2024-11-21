import data
import gleam/int
import gleam/list
import helpers
import lenient_parse
import parse_error
import startest.{describe, it}
import startest/expect

// TODO - output message
// TODO - clean up structure of test director, move things into utility directories, rename files
// TODO - output error messages?
// TODO - can base be pulled
// TODO - testing of different bases

pub fn random_value_tests() {
  describe(
    "random_integer_test",
    data.python_processed_random_integer_data()
      |> list.map(fn(random_integer_data) {
        let input = random_integer_data.0
        let actual_python_output = random_integer_data.1
        let base = 0
        let program_output = input |> lenient_parse.to_int_with_base(base: base)

        let input_printable_text = input |> helpers.to_printable_text

        let #(programs_matched, message) = case
          program_output,
          actual_python_output
        {
          Ok(program_output), Ok(python_output) -> {
            let program_output_string = program_output |> int.to_string
            // TODO: Ugh, not sure I like comparing the strings, might go back to just comparing the result variants themselves
            let values_matched = program_output_string == python_output

            let message = case values_matched {
              True -> {
                "input: \""
                <> input_printable_text
                <> "\" (base: "
                <> base |> int.to_string
                <> ") parsed successfully in both program (\""
                <> program_output_string
                <> "\") and python (\""
                <> python_output
                <> "\")"
              }
              False -> {
                "input: \""
                <> input_printable_text
                <> "\" (base: "
                <> base |> int.to_string
                <> ") parsed differently in program ("
                <> program_output_string
                <> ") and python (\""
                <> python_output
                <> "\")"
              }
            }

            #(values_matched, message)
          }
          Error(_), Error(_) -> {
            let message =
              "input: \""
              <> input_printable_text
              <> "\" (base: "
              <> base |> int.to_string
              <> ") failed to parse in both program and python"

            #(True, message)
          }
          Error(program_error), Ok(python_output) -> {
            let message =
              "input: \""
              <> input_printable_text
              <> "\" (base: "
              <> base |> int.to_string
              <> ") failed to parse in program (error: \""
              <> program_error |> parse_error.to_string
              <> "\") but parsed in python (\""
              <> python_output
              <> "\")"

            #(False, message)
          }
          Ok(program_output), Error(python_error) -> {
            let message =
              "input: \""
              <> input_printable_text
              <> "\" (base: "
              <> base |> int.to_string
              <> ") parsed in program (\""
              <> program_output |> int.to_string
              <> "\") but failed to parse in python (error: \""
              <> python_error.message
              <> "\")"

            #(False, message)
          }
        }

        use <- it(message)

        programs_matched |> expect.to_be_true
      }),
  )
}

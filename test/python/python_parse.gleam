import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import python/python_error.{type PythonError, ValueError}
import shellout
import test_data.{type FloatTestData, type IntegerTestData}

pub fn to_floats(
  float_test_data float_test_data: List(FloatTestData),
) -> List(Result(String, PythonError)) {
  float_test_data
  |> json.array(fn(float_data) {
    json.object([#("input", json.string(float_data.input))])
  })
  |> json.to_string
  |> parse(program_name: "parse_floats.py")
}

pub fn to_ints(
  integer_test_data integer_test_data: List(IntegerTestData),
) -> List(Result(String, PythonError)) {
  integer_test_data
  |> json.array(fn(integer_data) {
    json.object([
      #("input", json.string(integer_data.input)),
      #("base", json.int(integer_data.base)),
    ])
  })
  |> json.to_string
  |> parse(program_name: "parse_ints.py")
}

fn parse(
  input_json_string input_json_string: String,
  program_name program_name: String,
) -> List(Result(String, PythonError)) {
  let arguments = [
    "run",
    "--quiet",
    "-p",
    "3.13",
    "python",
    "./test/python/" <> program_name,
    input_json_string,
  ]

  let output_json_string = case
    shellout.command(run: "uv", with: arguments, in: ".", opt: [])
  {
    Error(error) -> {
      io.println_error("Error code: " <> int.to_string(error.0))
      io.println_error("Error message: " <> error.1)
      io.println_error("With input_json_string...")
      io.println_error(input_json_string)
      panic as "Shellout received bad data"
    }
    Ok(output_json_string) -> output_json_string
  }

  let parsed_strings = case
    json.parse(output_json_string, decode.list(of: decode.string))
  {
    Error(_) -> {
      io.println_error("With json string...")
      io.println_error(output_json_string)
      panic as "output_json_string failed to decode"
    }
    Ok(parsed_strings) -> parsed_strings
  }

  parsed_strings
  |> list.map(fn(value) {
    case value {
      "ValueError: " <> error_message -> Error(ValueError(error_message))
      _ -> Ok(value)
    }
  })
}

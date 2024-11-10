import gleam/dynamic
import gleam/json
import gleam/list
import shellout
import test_data.{type FloatTestData, type IntegerTestData}

pub fn to_floats(
  float_test_data float_test_data: List(FloatTestData),
) -> List(Result(String, Nil)) {
  float_test_data
  |> json.array(fn(float_data) {
    json.object([#("input", json.string(float_data.input))])
  })
  |> json.to_string
  |> parse(program_name: "parse_floats.py")
}

pub fn to_ints(
  integer_test_data integer_test_data: List(IntegerTestData),
) -> List(Result(String, Nil)) {
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
) -> List(Result(String, Nil)) {
  let arguments = [
    "run",
    "-p",
    "3.13",
    "python",
    "./test/python/" <> program_name,
    input_json_string,
  ]

  let assert Ok(output_json_string) =
    shellout.command(run: "uv", with: arguments, in: ".", opt: [])

  let assert Ok(processed_strings) =
    json.decode(output_json_string, dynamic.list(of: dynamic.string))

  processed_strings
  |> list.map(fn(value) {
    case value {
      "Nil" -> Error(Nil)
      _ -> Ok(value)
    }
  })
}

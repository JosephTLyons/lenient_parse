import gleam/result
import shellout

// TODO: Change function name, input name
// TODO: Make these take lists of test data, do conversion into json string here, return list of results
pub fn to_floats(
  input_json_string input_json_string: String,
) -> Result(String, Nil) {
  input_json_string |> parse(program_name: "parse_floats.py")
}

// TODO: Change function name, input name
pub fn to_ints(
  input_json_string input_json_string: String,
) -> Result(String, Nil) {
  input_json_string |> parse(program_name: "parse_ints.py")
}

// TODO: Change function name, input name
fn parse(
  input_json_string input_json_string: String,
  program_name program_name: String,
) -> Result(String, Nil) {
  let arguments = [
    "run",
    "-p",
    "3.13",
    "python",
    "./test/python/" <> program_name,
    input_json_string,
  ]

  shellout.command(run: "uv", with: arguments, in: ".", opt: [])
  |> result.replace_error(Nil)
}

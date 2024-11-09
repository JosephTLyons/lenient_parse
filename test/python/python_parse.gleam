import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import shellout

pub fn to_float(text text: String) -> Result(String, Nil) {
  text |> parse(program_name: "parse_float.py", base: None)
}

pub fn to_int(text text: String, base base: Int) -> Result(String, Nil) {
  text |> parse(program_name: "parse_int.py", base: Some(base))
}

fn parse(
  text text: String,
  base base: Option(Int),
  program_name program_name: String,
) -> Result(String, Nil) {
  let arguments = [
    "run",
    "-p",
    "3.13",
    "python",
    "./test/python/" <> program_name,
    text,
  ]
  let arguments = case base {
    Some(base) -> arguments |> list.append([base |> int.to_string])
    None -> arguments
  }
  shellout.command(run: "uv", with: arguments, in: ".", opt: [])
  |> result.replace_error(Nil)
}

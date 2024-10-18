import gleam/result
import lenient_parse/internal/parse
import parse_error.{type ParseError}
import shellout

pub fn to_float(text: String) -> Result(Float, ParseError) {
  text
  |> parse.to_float(do_to_float)
}

pub fn to_int(text: String) -> Result(Int, ParseError) {
  text
  |> parse.to_int(do_to_int)
}

fn do_to_float(text: String) -> Result(String, ParseError) {
  text
  |> coerce("./test/python/parse_float.py")
}

fn do_to_int(text: String) -> Result(String, ParseError) {
  text
  |> coerce("./test/python/parse_int.py")
}

fn coerce(text: String, program_path: String) -> Result(String, ParseError) {
  shellout.command(
    run: "uv",
    with: [
      "run",
      "-p",
      "3.13",
      "python",
      program_path,
      text,
      ..shellout.arguments()
    ],
    in: ".",
    opt: [],
  )
  |> result.replace_error(parse_error.Nil)
}

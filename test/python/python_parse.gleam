import gleam/result
import shellout

pub fn to_float(text: String) -> Result(String, Nil) {
  text |> coerce("./test/python/parse_float.py")
}

pub fn to_int(text: String) -> Result(String, Nil) {
  text |> coerce("./test/python/parse_int.py")
}

fn coerce(text: String, program_path: String) -> Result(String, Nil) {
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
  |> result.replace_error(Nil)
}

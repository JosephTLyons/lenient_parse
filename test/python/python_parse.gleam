import gleam/result
import shellout

pub fn to_float(text: String) -> Result(String, Nil) {
  text |> coerce("float")
}

pub fn to_int(text: String) -> Result(String, Nil) {
  text |> coerce("int")
}

fn coerce(text: String, parse_function_name: String) -> Result(String, Nil) {
  shellout.command(
    run: "uv",
    with: [
      "run",
      "-p",
      "3.13",
      "python",
      "./test/python/parse.py",
      parse_function_name,
      text,
      ..shellout.arguments()
    ],
    in: ".",
    opt: [],
  )
  |> result.replace_error(Nil)
}

import gleam/list
import gleam/result
import shellout
import startest/expect
import test_data

pub fn to_float_python_test() {
  test_data.float_should_coerce_strings()
  |> list.each(fn(text) { text |> to_float |> expect.to_be_ok })

  test_data.float_should_not_coerce_strings()
  |> list.each(fn(text) { text |> to_float |> expect.to_be_error })
}

pub fn to_int_python_test() {
  test_data.int_should_coerce_strings()
  |> list.each(fn(text) { text |> to_float |> expect.to_be_ok })

  test_data.int_should_not_coerce_strings()
  |> list.each(fn(text) { text |> to_float |> expect.to_be_error })
}

pub fn to_float(text: String) -> Result(Nil, Nil) {
  text |> coerce("./test/python/parse_float.py")
}

pub fn to_int(text: String) -> Result(Nil, Nil) {
  text |> coerce("./test/python/parse_int.py")
}

fn coerce(text: String, program_path: String) -> Result(Nil, Nil) {
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
  |> result.replace(Nil)
  |> result.replace_error(Nil)
}

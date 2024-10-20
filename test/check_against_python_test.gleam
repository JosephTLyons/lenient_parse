import gleam/list
import python/python_parse
import startest/expect
import test_data

pub fn to_float_python_test() {
  test_data.valid_float_strings()
  |> list.each(fn(text) { text |> python_parse.to_float |> expect.to_be_ok })

  test_data.invalid_float_strings()
  |> list.each(fn(text) { text |> python_parse.to_float |> expect.to_be_error })
}

pub fn to_int_python_test() {
  test_data.valid_int_strings()
  |> list.each(fn(text) { text |> python_parse.to_int |> expect.to_be_ok })

  test_data.int_should_not_coerce_strings()
  |> list.each(fn(text) { text |> python_parse.to_int |> expect.to_be_error })
}

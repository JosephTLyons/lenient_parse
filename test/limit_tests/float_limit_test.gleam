import gleam/string
import lenient_parse
import parse_error.{OutOfFloatRange}
import startest/expect

pub fn large_positive_float_limit_test() {
  let float_string = "34028235e301"
  let expected = "34028235" <> string.repeat("0", 301) <> ".0"

  float_string
  |> lenient_parse.to_float
  |> expect.to_equal(Error(OutOfFloatRange(expected)))
}

pub fn large_negative_float_limit_test() {
  let float_string = "-34028235e301"
  let expected = "-34028235" <> string.repeat("0", 301) <> ".0"

  float_string
  |> lenient_parse.to_float
  |> expect.to_equal(Error(OutOfFloatRange(expected)))
}

pub fn small_positive_float_limit_test() {
  let float_string = "0.34028235e-308"
  let expected = "0." <> string.repeat("0", 308) <> "34028235"

  float_string
  |> lenient_parse.to_float
  |> expect.to_equal(Error(OutOfFloatRange(expected)))
}

pub fn small_negative_float_limit_test() {
  let float_string = "-0.34028235e-308"
  let expected = "-0." <> string.repeat("0", 308) <> "34028235"

  float_string
  |> lenient_parse.to_float
  |> expect.to_equal(Error(OutOfFloatRange(expected)))
}
// TODO: For float, test limits and raise error
// TODO: Test erlang before and after negative safe integer check
// TODO: Test javascript before and after invalid base value check

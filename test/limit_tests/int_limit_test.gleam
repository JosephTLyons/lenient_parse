@target(erlang)
import javascript_constants.{
  max_safe_integer, max_safe_integer_plus_1, max_safe_integer_plus_1_string,
  max_safe_integer_string, min_safe_integer, min_safe_integer_minus_1,
  min_safe_integer_minus_1_string, min_safe_integer_string,
}
@target(javascript)
import javascript_constants.{
  max_safe_integer, max_safe_integer_plus_1_string, max_safe_integer_string,
  min_safe_integer, min_safe_integer_minus_1_string, min_safe_integer_string,
}
import lenient_parse
@target(javascript)
import parse_error.{OutOfIntRange}
import startest/expect

@target(erlang)
pub fn erlang_javascript_min_safe_integer_test() {
  min_safe_integer_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(min_safe_integer()))

  min_safe_integer_minus_1_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(min_safe_integer_minus_1()))
}

@target(erlang)
pub fn erlang_javascript_max_safe_integer_test() {
  max_safe_integer_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(max_safe_integer()))

  max_safe_integer_plus_1_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(max_safe_integer_plus_1()))
}

@target(javascript)
pub fn javascript_javascript_min_safe_integer_test() {
  min_safe_integer_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(min_safe_integer()))

  min_safe_integer_minus_1_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Error(OutOfIntRange(min_safe_integer_minus_1_string())))
}

@target(javascript)
pub fn javascript_javascript_max_safe_integer_test() {
  max_safe_integer_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(max_safe_integer()))

  max_safe_integer_plus_1_string()
  |> lenient_parse.to_int
  |> expect.to_equal(Error(OutOfIntRange(max_safe_integer_plus_1_string())))
}

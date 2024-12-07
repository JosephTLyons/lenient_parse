import javascript_constants.{
  max_safe_integer, max_safe_integer_plus_one, min_safe_integer,
  min_safe_integer_minus_one,
}
import lenient_parse
@target(javascript)
import parse_error.{NotASafeInteger}
import startest/expect

@target(erlang)
pub fn erlang_javascript_min_safe_integer_test() {
  min_safe_integer
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(-9_007_199_254_740_991))

  min_safe_integer_minus_one
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(-9_007_199_254_740_992))
}

@target(erlang)
pub fn erlang_javascript_max_safe_integer_test() {
  max_safe_integer
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(9_007_199_254_740_991))

  max_safe_integer_plus_one
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(9_007_199_254_740_992))
}

@target(javascript)
pub fn javascript_javascript_min_safe_integer_test() {
  min_safe_integer
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(-9_007_199_254_740_991))

  min_safe_integer_minus_one
  |> lenient_parse.to_int
  |> expect.to_equal(Error(NotASafeInteger(min_safe_integer_minus_one)))
}

@target(javascript)
pub fn javascript_javascript_max_safe_integer_test() {
  max_safe_integer
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(9_007_199_254_740_991))

  max_safe_integer_plus_one
  |> lenient_parse.to_int
  |> expect.to_equal(Error(NotASafeInteger(max_safe_integer_plus_one)))
}

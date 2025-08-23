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
import lenient_parse/parse_error.{OutOfIntRange}

@target(erlang)
pub fn erlang_javascript_min_safe_integer_test() {
  assert lenient_parse.to_int(min_safe_integer_string())
    == Ok(min_safe_integer())

  assert lenient_parse.to_int(min_safe_integer_minus_1_string())
    == Ok(min_safe_integer_minus_1())
}

@target(erlang)
pub fn erlang_javascript_max_safe_integer_test() {
  assert lenient_parse.to_int(max_safe_integer_string())
    == Ok(max_safe_integer())

  assert lenient_parse.to_int(max_safe_integer_plus_1_string())
    == Ok(max_safe_integer_plus_1())
}

@target(javascript)
pub fn javascript_javascript_min_safe_integer_test() {
  assert lenient_parse.to_int(min_safe_integer_string())
    == Ok(min_safe_integer())

  assert lenient_parse.to_int(min_safe_integer_minus_1_string())
    == Error(OutOfIntRange(min_safe_integer_minus_1_string()))
}

@target(javascript)
pub fn javascript_javascript_max_safe_integer_test() {
  assert lenient_parse.to_int(max_safe_integer_string())
    == Ok(max_safe_integer())

  assert lenient_parse.to_int(max_safe_integer_plus_1_string())
    == Error(OutOfIntRange(max_safe_integer_plus_1_string()))
}

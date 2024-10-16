import lenient_parse
import startest/expect

pub fn to_float_standard_format_positive_test() {
  "1.001"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1.001))
}

pub fn to_float_standard_format_positive_with_trailing_zeros_test() {
  "1.00"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1.0))
}

pub fn to_float_standard_format_positive_with_single_decimal_test() {
  "1.0"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1.0))
}

pub fn to_float_standard_format_less_than_one_test() {
  "0.1"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(0.1))
}

pub fn to_float_standard_format_positive_with_plus_test() {
  "+123.321"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(123.321))
}

pub fn to_float_standard_format_negative_test() {
  "-123.321"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(-123.321))
}

pub fn to_float_integer_test() {
  "1"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1.0))
}

pub fn to_float_with_trailing_dot_test() {
  "1."
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1.0))
}

pub fn to_float_with_leading_dot_test() {
  ".1"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(0.1))
}

pub fn to_float_underscores_test() {
  "1_000_000.0"
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1_000_000.0))
}

pub fn to_float_invalid_underscores_test() {
  "1_000__000.0"
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

pub fn to_float_with_surrounding_whitespace_integer_test() {
  " 1 "
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1.0))
}

pub fn to_float_with_surrounding_whitespace_float_test() {
  " 1.0 "
  |> lenient_parse.to_float
  |> expect.to_equal(Ok(1.0))
}

// pub fn to_float_scientific_notation_test() {
//   // "420e3"
//   // |> lenient_parse.to_float
//   // |> expect.to_equal(Ok(1e10))

//   // "420e-3"
//   // |> lenient_parse.to_float
//   // |> expect.to_equal(Ok(-2.5e-3))
// }

pub fn to_float_with_double_leading_dot_test() {
  "..1"
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

pub fn to_float_with_double_trailing_dot_test() {
  "1.."
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

pub fn to_float_with_sandwich_dot_test() {
  ".1."
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

pub fn to_float_with_single_dot_test() {
  "."
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

pub fn to_float_with_only_whitespace_test() {
  " "
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

pub fn to_float_with_empty_string_test() {
  ""
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

pub fn to_float_with_non_numeric_string_test() {
  "abc"
  |> lenient_parse.to_float
  |> expect.to_equal(Error(Nil))
}

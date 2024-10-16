import lenient_parse
import startest/expect

pub fn to_int_standard_format_positive_test() {
  "1"
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(1))
}

pub fn to_int_standard_format_positive_with_plus_test() {
  "+123"
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(123))
}

pub fn to_int_standard_format_with_leading_zeros_test() {
  "0123"
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(123))
}

pub fn to_int_standard_format_negative_test() {
  "-123"
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(-123))
}

pub fn to_int_underscores_test() {
  "1_000_000"
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(1_000_000))
}

pub fn to_int_invalid_underscores_test() {
  "1_000__000"
  |> lenient_parse.to_int
  |> expect.to_equal(Error(Nil))
}

pub fn to_int_with_surrounding_whitespace_test() {
  " 1 "
  |> lenient_parse.to_int
  |> expect.to_equal(Ok(1))
}

pub fn to_int_with_decimal_point_test() {
  "1."
  |> lenient_parse.to_int
  |> expect.to_equal(Error(Nil))
}

pub fn to_int_with_decimal_number_test() {
  "1.0"
  |> lenient_parse.to_int
  |> expect.to_equal(Error(Nil))
}

pub fn to_int_with_only_whitespace_test() {
  " "
  |> lenient_parse.to_int
  |> expect.to_equal(Error(Nil))
}

pub fn to_int_with_empty_string_test() {
  ""
  |> lenient_parse.to_int
  |> expect.to_equal(Error(Nil))
}

pub fn to_int_with_non_numeric_string_test() {
  "abc"
  |> lenient_parse.to_int
  |> expect.to_equal(Error(Nil))
}

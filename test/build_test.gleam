import gleam/deque
import lenient_parse/internal/build
import startest/expect

// ------------------ float

pub fn build_float_empty_test() {
  build.float_value(
    is_positive: True,
    whole_digits: deque.from_list([]),
    fractional_digits: deque.from_list([]),
    scale_factor: 0,
  )
  |> expect.to_equal(Ok(0.0))
}

pub fn build_float_explicit_0_both_test() {
  build.float_value(
    is_positive: True,
    whole_digits: deque.from_list([0]),
    fractional_digits: deque.from_list([0]),
    scale_factor: 0,
  )
  |> expect.to_equal(Ok(0.0))
}

pub fn build_float_empty_fractional_test() {
  build.float_value(
    is_positive: True,
    whole_digits: deque.from_list([1]),
    fractional_digits: deque.from_list([]),
    scale_factor: 0,
  )
  |> expect.to_equal(Ok(1.0))
}

pub fn build_float_explicit_0_fractional_test() {
  build.float_value(
    is_positive: True,
    whole_digits: deque.from_list([1]),
    fractional_digits: deque.from_list([0]),
    scale_factor: 0,
  )
  |> expect.to_equal(Ok(1.0))
}

pub fn build_float_empty_whole_test() {
  build.float_value(
    is_positive: True,
    whole_digits: deque.from_list([]),
    fractional_digits: deque.from_list([1]),
    scale_factor: 0,
  )
  |> expect.to_equal(Ok(0.1))
}

pub fn build_float_explicit_0_whole_test() {
  build.float_value(
    is_positive: True,
    whole_digits: deque.from_list([0]),
    fractional_digits: deque.from_list([1]),
    scale_factor: 0,
  )
  |> expect.to_equal(Ok(0.1))
}

// ------------------ int

pub fn build_int_empty_test() {
  build.integer_value(digits: deque.from_list([]), base: 10, is_positive: True)
  |> expect.to_equal(Ok(0))
}

pub fn build_int_explicit_0_test() {
  build.integer_value(digits: deque.from_list([0]), base: 10, is_positive: True)
  |> expect.to_equal(Ok(0))
}

pub fn build_int_test() {
  build.integer_value(
    digits: deque.from_list([1, 2, 3]),
    base: 10,
    is_positive: True,
  )
  |> expect.to_equal(Ok(123))
}

import data/float/invalid_float_data
import data/float/valid_float_data
import data/integer/invalid_integer_data
import data/integer/valid_integer_data
import gleam/list
import gleam/yielder
import python/python_error.{type PythonError}
import python/python_parse
import random_string.{random_integer_string}
import test_data.{type FloatTestData, type IntegerTestData}

// TODO: Only output tests when they fail? Too much noise
// TODO: Only report batch and percentage of pass / fail for randomized testing

pub fn float_test_data() -> List(FloatTestData) {
  [valid_float_data.data(), invalid_float_data.data()]
  |> list.flatten
}

pub fn integer_test_data() -> List(IntegerTestData) {
  [valid_integer_data.data(), invalid_integer_data.data()]
  |> list.flatten
}

// To prevent error code 7 (argument list too long) when passing large datasets
// to the Python programs, we divide the data into smaller lists.
const test_data_chunk_size = 500

pub fn python_processed_float_data() -> List(
  #(FloatTestData, Result(String, PythonError)),
) {
  let float_test_data = float_test_data()

  let processed_values =
    float_test_data
    |> list.sized_chunk(test_data_chunk_size)
    |> list.map(python_parse.to_floats)
    |> list.flatten

  float_test_data |> list.zip(processed_values)
}

// TODO: Consider doing lenient parse processing here so we can compare values directly?
pub fn python_processed_integer_data() -> List(
  #(IntegerTestData, Result(String, PythonError)),
) {
  let integer_test_data = integer_test_data()

  let processed_values =
    integer_test_data
    |> list.sized_chunk(test_data_chunk_size)
    |> list.map(python_parse.to_integers)
    |> list.flatten

  integer_test_data |> list.zip(processed_values)
}

// TODO: Reduce number after fixing previous TODOs
const number_of_random_values = 50_000

// TODO: Rename
pub fn python_processed_random_integer_data() -> List(
  #(String, Result(String, PythonError)),
) {
  let random_integer_strings =
    yielder.range(1, number_of_random_values)
    |> yielder.map(fn(_) { random_integer_string() })
    |> yielder.to_list

  let random_integer_strings_with_base_0 =
    random_integer_strings
    |> list.map(fn(integer_string) { #(integer_string, 0) })

  let processed_values =
    random_integer_strings_with_base_0
    |> list.sized_chunk(test_data_chunk_size)
    |> list.map(python_parse.to_integers_from_list)
    |> list.flatten

  random_integer_strings |> list.zip(processed_values)
}

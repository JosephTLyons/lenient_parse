import data/float/invalid_float_data
import data/float/valid_float_data
import data/integer/invalid_integer_data
import data/integer/valid_integer_data
import gleam/list
import python/python_parse
import test_data.{type FloatTestData, type IntegerTestData}

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
const test_data_chunk_size = 200

pub fn python_processed_float_data() {
  let float_test_data = float_test_data()

  let processed_values =
    float_test_data
    |> list.sized_chunk(test_data_chunk_size)
    |> list.map(python_parse.to_floats)
    |> list.flatten

  float_test_data |> list.zip(processed_values)
}

pub fn python_processed_integer_data() {
  let integer_test_data = integer_test_data()

  let processed_values =
    integer_test_data
    |> list.sized_chunk(test_data_chunk_size)
    |> list.map(python_parse.to_ints)
    |> list.flatten

  integer_test_data |> list.zip(processed_values)
}

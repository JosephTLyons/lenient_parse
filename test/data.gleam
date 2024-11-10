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

pub fn python_processed_float_data() {
  let float_test_data = float_test_data()
  let processed_values = python_parse.to_floats(float_test_data)
  float_test_data |> list.zip(processed_values)
}

pub fn python_processed_integer_data() {
  let integer_test_data = integer_test_data()
  let processed_values = python_parse.to_ints(integer_test_data)
  integer_test_data |> list.zip(processed_values)
}

import data/float/invalid_float_data
import data/float/valid_float_data
import data/integer/invalid_integer_data
import data/integer/valid_integer_data
import gleam/list
import types.{
  type FloatTestData, type IntegerTestData, FloatTestData, IntegerTestData,
}

pub fn float_data() -> List(FloatTestData) {
  [valid_float_data.data(), invalid_float_data.data()]
  |> list.flatten
}

pub fn integer_data() -> List(IntegerTestData) {
  [valid_integer_data.data(), invalid_integer_data.data()]
  |> list.flatten
}

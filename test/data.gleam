import data/float/invalid_float_data
import data/float/valid_float_data
import data/integer/invalid_integer_data
import data/integer/valid_integer_data
import gleam/dynamic
import gleam/int
import gleam/json
import gleam/list
import python/python_parse
import test_data.{type FloatTestData, type IntegerTestData}

pub fn float_data() -> List(FloatTestData) {
  [valid_float_data.data(), invalid_float_data.data()]
  |> list.flatten
}

pub fn integer_data() -> List(IntegerTestData) {
  [valid_integer_data.data(), invalid_integer_data.data()]
  |> list.flatten
}

pub fn python_processed_float_data() {
  let integer_data = float_data()
  let input_json_string =
    integer_data
    |> json.array(fn(data) {
      json.object([#("input", json.string(data.input))])
    })
    |> json.to_string

  let assert Ok(output_json_string) = python_parse.to_floats(input_json_string)

  let assert Ok(processed_strings) =
    json.decode(output_json_string, dynamic.list(of: dynamic.string))

  let processed_values =
    processed_strings
    |> list.map(fn(value) {
      case value {
        "Nil" -> Error(Nil)
        _ -> Ok(value)
      }
    })

  integer_data |> list.zip(processed_values)
}

pub fn python_processed_integer_data() {
  let integer_data = integer_data()
  let input_json_string =
    integer_data
    |> json.array(fn(data) {
      json.object([
        #("input", json.string(data.input)),
        #("base", json.string(data.base |> int.to_string)),
      ])
    })
    |> json.to_string

  let assert Ok(output_json_string) = python_parse.to_ints(input_json_string)

  let assert Ok(processed_strings) =
    json.decode(output_json_string, dynamic.list(of: dynamic.string))

  let processed_values =
    processed_strings
    |> list.map(fn(value) {
      case value {
        "Nil" -> Error(Nil)
        _ -> Ok(value)
      }
    })

  integer_data |> list.zip(processed_values)
}
// TODO - test python parsing directly

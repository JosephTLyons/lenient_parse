import gleam/list
import types.{type IntegerTestData, IntegerTestData}

const valid_simple_integers: List(IntegerTestData) = [
  IntegerTestData(input: "1", output: Ok(1), python_output: Ok("1")),
  IntegerTestData(input: "+123", output: Ok(123), python_output: Ok("123")),
  IntegerTestData(input: "-123", output: Ok(-123), python_output: Ok("-123")),
  IntegerTestData(input: "0123", output: Ok(123), python_output: Ok("123")),
]

const valid_integers_with_underscores: List(IntegerTestData) = [
  IntegerTestData(input: "1_000", output: Ok(1000), python_output: Ok("1000")),
  IntegerTestData(
    input: "1_000_000",
    output: Ok(1_000_000),
    python_output: Ok("1000000"),
  ),
]

const valid_integers_with_whitespace: List(IntegerTestData) = [
  IntegerTestData(input: " +123 ", output: Ok(123), python_output: Ok("123")),
  IntegerTestData(input: " -123 ", output: Ok(-123), python_output: Ok("-123")),
  IntegerTestData(input: " 0123", output: Ok(123), python_output: Ok("123")),
  IntegerTestData(input: " 1 ", output: Ok(1), python_output: Ok("1")),
]

pub fn data() -> List(IntegerTestData) {
  [
    valid_simple_integers,
    valid_integers_with_underscores,
    valid_integers_with_whitespace,
  ]
  |> list.flatten
}

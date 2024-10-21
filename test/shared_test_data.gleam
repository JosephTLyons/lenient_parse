import gleam/list
import parse_error.{
  type ParseError, EmptyString, InvalidCharacter, InvalidDecimalPosition,
  InvalidSignPosition, InvalidUnderscorePosition, WhitespaceOnlyString,
}

// ---- float should coerce

pub type FloatTestData {
  FloatTestData(
    input: String,
    output: Result(Float, ParseError),
    python_output: Result(String, Nil),
  )
}

pub type IntegerTestData {
  IntegerTestData(
    input: String,
    output: Result(Int, ParseError),
    python_output: Result(String, Nil),
  )
}

const valid_float_data = [
  FloatTestData(input: "1.001", output: Ok(1.001), python_output: Ok("1.001")),
  FloatTestData(input: "1.00", output: Ok(1.0), python_output: Ok("1.0")),
  FloatTestData(input: "1.0", output: Ok(1.0), python_output: Ok("1.0")),
  FloatTestData(input: "0.1", output: Ok(0.1), python_output: Ok("0.1")),
  FloatTestData(input: "+1.0", output: Ok(1.0), python_output: Ok("1.0")),
  FloatTestData(input: "-1.0", output: Ok(-1.0), python_output: Ok("-1.0")),
  FloatTestData(
    input: "+123.321",
    output: Ok(123.321),
    python_output: Ok("123.321"),
  ),
  FloatTestData(
    input: "-123.321",
    output: Ok(-123.321),
    python_output: Ok("-123.321"),
  ), FloatTestData(input: "1", output: Ok(1.0), python_output: Ok("1.0")),
  FloatTestData(input: "1.", output: Ok(1.0), python_output: Ok("1.0")),
  FloatTestData(input: ".1", output: Ok(0.1), python_output: Ok("0.1")),
  FloatTestData(
    input: "1_000_000.0",
    output: Ok(1_000_000.0),
    python_output: Ok("1000000.0"),
  ),
  FloatTestData(
    input: "1_000_000.000_1",
    output: Ok(1_000_000.0001),
    python_output: Ok("1000000.0001"),
  ),
  FloatTestData(
    input: "1000.000_000",
    output: Ok(1000.0),
    python_output: Ok("1000.0"),
  ),
  FloatTestData(
    input: "1000.000_000",
    output: Ok(1000.0),
    python_output: Ok("1000.0"),
  ), FloatTestData(input: " 1 ", output: Ok(1.0), python_output: Ok("1.0")),
  FloatTestData(input: " 1.0 ", output: Ok(1.0), python_output: Ok("1.0")),
  FloatTestData(
    input: " 1000 ",
    output: Ok(1000.0),
    python_output: Ok("1000.0"),
  ),
]

// ---- float should not coerce

// TODO - sort these out into invalid catogories and remove this one
const invalid_float_assortment_data = [
  FloatTestData(
    input: "",
    output: Error(EmptyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: " ",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\t",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\n",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\r",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\f",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "\r\n",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: " \t\n\r\f ",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1_000__000.0",
    output: Error(InvalidUnderscorePosition(6)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "..1",
    output: Error(InvalidDecimalPosition(1)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1..",
    output: Error(InvalidDecimalPosition(2)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".1.",
    output: Error(InvalidDecimalPosition(2)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: ".",
    output: Error(InvalidDecimalPosition(0)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "abc",
    output: Error(InvalidCharacter("a", 0)),
    python_output: Error(Nil),
  ),
]

const invalid_underscore_position_float_data = [
  FloatTestData(
    input: "1_.000",
    output: Error(InvalidUnderscorePosition(1)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1._000",
    output: Error(InvalidUnderscorePosition(2)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "_1000.0",
    output: Error(InvalidUnderscorePosition(0)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000.0_",
    output: Error(InvalidUnderscorePosition(6)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000._0",
    output: Error(InvalidUnderscorePosition(5)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000_.0",
    output: Error(InvalidUnderscorePosition(4)),
    python_output: Error(Nil),
  ),
  FloatTestData(
    input: "1000_.",
    output: Error(InvalidUnderscorePosition(4)),
    python_output: Error(Nil),
  ),
]

const invalid_character_position_float_data = [
  FloatTestData(
    input: "100.00c01",
    output: Error(InvalidCharacter("c", 6)),
    python_output: Error(Nil),
  ),
]

pub fn float_data() -> List(FloatTestData) {
  [
    valid_float_data,
    invalid_float_assortment_data,
    invalid_underscore_position_float_data,
    invalid_character_position_float_data,
  ]
  |> list.flatten
}

// ---- int should coerce

const valid_int_data = [
  IntegerTestData(input: "1", output: Ok(1), python_output: Ok("1")),
  IntegerTestData(input: "+123", output: Ok(123), python_output: Ok("123")),
  IntegerTestData(input: " +123 ", output: Ok(123), python_output: Ok("123")),
  IntegerTestData(input: " -123 ", output: Ok(-123), python_output: Ok("-123")),
  IntegerTestData(input: "0123", output: Ok(123), python_output: Ok("123")),
  IntegerTestData(input: " 0123", output: Ok(123), python_output: Ok("123")),
  IntegerTestData(input: "-123", output: Ok(-123), python_output: Ok("-123")),
  IntegerTestData(input: "1_000", output: Ok(1000), python_output: Ok("1000")),
  IntegerTestData(
    input: "1_000_000",
    output: Ok(1_000_000),
    python_output: Ok("1000000"),
  ), IntegerTestData(input: " 1 ", output: Ok(1), python_output: Ok("1")),
]

// ---- int should not coerce

// TODO - sort these out into invalid catogories and remove this one
const invalid_int_assortment_data = [
  IntegerTestData(
    input: "",
    output: Error(EmptyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " ",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\t",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\n",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\r",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\f",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "\r\n",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " \t\n\r\f\r\n ",
    output: Error(WhitespaceOnlyString),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1_000__000",
    output: Error(InvalidUnderscorePosition(6)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1.",
    output: Error(InvalidDecimalPosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1.0",
    output: Error(InvalidDecimalPosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "abc",
    output: Error(InvalidCharacter("a", 0)),
    python_output: Error(Nil),
  ),
]

const invalid_underscore_position_int_data = [
  IntegerTestData(
    input: "_",
    output: Error(InvalidUnderscorePosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "_1000",
    output: Error(InvalidUnderscorePosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1000_",
    output: Error(InvalidUnderscorePosition(4)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " _1000",
    output: Error(InvalidUnderscorePosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1000_ ",
    output: Error(InvalidUnderscorePosition(4)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "+_1000",
    output: Error(InvalidUnderscorePosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "-_1000",
    output: Error(InvalidUnderscorePosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1__000",
    output: Error(InvalidUnderscorePosition(2)),
    python_output: Error(Nil),
  ),
]

const invalid_character_position_int_data = [
  IntegerTestData(
    input: "a",
    output: Error(InvalidCharacter("a", 0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1b1",
    output: Error(InvalidCharacter("b", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "+ 1",
    output: Error(InvalidCharacter(" ", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1 1",
    output: Error(InvalidCharacter(" ", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: " 12 34 ",
    output: Error(InvalidCharacter(" ", 3)),
    python_output: Error(Nil),
  ),
]

const invalid_sign_position_int_data = [
  IntegerTestData(
    input: "1+",
    output: Error(InvalidSignPosition("+", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1-",
    output: Error(InvalidSignPosition("-", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1+1",
    output: Error(InvalidSignPosition("+", 1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "1-1",
    output: Error(InvalidSignPosition("-", 1)),
    python_output: Error(Nil),
  ),
]

const invalid_decimal_position_int_data = [
  IntegerTestData(
    input: ".",
    output: Error(InvalidDecimalPosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "..",
    output: Error(InvalidDecimalPosition(0)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: "0.0.",
    output: Error(InvalidDecimalPosition(1)),
    python_output: Error(Nil),
  ),
  IntegerTestData(
    input: ".0.0",
    output: Error(InvalidDecimalPosition(0)),
    python_output: Error(Nil),
  ),
]

pub fn int_data() -> List(IntegerTestData) {
  [
    valid_int_data,
    invalid_int_assortment_data,
    invalid_underscore_position_int_data,
    invalid_character_position_int_data,
    invalid_sign_position_int_data,
    invalid_decimal_position_int_data,
  ]
  |> list.flatten
}

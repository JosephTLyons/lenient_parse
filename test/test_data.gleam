import gleam/list
import parse_error.{
  EmptyString, InvalidCharacter, InvalidDecimalPosition,
  InvalidUnderscorePosition, WhitespaceOnlyString,
}

// ---- float should coerce

pub const valid_floats = [
  #("1.001", 1.001), #("1.00", 1.0), #("1.0", 1.0), #("0.1", 0.1),
  #("+1.0", 1.0), #("-1.0", -1.0), #("+123.321", 123.321),
  #("-123.321", -123.321), #("1", 1.0), #("1.", 1.0), #(".1", 0.1),
  #("1_000_000.0", 1_000_000.0), #("1_000_000.000_1", 1_000_000.0001),
  #("1000.000_000", 1000.0), #("1", 1.0), #(" 1 ", 1.0), #(" 1.0 ", 1.0),
  #(" 1000 ", 1000.0),
]

pub fn valid_float_strings() -> List(String) {
  valid_floats |> list.map(fn(a) { a.0 })
}

// ---- float should not coerce

pub const invalid_float_assortment = [
  #("", EmptyString), #(" ", WhitespaceOnlyString),
  #("\t", WhitespaceOnlyString), #("\n", WhitespaceOnlyString),
  #("\r", WhitespaceOnlyString), #("\f", WhitespaceOnlyString),
  #(" \t\n\r\f ", WhitespaceOnlyString),
  #("1_000__000.0", InvalidUnderscorePosition(6)),
  #("..1", InvalidDecimalPosition(1)), #("1..", InvalidDecimalPosition(2)),
  #(".1.", InvalidDecimalPosition(2)), #(".", InvalidDecimalPosition(0)),
  #("", EmptyString), #(" ", WhitespaceOnlyString),
  #("abc", InvalidCharacter("a", 0)),
]

pub const invalid_underscore_position_floats = [
  #("1_.000", 1), #("1._000", 2), #("_1000.0", 0), #("1000.0_", 6),
  #("1000._0", 5), #("1000_.0", 4), #("1000_.", 4),
]

pub const invalid_character_position_floats = [#("100.00c01", "c", 6)]

pub fn invalid_float_strings() -> List(String) {
  let a = invalid_float_assortment |> list.map(fn(a) { a.0 })
  let b = invalid_underscore_position_floats |> list.map(fn(a) { a.0 })
  let c = invalid_character_position_floats |> list.map(fn(a) { a.0 })
  [a, b, c] |> list.flatten
}

// ---- int should coerce

pub const valid_ints = [
  #("1", 1), #("+123", 123), #(" +123 ", 123), #(" -123 ", -123), #("0123", 123),
  #(" 0123", 123), #("-123", -123), #("1_000", 1000), #("1_000_000", 1_000_000),
  #(" 1 ", 1),
]

pub fn valid_int_strings() -> List(String) {
  valid_ints |> list.map(fn(a) { a.0 })
}

// ---- int should not coerce

pub const invalid_int_assortment = [
  #("", EmptyString), #(" ", WhitespaceOnlyString),
  #("\t", WhitespaceOnlyString), #("\n", WhitespaceOnlyString),
  #("\r", WhitespaceOnlyString), #("\f", WhitespaceOnlyString),
  #(" \t\n\r\f ", WhitespaceOnlyString),
  #("1_000__000", InvalidUnderscorePosition(6)),
  #("1.", InvalidDecimalPosition(1)), #("1.0", InvalidDecimalPosition(1)),
  #("", EmptyString), #(" ", WhitespaceOnlyString),
  #("abc", InvalidCharacter("a", 0)),
]

pub const invalid_underscore_position_ints = [
  #("_", 0), #("_1000", 0), #("1000_", 4), #(" _1000", 1), #("1000_ ", 4),
  #("+_1000", 1), #("-_1000", 1), #("1__000", 2),
]

pub const invalid_character_position_ints = [
  #("a", "a", 0), #("1b1", "b", 1), #("+ 1", " ", 1), #("1 1", " ", 1),
  #(" 12 34 ", " ", 3),
]

pub const invalid_sign_position_ints = [
  #("1+", "+", 1), #("1-", "-", 1), #("1+1", "+", 1), #("1-1", "-", 1),
]

pub const invalid_decimal_position_ints = [
  #(".", 0), #("..", 0), #("0.0.", 1), #(".0.0", 0),
]

pub fn invalid_int_strings() -> List(String) {
  let a = invalid_int_assortment |> list.map(fn(a) { a.0 })
  let b = invalid_underscore_position_ints |> list.map(fn(a) { a.0 })
  let c = invalid_character_position_ints |> list.map(fn(a) { a.0 })
  let d = invalid_sign_position_ints |> list.map(fn(a) { a.0 })
  let e = invalid_decimal_position_ints |> list.map(fn(a) { a.0 })
  [a, b, c, d, e] |> list.flatten
}

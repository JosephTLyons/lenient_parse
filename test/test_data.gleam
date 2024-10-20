import gleam/list
import parse_error.{
  EmptyString, GleamIntParseError, InvalidCharacter, InvalidDecimalPosition,
  InvalidUnderscorePosition, WhitespaceOnlyString,
}

// TODO - better list and function names

// ---- float should coerce

pub const float_should_coerce = [
  #("1.001", 1.001), #("1.00", 1.0), #("1.0", 1.0), #("0.1", 0.1),
  #("+1.0", 1.0), #("-1.0", -1.0), #("+123.321", 123.321),
  #("-123.321", -123.321), #("1", 1.0), #("1.", 1.0), #(".1", 0.1),
  #("1_000_000.0", 1_000_000.0), #("1_000_000.000_1", 1_000_000.0001),
  #("1000.000_000", 1000.0), #(" 1 ", 1.0), #(" 1.0 ", 1.0), #(" 1000 ", 1000.0),
]

pub fn float_should_coerce_strings() -> List(String) {
  float_should_coerce |> list.map(fn(a) { a.0 })
}

// ---- float should not coerce

pub const float_should_not_coerce_assortment = [
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

pub const float_should_not_coerce_invalid_underscore = [
  #("1_.000", 1), #("1._000", 2), #("_1000.0", 0), #("1000.0_", 6),
  #("1000._0", 5), #("1000_.0", 4), #("1000_.", 4),
]

pub const float_should_not_coerce_invalid_character = [#("100.00c01", "c", 6)]

pub fn float_should_not_coerce_strings() -> List(String) {
  let a = float_should_not_coerce_assortment |> list.map(fn(a) { a.0 })
  let b = float_should_not_coerce_invalid_underscore |> list.map(fn(a) { a.0 })
  let c = float_should_not_coerce_invalid_character |> list.map(fn(a) { a.0 })
  [a, b, c] |> list.flatten
}

// ---- int should coerce

pub const int_should_coerce = [
  #("1", 1), #("+123", 123), #(" +123 ", 123), #(" -123 ", -123), #("0123", 123),
  #(" 0123", 123), #("-123", -123), #("1_000", 1000), #("1_000_000", 1_000_000),
  #(" 1 ", 1),
]

pub fn int_should_coerce_strings() -> List(String) {
  int_should_coerce |> list.map(fn(a) { a.0 })
}

// ---- int should not coerce

pub const int_should_not_coerce_assortment = [
  #("", EmptyString), #(" ", WhitespaceOnlyString),
  #("\t", WhitespaceOnlyString), #("\n", WhitespaceOnlyString),
  #("\r", WhitespaceOnlyString), #("\f", WhitespaceOnlyString),
  #(" \t\n\r\f ", WhitespaceOnlyString),
  #("1_000__000", InvalidUnderscorePosition(6)), #("1.", GleamIntParseError),
  #("1.0", GleamIntParseError), #("", EmptyString), #(" ", WhitespaceOnlyString),
  #("abc", InvalidCharacter("a", 0)),
]

pub const int_should_not_coerce_invalid_underscore = [
  #("_", 0), #("_1000", 0), #("1000_", 4), #(" _1000", 1), #("1000_ ", 4),
  #("+_1000", 1), #("-_1000", 1), #("1__000", 2),
]

pub const int_should_not_coerce_invalid_character = [
  #("a", "a", 0), #("1b1", "b", 1), #("+ 1", " ", 1), #("1 1", " ", 1),
  #(" 12 34 ", " ", 3),
]

pub const int_should_not_coerce_invalid_sign = [
  #("1+", "+", 1), #("1-", "-", 1), #("1+1", "+", 1), #("1-1", "-", 1),
]

pub const int_should_not_coerce_decimal_position = [
  #(".", 0), #("..", 1), #("0.0.", 3), #(".0.0", 2),
]

pub fn int_should_not_coerce_strings() -> List(String) {
  let a = int_should_not_coerce_assortment |> list.map(fn(a) { a.0 })
  let b = int_should_not_coerce_invalid_underscore |> list.map(fn(a) { a.0 })
  let c = int_should_not_coerce_invalid_character |> list.map(fn(a) { a.0 })
  let d = int_should_not_coerce_invalid_sign |> list.map(fn(a) { a.0 })
  let e = int_should_not_coerce_decimal_position |> list.map(fn(a) { a.0 })
  [a, b, c, d, e] |> list.flatten
}

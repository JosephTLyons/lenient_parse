import gleam/list
import lenient_parse.{
  InvalidCharacter, InvalidDecimalPosition, InvalidUnderscorePosition,
  WhitespaceOnlyOrEmptyString,
}
import startest/expect

pub fn coerce_into_valid_number_string_test() {
  ""
  |> lenient_parse.coerce_into_valid_number_string
  |> expect.to_equal(Error(WhitespaceOnlyOrEmptyString))

  " "
  |> lenient_parse.coerce_into_valid_number_string
  |> expect.to_equal(Error(WhitespaceOnlyOrEmptyString))

  "\t\n\r"
  |> lenient_parse.coerce_into_valid_number_string
  |> expect.to_equal(Error(WhitespaceOnlyOrEmptyString))

  "a"
  |> lenient_parse.coerce_into_valid_number_string
  |> expect.to_equal(Error(InvalidCharacter("a")))

  "1a1"
  |> lenient_parse.coerce_into_valid_number_string
  |> expect.to_equal(Error(InvalidCharacter("a")))
}

pub fn check_for_valid_underscore_positions_test() {
  [
    "0", "0.0", "+1000", "-1000", " 1000 ", " -1000 ", "1_000", "1_000_000",
    "1_000_000.0", "1_000_000.000_1", "1000.000_000",
  ]
  |> list.each(fn(text) {
    text
    |> lenient_parse.check_for_valid_underscore_positions
    |> expect.to_equal(Ok(Nil))
  })

  [
    "_", "_1000", "1000_", "+_1000", "-_1000", "1__000", "1_.000", "1._000",
    "_1000.0", "1000.0_", "1000._0", "1000_.0", "1000_.",
  ]
  |> list.each(fn(text) {
    text
    |> lenient_parse.check_for_valid_underscore_positions
    |> expect.to_equal(Error(InvalidUnderscorePosition))
  })
}

pub fn check_for_valid_decimal_positions_test() {
  [".0", "0."]
  |> list.each(fn(text) {
    text
    |> lenient_parse.check_for_valid_decimal_positions()
    |> expect.to_equal(Ok(Nil))
  })

  [".", "..", "0.0.", ".0.0"]
  |> list.each(fn(text) {
    text
    |> lenient_parse.check_for_valid_decimal_positions()
    |> expect.to_equal(Error(InvalidDecimalPosition))
  })
}
// pub fn is_valid_number_string_true_test() {
//   lenient_parse.is_valid_number_string("0.0.") |> expect.to_equal(False)
// }

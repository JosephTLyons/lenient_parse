import coerce.{
  InvalidCharacter, InvalidDecimalPosition, InvalidUnderscorePosition,
  WhitespaceOnlyOrEmptyString, coerce_into_valid_number_string,
  coerce_into_valid_underscore_string,
}
import gleam/list
import gleam/string
import startest.{describe, it}
import startest/expect

pub fn coerce_into_valid_number_string_tests() {
  describe(
    "Is invalid number string: whitespace only or empty string",
    [
      ["", " ", " \t\n\r "]
      |> list.map(fn(text) {
        let printable_text = text |> into_printable

        use <- it("'" <> printable_text <> "'")

        text
        |> coerce_into_valid_number_string
        |> expect.to_equal(Error(WhitespaceOnlyOrEmptyString))
      }),
    ]
      |> list.concat,
  )
}

fn into_printable(text: String) -> String {
  do_into_printable(text |> string.to_graphemes, "")
}

fn do_into_printable(characters: List(String), acc: String) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case first {
        "\t" -> "\\t"
        "\n" -> "\\n"
        "\r" -> "\\r"
        _ -> first
      }
      do_into_printable(rest, acc <> printable)
    }
  }
}

// Literally testing the test helper function
pub fn into_printable_test() {
  "\t" |> into_printable |> expect.to_equal("\\t")
  "\n" |> into_printable |> expect.to_equal("\\n")
  "\r" |> into_printable |> expect.to_equal("\\r")
  "\t\nabc123\r" |> into_printable |> expect.to_equal("\\t\\nabc123\\r")
}

pub fn coerce_into_valid_number_string_test() {
  "a"
  |> coerce_into_valid_number_string
  |> expect.to_equal(Error(InvalidCharacter("a")))

  "1a1"
  |> coerce_into_valid_number_string
  |> expect.to_equal(Error(InvalidCharacter("a")))
}

pub fn coerce_into_valid_underscore_string_test() {
  "0"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("0"))

  "0.0"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("0.0"))

  "+1000"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("+1000"))

  "-1000"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("-1000"))

  " 1000 "
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok(" 1000 "))

  " -1000 "
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok(" -1000 "))

  "1_000"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("1000"))

  "1_000_000"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("1000000"))

  "1_000_000.0"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("1000000.0"))

  "1_000_000.000_1"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("1000000.0001"))

  "1000.000_000"
  |> coerce_into_valid_underscore_string
  |> expect.to_equal(Ok("1000.000000"))

  [
    "_", "_1000", "1000_", "+_1000", "-_1000", "1__000", "1_.000", "1._000",
    "_1000.0", "1000.0_", "1000._0", "1000_.0", "1000_.",
  ]
  |> list.each(fn(text) {
    text
    |> coerce_into_valid_underscore_string
    |> expect.to_equal(Error(InvalidUnderscorePosition))
  })
}

pub fn check_for_valid_decimal_positions_test() {
  ".1"
  |> coerce_into_valid_number_string()
  |> expect.to_equal(Ok("0.1"))

  "1."
  |> coerce_into_valid_number_string()
  |> expect.to_equal(Ok("1.0"))

  [".", "..", "0.0.", ".0.0"]
  |> list.each(fn(text) {
    text
    |> coerce_into_valid_number_string()
    |> expect.to_equal(Error(InvalidDecimalPosition))
  })
}

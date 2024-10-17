import coerce.{
  InvalidCharacter, InvalidDecimalPosition, InvalidUnderscorePosition,
  SignAtInvalidPosition, WhitespaceOnlyOrEmptyString,
  coerce_into_valid_number_string, coerce_into_valid_underscore_string,
  has_valid_sign_position,
}
import gleam/list
import gleam/string
import startest.{describe, it}
import startest/expect

pub fn failure_to_coerce_into_valid_number_string_tests() {
  describe("is_invalid_number_string", [
    describe(
      "whitespace_only_or_empty_string",
      [
        ["", " ", "\t", "\n", "\r", "\f", " \t\n\r\f "]
        |> list.map(fn(text) {
          let printable_text = text |> into_printable_text

          use <- it("\"" <> printable_text <> "\"")

          text
          |> coerce_into_valid_number_string
          |> expect.to_equal(Error(WhitespaceOnlyOrEmptyString))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "invalid_character",
      [
        [#("a", "a"), #("1b1", "b"), #("100.00c01", "c"), #("1 1", " ")]
        |> list.map(fn(input_invalid_character_pair) {
          let #(input, invalid_character) = input_invalid_character_pair
          use <- it("\"" <> invalid_character <> "\" in \"" <> input <> "\"")

          input
          |> coerce_into_valid_number_string
          |> expect.to_equal(Error(InvalidCharacter(invalid_character)))
        }),
      ]
        |> list.concat,
    ),
  ])
}

fn into_printable_text(text: String) -> String {
  do_into_printable_text(text |> string.to_graphemes, "")
}

fn do_into_printable_text(characters: List(String), acc: String) -> String {
  case characters {
    [] -> acc
    [first, ..rest] -> {
      let printable = case first {
        "\t" -> "\\t"
        "\n" -> "\\n"
        "\r" -> "\\r"
        "\f" -> "\\f"
        _ -> first
      }
      do_into_printable_text(rest, acc <> printable)
    }
  }
}

pub fn x() {
  "1+1"
  |> coerce_into_valid_number_string
  |> expect.to_equal(Error(SignAtInvalidPosition("+")))

  "1-1"
  |> coerce_into_valid_number_string
  |> expect.to_equal(Error(SignAtInvalidPosition("-")))

  " +1"
  |> coerce_into_valid_number_string
  |> expect.to_equal(Ok("1"))
}

// Literally testing the test helper function
pub fn into_printable_text_tests() {
  describe(
    "into_printable_text_test",
    [
      [
        #("\t", "\\t"),
        #("\n", "\\n"),
        #("\r", "\\r"),
        #("\f", "\\f"),
        #("\t\nabc123\r", "\\t\\nabc123\\r"),
      ]
      |> list.map(fn(input_output_pair) {
        let #(input, output) = input_output_pair
        use <- it("\"" <> output <> "\"")
        input |> into_printable_text |> expect.to_equal(output)
      }),
    ]
      |> list.concat,
  )
}

pub fn coerce_into_valid_underscore_string_tests() {
  describe("underscore_string_test", [
    describe(
      "has_valid_underscore_position",
      [
        [
          #("0", "0"),
          #("0.0", "0.0"),
          #("+1000", "+1000"),
          #("-1000", "-1000"),
          #(" 1000 ", " 1000 "),
          #(" -1000 ", " -1000 "),
          #("1_000", "1000"),
          #("1_000_000", "1000000"),
          #("1_000_000.0", "1000000.0"),
          #("1_000_000.000_1", "1000000.0001"),
          #("1000.000_000", "1000.000000"),
        ]
        |> list.map(fn(input_output_pair) {
          let #(input, output) = input_output_pair
          use <- it("\"" <> input <> "\" -> \"" <> output <> "\"")

          input
          |> coerce_into_valid_underscore_string
          |> expect.to_equal(Ok(output))
        }),
      ]
        |> list.concat,
    ),
    describe(
      "has_invalid_underscore_position",
      [
        [
          "_", "_1000", "1000_", "+_1000", "-_1000", "1__000", "1_.000",
          "1._000", "_1000.0", "1000.0_", "1000._0", "1000_.0", "1000_.",
        ]
        |> list.map(fn(text) {
          use <- it("\"" <> text <> "\"")

          text
          |> coerce_into_valid_underscore_string
          |> expect.to_equal(Error(InvalidUnderscorePosition))
        }),
      ]
        |> list.concat,
    ),
  ])
}

pub fn has_valid_sign_position_test() {
  "+1"
  |> has_valid_sign_position
  |> expect.to_equal(Ok(Nil))

  "-1"
  |> has_valid_sign_position
  |> expect.to_equal(Ok(Nil))

  "1+"
  |> has_valid_sign_position
  |> expect.to_equal(Error(SignAtInvalidPosition("+")))

  "1-"
  |> has_valid_sign_position
  |> expect.to_equal(Error(SignAtInvalidPosition("-")))

  "1+1"
  |> has_valid_sign_position
  |> expect.to_equal(Error(SignAtInvalidPosition("+")))

  "1-1"
  |> has_valid_sign_position
  |> expect.to_equal(Error(SignAtInvalidPosition("-")))
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

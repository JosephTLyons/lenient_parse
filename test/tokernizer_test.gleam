import gleam/list
import gleam/string
import lenient_parse/internal/tokenizer.{
  DecimalPoint, Digit, Sign, Underscore, Unknown, Whitespace,
  tokenize_number_string,
}
import startest/expect

pub fn tokenize_number_string_test() {
  " \t\n\r\f+-0123456789._abc"
  |> tokenize_number_string
  |> expect.to_equal([
    Whitespace(" "),
    Whitespace("\t"),
    Whitespace("\n"),
    Whitespace("\r"),
    Whitespace("\f"),
    Sign("+"),
    Sign("-"),
    Digit("0"),
    Digit("1"),
    Digit("2"),
    Digit("3"),
    Digit("4"),
    Digit("5"),
    Digit("6"),
    Digit("7"),
    Digit("8"),
    Digit("9"),
    DecimalPoint,
    Underscore,
    Unknown("a"),
    Unknown("b"),
    Unknown("c"),
  ])
}

pub fn is_digit_test() {
  "0123456789"
  |> tokenize_number_string
  |> list.each(fn(token) { token |> tokenizer.is_digit |> expect.to_be_true })

  "abc"
  |> tokenize_number_string
  |> list.each(fn(token) { token |> tokenizer.is_digit |> expect.to_be_false })
}

pub fn to_result_test() {
  "0123456789"
  |> tokenize_number_string
  |> list.each(fn(token) { token |> tokenizer.to_result |> expect.to_be_ok })

  "._"
  |> tokenize_number_string
  |> list.each(fn(token) { token |> tokenizer.to_result |> expect.to_be_ok })

  "+-"
  |> tokenize_number_string
  |> list.each(fn(token) { token |> tokenizer.to_result |> expect.to_be_ok })

  [" ", "\n", "\t", "\r", "\f", "\r\n"]
  |> string.join("")
  |> tokenize_number_string
  |> list.each(fn(token) { token |> tokenizer.to_result |> expect.to_be_ok })

  "abc"
  |> tokenize_number_string
  |> list.each(fn(token) { token |> tokenizer.to_result |> expect.to_be_error })
}

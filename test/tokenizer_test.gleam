import lenient_parse/internal/token.{
  DecimalPoint, Digit, ExponentSymbol, Sign, Underscore, Unknown, Whitespace,
}
import lenient_parse/internal/tokenizer
import parse_error.{InvalidBaseValue}
import startest/expect

pub fn tokenize_float_test() {
  " \t\n\r\f\r\n+-0123456789eE._abc"
  |> tokenizer.tokenize_float
  |> expect.to_equal([
    Whitespace(" "),
    Whitespace("\t"),
    Whitespace("\n"),
    Whitespace("\r"),
    Whitespace("\f"),
    Whitespace("\r\n"),
    Sign("+", True),
    Sign("-", False),
    Digit("0", 0, True),
    Digit("1", 1, True),
    Digit("2", 2, True),
    Digit("3", 3, True),
    Digit("4", 4, True),
    Digit("5", 5, True),
    Digit("6", 6, True),
    Digit("7", 7, True),
    Digit("8", 8, True),
    Digit("9", 9, True),
    ExponentSymbol("e"),
    ExponentSymbol("E"),
    DecimalPoint,
    Underscore,
    Unknown("a"),
    Unknown("b"),
    Unknown("c"),
  ])
}

pub fn tokenize_int_base_10_test() {
  " \t\n\r\f\r\n+-0123456789eE._abcZ"
  |> tokenizer.tokenize_int(base: 10)
  |> expect.to_equal(
    Ok([
      Whitespace(" "),
      Whitespace("\t"),
      Whitespace("\n"),
      Whitespace("\r"),
      Whitespace("\f"),
      Whitespace("\r\n"),
      Sign("+", True),
      Sign("-", False),
      Digit("0", 0, True),
      Digit("1", 1, True),
      Digit("2", 2, True),
      Digit("3", 3, True),
      Digit("4", 4, True),
      Digit("5", 5, True),
      Digit("6", 6, True),
      Digit("7", 7, True),
      Digit("8", 8, True),
      Digit("9", 9, True),
      Digit("e", 14, False),
      Digit("E", 14, False),
      Unknown("."),
      Underscore,
      Digit("a", 10, False),
      Digit("b", 11, False),
      Digit("c", 12, False),
      Digit("Z", 35, False),
    ]),
  )
}

pub fn tokenize_int_base_2_test() {
  "0102101"
  |> tokenizer.tokenize_int(base: 2)
  |> expect.to_equal(
    Ok([
      Digit("0", 0, True),
      Digit("1", 1, True),
      Digit("0", 0, True),
      Digit("2", 2, False),
      Digit("1", 1, True),
      Digit("0", 0, True),
      Digit("1", 1, True),
    ]),
  )
}

pub fn tokenize_int_base_16_test() {
  "dead_beefZ"
  |> tokenizer.tokenize_int(base: 16)
  |> expect.to_equal(
    Ok([
      Digit("d", 0xD, True),
      Digit("e", 0xE, True),
      Digit("a", 0xA, True),
      Digit("d", 0xD, True),
      Underscore,
      Digit("b", 0xB, True),
      Digit("e", 0xE, True),
      Digit("e", 0xE, True),
      Digit("f", 0xF, True),
      Digit("Z", 35, False),
    ]),
  )
}

pub fn tokenize_int_base_35_test() {
  "1234567890abcdefghijklmnopqrstuvwxyz"
  |> tokenizer.tokenize_int(base: 35)
  |> expect.to_equal(
    Ok([
      Digit("1", 1, True),
      Digit("2", 2, True),
      Digit("3", 3, True),
      Digit("4", 4, True),
      Digit("5", 5, True),
      Digit("6", 6, True),
      Digit("7", 7, True),
      Digit("8", 8, True),
      Digit("9", 9, True),
      Digit("0", 0, True),
      Digit("a", 10, True),
      Digit("b", 11, True),
      Digit("c", 12, True),
      Digit("d", 13, True),
      Digit("e", 14, True),
      Digit("f", 15, True),
      Digit("g", 16, True),
      Digit("h", 17, True),
      Digit("i", 18, True),
      Digit("j", 19, True),
      Digit("k", 20, True),
      Digit("l", 21, True),
      Digit("m", 22, True),
      Digit("n", 23, True),
      Digit("o", 24, True),
      Digit("p", 25, True),
      Digit("q", 26, True),
      Digit("r", 27, True),
      Digit("s", 28, True),
      Digit("t", 29, True),
      Digit("u", 30, True),
      Digit("v", 31, True),
      Digit("w", 32, True),
      Digit("x", 33, True),
      Digit("y", 34, True),
      Digit("z", 35, False),
    ]),
  )
}

pub fn tokenize_int_base_36_test() {
  "159az"
  |> tokenizer.tokenize_int(base: 36)
  |> expect.to_equal(
    Ok([
      Digit("1", 1, True),
      Digit("5", 5, True),
      Digit("9", 9, True),
      Digit("a", 10, True),
      Digit("z", 35, True),
    ]),
  )
}

pub fn tokenize_int_invalid_1_test() {
  "1"
  |> tokenizer.tokenize_int(base: 1)
  |> expect.to_equal(Error(InvalidBaseValue(1)))
}

pub fn tokenize_int_invalid_2_test() {
  "1"
  |> tokenizer.tokenize_int(base: 37)
  |> expect.to_equal(Error(InvalidBaseValue(37)))
}

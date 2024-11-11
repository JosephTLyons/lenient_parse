import lenient_parse/internal/token.{
  DecimalPoint, Digit, ExponentSymbol, InferredBase, Sign, Underscore, Unknown,
  Whitespace,
}
import lenient_parse/internal/tokenizer
import startest/expect

// In Python's `float()`, only base 10 is supported. Any letter character
// (a-z/A-Z), outside of an exponent character, should be considered an Unknown.
pub fn tokenize_float_test() {
  " \t\n\r\f\r\n+-0123456789eE._abc"
  |> tokenizer.tokenize_float
  |> expect.to_equal([
    Whitespace(#(0, 1), " "),
    Whitespace(#(1, 2), "\t"),
    Whitespace(#(2, 3), "\n"),
    Whitespace(#(3, 4), "\r"),
    Whitespace(#(4, 5), "\f"),
    Whitespace(#(5, 6), "\r\n"),
    Sign(#(6, 7), "+", True),
    Sign(#(7, 8), "-", False),
    Digit(#(8, 9), "0", 0, 10),
    Digit(#(9, 10), "1", 1, 10),
    Digit(#(10, 11), "2", 2, 10),
    Digit(#(11, 12), "3", 3, 10),
    Digit(#(12, 13), "4", 4, 10),
    Digit(#(13, 14), "5", 5, 10),
    Digit(#(14, 15), "6", 6, 10),
    Digit(#(15, 16), "7", 7, 10),
    Digit(#(16, 17), "8", 8, 10),
    Digit(#(17, 18), "9", 9, 10),
    ExponentSymbol(#(18, 19), "e"),
    ExponentSymbol(#(19, 20), "E"),
    DecimalPoint(#(20, 21)),
    Underscore(#(21, 22)),
    Unknown(#(22, 23), "a"),
    Unknown(#(23, 24), "b"),
    Unknown(#(24, 25), "c"),
  ])
}

// In Python's `int()`, Letter characters (a-z/A-Z) are all supported given the
// right base, so we mark these as Digits.
pub fn tokenize_int_base_10_test() {
  " \t\n\r\f\r\n+-0123456789eE._abcZ"
  |> tokenizer.tokenize_int(base: 10)
  |> expect.to_equal([
    Whitespace(#(0, 1), " "),
    Whitespace(#(1, 2), "\t"),
    Whitespace(#(2, 3), "\n"),
    Whitespace(#(3, 4), "\r"),
    Whitespace(#(4, 5), "\f"),
    Whitespace(#(5, 6), "\r\n"),
    Sign(#(6, 7), "+", True),
    Sign(#(7, 8), "-", False),
    Digit(#(8, 9), "0", 0, 10),
    Digit(#(9, 10), "1", 1, 10),
    Digit(#(10, 11), "2", 2, 10),
    Digit(#(11, 12), "3", 3, 10),
    Digit(#(12, 13), "4", 4, 10),
    Digit(#(13, 14), "5", 5, 10),
    Digit(#(14, 15), "6", 6, 10),
    Digit(#(15, 16), "7", 7, 10),
    Digit(#(16, 17), "8", 8, 10),
    Digit(#(17, 18), "9", 9, 10),
    Digit(#(18, 19), "e", 14, 10),
    Digit(#(19, 20), "E", 14, 10),
    Unknown(#(20, 21), "."),
    Underscore(#(21, 22)),
    Digit(#(22, 23), "a", 10, 10),
    Digit(#(23, 24), "b", 11, 10),
    Digit(#(24, 25), "c", 12, 10),
    Digit(#(25, 26), "Z", 35, 10),
  ])
}

pub fn tokenize_int_base_2_test() {
  "0102101"
  |> tokenizer.tokenize_int(base: 2)
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0, 2),
    Digit(#(1, 2), "1", 1, 2),
    Digit(#(2, 3), "0", 0, 2),
    Digit(#(3, 4), "2", 2, 2),
    Digit(#(4, 5), "1", 1, 2),
    Digit(#(5, 6), "0", 0, 2),
    Digit(#(6, 7), "1", 1, 2),
  ])
}

pub fn tokenize_int_base_16_test() {
  "dead_beefZ"
  |> tokenizer.tokenize_int(base: 16)
  |> expect.to_equal([
    Digit(#(0, 1), "d", 0xD, 16),
    Digit(#(1, 2), "e", 0xE, 16),
    Digit(#(2, 3), "a", 0xA, 16),
    Digit(#(3, 4), "d", 0xD, 16),
    Underscore(#(4, 5)),
    Digit(#(5, 6), "b", 0xB, 16),
    Digit(#(6, 7), "e", 0xE, 16),
    Digit(#(7, 8), "e", 0xE, 16),
    Digit(#(8, 9), "f", 0xF, 16),
    Digit(#(9, 10), "Z", 35, 16),
  ])
}

pub fn tokenize_int_base_35_test() {
  "1234567890abcdefghijklmnopqrstuvwxyz"
  |> tokenizer.tokenize_int(base: 35)
  |> expect.to_equal([
    Digit(#(0, 1), "1", 1, 35),
    Digit(#(1, 2), "2", 2, 35),
    Digit(#(2, 3), "3", 3, 35),
    Digit(#(3, 4), "4", 4, 35),
    Digit(#(4, 5), "5", 5, 35),
    Digit(#(5, 6), "6", 6, 35),
    Digit(#(6, 7), "7", 7, 35),
    Digit(#(7, 8), "8", 8, 35),
    Digit(#(8, 9), "9", 9, 35),
    Digit(#(9, 10), "0", 0, 35),
    Digit(#(10, 11), "a", 10, 35),
    Digit(#(11, 12), "b", 11, 35),
    Digit(#(12, 13), "c", 12, 35),
    Digit(#(13, 14), "d", 13, 35),
    Digit(#(14, 15), "e", 14, 35),
    Digit(#(15, 16), "f", 15, 35),
    Digit(#(16, 17), "g", 16, 35),
    Digit(#(17, 18), "h", 17, 35),
    Digit(#(18, 19), "i", 18, 35),
    Digit(#(19, 20), "j", 19, 35),
    Digit(#(20, 21), "k", 20, 35),
    Digit(#(21, 22), "l", 21, 35),
    Digit(#(22, 23), "m", 22, 35),
    Digit(#(23, 24), "n", 23, 35),
    Digit(#(24, 25), "o", 24, 35),
    Digit(#(25, 26), "p", 25, 35),
    Digit(#(26, 27), "q", 26, 35),
    Digit(#(27, 28), "r", 27, 35),
    Digit(#(28, 29), "s", 28, 35),
    Digit(#(29, 30), "t", 29, 35),
    Digit(#(30, 31), "u", 30, 35),
    Digit(#(31, 32), "v", 31, 35),
    Digit(#(32, 33), "w", 32, 35),
    Digit(#(33, 34), "x", 33, 35),
    Digit(#(34, 35), "y", 34, 35),
    Digit(#(35, 36), "z", 35, 35),
  ])
}

pub fn tokenize_int_base_36_test() {
  "159az"
  |> tokenizer.tokenize_int(base: 36)
  |> expect.to_equal([
    Digit(#(0, 1), "1", 1, 36),
    Digit(#(1, 2), "5", 5, 36),
    Digit(#(2, 3), "9", 9, 36),
    Digit(#(3, 4), "a", 10, 36),
    Digit(#(4, 5), "z", 35, 36),
  ])
}

pub fn tokenize_int_inferred_base_2_test() {
  "   0b1010b"
  |> tokenizer.tokenize_int(base: 0)
  |> expect.to_equal([
    Whitespace(#(0, 1), " "),
    Whitespace(#(1, 2), " "),
    Whitespace(#(2, 3), " "),
    InferredBase(#(3, 5), "0b", 2),
    Digit(#(5, 6), "1", 1, 2),
    Digit(#(6, 7), "0", 0, 2),
    Digit(#(7, 8), "1", 1, 2),
    Digit(#(8, 9), "0", 0, 2),
    Digit(#(9, 10), "b", 11, 2),
  ])
}

pub fn tokenize_int_inferred_base_8_test() {
  "   0o0123456780o"
  |> tokenizer.tokenize_int(base: 0)
  |> expect.to_equal([
    Whitespace(#(0, 1), " "),
    Whitespace(#(1, 2), " "),
    Whitespace(#(2, 3), " "),
    InferredBase(#(3, 5), "0o", 8),
    Digit(#(5, 6), "0", 0, 8),
    Digit(#(6, 7), "1", 1, 8),
    Digit(#(7, 8), "2", 2, 8),
    Digit(#(8, 9), "3", 3, 8),
    Digit(#(9, 10), "4", 4, 8),
    Digit(#(10, 11), "5", 5, 8),
    Digit(#(11, 12), "6", 6, 8),
    Digit(#(12, 13), "7", 7, 8),
    Digit(#(13, 14), "8", 8, 8),
    Digit(#(14, 15), "0", 0, 8),
    Digit(#(15, 16), "o", 24, 8),
  ])
}

pub fn tokenize_int_inferred_base_16_test() {
  " +0XDEAD_BEEF0x "
  |> tokenizer.tokenize_int(base: 0)
  |> expect.to_equal([
    Whitespace(#(0, 1), " "),
    Sign(#(1, 2), "+", True),
    InferredBase(#(2, 4), "0X", 16),
    Digit(#(4, 5), "D", 13, 16),
    Digit(#(5, 6), "E", 14, 16),
    Digit(#(6, 7), "A", 10, 16),
    Digit(#(7, 8), "D", 13, 16),
    Underscore(#(8, 9)),
    Digit(#(9, 10), "B", 11, 16),
    Digit(#(10, 11), "E", 14, 16),
    Digit(#(11, 12), "E", 14, 16),
    Digit(#(12, 13), "F", 15, 16),
    Digit(#(13, 14), "0", 0, 16),
    Digit(#(14, 15), "x", 33, 16),
    Whitespace(#(15, 16), " "),
  ])
}
// pub fn tokenize_int_inferred_base_10_test() {
//   "1990_04_12"
//   |> tokenizer.tokenize_int(base: 0)
//   |> expect.to_equal([
//     Digit(#(0, 1), "1", 1, 10),
//     Digit(#(1, 2), "9", 9, 10),
//     Digit(#(2, 3), "9", 9, 10),
//     Digit(#(3, 4), "0", 0, 10),
//     Underscore(#(4, 5)),
//     Digit(#(5, 6), "0", 0, 10),
//     Digit(#(6, 7), "4", 4, 10),
//     Underscore(#(7, 8)),
//     Digit(#(8, 9), "1", 1, 10),
//     Digit(#(9, 10), "2", 2, 10),
//   ])
// }

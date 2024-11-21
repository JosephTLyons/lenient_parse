import gleam/dict
import gleam/list
import gleam/string
import lenient_parse/internal/whitespace.{
  carriage_return, form_feed, horizontal_tab, line_feed, space, windows_newline,
}

import lenient_parse/internal/token.{
  DecimalPoint, Digit, ExponentSymbol, Sign, Underscore, Unknown, Whitespace,
}
import lenient_parse/internal/tokenizer
import startest/expect

// With floats, only base 10 is supported. Any letter character (a-z/A-Z),
// outside of an exponent character, should be considered an Unknown.
pub fn tokenize_float_test() {
  " \t\n\r\f\r\n+-0123456789eE._abc"
  |> tokenizer.tokenize_float
  |> expect.to_equal([
    Whitespace(0, space),
    Whitespace(1, horizontal_tab),
    Whitespace(2, line_feed),
    Whitespace(3, carriage_return),
    Whitespace(4, form_feed),
    Whitespace(5, windows_newline),
    Sign(6, "+", True),
    Sign(7, "-", False),
    Digit(8, "0", 0),
    Digit(9, "1", 1),
    Digit(10, "2", 2),
    Digit(11, "3", 3),
    Digit(12, "4", 4),
    Digit(13, "5", 5),
    Digit(14, "6", 6),
    Digit(15, "7", 7),
    Digit(16, "8", 8),
    Digit(17, "9", 9),
    ExponentSymbol(18, "e"),
    ExponentSymbol(19, "E"),
    DecimalPoint(20),
    Underscore(21),
    Unknown(22, "a"),
    Unknown(23, "b"),
    Unknown(24, "c"),
  ])
}

// With integers, Letter characters (a-z/A-Z) are all supported given the right
// base, so we mark these as Digits.
pub fn tokenize_int_test() {
  " \t\n\r\f\r\n+-abcdefghijklmnopqrstuvwxyz._ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(0, space),
    Whitespace(1, horizontal_tab),
    Whitespace(2, line_feed),
    Whitespace(3, carriage_return),
    Whitespace(4, form_feed),
    Whitespace(5, windows_newline),
    Sign(6, "+", True),
    Sign(7, "-", False),
    Digit(8, "a", 10),
    Digit(9, "b", 11),
    Digit(10, "c", 12),
    Digit(11, "d", 13),
    Digit(12, "e", 14),
    Digit(13, "f", 15),
    Digit(14, "g", 16),
    Digit(15, "h", 17),
    Digit(16, "i", 18),
    Digit(17, "j", 19),
    Digit(18, "k", 20),
    Digit(19, "l", 21),
    Digit(20, "m", 22),
    Digit(21, "n", 23),
    Digit(22, "o", 24),
    Digit(23, "p", 25),
    Digit(24, "q", 26),
    Digit(25, "r", 27),
    Digit(26, "s", 28),
    Digit(27, "t", 29),
    Digit(28, "u", 30),
    Digit(29, "v", 31),
    Digit(30, "w", 32),
    Digit(31, "x", 33),
    Digit(32, "y", 34),
    Digit(33, "z", 35),
    Unknown(34, "."),
    Underscore(35),
    Digit(36, "A", 10),
    Digit(37, "B", 11),
    Digit(38, "C", 12),
    Digit(39, "D", 13),
    Digit(40, "E", 14),
    Digit(41, "F", 15),
    Digit(42, "G", 16),
    Digit(43, "H", 17),
    Digit(44, "I", 18),
    Digit(45, "J", 19),
    Digit(46, "K", 20),
    Digit(47, "L", 21),
    Digit(48, "M", 22),
    Digit(49, "N", 23),
    Digit(50, "O", 24),
    Digit(51, "P", 25),
    Digit(52, "Q", 26),
    Digit(53, "R", 27),
    Digit(54, "S", 28),
    Digit(55, "T", 29),
    Digit(56, "U", 30),
    Digit(57, "V", 31),
    Digit(58, "W", 32),
    Digit(59, "X", 33),
    Digit(60, "Y", 34),
    Digit(61, "Z", 35),
  ])
}

pub fn tokenize_int_with_all_whitespace_characters_test() {
  let whitespace_character_strings = whitespace.character_dict() |> dict.to_list

  let expected_tokens =
    whitespace_character_strings
    |> list.index_map(fn(whitespace_data, index) {
      Whitespace(index, data: whitespace_data.1)
    })

  let whitespace_character_strings = whitespace.character_dict() |> dict.keys()

  whitespace_character_strings
  |> string.join("")
  |> tokenizer.tokenize_int
  |> expect.to_equal(expected_tokens)
}

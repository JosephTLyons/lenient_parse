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

// In Python's `float()`, only base 10 is supported. Any letter character
// (a-z/A-Z), outside of an exponent character, should be considered an Unknown.
pub fn tokenize_float_test() {
  " \t\n\r\f\r\n+-0123456789eE._abc"
  |> tokenizer.tokenize_float
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), horizontal_tab),
    Whitespace(#(2, 3), line_feed),
    Whitespace(#(3, 4), carriage_return),
    Whitespace(#(4, 5), form_feed),
    Whitespace(#(5, 6), windows_newline),
    Sign(#(6, 7), "+", True),
    Sign(#(7, 8), "-", False),
    Digit(#(8, 9), "0", 0),
    Digit(#(9, 10), "1", 1),
    Digit(#(10, 11), "2", 2),
    Digit(#(11, 12), "3", 3),
    Digit(#(12, 13), "4", 4),
    Digit(#(13, 14), "5", 5),
    Digit(#(14, 15), "6", 6),
    Digit(#(15, 16), "7", 7),
    Digit(#(16, 17), "8", 8),
    Digit(#(17, 18), "9", 9),
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
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), horizontal_tab),
    Whitespace(#(2, 3), line_feed),
    Whitespace(#(3, 4), carriage_return),
    Whitespace(#(4, 5), form_feed),
    Whitespace(#(5, 6), windows_newline),
    Sign(#(6, 7), "+", True),
    Sign(#(7, 8), "-", False),
    Digit(#(8, 9), "0", 0),
    Digit(#(9, 10), "1", 1),
    Digit(#(10, 11), "2", 2),
    Digit(#(11, 12), "3", 3),
    Digit(#(12, 13), "4", 4),
    Digit(#(13, 14), "5", 5),
    Digit(#(14, 15), "6", 6),
    Digit(#(15, 16), "7", 7),
    Digit(#(16, 17), "8", 8),
    Digit(#(17, 18), "9", 9),
    Digit(#(18, 19), "e", 14),
    Digit(#(19, 20), "E", 14),
    Unknown(#(20, 21), "."),
    Underscore(#(21, 22)),
    Digit(#(22, 23), "a", 10),
    Digit(#(23, 24), "b", 11),
    Digit(#(24, 25), "c", 12),
    Digit(#(25, 26), "Z", 35),
  ])
}

pub fn tokenize_int_base_2_test() {
  "0102101"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "1", 1),
    Digit(#(2, 3), "0", 0),
    Digit(#(3, 4), "2", 2),
    Digit(#(4, 5), "1", 1),
    Digit(#(5, 6), "0", 0),
    Digit(#(6, 7), "1", 1),
  ])
}

pub fn tokenize_int_base_16_test() {
  "dead_beefZ"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "d", 0xD),
    Digit(#(1, 2), "e", 0xE),
    Digit(#(2, 3), "a", 0xA),
    Digit(#(3, 4), "d", 0xD),
    Underscore(#(4, 5)),
    Digit(#(5, 6), "b", 0xB),
    Digit(#(6, 7), "e", 0xE),
    Digit(#(7, 8), "e", 0xE),
    Digit(#(8, 9), "f", 0xF),
    Digit(#(9, 10), "Z", 35),
  ])
}

pub fn tokenize_int_base_35_test() {
  "1234567890abcdefghijklmnopqrstuvwxyz"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "1", 1),
    Digit(#(1, 2), "2", 2),
    Digit(#(2, 3), "3", 3),
    Digit(#(3, 4), "4", 4),
    Digit(#(4, 5), "5", 5),
    Digit(#(5, 6), "6", 6),
    Digit(#(6, 7), "7", 7),
    Digit(#(7, 8), "8", 8),
    Digit(#(8, 9), "9", 9),
    Digit(#(9, 10), "0", 0),
    Digit(#(10, 11), "a", 10),
    Digit(#(11, 12), "b", 11),
    Digit(#(12, 13), "c", 12),
    Digit(#(13, 14), "d", 13),
    Digit(#(14, 15), "e", 14),
    Digit(#(15, 16), "f", 15),
    Digit(#(16, 17), "g", 16),
    Digit(#(17, 18), "h", 17),
    Digit(#(18, 19), "i", 18),
    Digit(#(19, 20), "j", 19),
    Digit(#(20, 21), "k", 20),
    Digit(#(21, 22), "l", 21),
    Digit(#(22, 23), "m", 22),
    Digit(#(23, 24), "n", 23),
    Digit(#(24, 25), "o", 24),
    Digit(#(25, 26), "p", 25),
    Digit(#(26, 27), "q", 26),
    Digit(#(27, 28), "r", 27),
    Digit(#(28, 29), "s", 28),
    Digit(#(29, 30), "t", 29),
    Digit(#(30, 31), "u", 30),
    Digit(#(31, 32), "v", 31),
    Digit(#(32, 33), "w", 32),
    Digit(#(33, 34), "x", 33),
    Digit(#(34, 35), "y", 34),
    Digit(#(35, 36), "z", 35),
  ])
}

pub fn tokenize_int_base_36_test() {
  "159az"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "1", 1),
    Digit(#(1, 2), "5", 5),
    Digit(#(2, 3), "9", 9),
    Digit(#(3, 4), "a", 10),
    Digit(#(4, 5), "z", 35),
  ])
}

pub fn tokenize_int_with_0b_prefix_and_base_0_test() {
  "   0b1010b"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), space),
    Whitespace(#(2, 3), space),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "b", 11),
    Digit(#(5, 6), "1", 1),
    Digit(#(6, 7), "0", 0),
    Digit(#(7, 8), "1", 1),
    Digit(#(8, 9), "0", 0),
    Digit(#(9, 10), "b", 11),
  ])
}

pub fn tokenize_int_with_0o_prefix_and_base_0_test() {
  "   0o0123456780o"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), space),
    Whitespace(#(2, 3), space),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "o", 24),
    Digit(#(5, 6), "0", 0),
    Digit(#(6, 7), "1", 1),
    Digit(#(7, 8), "2", 2),
    Digit(#(8, 9), "3", 3),
    Digit(#(9, 10), "4", 4),
    Digit(#(10, 11), "5", 5),
    Digit(#(11, 12), "6", 6),
    Digit(#(12, 13), "7", 7),
    Digit(#(13, 14), "8", 8),
    Digit(#(14, 15), "0", 0),
    Digit(#(15, 16), "o", 24),
  ])
}

pub fn tokenize_int_with_0x_prefix_and_base_0_test() {
  " +0XDEAD_BEEF0x "
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Sign(#(1, 2), "+", True),
    Digit(#(2, 3), "0", 0),
    Digit(#(3, 4), "X", 33),
    Digit(#(4, 5), "D", 13),
    Digit(#(5, 6), "E", 14),
    Digit(#(6, 7), "A", 10),
    Digit(#(7, 8), "D", 13),
    Underscore(#(8, 9)),
    Digit(#(9, 10), "B", 11),
    Digit(#(10, 11), "E", 14),
    Digit(#(11, 12), "E", 14),
    Digit(#(12, 13), "F", 15),
    Digit(#(13, 14), "0", 0),
    Digit(#(14, 15), "x", 33),
    Whitespace(#(15, 16), space),
  ])
}

pub fn tokenize_int_with_0b_prefix_and_base_2_test() {
  "   0b1010 a"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), space),
    Whitespace(#(2, 3), space),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "b", 11),
    Digit(#(5, 6), "1", 1),
    Digit(#(6, 7), "0", 0),
    Digit(#(7, 8), "1", 1),
    Digit(#(8, 9), "0", 0),
    Whitespace(#(9, 10), space),
    Digit(#(10, 11), "a", 10),
  ])
}

pub fn tokenize_int_with_0o_prefix_and_base_8_test() {
  "   0o77 a"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), space),
    Whitespace(#(2, 3), space),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "o", 24),
    Digit(#(5, 6), "7", 7),
    Digit(#(6, 7), "7", 7),
    Whitespace(#(7, 8), space),
    Digit(#(8, 9), "a", 10),
  ])
}

pub fn tokenize_int_with_0x_prefix_and_base_16_test() {
  "   0x_ABC ."
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), space),
    Whitespace(#(2, 3), space),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "x", 33),
    Underscore(#(5, 6)),
    Digit(#(6, 7), "A", 10),
    Digit(#(7, 8), "B", 11),
    Digit(#(8, 9), "C", 12),
    Whitespace(#(9, 10), space),
    Unknown(#(10, 11), "."),
  ])
}

// ---- Uppercase / lowercase prefix with base 0 tests

pub fn tokenize_int_with_lowercase_binary_prefix_and_base_0_test() {
  "0b101"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "b", 11),
    Digit(#(2, 3), "1", 1),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "1", 1),
  ])
}

pub fn tokenize_int_with_uppercase_binary_prefix_and_base_0_test() {
  "0B101"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "B", 11),
    Digit(#(2, 3), "1", 1),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "1", 1),
  ])
}

pub fn tokenize_int_with_lowercase_octal_prefix_and_base_0_test() {
  "0o777"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "o", 24),
    Digit(#(2, 3), "7", 7),
    Digit(#(3, 4), "7", 7),
    Digit(#(4, 5), "7", 7),
  ])
}

pub fn tokenize_int_with_uppercase_octal_prefix_and_base_0_test() {
  "0O777"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "O", 24),
    Digit(#(2, 3), "7", 7),
    Digit(#(3, 4), "7", 7),
    Digit(#(4, 5), "7", 7),
  ])
}

pub fn tokenize_int_with_lowercase_hexadecimal_prefix_and_base_0_test() {
  "0xABC"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "x", 33),
    Digit(#(2, 3), "A", 10),
    Digit(#(3, 4), "B", 11),
    Digit(#(4, 5), "C", 12),
  ])
}

pub fn tokenize_int_with_uppercase_hexadecimal_prefix_and_base_0_test() {
  "0XABC"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "X", 33),
    Digit(#(2, 3), "A", 10),
    Digit(#(3, 4), "B", 11),
    Digit(#(4, 5), "C", 12),
  ])
}

pub fn tokenize_int_with_no_prefix_and_base_0_test() {
  "  \n+1990_04_12.0e4 "
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Whitespace(#(0, 1), space),
    Whitespace(#(1, 2), space),
    Whitespace(#(2, 3), line_feed),
    Sign(#(3, 4), "+", True),
    Digit(#(4, 5), "1", 1),
    Digit(#(5, 6), "9", 9),
    Digit(#(6, 7), "9", 9),
    Digit(#(7, 8), "0", 0),
    Underscore(#(8, 9)),
    Digit(#(9, 10), "0", 0),
    Digit(#(10, 11), "4", 4),
    Underscore(#(11, 12)),
    Digit(#(12, 13), "1", 1),
    Digit(#(13, 14), "2", 2),
    Unknown(#(14, 15), "."),
    Digit(#(15, 16), "0", 0),
    Digit(#(16, 17), "e", 14),
    Digit(#(17, 18), "4", 4),
    Whitespace(#(18, 19), space),
  ])
}

// ---- Tests for matching base prefixes and specified bases

pub fn tokenize_int_with_base_2_and_binary_prefix_test() {
  "0b101"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "b", 11),
    Digit(#(2, 3), "1", 1),
    Digit(#(3, 4), "0", 0),
    Digit(#(4, 5), "1", 1),
  ])
}

pub fn tokenize_int_with_base_8_and_octal_prefix_test() {
  "0o777"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "o", 24),
    Digit(#(2, 3), "7", 7),
    Digit(#(3, 4), "7", 7),
    Digit(#(4, 5), "7", 7),
  ])
}

pub fn tokenize_int_with_base_16_and_hexadecimal_prefix_test() {
  "0xABC"
  |> tokenizer.tokenize_int
  |> expect.to_equal([
    Digit(#(0, 1), "0", 0),
    Digit(#(1, 2), "x", 33),
    Digit(#(2, 3), "A", 10),
    Digit(#(3, 4), "B", 11),
    Digit(#(4, 5), "C", 12),
  ])
}

// ---- Tests for all whitespace characters

pub fn tokenize_int_with_all_whitespace_characters_test() {
  let whitespace_character_strings = whitespace.character_dict() |> dict.to_list

  let expected_tokens =
    whitespace_character_strings
    |> list.index_map(fn(whitespace_data, index) {
      Whitespace(#(index, index + 1), data: whitespace_data.1)
    })

  let whitespace_character_strings = whitespace.character_dict() |> dict.keys()

  whitespace_character_strings
  |> string.join("")
  |> tokenizer.tokenize_int
  |> expect.to_equal(expected_tokens)
}

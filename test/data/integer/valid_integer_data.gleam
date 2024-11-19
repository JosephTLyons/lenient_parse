import gleam/dict
import gleam/list
import gleam/string
import lenient_parse/internal/base_constants.{
  base_0, base_10, base_16, base_2, base_8,
}
import lenient_parse/internal/whitespace
import test_data.{type IntegerTestData, IntegerTestData}

fn valid_simple() -> List(IntegerTestData) {
  [
    IntegerTestData(
      input: "1",
      base: base_10,
      expected_program_output: Ok(1),
      expected_python_output: Ok("1"),
    ),
    IntegerTestData(
      input: "+123",
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: "-123",
      base: base_10,
      expected_program_output: Ok(-123),
      expected_python_output: Ok("-123"),
    ),
    IntegerTestData(
      input: "0123",
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: "9876",
      base: base_10,
      expected_program_output: Ok(9876),
      expected_python_output: Ok("9876"),
    ),
    IntegerTestData(
      input: "-10",
      base: base_10,
      expected_program_output: Ok(-10),
      expected_python_output: Ok("-10"),
    ),
    IntegerTestData(
      input: "01_32",
      base: 4,
      expected_program_output: Ok(30),
      expected_python_output: Ok("30"),
    ),
    IntegerTestData(
      input: "+0",
      base: base_10,
      expected_program_output: Ok(0),
      expected_python_output: Ok("0"),
    ),
    IntegerTestData(
      input: "42",
      base: base_10,
      expected_program_output: Ok(42),
      expected_python_output: Ok("42"),
    ),
    IntegerTestData(
      input: "-987654",
      base: base_10,
      expected_program_output: Ok(-987_654),
      expected_python_output: Ok("-987654"),
    ),
  ]
}

fn valid_simple_base_2() -> List(IntegerTestData) {
  [
    IntegerTestData(
      input: "0",
      base: base_2,
      expected_program_output: Ok(0),
      expected_python_output: Ok("0"),
    ),
    IntegerTestData(
      input: "101",
      base: base_2,
      expected_program_output: Ok(0b101),
      expected_python_output: Ok("5"),
    ),
    IntegerTestData(
      input: "11111",
      base: base_2,
      expected_program_output: Ok(0b11111),
      expected_python_output: Ok("31"),
    ),
    IntegerTestData(
      input: "-11111",
      base: base_2,
      expected_program_output: Ok(-31),
      expected_python_output: Ok("-31"),
    ),
    IntegerTestData(
      input: "  1_1_1  ",
      base: base_2,
      expected_program_output: Ok(0b111),
      expected_python_output: Ok("7"),
    ),
  ]
}

fn valid_simple_base_8() -> List(IntegerTestData) {
  [
    IntegerTestData(
      input: "0",
      base: base_8,
      expected_program_output: Ok(0),
      expected_python_output: Ok("0"),
    ),
    IntegerTestData(
      input: "77",
      base: base_8,
      expected_program_output: Ok(0o77),
      expected_python_output: Ok("63"),
    ),
  ]
}

fn valid_simple_base_16() -> List(IntegerTestData) {
  [
    IntegerTestData(
      input: "DEAD_BEEF",
      base: base_16,
      expected_program_output: Ok(0xDEADBEEF),
      expected_python_output: Ok("3735928559"),
    ),
    IntegerTestData(
      input: "ABCDEF",
      base: base_16,
      expected_program_output: Ok(0xABCDEF),
      expected_python_output: Ok("11259375"),
    ),
  ]
}

fn valid_simple_base_prefix() -> List(IntegerTestData) {
  [
    // Base 0, has lowercase binary prefix
    IntegerTestData(
      input: "0b10",
      base: base_0,
      expected_program_output: Ok(0b10),
      expected_python_output: Ok("2"),
    ),
    // Base 0, has uppercase binary prefix
    IntegerTestData(
      input: "0B10",
      base: base_0,
      expected_program_output: Ok(0b10),
      expected_python_output: Ok("2"),
    ),
    // Base 0, has lowercase octal prefix
    IntegerTestData(
      input: "0o01234",
      base: base_0,
      expected_program_output: Ok(0o01234),
      expected_python_output: Ok("668"),
    ),
    // Base 0, has uppercase octal prefix
    IntegerTestData(
      input: "0O01234",
      base: base_0,
      expected_program_output: Ok(0o01234),
      expected_python_output: Ok("668"),
    ),
    // Base 0, has lowercase hexadecimal prefix
    IntegerTestData(
      input: "0xDEADBEEF",
      base: base_0,
      expected_program_output: Ok(0xDEADBEEF),
      expected_python_output: Ok("3735928559"),
    ),
    // Base 0, has uppercase hexadecimal prefix
    IntegerTestData(
      input: "0XDEADBEEF",
      base: base_0,
      expected_program_output: Ok(0xDEADBEEF),
      expected_python_output: Ok("3735928559"),
    ),
    // Base 0, has no prefix, default to decimal
    IntegerTestData(
      input: " \n6_666",
      base: base_0,
      expected_program_output: Ok(6666),
      expected_python_output: Ok("6666"),
    ),
    // Base 0, has lowercase hexadecimal prefix, and an underscore between the prefix and the number
    IntegerTestData(
      input: "0x_DEAD_BEEF",
      base: base_0,
      expected_program_output: Ok(0xDEADBEEF),
      expected_python_output: Ok("3735928559"),
    ),
    // Base 0, has uppercase hexadecimal prefix, and an underscore between the prefix and the number
    IntegerTestData(
      input: "0X_DEAD_BEEF",
      base: base_0,
      expected_program_output: Ok(0xDEADBEEF),
      expected_python_output: Ok("3735928559"),
    ),
    // Base 2 and has lowercase binary prefix
    IntegerTestData(
      input: "0b1001",
      base: base_2,
      expected_program_output: Ok(0b1001),
      expected_python_output: Ok("9"),
    ),
    // Base 2 and has uppercase binary prefix
    IntegerTestData(
      input: "0B1001",
      base: base_2,
      expected_program_output: Ok(0b1001),
      expected_python_output: Ok("9"),
    ),
    // Base 8 and has lowercase octal prefix
    IntegerTestData(
      input: "0o777",
      base: base_8,
      expected_program_output: Ok(0o777),
      expected_python_output: Ok("511"),
    ),
    // Base 8 and has uppercase octal prefix
    IntegerTestData(
      input: "0O777",
      base: base_8,
      expected_program_output: Ok(0o777),
      expected_python_output: Ok("511"),
    ),
    // Base 16 and has lowercase hexadecimal prefix
    IntegerTestData(
      input: "0xDEAD_BEEF",
      base: base_16,
      expected_program_output: Ok(0xDEAD_BEEF),
      expected_python_output: Ok("3735928559"),
    ),
    // Base 16 and has uppercase hexadecimal prefix
    IntegerTestData(
      input: "0XDEAD_BEEF",
      base: base_16,
      expected_program_output: Ok(0xDEAD_BEEF),
      expected_python_output: Ok("3735928559"),
    ),
  ]
}

fn valid_underscore() -> List(IntegerTestData) {
  [
    IntegerTestData(
      input: "1_000",
      base: base_10,
      expected_program_output: Ok(1000),
      expected_python_output: Ok("1000"),
    ),
    IntegerTestData(
      input: "1_000_000",
      base: base_10,
      expected_program_output: Ok(1_000_000),
      expected_python_output: Ok("1000000"),
    ),
    IntegerTestData(
      input: "1_234_567_890",
      base: base_10,
      expected_program_output: Ok(1_234_567_890),
      expected_python_output: Ok("1234567890"),
    ),
    IntegerTestData(
      input: "-1_000_000",
      base: base_10,
      expected_program_output: Ok(-1_000_000),
      expected_python_output: Ok("-1000000"),
    ),
    IntegerTestData(
      input: "+1_234_567",
      base: base_10,
      expected_program_output: Ok(1_234_567),
      expected_python_output: Ok("1234567"),
    ),
    IntegerTestData(
      input: "9_876_543_210",
      base: base_10,
      expected_program_output: Ok(9_876_543_210),
      expected_python_output: Ok("9876543210"),
    ),
  ]
}

fn valid_whitespace() -> List(IntegerTestData) {
  let all_whitespace_characters_string =
    whitespace.character_dict() |> dict.keys |> string.join("")

  [
    IntegerTestData(
      input: " +123 ",
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: " -123 ",
      base: base_10,
      expected_program_output: Ok(-123),
      expected_python_output: Ok("-123"),
    ),
    IntegerTestData(
      input: " 0123",
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: " 1 ",
      base: base_10,
      expected_program_output: Ok(1),
      expected_python_output: Ok("1"),
    ),
    IntegerTestData(
      input: "42 ",
      base: base_10,
      expected_program_output: Ok(42),
      expected_python_output: Ok("42"),
    ),
    IntegerTestData(
      input: " +0 ",
      base: base_10,
      expected_program_output: Ok(0),
      expected_python_output: Ok("0"),
    ),
    IntegerTestData(
      input: "  -987  ",
      base: base_10,
      expected_program_output: Ok(-987),
      expected_python_output: Ok("-987"),
    ),
    IntegerTestData(
      input: "\t123\t",
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: "\n456\n",
      base: base_10,
      expected_program_output: Ok(456),
      expected_python_output: Ok("456"),
    ),
    // Unicode cases
    IntegerTestData(
      input: whitespace.horizontal_tab.character
        <> "789"
        <> whitespace.horizontal_tab.character,
      base: base_10,
      expected_program_output: Ok(789),
      expected_python_output: Ok("789"),
    ),
    IntegerTestData(
      input: whitespace.line_feed.character
        <> "123"
        <> whitespace.line_feed.character,
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: whitespace.vertical_tab.character
        <> "234"
        <> whitespace.vertical_tab.character,
      base: base_10,
      expected_program_output: Ok(234),
      expected_python_output: Ok("234"),
    ),
    IntegerTestData(
      input: whitespace.form_feed.character
        <> "345"
        <> whitespace.form_feed.character,
      base: base_10,
      expected_program_output: Ok(345),
      expected_python_output: Ok("345"),
    ),
    IntegerTestData(
      input: whitespace.carriage_return.character
        <> "567"
        <> whitespace.carriage_return.character,
      base: base_10,
      expected_program_output: Ok(567),
      expected_python_output: Ok("567"),
    ),
    IntegerTestData(
      input: whitespace.space.character <> "678" <> whitespace.space.character,
      base: base_10,
      expected_program_output: Ok(678),
      expected_python_output: Ok("678"),
    ),
    IntegerTestData(
      input: whitespace.next_line.character
        <> "890"
        <> whitespace.next_line.character,
      base: base_10,
      expected_program_output: Ok(890),
      expected_python_output: Ok("890"),
    ),
    IntegerTestData(
      input: whitespace.no_break_space.character
        <> "901"
        <> whitespace.no_break_space.character,
      base: base_10,
      expected_program_output: Ok(901),
      expected_python_output: Ok("901"),
    ),
    IntegerTestData(
      input: whitespace.ogham_space_mark.character
        <> "012"
        <> whitespace.ogham_space_mark.character,
      base: base_10,
      expected_program_output: Ok(12),
      expected_python_output: Ok("12"),
    ),
    IntegerTestData(
      input: whitespace.en_quad.character
        <> "123"
        <> whitespace.en_quad.character,
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: whitespace.em_quad.character
        <> "234"
        <> whitespace.em_quad.character,
      base: base_10,
      expected_program_output: Ok(234),
      expected_python_output: Ok("234"),
    ),
    IntegerTestData(
      input: whitespace.en_space.character
        <> "345"
        <> whitespace.en_space.character,
      base: base_10,
      expected_program_output: Ok(345),
      expected_python_output: Ok("345"),
    ),
    IntegerTestData(
      input: whitespace.em_space.character
        <> "567"
        <> whitespace.em_space.character,
      base: base_10,
      expected_program_output: Ok(567),
      expected_python_output: Ok("567"),
    ),
    IntegerTestData(
      input: whitespace.three_per_em_space.character
        <> "678"
        <> whitespace.three_per_em_space.character,
      base: base_10,
      expected_program_output: Ok(678),
      expected_python_output: Ok("678"),
    ),
    IntegerTestData(
      input: whitespace.four_per_em_space.character
        <> "789"
        <> whitespace.four_per_em_space.character,
      base: base_10,
      expected_program_output: Ok(789),
      expected_python_output: Ok("789"),
    ),
    IntegerTestData(
      input: whitespace.six_per_em_space.character
        <> "890"
        <> whitespace.six_per_em_space.character,
      base: base_10,
      expected_program_output: Ok(890),
      expected_python_output: Ok("890"),
    ),
    IntegerTestData(
      input: whitespace.figure_space.character
        <> "901"
        <> whitespace.figure_space.character,
      base: base_10,
      expected_program_output: Ok(901),
      expected_python_output: Ok("901"),
    ),
    IntegerTestData(
      input: whitespace.punctuation_space.character
        <> "012"
        <> whitespace.punctuation_space.character,
      base: base_10,
      expected_program_output: Ok(12),
      expected_python_output: Ok("12"),
    ),
    IntegerTestData(
      input: whitespace.thin_space.character
        <> "123"
        <> whitespace.thin_space.character,
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: whitespace.hair_space.character
        <> "234"
        <> whitespace.hair_space.character,
      base: base_10,
      expected_program_output: Ok(234),
      expected_python_output: Ok("234"),
    ),
    IntegerTestData(
      input: whitespace.line_separator.character
        <> "345"
        <> whitespace.line_separator.character,
      base: base_10,
      expected_program_output: Ok(345),
      expected_python_output: Ok("345"),
    ),
    IntegerTestData(
      input: whitespace.paragraph_separator.character
        <> "567"
        <> whitespace.paragraph_separator.character,
      base: base_10,
      expected_program_output: Ok(567),
      expected_python_output: Ok("567"),
    ),
    IntegerTestData(
      input: whitespace.narrow_no_break_space.character
        <> "678"
        <> whitespace.narrow_no_break_space.character,
      base: base_10,
      expected_program_output: Ok(678),
      expected_python_output: Ok("678"),
    ),
    IntegerTestData(
      input: whitespace.medium_mathematical_space.character
        <> "789"
        <> whitespace.medium_mathematical_space.character,
      base: base_10,
      expected_program_output: Ok(789),
      expected_python_output: Ok("789"),
    ),
    IntegerTestData(
      input: whitespace.ideographic_space.character
        <> "890"
        <> whitespace.ideographic_space.character,
      base: base_10,
      expected_program_output: Ok(890),
      expected_python_output: Ok("890"),
    ),
    IntegerTestData(
      input: whitespace.windows_newline.character
        <> "123"
        <> whitespace.windows_newline.character,
      base: base_10,
      expected_program_output: Ok(123),
      expected_python_output: Ok("123"),
    ),
    IntegerTestData(
      input: all_whitespace_characters_string
        <> "666"
        <> all_whitespace_characters_string,
      base: base_10,
      expected_program_output: Ok(666),
      expected_python_output: Ok("666"),
    ),
  ]
}

pub fn data() -> List(IntegerTestData) {
  [
    valid_simple(),
    valid_simple_base_2(),
    valid_simple_base_8(),
    valid_simple_base_16(),
    valid_underscore(),
    valid_whitespace(),
    valid_simple_base_prefix(),
  ]
  |> list.flatten
}

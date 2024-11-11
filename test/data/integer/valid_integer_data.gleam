import gleam/list
import test_data.{type IntegerTestData, IntegerTestData}

// TODO: Comment all test data, put into one list?
// TODO: Rename all lists to make more sense
const simple_integer: List(IntegerTestData) = [
  IntegerTestData(
    input: "1",
    base: 10,
    expected_program_output: Ok(1),
    expected_python_output: Ok("1"),
  ),
  IntegerTestData(
    input: "+123",
    base: 10,
    expected_program_output: Ok(123),
    expected_python_output: Ok("123"),
  ),
  IntegerTestData(
    input: "-123",
    base: 10,
    expected_program_output: Ok(-123),
    expected_python_output: Ok("-123"),
  ),
  IntegerTestData(
    input: "0123",
    base: 10,
    expected_program_output: Ok(123),
    expected_python_output: Ok("123"),
  ),
  IntegerTestData(
    input: "9876",
    base: 10,
    expected_program_output: Ok(9876),
    expected_python_output: Ok("9876"),
  ),
  IntegerTestData(
    input: "-10",
    base: 10,
    expected_program_output: Ok(-10),
    expected_python_output: Ok("-10"),
  ),
  IntegerTestData(
    input: "+0",
    base: 10,
    expected_program_output: Ok(0),
    expected_python_output: Ok("0"),
  ),
  IntegerTestData(
    input: "42",
    base: 10,
    expected_program_output: Ok(42),
    expected_python_output: Ok("42"),
  ),
  IntegerTestData(
    input: "-987654",
    base: 10,
    expected_program_output: Ok(-987_654),
    expected_python_output: Ok("-987654"),
  ),
]

const integer_with_underscore: List(IntegerTestData) = [
  IntegerTestData(
    input: "1_000",
    base: 10,
    expected_program_output: Ok(1000),
    expected_python_output: Ok("1000"),
  ),
  IntegerTestData(
    input: "1_000_000",
    base: 10,
    expected_program_output: Ok(1_000_000),
    expected_python_output: Ok("1000000"),
  ),
  IntegerTestData(
    input: "1_234_567_890",
    base: 10,
    expected_program_output: Ok(1_234_567_890),
    expected_python_output: Ok("1234567890"),
  ),
  IntegerTestData(
    input: "-1_000_000",
    base: 10,
    expected_program_output: Ok(-1_000_000),
    expected_python_output: Ok("-1000000"),
  ),
  IntegerTestData(
    input: "+1_234_567",
    base: 10,
    expected_program_output: Ok(1_234_567),
    expected_python_output: Ok("1234567"),
  ),
  IntegerTestData(
    input: "9_876_543_210",
    base: 10,
    expected_program_output: Ok(9_876_543_210),
    expected_python_output: Ok("9876543210"),
  ),
]

const integer_with_whitespace: List(IntegerTestData) = [
  IntegerTestData(
    input: " +123 ",
    base: 10,
    expected_program_output: Ok(123),
    expected_python_output: Ok("123"),
  ),
  IntegerTestData(
    input: " -123 ",
    base: 10,
    expected_program_output: Ok(-123),
    expected_python_output: Ok("-123"),
  ),
  IntegerTestData(
    input: " 0123",
    base: 10,
    expected_program_output: Ok(123),
    expected_python_output: Ok("123"),
  ),
  IntegerTestData(
    input: " 1 ",
    base: 10,
    expected_program_output: Ok(1),
    expected_python_output: Ok("1"),
  ),
  IntegerTestData(
    input: "42 ",
    base: 10,
    expected_program_output: Ok(42),
    expected_python_output: Ok("42"),
  ),
  IntegerTestData(
    input: " +0 ",
    base: 10,
    expected_program_output: Ok(0),
    expected_python_output: Ok("0"),
  ),
  IntegerTestData(
    input: "  -987  ",
    base: 10,
    expected_program_output: Ok(-987),
    expected_python_output: Ok("-987"),
  ),
  IntegerTestData(
    input: "\t123\t",
    base: 10,
    expected_program_output: Ok(123),
    expected_python_output: Ok("123"),
  ),
  IntegerTestData(
    input: "\n456\n",
    base: 10,
    expected_program_output: Ok(456),
    expected_python_output: Ok("456"),
  ),
]

const simple_integer_base_2: List(IntegerTestData) = [
  IntegerTestData(
    input: "0",
    base: 2,
    expected_program_output: Ok(0),
    expected_python_output: Ok("0"),
  ),
  IntegerTestData(
    input: "101",
    base: 2,
    expected_program_output: Ok(0b101),
    expected_python_output: Ok("5"),
  ),
  IntegerTestData(
    input: "11111",
    base: 2,
    expected_program_output: Ok(0b11111),
    expected_python_output: Ok("31"),
  ),
  IntegerTestData(
    input: "-11111",
    base: 2,
    expected_program_output: Ok(-31),
    expected_python_output: Ok("-31"),
  ),
  IntegerTestData(
    input: "  1_1_1  ",
    base: 2,
    expected_program_output: Ok(0b111),
    expected_python_output: Ok("7"),
  ),
]

const simple_integer_base_8: List(IntegerTestData) = [
  IntegerTestData(
    input: "0",
    base: 8,
    expected_program_output: Ok(0),
    expected_python_output: Ok("0"),
  ),
  IntegerTestData(
    input: "77",
    base: 8,
    expected_program_output: Ok(0o77),
    expected_python_output: Ok("63"),
  ),
]

const simple_integer_base_16: List(IntegerTestData) = [
  IntegerTestData(
    input: "DEAD_BEEF",
    base: 16,
    expected_program_output: Ok(0xDEADBEEF),
    expected_python_output: Ok("3735928559"),
  ),
  IntegerTestData(
    input: "ABCDEF",
    base: 16,
    expected_program_output: Ok(0xABCDEF),
    expected_python_output: Ok("11259375"),
  ),
]

const simple_base_prefix: List(IntegerTestData) = [
  // Base 0, has binary prefix
  IntegerTestData(
    input: "0b10",
    base: 0,
    expected_program_output: Ok(0b10),
    expected_python_output: Ok("2"),
  ),
  // Base 0, has prefix, and an underscore between the prefix and the number
  // IntegerTestData(
  //   input: "0x_DEAD_BEEF",
  //   base: 0,
  //   expected_program_output: Ok(0xDEADBEEF),
  //   expected_python_output: Ok("3735928559"),
  // ),
  // Base 0, has no prefix, default to decimal
  IntegerTestData(
    input: " \n6_666",
    base: 0,
    expected_program_output: Ok(6666),
    expected_python_output: Ok("6666"),
  ),
  // Base 2 and also has binary prefix
  IntegerTestData(
    input: "0b1001",
    base: 2,
    expected_program_output: Ok(0b1001),
    expected_python_output: Ok("9"),
  ),
  // Base 8 and also has octal prefix
  IntegerTestData(
    input: "0o777",
    base: 8,
    expected_program_output: Ok(0o777),
    expected_python_output: Ok("511"),
  ),
  // Base 16 and also has hexadecimal prefix
  IntegerTestData(
    input: "0xDEAD_BEEF",
    base: 16,
    expected_program_output: Ok(0xDEAD_BEEF),
    expected_python_output: Ok("3735928559"),
  ),
  // Base 0, has octal prefix
  IntegerTestData(
    input: "0o01234",
    base: 0,
    expected_program_output: Ok(0o01234),
    expected_python_output: Ok("668"),
  ),
  // Base 0, has hexadecimal prefix
  IntegerTestData(
    input: "0xDEADBEEF",
    base: 0,
    expected_program_output: Ok(0xDEADBEEF),
    expected_python_output: Ok("3735928559"),
  ),
]

pub fn data() -> List(IntegerTestData) {
  [
    simple_integer,
    simple_integer_base_2,
    simple_integer_base_8,
    simple_integer_base_16,
    integer_with_underscore,
    integer_with_whitespace,
    simple_base_prefix,
  ]
  |> list.flatten
}

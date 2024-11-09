import gleam/list
import test_data.{type IntegerTestData, IntegerTestData}

const valid_simple_integers: List(IntegerTestData) = [
  IntegerTestData(input: "1", base: 10, output: Ok(1), python_output: Ok("1")),
  IntegerTestData(
    input: "+123",
    base: 10,
    output: Ok(123),
    python_output: Ok("123"),
  ),
  IntegerTestData(
    input: "-123",
    base: 10,
    output: Ok(-123),
    python_output: Ok("-123"),
  ),
  IntegerTestData(
    input: "0123",
    base: 10,
    output: Ok(123),
    python_output: Ok("123"),
  ),
  IntegerTestData(
    input: "9876",
    base: 10,
    output: Ok(9876),
    python_output: Ok("9876"),
  ),
  IntegerTestData(
    input: "-10",
    base: 10,
    output: Ok(-10),
    python_output: Ok("-10"),
  ),
  IntegerTestData(input: "+0", base: 10, output: Ok(0), python_output: Ok("0")),
  IntegerTestData(
    input: "42",
    base: 10,
    output: Ok(42),
    python_output: Ok("42"),
  ),
  IntegerTestData(
    input: "-987654",
    base: 10,
    output: Ok(-987_654),
    python_output: Ok("-987654"),
  ),
]

const valid_integers_with_underscores: List(IntegerTestData) = [
  IntegerTestData(
    input: "1_000",
    base: 10,
    output: Ok(1000),
    python_output: Ok("1000"),
  ),
  IntegerTestData(
    input: "1_000_000",
    base: 10,
    output: Ok(1_000_000),
    python_output: Ok("1000000"),
  ),
  IntegerTestData(
    input: "1_234_567_890",
    base: 10,
    output: Ok(1_234_567_890),
    python_output: Ok("1234567890"),
  ),
  IntegerTestData(
    input: "-1_000_000",
    base: 10,
    output: Ok(-1_000_000),
    python_output: Ok("-1000000"),
  ),
  IntegerTestData(
    input: "+1_234_567",
    base: 10,
    output: Ok(1_234_567),
    python_output: Ok("1234567"),
  ),
  IntegerTestData(
    input: "9_876_543_210",
    base: 10,
    output: Ok(9_876_543_210),
    python_output: Ok("9876543210"),
  ),
]

const valid_integers_with_whitespace: List(IntegerTestData) = [
  IntegerTestData(
    input: " +123 ",
    base: 10,
    output: Ok(123),
    python_output: Ok("123"),
  ),
  IntegerTestData(
    input: " -123 ",
    base: 10,
    output: Ok(-123),
    python_output: Ok("-123"),
  ),
  IntegerTestData(
    input: " 0123",
    base: 10,
    output: Ok(123),
    python_output: Ok("123"),
  ),
  IntegerTestData(input: " 1 ", base: 10, output: Ok(1), python_output: Ok("1")),
  IntegerTestData(
    input: "42 ",
    base: 10,
    output: Ok(42),
    python_output: Ok("42"),
  ),
  IntegerTestData(
    input: " +0 ",
    base: 10,
    output: Ok(0),
    python_output: Ok("0"),
  ),
  IntegerTestData(
    input: "  -987  ",
    base: 10,
    output: Ok(-987),
    python_output: Ok("-987"),
  ),
  IntegerTestData(
    input: "\t123\t",
    base: 10,
    output: Ok(123),
    python_output: Ok("123"),
  ),
  IntegerTestData(
    input: "\n456\n",
    base: 10,
    output: Ok(456),
    python_output: Ok("456"),
  ),
]

const valid_simple_integers_base_2: List(IntegerTestData) = [
  IntegerTestData(input: "0", base: 2, output: Ok(0), python_output: Ok("0")),
  IntegerTestData(
    input: "101",
    base: 2,
    output: Ok(0b101),
    python_output: Ok("5"),
  ),
  IntegerTestData(
    input: "11111",
    base: 2,
    output: Ok(0b11111),
    python_output: Ok("31"),
  ),
  IntegerTestData(
    input: "-11111",
    base: 2,
    output: Ok(-31),
    python_output: Ok("-31"),
  ),
]

const valid_simple_integers_base_8: List(IntegerTestData) = [
  IntegerTestData(input: "0", base: 8, output: Ok(0), python_output: Ok("0")),
  IntegerTestData(
    input: "77",
    base: 8,
    output: Ok(0o77),
    python_output: Ok("63"),
  ),
]

const valid_simple_integers_with_inferred_base: List(IntegerTestData) = [
  // IntegerTestData(
//   input: "0b11111",
//   base: 0,
//   output: Ok(31),
//   python_output: Ok("31"),
// ),
// IntegerTestData(
//   input: "0o377",
//   base: 0,
//   output: Ok(255),
//   python_output: Ok("255"),
// ),
// IntegerTestData(
//   input: "0xdeadbeef",
//   base: 0,
//   output: Ok(0xDEADBEEF),
//   python_output: Ok("3735928559"),
// ),
]

const valid_simple_integers_base_16: List(IntegerTestData) = [
  IntegerTestData(
    input: "DEAD_BEEF",
    base: 16,
    output: Ok(0xDEADBEEF),
    python_output: Ok("3735928559"),
  ),
  IntegerTestData(
    input: "ABCDEF",
    base: 16,
    output: Ok(0xABCDEF),
    python_output: Ok("11259375"),
  ),
]

pub fn data() -> List(IntegerTestData) {
  [
    valid_simple_integers,
    valid_simple_integers_base_2,
    valid_simple_integers_base_8,
    valid_simple_integers_base_16,
    valid_simple_integers_with_inferred_base,
    valid_integers_with_underscores,
    valid_integers_with_whitespace,
  ]
  |> list.flatten
}

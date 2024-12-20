import gleam/dict
import gleam/list
import gleam/string
import lenient_parse/internal/whitespace
import test_data.{type FloatTestData, FloatTestData}

fn valid_simple() -> List(FloatTestData) {
  [
    FloatTestData(
      input: "1.001",
      expected_program_output: Ok(1.001),
      expected_python_output: Ok("1.001"),
    ),
    FloatTestData(
      input: "1.00",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: "1.0",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: "0.1",
      expected_program_output: Ok(0.1),
      expected_python_output: Ok("0.1"),
    ),
    FloatTestData(
      input: "+1.0",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: "-1.0",
      expected_program_output: Ok(-1.0),
      expected_python_output: Ok("-1.0"),
    ),
    FloatTestData(
      input: "+123.321",
      expected_program_output: Ok(123.321),
      expected_python_output: Ok("123.321"),
    ),
    FloatTestData(
      input: "-123.321",
      expected_program_output: Ok(-123.321),
      expected_python_output: Ok("-123.321"),
    ),
    FloatTestData(
      input: "1",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: "1.",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: ".1",
      expected_program_output: Ok(0.1),
      expected_python_output: Ok("0.1"),
    ),
    FloatTestData(
      input: "0",
      expected_program_output: Ok(0.0),
      expected_python_output: Ok("0.0"),
    ),
    FloatTestData(
      input: "-0",
      expected_program_output: Ok(-0.0),
      expected_python_output: Ok("-0.0"),
    ),
    FloatTestData(
      input: "+0",
      expected_program_output: Ok(0.0),
      expected_python_output: Ok("0.0"),
    ),
    FloatTestData(
      input: "0.0",
      expected_program_output: Ok(0.0),
      expected_python_output: Ok("0.0"),
    ),
  ]
}

fn valid_underscore() -> List(FloatTestData) {
  [
    FloatTestData(
      input: "1_000_000.0",
      expected_program_output: Ok(1_000_000.0),
      expected_python_output: Ok("1000000.0"),
    ),
    FloatTestData(
      input: "1_000_000.000_1",
      expected_program_output: Ok(1_000_000.0001),
      expected_python_output: Ok("1000000.0001"),
    ),
    FloatTestData(
      input: "1000.000_000",
      expected_program_output: Ok(1000.0),
      expected_python_output: Ok("1000.0"),
    ),
    FloatTestData(
      input: "1_234_567.890_123",
      expected_program_output: Ok(1_234_567.890123),
      expected_python_output: Ok("1234567.890123"),
    ),
    FloatTestData(
      input: "0.000_000_1",
      expected_program_output: Ok(0.0000001),
      expected_python_output: Ok("1e-07"),
    ),
  ]
}

fn valid_whitespace() -> List(FloatTestData) {
  let all_whitespace_characters_string =
    whitespace.character_dict() |> dict.keys |> string.join("")

  [
    FloatTestData(
      input: " 1 ",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: " 1.0 ",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: " 1000 ",
      expected_program_output: Ok(1000.0),
      expected_python_output: Ok("1000.0"),
    ),
    FloatTestData(
      input: "\t3.14\n",
      expected_program_output: Ok(3.14),
      expected_python_output: Ok("3.14"),
    ),
    FloatTestData(
      input: "  -0.5  ",
      expected_program_output: Ok(-0.5),
      expected_python_output: Ok("-0.5"),
    ),
    FloatTestData(
      input: whitespace.em_space.character
        <> "-0.6"
        <> whitespace.em_space.character,
      expected_program_output: Ok(-0.6),
      expected_python_output: Ok("-0.6"),
    ),
    FloatTestData(
      input: all_whitespace_characters_string
        <> "666.0"
        <> all_whitespace_characters_string,
      expected_program_output: Ok(666.0),
      expected_python_output: Ok("666.0"),
    ),
  ]
}

fn valid_exponent_symbol_position() -> List(FloatTestData) {
  [
    FloatTestData(
      input: "4e3",
      expected_program_output: Ok(4000.0),
      expected_python_output: Ok("4000.0"),
    ),
    FloatTestData(
      input: "4e-3",
      expected_program_output: Ok(0.004),
      expected_python_output: Ok("0.004"),
    ),
    FloatTestData(
      input: "4.0e3",
      expected_program_output: Ok(4000.0),
      expected_python_output: Ok("4000.0"),
    ),
    FloatTestData(
      input: "4.0e-3",
      expected_program_output: Ok(0.004),
      expected_python_output: Ok("0.004"),
    ),
    FloatTestData(
      input: "4E3",
      expected_program_output: Ok(4000.0),
      expected_python_output: Ok("4000.0"),
    ),
    FloatTestData(
      input: "4E-3",
      expected_program_output: Ok(0.004),
      expected_python_output: Ok("0.004"),
    ),
    FloatTestData(
      input: "4.0E3",
      expected_program_output: Ok(4000.0),
      expected_python_output: Ok("4000.0"),
    ),
    FloatTestData(
      input: "4.0E-3",
      expected_program_output: Ok(0.004),
      expected_python_output: Ok("0.004"),
    ),
    FloatTestData(
      input: ".3e3",
      expected_program_output: Ok(300.0),
      expected_python_output: Ok("300.0"),
    ),
    FloatTestData(
      input: ".3e-3",
      expected_program_output: Ok(0.0003),
      expected_python_output: Ok("0.0003"),
    ),
    FloatTestData(
      input: "3.e3",
      expected_program_output: Ok(3000.0),
      expected_python_output: Ok("3000.0"),
    ),
    FloatTestData(
      input: "3.e-3",
      expected_program_output: Ok(0.003),
      expected_python_output: Ok("0.003"),
    ),
    FloatTestData(
      input: "1e0",
      expected_program_output: Ok(1.0),
      expected_python_output: Ok("1.0"),
    ),
    FloatTestData(
      input: "1e+3",
      expected_program_output: Ok(1000.0),
      expected_python_output: Ok("1000.0"),
    ),
    FloatTestData(
      input: "1E+3",
      expected_program_output: Ok(1000.0),
      expected_python_output: Ok("1000.0"),
    ),
  ]
}

fn valid_precision() -> List(FloatTestData) {
  [
    // Would produce a floating point error in v1.3.1: 2.7119999999999997
    FloatTestData(
      input: "2.712",
      expected_program_output: Ok(2.712),
      expected_python_output: Ok("2.712"),
    ),
    // Would produce a floating point error in v1.3.1: 7.5776864147000005
    FloatTestData(
      input: "7.5776864147",
      expected_program_output: Ok(7.5776864147),
      expected_python_output: Ok("7.5776864147"),
    ),
    // Would produce a floating point error in v1.3.2: 8556272791.328557
    FloatTestData(
      input: "8556272791.3285562727",
      expected_program_output: Ok(8_556_272_791.328556),
      // Python rounds this value
      expected_python_output: Ok("8556272791.328556"),
    ),
  ]
}

fn valid_mixed() -> List(FloatTestData) {
  [
    FloatTestData(
      input: "   -30.01e-2   ",
      expected_program_output: Ok(-0.3001),
      expected_python_output: Ok("-0.3001"),
    ),
    FloatTestData(
      input: "+1_234.567_8e-2",
      expected_program_output: Ok(12.345678),
      expected_python_output: Ok("12.345678"),
    ),
    FloatTestData(
      input: "-1_234.567_8e-2",
      expected_program_output: Ok(-12.345678),
      expected_python_output: Ok("-12.345678"),
    ),
    FloatTestData(
      input: " -0.000_1E+3 ",
      expected_program_output: Ok(-0.1),
      expected_python_output: Ok("-0.1"),
    ),
  ]
}

pub fn data() -> List(FloatTestData) {
  [
    valid_simple(),
    valid_underscore(),
    valid_whitespace(),
    valid_exponent_symbol_position(),
    valid_precision(),
    valid_mixed(),
  ]
  |> list.flatten
}

import gleam/list
import test_data.{type FloatTestData, FloatTestData}

// TODO: Rename all lists to make more sense
const simple_float: List(FloatTestData) = [
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

const float_with_underscore: List(FloatTestData) = [
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

const float_with_whitespace: List(FloatTestData) = [
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
]

const float_with_exponent: List(FloatTestData) = [
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

const mixed: List(FloatTestData) = [
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

pub fn data() -> List(FloatTestData) {
  [
    simple_float,
    float_with_underscore,
    float_with_whitespace,
    float_with_exponent,
    mixed,
  ]
  |> list.flatten
}

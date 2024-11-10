import parse_error.{type ParseError}

pub type FloatTestData {
  FloatTestData(
    input: String,
    expected_program_output: Result(Float, ParseError),
    expected_python_output: Result(String, Nil),
  )
}

pub type IntegerTestData {
  IntegerTestData(
    input: String,
    base: Int,
    expected_program_output: Result(Int, ParseError),
    expected_python_output: Result(String, Nil),
  )
}

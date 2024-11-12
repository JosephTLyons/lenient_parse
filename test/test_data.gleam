import parse_error.{type ParseError}
import python/python_error.{type PythonError}

pub type FloatTestData {
  FloatTestData(
    input: String,
    expected_program_output: Result(Float, ParseError),
    expected_python_output: Result(String, PythonError),
  )
}

pub type IntegerTestData {
  IntegerTestData(
    input: String,
    base: Int,
    expected_program_output: Result(Int, ParseError),
    expected_python_output: Result(String, PythonError),
  )
}

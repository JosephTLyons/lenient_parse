import parse_error.{type ParseError}

pub type FloatTestData {
  FloatTestData(
    input: String,
    output: Result(Float, ParseError),
    python_output: Result(String, Nil),
  )
}

pub type IntegerTestData {
  IntegerTestData(
    input: String,
    output: Result(Int, ParseError),
    python_output: Result(String, Nil),
  )
}

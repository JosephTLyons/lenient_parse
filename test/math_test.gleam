import lenient_parse/internal/math.{expand_scientific_notation_float}
import startest/expect

pub fn expand_scientific_notation_float_test() {
  10.0 |> expand_scientific_notation_float(0) |> expect.to_equal(10.0)

  10.0
  |> expand_scientific_notation_float(1)
  |> expect.to_equal(100.0)

  10.0
  |> expand_scientific_notation_float(2)
  |> expect.to_equal(1000.0)

  100.0
  |> expand_scientific_notation_float(-2)
  |> expect.to_equal(1.0)
}

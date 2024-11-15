import lenient_parse/internal/base_constants.{base_10}
import lenient_parse/internal/math.{multiply_by_power_of_10}
import startest/expect

pub fn multiply_by_power_of_10_test() {
  10.0 |> multiply_by_power_of_10(base_10, 0) |> expect.to_equal(10.0)
  10.0 |> multiply_by_power_of_10(base_10, 1) |> expect.to_equal(100.0)
  10.0 |> multiply_by_power_of_10(base_10, 2) |> expect.to_equal(1000.0)
  100.0 |> multiply_by_power_of_10(base_10, -2) |> expect.to_equal(1.0)
}

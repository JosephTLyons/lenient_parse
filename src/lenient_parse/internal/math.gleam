import gleam/int
import gleam/order
import lenient_parse/internal/base_constants.{base_10}

pub fn multiply_by_power_of_10(factor: Float, base: Int, exponent: Int) {
  do_multiply_by_power_of_10(
    factor: factor,
    base: base,
    exponent: exponent,
    scale_factor: 1,
    exponent_is_positive: exponent >= 0,
  )
}

fn do_multiply_by_power_of_10(
  factor factor: Float,
  base base: Int,
  exponent exponent: Int,
  scale_factor scale_factor: Int,
  exponent_is_positive exponent_is_positive: Bool,
) -> Float {
  case int.compare(exponent, 0) {
    order.Eq -> {
      let scale_factor_float = scale_factor |> int.to_float
      case exponent_is_positive {
        True -> factor *. scale_factor_float
        False -> factor /. scale_factor_float
      }
    }
    order.Gt ->
      do_multiply_by_power_of_10(
        factor,
        base,
        exponent - 1,
        scale_factor * base_10,
        exponent_is_positive,
      )
    order.Lt ->
      do_multiply_by_power_of_10(
        factor,
        base,
        exponent + 1,
        scale_factor * base_10,
        exponent_is_positive,
      )
  }
}

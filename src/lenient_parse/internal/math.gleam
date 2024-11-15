import gleam/int
import gleam/order
import lenient_parse/internal/base_constants.{base_10}

pub fn expand_scientific_notation_float(factor: Float, exponent: Int) {
  do_expand_scientific_notation_float(
    factor: factor,
    exponent: exponent,
    scale_factor: 1,
    exponent_is_positive: exponent >= 0,
  )
}

fn do_expand_scientific_notation_float(
  factor factor: Float,
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
      do_expand_scientific_notation_float(
        factor,
        exponent - 1,
        scale_factor * base_10,
        exponent_is_positive,
      )
    order.Lt ->
      do_expand_scientific_notation_float(
        factor,
        exponent + 1,
        scale_factor * base_10,
        exponent_is_positive,
      )
  }
}

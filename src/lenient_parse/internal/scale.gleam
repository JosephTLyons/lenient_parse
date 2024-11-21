import gleam/deque.{type Deque}
import gleam/int
import gleam/order
import gleam/result
import lenient_parse/internal/base_constants.{base_10}

pub fn deques(
  whole_digits whole_digits: Deque(Int),
  fractional_digits fractional_digits: Deque(Int),
  scale_factor scale_factor: Int,
) -> #(Deque(Int), Deque(Int)) {
  case int.compare(scale_factor, 0) {
    order.Eq -> #(whole_digits, fractional_digits)
    order.Gt -> {
      let #(digit, fractional_digits) =
        deque.pop_front(fractional_digits)
        |> result.unwrap(#(0, fractional_digits))
      deques(
        deque.push_back(whole_digits, digit),
        fractional_digits,
        scale_factor - 1,
      )
    }
    order.Lt -> {
      let #(digit, whole_digits) =
        deque.pop_back(whole_digits)
        |> result.unwrap(#(0, whole_digits))
      deques(
        whole_digits,
        deque.push_front(fractional_digits, digit),
        scale_factor + 1,
      )
    }
  }
}

pub fn float(factor: Float, exponent: Int) -> Float {
  do_float(
    factor: factor,
    exponent: exponent,
    scale_factor: 1,
    exponent_is_positive: exponent >= 0,
  )
}

fn do_float(
  factor factor: Float,
  exponent exponent: Int,
  scale_factor scale_factor: Int,
  exponent_is_positive exponent_is_positive: Bool,
) -> Float {
  case int.compare(exponent, 0) {
    order.Eq -> {
      let scale_factor_float = int.to_float(scale_factor)
      case exponent_is_positive {
        True -> factor *. scale_factor_float
        False -> factor /. scale_factor_float
      }
    }
    _ ->
      do_float(
        factor,
        case exponent_is_positive {
          True -> exponent - 1
          False -> exponent + 1
        },
        scale_factor * base_10,
        exponent_is_positive,
      )
  }
}

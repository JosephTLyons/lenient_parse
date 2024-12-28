import gleam/deque.{type Deque}
import gleam/int
import gleam/order
import gleam/result

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

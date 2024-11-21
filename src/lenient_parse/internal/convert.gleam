import gleam/deque.{type Deque}
import gleam/list
import lenient_parse/internal/base_constants.{base_10}

pub fn digits_to_int(digits digits: Deque(Int)) -> Int {
  digits_to_int_with_base(digits: digits, base: base_10)
}

pub fn digits_to_int_with_base(digits digits: Deque(Int), base base: Int) -> Int {
  digits |> deque.to_list |> digits_to_int_from_list(base)
}

pub fn digits_to_int_from_list(digits digits: List(Int), base base: Int) -> Int {
  digits |> list.fold(0, fn(acc, digit) { acc * base + digit })
}

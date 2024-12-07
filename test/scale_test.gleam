import gleam/deque
import lenient_parse/internal/scale
import startest/expect

pub fn scale_deques_test() {
  let a = deque.from_list([1, 2, 3])
  let b = deque.from_list([4, 5, 6])

  let #(a, b) = scale.deques(a, b, 1)

  a |> deque.to_list |> expect.to_equal([1, 2, 3, 4])
  b |> deque.to_list |> expect.to_equal([5, 6])

  let #(a, b) = scale.deques(a, b, 1)

  a |> deque.to_list |> expect.to_equal([1, 2, 3, 4, 5])
  b |> deque.to_list |> expect.to_equal([6])

  let #(a, b) = scale.deques(a, b, 1)

  a |> deque.to_list |> expect.to_equal([1, 2, 3, 4, 5, 6])
  b |> deque.to_list |> expect.to_equal([])

  let #(a, b) = scale.deques(a, b, 1)

  a |> deque.to_list |> expect.to_equal([1, 2, 3, 4, 5, 6, 0])
  b |> deque.to_list |> expect.to_equal([])

  let #(a, b) = scale.deques(a, b, -3)

  a |> deque.to_list |> expect.to_equal([1, 2, 3, 4])
  b |> deque.to_list |> expect.to_equal([5, 6, 0])

  let #(a, b) = scale.deques(a, b, -4)

  a |> deque.to_list |> expect.to_equal([])
  b |> deque.to_list |> expect.to_equal([1, 2, 3, 4, 5, 6, 0])

  let #(a, b) = scale.deques(a, b, -3)

  a |> deque.to_list |> expect.to_equal([])
  b |> deque.to_list |> expect.to_equal([0, 0, 0, 1, 2, 3, 4, 5, 6, 0])
}

pub fn scale_float_test() {
  10.0 |> scale.float(0) |> expect.to_equal(10.0)

  10.0
  |> scale.float(1)
  |> expect.to_equal(100.0)

  10.0
  |> scale.float(2)
  |> expect.to_equal(1000.0)

  100.0
  |> scale.float(-2)
  |> expect.to_equal(1.0)
}
